#!/bin/bash

# Script para crear el backend de Terraform (solo S3 bucket)
# Ejecutar UNA SOLA VEZ antes de usar Terraform

set -e

AWS_REGION="us-east-2"
BUCKET_NAME="draftbook-terraform-state"

echo "🚀 Configurando backend de Terraform..."
echo ""

# Verificar que AWS CLI esté configurado
if ! aws sts get-caller-identity > /dev/null 2>&1; then
    echo "❌ Error: AWS CLI no está configurado o no tiene credenciales válidas"
    echo "   Ejecuta: aws configure"
    exit 1
fi

echo "✅ Credenciales AWS verificadas"
echo ""

# Crear bucket S3 si no existe
echo "📦 Verificando bucket S3: $BUCKET_NAME"
if aws s3 ls "s3://$BUCKET_NAME" 2>/dev/null; then
    echo "✅ Bucket ya existe"
else
    echo "🔨 Creando bucket S3..."
    aws s3api create-bucket \
        --bucket "$BUCKET_NAME" \
        --region "$AWS_REGION" \
        --create-bucket-configuration LocationConstraint="$AWS_REGION"
    
    # Habilitar versionado
    aws s3api put-bucket-versioning \
        --bucket "$BUCKET_NAME" \
        --versioning-configuration Status=Enabled
    
    # Habilitar encriptación
    aws s3api put-bucket-encryption \
        --bucket "$BUCKET_NAME" \
        --server-side-encryption-configuration '{
            "Rules": [{
                "ApplyServerSideEncryptionByDefault": {
                    "SSEAlgorithm": "AES256"
                }
            }]
        }'
    
    # Bloquear acceso público
    aws s3api put-public-access-block \
        --bucket "$BUCKET_NAME" \
        --public-access-block-configuration \
        "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true"
    
    echo "✅ Bucket S3 creado y configurado"
fi
echo ""

echo "🎉 Backend de Terraform configurado correctamente!"
echo ""
echo "📋 Configuración:"
echo "   Bucket S3: $BUCKET_NAME"
echo "   Región: $AWS_REGION"
echo ""
echo "✅ Ahora puedes ejecutar los workflows de Terraform"
