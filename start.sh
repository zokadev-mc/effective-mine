#!/bin/bash

# Guardamos ubicación
CARPETA_PRINCIPAL=$(pwd)

# --- FUNCIÓN DE CIERRE ---
al_cerrar() {
    echo ""
    echo "🛑 El servidor se ha detenido."
    echo "🔌 Desconectando Playit..."
    pkill -f playit
    
    # --- PREGUNTA DE SEGURIDAD ---
    echo ""
    echo "❓ ¿Quieres subir una COPIA DE SEGURIDAD a GitHub? (s/n)"
    read -r -n 1 respuesta
    echo "" # Salto de línea estético

    # Si la respuesta es 's' o 'S', hacemos el backup
    if [[ "$respuesta" =~ ^[sS]$ ]]; then
        echo "📦 INICIANDO BACKUP (Hora Colombia)..."
        echo "---------------------------------------------"
        
        cd "$CARPETA_PRINCIPAL"
        
        # Instalar ZIP si falta
        if ! command -v zip &> /dev/null; then
            sudo apt-get update -qq && sudo apt-get install -y zip -qq
        fi

        if [ ! -d "server/backups" ]; then
            mkdir -p server/backups
        fi

        # Configuración de hora Colombia
        FECHA=$(TZ="America/Bogota" date '+%Y-%m-%d_%I-%M-%p')
        NOMBRE_BASE="server/backups/backup_$FECHA.zip"

        echo "🗜️ Creando archivo: $NOMBRE_BASE"
        
        # Comprimir dividido (90MB) compatible con WinRAR
        zip -r -s 90m -q "$NOMBRE_BASE" server/world server/world_nether server/world_the_end
        
        echo "☁️ Subiendo a GitHub..."
        git add server/backups/backup_*
        git commit -m "Backup Colombia: $FECHA"
        git push origin main
        
        echo "---------------------------------------------"
        echo "✅ ¡Backup guardado con éxito!"
    else
        echo "NO se ha creado copia de seguridad."
    fi
}

trap al_cerrar EXIT

# --- INICIO ---
echo "---------------------------------------"
echo "🟢 INICIANDO SERVIDOR (Con Pregunta de Backup)"
echo "---------------------------------------"

echo "📡 Arrancando Playit..."
playit > playit_log.txt 2>&1 &
echo "⏳ Esperando túnel (5s)..."
sleep 5

if [ -d "server" ]; then
    cd server
    echo "🎮 Servidor ONLINE (12GB)"
    
    # TU COMANDO:
    java -Xms12G -Xmx12G -jar server.jar nogui
    
else
    echo "❌ Error: No encuentro la carpeta server."
fi
