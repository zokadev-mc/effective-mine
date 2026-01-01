#!/bin/bash

# 1. Guardamos la ubicación de la carpeta principal del repositorio
CARPETA_PRINCIPAL=$(pwd)

# --- FUNCIÓN DE CIERRE Y BACKUP ---
al_cerrar() {
    echo ""
    echo "🛑 El servidor se ha detenido."
    
    echo "🔌 Desconectando Playit..."
    pkill -f playit

    echo "📦 INICIANDO COPIA DE SEGURIDAD EN 'server/backups'..."
    echo "---------------------------------------------"
    
    # Volvemos a la raíz del repositorio
    cd "$CARPETA_PRINCIPAL"
    
    # 1. Instalar ZIP si no existe (necesario para comprimir)
    if ! command -v zip &> /dev/null; then
        echo "🔧 Instalando herramienta de compresión (zip)..."
        sudo apt-get update -qq && sudo apt-get install -y zip -qq
    fi

    # 2. Crear la carpeta de backups si no existe
    if [ ! -d "server/backups" ]; then
        mkdir -p server/backups
        echo "📂 Carpeta 'server/backups' creada."
    fi

    # 3. Generar nombre del archivo con fecha y hora (Ej: backup_2023-12-31_18-00.zip)
    FECHA=$(date '+%Y-%m-%d_%H-%M')
    NOMBRE_ZIP="server/backups/backup_$FECHA.zip"

    echo "🗜️ Comprimiendo mundos en: $NOMBRE_ZIP"
    
    # Comprimimos las carpetas de los mundos (world, nether, end) en el archivo zip
    # -r = recursivo (todo lo de adentro)
    # -q = silencioso (para no llenar la pantalla de texto)
    zip -r -q "$NOMBRE_ZIP" server/world server/world_nether server/world_the_end

    # 4. Subir a GitHub
    echo "☁️ Subiendo archivo a la nube..."
    
    # Solo agregamos el nuevo zip creado
    git add "$NOMBRE_ZIP"
    
    git commit -m "Backup automático: $FECHA"
    git push origin main
    
    echo "---------------------------------------------"
    echo "✅ ¡Copia de seguridad guardada en server/backups!"
}

# Trampa para activar el cierre
trap al_cerrar EXIT

# --- INICIO ---
echo "---------------------------------------"
echo "🟢 INICIANDO SERVIDOR (Con Backups ZIP)"
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
    echo "   Escribe 'stop' para guardar y salir."
    echo "---------------------------------------"
    
    # TU COMANDO CORRECTO (El que funcionó):
    java -Xms12G -Xmx12G -jar server.jar nogui
    
else
    echo "❌ Error: No encuentro la carpeta server."
fi
