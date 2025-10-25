# Cómo Agregar el Secreto SSH_PRIVATE_KEY Correctamente

## ⚠️ IMPORTANTE: Formato de la Llave SSH

GitHub Actions puede corromper las llaves SSH si no se agregan correctamente. Sigue estos pasos **EXACTAMENTE**.

## Paso 1: Obtener tu Llave Privada

Ejecuta este comando en tu terminal para obtener tu llave privada:

```bash
cat ~/.ssh/draftbook_KEYPAR.pem
```

O si está en otro lugar (por ejemplo, en tu carpeta de descargas):

```bash
cat ~/Downloads/draftbook_KEYPAR.pem
```

## Paso 2: Copiar la Llave COMPLETA

La salida debe verse **EXACTAMENTE** así:

```
-----BEGIN OPENSSH PRIVATE KEY-----
b3BlbnNzaC1rZXktdjEAAAAABG5vbmUAAAAEbm9uZQAAAAAAAAABAAABlwAAAAdzc2gtcn
NhAAAAAwEAAQAAAYEAx...
[muchas líneas más]
...YourKeyDataHere==
-----END OPENSSH PRIVATE KEY-----
```

O si es RSA:

```
-----BEGIN RSA PRIVATE KEY-----
MIIEpAIBAAKCAQEAx...
[muchas líneas más]
...YourKeyDataHere==
-----END RSA PRIVATE KEY-----
```

### ✅ COPIAR TODO, incluyendo:
- La línea `-----BEGIN OPENSSH PRIVATE KEY-----` o `-----BEGIN RSA PRIVATE KEY-----`
- TODO el contenido del medio (todas las líneas de caracteres)
- La línea `-----END OPENSSH PRIVATE KEY-----` o `-----END RSA PRIVATE KEY-----`

## Paso 3: Agregar el Secreto en GitHub

1. Ve a tu repositorio: https://github.com/NextGenDraftBook/draftbook_Infraestructure
2. Haz clic en **Settings** (Configuración)
3. En el menú lateral izquierdo, busca **Secrets and variables** → **Actions**
4. Si el secreto `SSH_PRIVATE_KEY` ya existe:
   - Haz clic en **Update** (Actualizar)
5. Si no existe:
   - Haz clic en **New repository secret**
   - Nombre: `SSH_PRIVATE_KEY`
6. En el campo **Value** (Valor):
   - **PEGA** la llave completa que copiaste
   - **NO agregues espacios al inicio o al final**
   - **NO agregues comillas**
   - **NO modifiques nada**

## Paso 4: Verificar

Después de guardar el secreto, ejecuta el workflow nuevamente. El output del paso "Create SSH Keys from secrets" debería mostrar:

```
=== Primera línea de la llave privada ===
-----BEGIN OPENSSH PRIVATE KEY-----
=== Última línea de la llave privada ===
-----END OPENSSH PRIVATE KEY-----
=== Número de líneas ===
      28 ./envs/dev/keys/draftbook_app_key
```

(El número de líneas variará dependiendo del tamaño de tu llave)

## ❌ Problemas Comunes

### Error: "no key found"
- La llave no tiene el formato correcto
- Falta el header `-----BEGIN...` o el footer `-----END...`
- Hay espacios extra al inicio o final
- Se copió con formato incorrecto

### Error: "invalid format"
- La llave tiene saltos de línea incorrectos
- Se usó un editor que modificó el formato

## 🔧 Solución Alternativa: Base64

Si el problema persiste, puedes codificar la llave en Base64:

```bash
# En tu máquina local
cat ~/.ssh/draftbook_KEYPAR.pem | base64
```

Copia TODO el output (será una línea muy larga) y:
1. Guárdalo en el secreto `SSH_PRIVATE_KEY_BASE64`
2. Modifica el workflow para decodificarlo

## 📝 Verificación Local

Antes de agregar el secreto, verifica que tu llave funciona:

```bash
# Verificar que la llave es válida
ssh-keygen -l -f ~/.ssh/draftbook_KEYPAR.pem

# Debería mostrar algo como:
# 2048 SHA256:abc123... rsa (RSA)
```

## 🆘 ¿Sigues teniendo problemas?

Revisa el output del workflow en el paso "Create SSH Keys from secrets" y compártelo para diagnóstico.
