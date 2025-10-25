#!/bin/bash

# Script para agregar permisos de S3 al rol de GitHub Actions
# Ejecutar UNA VEZ después de crear el bucket S3

set -e

POLICY_FILE="policies/terraform-state-policy.json"

echo "🔐 Agregando permisos de S3 al rol de GitHub Actions..."
echo ""

# Verificar que AWS CLI esté configurado
if ! aws sts get-caller-identity > /dev/null 2>&1; then
    echo "❌ Error: AWS CLI no está configurado"
    exit 1
fi

# Obtener el nombre del rol desde el ARN
echo "📝 Por favor ingresa el ARN del rol de GitHub Actions (el valor de AWS_ROLE secret):"
read ROLE_ARN

# Extraer el nombre del rol del ARN
ROLE_NAME=$(echo $ROLE_ARN | sed 's/.*role\///')

echo ""
echo "🔍 Rol detectado: $ROLE_NAME"
echo ""

# Agregar la política inline al rol
echo "📋 Agregando política de S3..."
aws iam put-role-policy \
    --role-name "$ROLE_NAME" \
    --policy-name "TerraformStateAccess" \
    --policy-document file://$POLICY_FILE

echo ""
echo "✅ Permisos agregados exitosamente!"
echo ""
echo "🚀 Ahora puedes ejecutar los workflows de Terraform"
