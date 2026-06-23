#!/bin/bash

OUTPUT="proyecto_completo_v2.txt"
> "$OUTPUT"

echo "🚀 Exportando proyecto Durakitos..."

# Encabezado
cat >> "$OUTPUT" << HEADER
================================================================================
PROYECTO: DURAKITOS - EXPORTACIÓN COMPLETA
FECHA: $(date '+%Y-%m-%d %H:%M:%S')
================================================================================

HEADER

# Función para agregar archivo
add_file() {
    local file="$1"
    echo "" >> "$OUTPUT"
    echo "================================================================================" >> "$OUTPUT"
    echo "📄 $file" >> "$OUTPUT"
    echo "================================================================================" >> "$OUTPUT"
    cat "$file" >> "$OUTPUT" 2>/dev/null
    echo "" >> "$OUTPUT"
}

# 1. Archivos de configuración raíz
echo "📋 Exportando configuración..."
for file in pubspec.yaml analysis_options.yaml firebase.json README.md blueprint.md GEMINI.md; do
    [ -f "$file" ] && add_file "$file"
done

# 2. Todo el código Flutter en lib/
echo "📱 Exportando código Flutter (lib/)..."
find lib -type f -name "*.dart" | sort | while read file; do
    add_file "$file"
done

# 3. Configuración de Android
echo "🤖 Exportando configuración Android..."
for file in android/build.gradle.kts android/settings.gradle.kts android/gradle.properties android/app/build.gradle.kts; do
    [ -f "$file" ] && add_file "$file"
done

# 4. Firebase Functions
echo "🔥 Exportando Firebase Functions..."
for file in functions/package.json functions/tsconfig.json functions/src/index.ts functions/index.js; do
    [ -f "$file" ] && add_file "$file"
done

# 5. Prototipos HTML en stitch/ (si son relevantes)
echo "🎨 Exportando prototipos de diseño..."
find android/stitch -type f \( -name "*.html" -o -name "*.md" -o -name "*.txt" \) 2>/dev/null | sort | while read file; do
    add_file "$file"
done

# 6. Archivos de configuración web
echo "🌐 Exportando configuración web..."
for file in web/index.html web/manifest.json; do
    [ -f "$file" ] && add_file "$file"
done

# Resumen
total=$(grep -c "^📄" "$OUTPUT")
size=$(du -h "$OUTPUT" | cut -f1)

cat >> "$OUTPUT" << RESUMEN

================================================================================
📊 RESUMEN
================================================================================
Total de archivos exportados: $total
Tamaño del archivo: $size
Fecha de finalización: $(date '+%Y-%m-%d %H:%M:%S')
================================================================================
RESUMEN

echo ""
echo "✅ Exportación completada!"
echo "📄 Archivo: $OUTPUT"
echo "📊 Archivos: $total"
echo "📏 Tamaño: $size"
echo ""
echo "💡 Para ver el contenido:"
echo "   cat $OUTPUT"
echo ""
echo "💡 O dividirlo si es muy grande:"
echo "   split -l 1000 $OUTPUT parte_"
