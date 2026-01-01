#!/bin/bash

# Guardamos ubicación
CARPETA_PRINCIPAL=$(pwd)

# --- FUNCIÓN DE CIERRE ---
al_cerrar() {
    echo ""
    echo "🛑 El servidor se ha detenido."
    echo "🔌 Desconectando Playit..."
    pkill -f playit

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

    # --- CAMBIO CLAVE: Hora de Colombia (America/Bogota) ---
    # %I = Hora formato 12h
    # %M = Minutos
    # %p = AM/PM
    # Ejemplo de nombre resultante: backup_2025-12-31_08-55-PM.zip
    FECHA=$(TZ="America/Bogota" date '+%Y-%m-%d_%I-%M-%p')
    
    # Nombre base (WinRAR compatible)
    NOMBRE_BASE="server/backups/backup_$FECHA.zip"

    echo "🗜️ Creando archivo: $NOMBRE_BASE"
    echo "   (División automática en partes de 90MB para GitHub)"
    
    # Creamos el zip dividido compatible con WinRAR
    zip -r -s 90m -q "$NOMBRE_BASE" server/world server/world_nether server/world_the_end
    
    echo "☁️ Subiendo a GitHub..."
    
    # Agregamos los archivos generados (.z01, .zip, etc)
    git add server/backups/backup_*
    
    # En el mensaje del commit también ponemos la hora colombiana exacta
    git commit -m "Backup Colombia: $FECHA"
    git push origin main
    
    echo "---------------------------------------------"
    echo "✅ ¡Backup guardado con hora local!"
}

trap al_cerrar EXIT

# --- INICIO ---
echo "---------------------------------------"
echo "🟢 INICIANDO SERVIDOR"
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
