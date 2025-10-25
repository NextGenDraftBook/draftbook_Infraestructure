#!/bin/bash
# Script para verificar que la llave SSH es válida

KEY_FILE="$1"

if [ ! -f "$KEY_FILE" ]; then
    echo "❌ Error: El archivo $KEY_FILE no existe"
    exit 1
fi

echo "Archivo: $KEY_FILE"
echo "Tamaño: $(stat -f%z "$KEY_FILE" 2>/dev/null || stat -c%s "$KEY_FILE" 2>/dev/null) bytes"
echo "Líneas: $(wc -l < "$KEY_FILE")"
echo ""

# Verificar que comienza con el header correcto
FIRST_LINE=$(head -1 "$KEY_FILE")
if [[ "$FIRST_LINE" == "-----BEGIN "* ]]; then
    echo "✅ La llave comienza correctamente: $FIRST_LINE"
else
    echo "❌ La llave NO comienza correctamente. Se esperaba '-----BEGIN ...' pero se encontró:"
    echo "   '$FIRST_LINE'"
    exit 1
fi

# Verificar que termina con el footer correcto
LAST_LINE=$(tail -1 "$KEY_FILE")
if [[ "$LAST_LINE" == "-----END "* ]]; then
    echo "✅ La llave termina correctamente: $LAST_LINE"
else
    echo "❌ La llave NO termina correctamente. Se esperaba '-----END ...' pero se encontró:"
    echo "   '$LAST_LINE'"
    exit 1
fi

# Intentar validar la llave con ssh-keygen
if command -v ssh-keygen >/dev/null 2>&1; then
    echo ""
    echo "Validando con ssh-keygen..."
    if ssh-keygen -l -f "$KEY_FILE" >/dev/null 2>&1; then
        echo "✅ La llave es válida según ssh-keygen"
        ssh-keygen -l -f "$KEY_FILE"
    else
        echo "❌ ssh-keygen reporta que la llave es inválida"
        exit 1
    fi
fi

echo ""
echo "✅ Todas las verificaciones pasaron"
exit 0
