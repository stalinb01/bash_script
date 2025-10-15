# Comando base de certbot (puedes ajustar si usas otro)
CERTBOT_BASE="certbot-2 --apache"

# Fecha actual en formato ISO
CURRENT_DATE=$(date +"%Y-%m-%d")

echo "=============================="
echo "🔍 Verificación de certificados SSL"
echo "📅 Fecha actual: $CURRENT_DATE"
echo "=============================="

# Recorrer cada certificado PEM en los subdirectorios del directorio especificado
for CERT_FILE in $(find "$CERT_DIR" -type f -name "cert.pem"); do
  DOMAIN=$(basename "$(dirname "$CERT_FILE")")  # nombre del dominio según carpeta
  echo "--------------------------------------------------"
  echo "🌐 Dominio: $DOMAIN"
  echo "📄 Archivo: $CERT_FILE"

  # Obtener fecha de expiración
  EXPIRATION_RAW=$(openssl x509 -in "$CERT_FILE" -noout -dates | grep notAfter | cut -d= -f2)

  # Validar que se obtuvo una fecha
  if [ -z "$EXPIRATION_RAW" ]; then
    echo "❌ No se pudo leer la fecha de expiración."
    continue
  fi

  # Convertir fecha a formato ISO (YYYY-MM-DD)
  EXPIRATION_DATE=$(date -d "$EXPIRATION_RAW" +"%Y-%m-%d")

  # Calcular diferencia en días
  DIFF_DAYS=$(( ($(date -d "$EXPIRATION_DATE" +%s) - $(date -d "$CURRENT_DATE" +%s)) / 86400 ))

  echo "📜 Expira el: $EXPIRATION_DATE"
  echo "🕒 Días restantes: $DIFF_DAYS"

  # Si la diferencia es 1 día, renovar
  if [ "$DIFF_DAYS" -eq 1 ]; then
    echo "⚠️ El certificado expira mañana. Ejecutando renovación..."
    $CERTBOT_BASE -d "$DOMAIN"
  else
    echo "✅ No requiere renovación (faltan $DIFF_DAYS días)."
  fi
done

echo "=============================="
echo "✅ Verificación completada."
echo "=============================="
