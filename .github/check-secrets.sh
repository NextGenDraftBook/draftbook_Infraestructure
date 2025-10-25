#!/bin/bash

# Script para verificar la configuración de secrets en GitHub
# Uso: ./check-secrets.sh

set -e

echo "Verificando configuración de GitHub Actions para draftbook_Infraestructure"
echo "=================================================================="
echo ""

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Verificar si gh está instalado
if ! command -v gh &> /dev/null; then
    echo -e "${RED}❌ GitHub CLI (gh) no está instalado${NC}"
    echo "   Instala con: brew install gh"
    exit 1
fi

# Verificar autenticación
if ! gh auth status &> /dev/null; then
    echo -e "${RED}❌ No estás autenticado en GitHub CLI${NC}"
    echo "   Ejecuta: gh auth login"
    exit 1
fi

echo -e "${GREEN}✅ GitHub CLI instalado y autenticado${NC}"
echo ""

# Lista de secrets requeridos
REQUIRED_SECRETS=(
    "AWS_ROLE"
    "TF_VAR_AWS_REGION"
    "TF_VAR_AWS_KEY_PAIR_NAME"
    "TF_VAR_AWS_INSTANCE_TYPE"
    "TF_VAR_AWS_INSTANCE_TYPE_PROD"
    "TF_VAR_AWS_RESTAURANT_SG"
    "SSH_PRIVATE_KEY"
    "SSH_PUBLIC_KEY"
    "TF_VAR_NODE_APP_EMAIL"
    "TF_VAR_NODE_APP_PASSWORD"
    "TF_VAR_NODE_APP_SERVICE"
    "TF_VAR_MAIN_DOMAIN"
)

echo "Verificando secrets requeridos..."
echo ""

# Obtener lista de secrets configurados
CONFIGURED_SECRETS=$(gh secret list --json name -q '.[].name' 2>/dev/null || echo "")

MISSING_SECRETS=()

for secret in "${REQUIRED_SECRETS[@]}"; do
    if echo "$CONFIGURED_SECRETS" | grep -q "^${secret}$"; then
        echo -e "${GREEN}✅${NC} $secret"
    else
        echo -e "${RED}❌${NC} $secret ${YELLOW}(faltante)${NC}"
        MISSING_SECRETS+=("$secret")
    fi
done

echo ""

# Verificar environments
echo "Verificando environments..."
echo ""

REQUIRED_ENVIRONMENTS=("development" "qa" "production")
CONFIGURED_ENVIRONMENTS=$(gh api repos/:owner/:repo/environments --jq '.environments[].name' 2>/dev/null || echo "")

MISSING_ENVIRONMENTS=()

for env in "${REQUIRED_ENVIRONMENTS[@]}"; do
    if echo "$CONFIGURED_ENVIRONMENTS" | grep -q "^${env}$"; then
        echo -e "${GREEN}✅${NC} $env"
    else
        echo -e "${YELLOW}⚠️${NC}  $env ${YELLOW}(no configurado, se creará automáticamente)${NC}"
        MISSING_ENVIRONMENTS+=("$env")
    fi
done

echo ""
echo "=================================================================="
echo ""

# Resumen
if [ ${#MISSING_SECRETS[@]} -eq 0 ]; then
    echo -e "${GREEN}Excelente, todos los secrets están configurados correctamente!${NC}"
else
    echo -e "${RED}Upsss, faltan ${#MISSING_SECRETS[@]} secret(s):${NC}"
    for secret in "${MISSING_SECRETS[@]}"; do
        echo "   - $secret"
    done
    echo ""
    echo "Configura los secrets faltantes en:"
    echo "https://github.com/$(gh repo view --json nameWithOwner -q .nameWithOwner)/settings/secrets/actions"
fi

echo ""

# Verificar workflows
echo "Workflows disponibles:"
echo ""
gh workflow list

echo ""
echo "=================================================================="
echo ""
echo "Para ejecutar un workflow:"
echo "  gh workflow run <workflow-name>"
echo ""
echo "Por ejemplo:"
echo "  gh workflow run deploy-dev.yml"
echo ""
