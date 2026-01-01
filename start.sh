#!/bin/bash

# 1. Guardamos la ubicación de la carpeta principal
CARPETA_PRINCIPAL=$(pwd)

# --- FUNCIÓN DE CIERRE Y BACKUP ---
al_cerrar() {
    echo ""
    echo "🛑 El servidor se ha detenido."
    
    echo "🔌 Desconectando Playit..."
    pkill -f playit

    echo "📦 INICIANDO COPIA DE SEGURIDAD DIVIDIDA..."
    echo "---------------------------------------------"
    
    # Volvemos a la raíz
    cd "$CARPETA_PRINCIPAL"
    
    # Instalar ZIP si falta
    if ! command -v zip &> /dev/null; then
        sudo apt-get update -qq && sudo apt-get install -y zip -qq
    fi

    # Crear carpeta
    if [ ! -d "server/backups" ]; then
        mkdir -p server/backups
    fi

    # Configurar nombre
    FECHA=$(date '+%Y-%m-%d_%H-%M')
    NOMBRE_ZIP="server/backups/backup_$FECHA.zip"

    echo "🗜️ Comprimiendo mundos..."
    zip -r -q "$NOMBRE_ZIP" server/world server/world_nether server/world_the_end
    
    echo "✂️ Dividiendo archivo en partes de 90MB..."
    # Aquí está la MAGIA: 'split' divide el zip grande en trozos pequeños
    split -b 90M "$NOMBRE_ZIP" "$NOMBRE_ZIP.part"
    
    # Borramos el ZIP gigante original porque ya tenemos los trozos
    rm "$NOMBRE_ZIP"

    # 4. Subir a GitHub
    echo "☁️ Subiendo partes a la nube..."
    
    # Agregamos todas las partes generadas (.partaa, .partab, etc)
    git add server/backups/backup_*.part*
    
    git commit -m "Backup dividido: $FECHA"
    git push origin main
    
    echo "---------------------------------------------"
    echo "✅ ¡Backup guardado en trozos!"
}

trap al_cerrar EXIT

# --- INICIO ---
echo "---------------------------------------"
echo "🟢 INICIANDO SERVIDOR (Modo Split-Backup)"
echo "---------------------------------------"

# 1. Playit
echo "📡 Arrancando Playit..."
playit > playit_log.txt 2>&1 &
echo "⏳ Esperando túnel (5s)..."
sleep 5

# 2. Minecraft
if [ -d "server" ]; then
    cd server
    echo "🎮 Servidor ONLINE (12GB)"
    
    # TU COMANDO QUE FUNCIONA:
    java -Xms12G -Xmx12G -jar server.jar nogui
    
else
    echo "❌ Error: No encuentro la carpeta server."
fi
