# 📦 Migración de Workflows de Terraform Completada

## ✅ Resumen de Cambios

### Workflows Migrados al Repositorio `draftbook_Infraestructure`

Se han creado **6 workflows** en el repositorio de infraestructura:

#### Despliegue:
1. ✅ `.github/workflows/deploy-dev.yml` - Despliegue automático/manual para Dev
2. ✅ `.github/workflows/deploy-qa.yml` - Despliegue manual para QA
3. ✅ `.github/workflows/deploy-prod.yml` - Despliegue manual para Producción

#### Destrucción:
4. ✅ `.github/workflows/destroy-dev.yml` - Destrucción de infraestructura Dev
5. ✅ `.github/workflows/destroy-qa.yml` - Destrucción de infraestructura QA
6. ✅ `.github/workflows/destroy-prod.yml` - Destrucción de infraestructura Prod

### Documentación Creada:
- ✅ `.github/workflows/README.md` - Guía completa de uso de workflows
- ✅ `.github/check-secrets.sh` - Script de verificación de configuración

---

## 🚀 Pasos para Activar los Workflows

### 1. Hacer Commit y Push de los Nuevos Workflows

Primero, necesitas hacer commit y push de los workflows al repositorio de infraestructura:

```bash
cd /Users/manu/Desktop/DColaborativo/align/draftbook_Infraestructure

git add .github/
git commit -m "feat: migrar workflows de Terraform desde repositorio de aplicación

- Agregar workflows de deploy para dev, qa y prod
- Agregar workflows de destroy para todos los ambientes
- Incluir README con documentación completa
- Agregar script de verificación de secrets"

git push origin main
```

### 2. Configurar AWS OIDC Provider

**IMPORTANTE:** Necesitas configurar un OIDC provider en AWS específicamente para el repositorio de infraestructura.

#### Opción A: Usando la consola de AWS

1. Ve a **IAM** → **Identity providers**
2. Crea un nuevo provider:
   - **Provider type:** OpenID Connect
   - **Provider URL:** `https://token.actions.githubusercontent.com`
   - **Audience:** `sts.amazonaws.com`

3. Crea o actualiza el rol de IAM con el trust policy:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::537692431882:oidc-provider/token.actions.githubusercontent.com"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
        },
        "StringLike": {
          "token.actions.githubusercontent.com:sub": "repo:NextGenDraftBook/draftbook_Infraestructure:*"
        }
      }
    }
  ]
}
```

#### Opción B: Usando AWS CLI

```bash
# Si ya tienes el provider, solo necesitas actualizar el trust policy del rol
aws iam update-assume-role-policy \
  --role-name github-actions-role \
  --policy-document file://trust-policy.json
```

### 3. Configurar Secrets en GitHub

Copia TODOS los secrets del repositorio `draftbook` al repositorio `draftbook_Infraestructure`:

Ve a: https://github.com/NextGenDraftBook/draftbook_Infraestructure/settings/secrets/actions

Secrets requeridos:
- ✅ `AWS_ROLE` - ARN del rol de IAM (ej: `arn:aws:iam::123456789012:role/github-actions-role`)
- ✅ `TF_VAR_AWS_REGION`
- ✅ `TF_VAR_AWS_KEY_PAIR_NAME`
- ✅ `TF_VAR_AWS_INSTANCE_TYPE`
- ✅ `TF_VAR_AWS_INSTANCE_TYPE_PROD`
- ✅ `TF_VAR_AWS_RESTAURANT_SG`
- ✅ `SSH_PRIVATE_KEY`
- ✅ `SSH_PUBLIC_KEY`
- ✅ `TF_VAR_NODE_APP_EMAIL`
- ✅ `TF_VAR_NODE_APP_PASSWORD`
- ✅ `TF_VAR_NODE_APP_SERVICE`
- ✅ `TF_VAR_MAIN_DOMAIN`

### 4. Verificar Configuración

Después de configurar los secrets, ejecuta el script de verificación:

```bash
cd /Users/manu/Desktop/DColaborativo/align/draftbook_Infraestructure
./.github/check-secrets.sh
```

Este script te dirá qué secrets faltan y verificará que todo esté correcto.

---

## 🧪 Cómo Probar los Workflows

### Prueba 1: Verificar que los Workflows Aparezcan en GitHub

1. Ve a: https://github.com/NextGenDraftBook/draftbook_Infraestructure/actions
2. Deberías ver 6 workflows listados:
   - Deploy Dev Infrastructure
   - Deploy QA Infrastructure
   - Deploy Prod Infrastructure
   - Destroy Dev Infrastructure
   - Destroy QA Infrastructure
   - Destroy Prod Infrastructure

### Prueba 2: Ejecutar un Terraform Plan (Sin Aplicar)

**Usando la interfaz de GitHub:**

1. Ve a **Actions** → **Deploy Dev Infrastructure**
2. Haz clic en **Run workflow**
3. Selecciona la rama `main`
4. Haz clic en **Run workflow**
5. El workflow ejecutará `terraform plan` pero NO aplicará cambios
6. Revisa el output en la pestaña **terraform-plan** job

**Usando GitHub CLI:**

```bash
# Ejecutar workflow
gh workflow run deploy-dev.yml --repo NextGenDraftBook/draftbook_Infraestructure

# Ver el estado
gh run list --workflow=deploy-dev.yml --repo NextGenDraftBook/draftbook_Infraestructure

# Ver los logs
gh run view --repo NextGenDraftBook/draftbook_Infraestructure
```

### Prueba 3: Desplegar Infraestructura de Dev (Con Aprobación)

1. Ejecuta el workflow como en la Prueba 2
2. Después del job `terraform-plan`, el workflow esperará en `terraform-apply`
3. El job `terraform-apply` esperará aprobación del ambiente `development`
4. Ve a **Actions** → Click en el run activo
5. Haz clic en **Review deployments**
6. Selecciona **development** y haz clic en **Approve and deploy**
7. El workflow aplicará los cambios en AWS

### Prueba 4: Verificar Recursos en AWS

Después de que el workflow complete:

1. Ve a la consola de AWS EC2
2. Busca la instancia: `draftbook-dev-server`
3. Verifica que esté en estado `running`
4. Revisa los outputs del workflow para ver la IP asignada

### Prueba 5: Destruir la Infraestructura de Prueba

```bash
# Ejecutar workflow de destrucción
gh workflow run destroy-dev.yml --repo NextGenDraftBook/draftbook_Infraestructure
```

Esto eliminará todos los recursos creados en la prueba anterior.

---

## 🧹 Limpieza del Repositorio de Aplicación

Después de verificar que todo funciona correctamente, ELIMINA los workflows de Terraform del repositorio `draftbook`:

```bash
cd /Users/manu/Desktop/DColaborativo/align/draftbook

# Eliminar workflows de Terraform
rm .github/workflows/deploy-dev.yml
rm .github/workflows/deploy-qa.yml
rm .github/workflows/deploy-prod.yml
rm .github/workflows/destroy-dev.yml
rm .github/workflows/destroy-qa.yml
rm .github/workflows/destroy-prod.yml

git add .github/workflows/
git commit -m "chore: eliminar workflows de Terraform

Los workflows de infraestructura se han migrado al repositorio draftbook_Infraestructure.
Este repositorio ahora solo contiene CI/CD para la aplicación."

git push origin integration/sprint-features
```

---

## 📋 Checklist Final

- [ ] 1. Commit y push de workflows al repo de infraestructura
- [ ] 2. Configurar OIDC provider en AWS (si no existe)
- [ ] 3. Actualizar trust policy del rol IAM con el nuevo repositorio
- [ ] 4. Copiar todos los secrets a draftbook_Infraestructure
- [ ] 5. Ejecutar script de verificación (`.github/check-secrets.sh`)
- [ ] 6. Hacer prueba de `terraform plan` en Dev
- [ ] 7. Verificar que el plan se ejecute sin errores
- [ ] 8. (Opcional) Desplegar y destruir infraestructura de prueba
- [ ] 9. Eliminar workflows de Terraform del repo de aplicación
- [ ] 10. Documentar el cambio en el README del proyecto

---

## 🎯 Beneficios de Esta Arquitectura

✅ **Separación de responsabilidades:** Código de aplicación vs infraestructura
✅ **Seguridad mejorada:** Diferentes permisos y roles para cada repositorio
✅ **CI/CD más rápido:** Los workflows de aplicación no esperan a Terraform
✅ **Auditoría clara:** Historial de cambios de infraestructura separado
✅ **Rollbacks independientes:** Puedes hacer rollback de infra sin afectar app
✅ **Mejor organización:** Cada equipo puede trabajar en su repositorio

---

## ❓ Preguntas Frecuentes

### ¿Por qué el error "No OpenIDConnect provider found"?

Este error ocurría porque el OIDC provider en AWS solo estaba configurado para el repositorio `draftbook`, pero los workflows de Terraform necesitan correr desde `draftbook_Infraestructure`. Al migrar los workflows y actualizar el trust policy, el problema se resuelve.

### ¿Puedo ejecutar Terraform desde ambos repositorios?

No es recomendable. Mantén TODA la gestión de infraestructura en el repositorio `draftbook_Infraestructure`. El repositorio `draftbook` solo debe contener workflows de CI/CD para la aplicación (tests, builds, publicación a ECR).

### ¿Qué pasa con el state de Terraform?

El state de Terraform permanece en el mismo lugar (S3 backend configurado en tus archivos `main.tf`). Solo cambia el lugar desde donde se ejecutan los comandos de Terraform.

### ¿Cómo coordinamos despliegues de aplicación e infraestructura?

1. Primero despliega la infraestructura usando workflows de `draftbook_Infraestructure`
2. Luego despliega la aplicación usando workflows de `draftbook`
3. Puedes crear un workflow adicional que coordine ambos si es necesario

---

## 📞 Soporte

Si encuentras problemas:

1. Revisa los logs del workflow en GitHub Actions
2. Verifica que todos los secrets estén configurados correctamente
3. Confirma que el OIDC provider esté configurado para el repositorio correcto
4. Revisa el trust policy del rol de IAM

Para más información, consulta:
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [AWS OIDC Setup](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/configuring-openid-connect-in-amazon-web-services)
- [Terraform with GitHub Actions](https://developer.hashicorp.com/terraform/tutorials/automation/github-actions)
