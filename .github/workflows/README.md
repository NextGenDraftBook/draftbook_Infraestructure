# Workflows de Infraestructura - Draftbook

Este directorio contiene los workflows de GitHub Actions para gestionar la infraestructura de AWS mediante Terraform.

## 📁 Workflows Disponibles

### Despliegue (Deploy)
- **deploy-dev.yml**: Despliega la infraestructura de desarrollo (manual + push a main/feature/SCRUM-49)
- **deploy-qa.yml**: Despliega la infraestructura de QA (solo manual)
- **deploy-prod.yml**: Despliega la infraestructura de producción (solo manual, con protección de ambiente)

### Destrucción (Destroy)
- **destroy-dev.yml**: Destruye la infraestructura de desarrollo
- **destroy-qa.yml**: Destruye la infraestructura de QA
- **destroy-prod.yml**: Destruye la infraestructura de producción

## 🔐 Configuración de Secrets Requeridos

Estos workflows requieren que configures los siguientes secrets en GitHub:

### Secrets de AWS
- `AWS_ROLE`: ARN del rol de IAM para OIDC (ej: `arn:aws:iam::123456789012:role/github-actions-role`)
- `TF_VAR_AWS_REGION`: Región de AWS (ej: `us-east-1`)
- `TF_VAR_AWS_KEY_PAIR_NAME`: Nombre del key pair en AWS
- `TF_VAR_AWS_INSTANCE_TYPE`: Tipo de instancia para dev/qa (ej: `t3.small`)
- `TF_VAR_AWS_INSTANCE_TYPE_PROD`: Tipo de instancia para producción (ej: `t3.medium`)
- `TF_VAR_AWS_RESTAURANT_SG`: ID del security group

### Secrets SSH
- `SSH_PRIVATE_KEY`: Llave privada SSH completa (incluye `-----BEGIN ... KEY-----`)
- `SSH_PUBLIC_KEY`: Llave pública SSH

### Secrets de Aplicación
- `TF_VAR_NODE_APP_EMAIL`: Email para la aplicación Node.js
- `TF_VAR_NODE_APP_PASSWORD`: Password para la aplicación
- `TF_VAR_NODE_APP_SERVICE`: Servicio de la aplicación
- `TF_VAR_MAIN_DOMAIN`: Dominio principal de la aplicación

### Cómo Configurar los Secrets

1. Ve a tu repositorio de infraestructura en GitHub
2. Navega a **Settings** → **Secrets and variables** → **Actions**
3. Haz clic en **New repository secret**
4. Agrega cada secret con su valor correspondiente

## 🚀 Cómo Ejecutar los Workflows

### Opción 1: Desde la Interfaz de GitHub

1. Ve a la pestaña **Actions** en tu repositorio
2. Selecciona el workflow que quieres ejecutar (ej: "Deploy Dev Infrastructure")
3. Haz clic en **Run workflow**
4. Selecciona la rama (generalmente `main`)
5. Haz clic en **Run workflow** para confirmar

### Opción 2: Usando GitHub CLI

```bash
# Desplegar Dev
gh workflow run deploy-dev.yml

# Desplegar QA
gh workflow run deploy-qa.yml

# Desplegar Prod
gh workflow run deploy-prod.yml

# Destruir Dev
gh workflow run destroy-dev.yml
```

## 📊 Flujo de Trabajo

### Workflows de Despliegue

Cada workflow de despliegue sigue este proceso:

1. **terraform-plan** job:
   - Configura credenciales AWS usando OIDC
   - Crea las llaves SSH desde secrets
   - Sube las llaves como artefacto
   - Ejecuta `terraform init`, `validate` y `plan`
   - Sube el plan como artefacto

2. **terraform-apply** job:
   - Espera aprobación del ambiente (QA/Prod requieren aprobación manual)
   - Descarga las llaves SSH
   - Descarga el plan de Terraform
   - Ejecuta `terraform apply` con el plan

### Workflows de Destrucción

Los workflows de destrucción:
- Solo se ejecutan manualmente
- Requieren aprobación explícita
- Ejecutan `terraform destroy -auto-approve` directamente

## ✅ Validación

### Verificar que el workflow funcionó correctamente:

1. **En GitHub Actions:**
   - Verifica que todos los jobs estén en verde ✅
   - Revisa los logs de cada step
   - El job de apply debe mostrar los recursos creados

2. **En AWS:**
   - Ve a la consola de EC2
   - Busca la instancia con el nombre `draftbook-{env}-server`
   - Verifica que esté en estado "running"

3. **En Terraform:**
   - Los outputs del workflow mostrarán la IP del servidor
   - Puedes ver los outputs en la pestaña Actions → Summary

## 🔍 Troubleshooting

### Error: "No OpenIDConnect provider found"
**Solución:** Necesitas configurar el OIDC provider en AWS. Este error ocurre cuando el rol de IAM no tiene configurado el trust relationship con GitHub Actions.

### Error: "Invalid AWS credentials"
**Solución:** Verifica que el secret `AWS_ROLE` tenga el ARN correcto del rol de IAM.

### Error: "SSH key permission denied"
**Solución:** Verifica que los secrets `SSH_PRIVATE_KEY` y `SSH_PUBLIC_KEY` estén correctamente configurados y sean un par válido.

### El workflow no aparece en Actions
**Solución:** Asegúrate de haber hecho commit y push de los archivos workflow al repositorio.

## 📝 Diferencia con el Repositorio de Aplicación

- **Repositorio `draftbook`**: Contiene el código de la aplicación (frontend/backend) y workflows de CI/CD para tests y build
- **Repositorio `draftbook_Infraestructure`**: Contiene SOLO el código de infraestructura (Terraform) y workflows para desplegar/destruir infraestructura

Esta separación sigue las mejores prácticas de GitOps, donde la infraestructura se gestiona independientemente del código de aplicación.

## 🎯 Próximos Pasos

Después de migrar los workflows:

1. ✅ Configurar todos los secrets en el repositorio de infraestructura
2. ✅ Ejecutar un despliegue de prueba en Dev
3. ✅ Verificar que todo funcione correctamente
4. ✅ Eliminar los workflows de Terraform del repositorio `draftbook`
5. ✅ Actualizar la documentación del proyecto
