#!/bin/bash

# Script para verificar y corregir permisos del bucket S3 para Terraform

set -e

BUCKET_NAME="draftbook-terraform-state"
REGION="us-east-1"

echo "🔧 Verificando y corrigiendo configuración del bucket S3..."
echo ""

# 1. Verificar que el bucket existe
echo "📦 Verificando bucket: $BUCKET_NAME"
if ! aws s3 ls "s3://$BUCKET_NAME" > /dev/null 2>&1; then
    echo "❌ Error: El bucket no existe"
    exit 1
fi
echo "✅ Bucket existe"
echo ""

# 2. Eliminar bucket policy si existe (puede estar bloqueando)
echo "🗑️  Eliminando bucket policy si existe..."
aws s3api delete-bucket-policy --bucket "$BUCKET_NAME" 2>/dev/null && echo "✅ Bucket policy eliminada" || echo "ℹ️  No había bucket policy"
echo ""

# 3. Verificar configuración del bucket
echo "🔍 Configuración actual del bucket:"
echo ""
echo "=== Public Access Block ==="
aws s3api get-public-access-block --bucket "$BUCKET_NAME" 2>/dev/null || echo "No configurado"
echo ""

# 4. Crear un archivo de prueba para verificar permisos
echo "🧪 Probando escritura en el bucket..."
echo "test" > /tmp/terraform-test.txt
if aws s3 cp /tmp/terraform-test.txt "s3://$BUCKET_NAME/test/terraform-test.txt" 2>/dev/null; then
    echo "✅ Escritura exitosa"
    aws s3 rm "s3://$BUCKET_NAME/test/terraform-test.txt" 2>/dev/null
    rm /tmp/terraform-test.txt
else
    echo "❌ Error al escribir. Verifica los permisos del rol IAM"
    rm /tmp/terraform-test.txt
    exit 1
fi
echo ""

echo "🎉 Bucket configurado correctamente!"
echo ""
echo "📋 Próximos pasos:"
echo "1. Asegúrate de que la política del rol IAM tenga permisos de S3"
echo "2. Ejecuta el workflow de Terraform"
echo "3. El state se guardará en: s3://$BUCKET_NAME/dev/terraform.tfstate"
