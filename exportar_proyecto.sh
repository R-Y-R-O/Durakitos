#!/bin/bash

# ============================================
# SCRIPT DE EXPORTACIÓN - PROYECTO DURAKITOS
# ============================================
# Este script exporta toda la estructura y contenido
# del proyecto a un archivo TXT para revisión.

OUTPUT_FILE="proyecto_completo.txt"
PROJECT_NAME="Durakitos"

# Limpiar archivo anterior si existe
> "$OUTPUT_FILE"

echo "🚀 Iniciando exportación del proyecto $PROJECT_NAME..."
echo ""

# Encabezado del archivo
cat >> "$OUTPUT_FILE" << HEADER
================================================================================
PROYECTO: $PROJECT_NAME
FECHA DE EXPORTACIÓN: $(date '+%Y-%m-%d %H:%M:%S')
================================================================================

ESTRUCTURA DE CARPETAS:
--------------------------------------------------------------------------------
HEADER

# Generar árbol de directorios (excluyendo carpetas pesadas)
if command -v tree &> /dev/null; then
    tree -I 'build|.git|.dart_tool|.gradle|.idea|node_modules|.firebase|.vscode|android/.gradle' -L 4 >> "$OUTPUT_FILE"
else
    find . -type d \
        -not -path "*/build/*" \
        -not -path "*/.git/*" \
        -not -path "*/.dart_tool/*" \
        -not -path "*/.gradle/*" \
        -not -path "*/.idea/*" \
        -not -path "*/node_modules/*" \
        -not -path "*/.firebase/*" \
        -not -path "*/.vscode/*" \
        -not -path "*/android/.gradle/*" \
        | head -200 >> "$OUTPUT_FILE"
fi

echo "" >> "$OUTPUT_FILE"
echo "================================================================================" >> "$OUTPUT_FILE"
echo "CONTENIDO DE ARCHIVOS:" >> "$OUTPUT_FILE"echo "================================================================================" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

# Función para agregar archivo al output
agregar_archivo() {
    local archivo="$1"
    local tamano=$(stat -c%s "$archivo" 2>/dev/null || stat -f%z "$archivo" 2>/dev/null)
    
    # Solo archivos menores a 500KB (evitar binarios gigantes)
    if [ "$tamano" -lt 512000 ]; then
        echo "" >> "$OUTPUT_FILE"
        echo "================================================================================" >> "$OUTPUT_FILE"
        echo "📄 ARCHIVO: $archivo" >> "$OUTPUT_FILE"
        echo "📏 TAMAÑO: $tamano bytes" >> "$OUTPUT_FILE"
        echo "================================================================================" >> "$OUTPUT_FILE"
        cat "$archivo" >> "$OUTPUT_FILE" 2>/dev/null
        echo "" >> "$OUTPUT_FILE"
        echo "[FIN DEL ARCHIVO]" >> "$OUTPUT_FILE"
    else
        echo "" >> "$OUTPUT_FILE"
        echo "⚠️  ARCHIVO OMITIDO (muy grande): $archivo ($tamano bytes)" >> "$OUTPUT_FILE"
    fi
}

# Extensiones a incluir
EXTENSIONES="dart|yaml|yml|json|xml|kt|java|gradle|properties|ts|js|md|txt|sh|html|css|toml|lock"

# Buscar archivos excluyendo carpetas pesadas
echo "📂 Escaneando archivos del proyecto..."

find . -type f \
    -not -path "*/build/*" \
    -not -path "*/.git/*" \
    -not -path "*/.dart_tool/*" \
    -not -path "*/.gradle/*" \
    -not -path "*/.idea/*" \
    -not -path "*/node_modules/*" \
    -not -path "*/.firebase/*" \
    -not -path "*/.vscode/*" \
    -not -path "*/android/.gradle/*" \
    -not -path "*/ios/Pods/*" \
    -not -path "*/ios/.symlinks/*" \
    -not -name "*.apk" \
    -not -name "*.aab" \
    -not -name "*.png" \
    -not -name "*.jpg" \
    -not -name "*.jpeg" \
    -not -name "*.gif" \
    -not -name "*.webp" \
    -not -name "*.ttf" \    -not -name "*.otf" \
    -not -name "*.so" \
    -not -name "*.dylib" \
    -not -name "*.dll" \
    -not -name "*.exe" \
    -not -name "proyecto_completo.txt" \
    -not -name "exportar_proyecto.sh" \
    | sort | while read -r archivo; do
    
    # Verificar si es una extensión de interés o está en carpetas clave
    if echo "$archivo" | grep -qE "\.($EXTENSIONES)$"; then
        agregar_archivo "$archivo"
    elif echo "$archivo" | grep -qE "(pubspec|README|CHANGELOG|LICENSE|\.gitignore|\.metadata)"; then
        agregar_archivo "$archivo"
    fi
done

# Resumen final
total_archivos=$(grep -c "📄 ARCHIVO:" "$OUTPUT_FILE")
tamano_total=$(stat -c%s "$OUTPUT_FILE" 2>/dev/null || stat -f%z "$OUTPUT_FILE" 2>/dev/null)

cat >> "$OUTPUT_FILE" << RESUMEN

================================================================================
📊 RESUMEN DE EXPORTACIÓN
================================================================================
Total de archivos exportados: $total_archivos
Tamaño del archivo generado: $tamano_total bytes ($(echo "scale=2; $tamano_total/1024/1024" | bc) MB)
Fecha de finalización: $(date '+%Y-%m-%d %H:%M:%S')
================================================================================
RESUMEN

echo ""
echo "✅ Exportación completada!"
echo "📄 Archivo generado: $OUTPUT_FILE"
echo "📊 Archivos incluidos: $total_archivos"
echo "📏 Tamaño: $(du -h "$OUTPUT_FILE" | cut -f1)"
echo ""
echo "💡 Para ver las primeras líneas:"
echo "   head -50 $OUTPUT_FILE"
echo ""
echo "💡 Para buscar un archivo específico dentro del TXT:"
echo "   grep -n '📄 ARCHIVO:' $OUTPUT_FILE"
