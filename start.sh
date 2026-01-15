#!/bin/bash

# --- CONFIGURACIÓN DE IDENTIDADES (¡CAMBIA ESTO!) ---
# Pon aquí el nombre EXACTO del archivo .dat de tu cuenta de Java (sin la ruta, solo el nombre)
UUID_JAVA="af334b6e-99af-345f-bdef-5e86f82e3ded.dat"

# Pon aquí el nombre EXACTO del archivo .dat de tu cuenta de Bedrock
UUID_BEDROCK="c968f818-ff25-4de4-a70b-e399afdd7968.dat"
# ----------------------------------------------------

CARPETA_PRINCIPAL=$(pwd)
RUTA_DATA="server/world/playerdata"

# --- FUNCIÓN MAESTRA DE SINCRONIZACIÓN ---
# Esta función compara fechas y clona el más nuevo sobre el más viejo
sincronizar_cuentas() {
    echo "🔄 Analizando fechas de guardado..."
    
    FILE_JAVA="$RUTA_DATA/$UUID_JAVA"
    FILE_BEDROCK="$RUTA_DATA/$UUID_BEDROCK"

    if [ -f "$FILE_JAVA" ] && [ -f "$FILE_BEDROCK" ]; then
        # ¿Es Bedrock más nuevo que Java?
        if [ "$FILE_BEDROCK" -nt "$FILE_JAVA" ]; then
            echo "📱 Detectado progreso reciente en BEDROCK."
            echo "   ↳ Sincronizando: Bedrock >>> Java"
            cp "$FILE_BEDROCK" "$FILE_JAVA"
        # ¿Es Java más nuevo que Bedrock?
        elif [ "$FILE_JAVA" -nt "$FILE_BEDROCK" ]; then
            echo "💻 Detectado progreso reciente en JAVA."
            echo "   ↳ Sincronizando: Java >>> Bedrock"
            cp "$FILE_JAVA" "$FILE_BEDROCK"
        else
            echo "✅ Ambas cuentas están sincronizadas (mismo timestamp)."
        fi
    else
        echo "⚠️ Alerta: No encuentro uno de los archivos de datos (UUIDs). Revisa la configuración."
    fi
}

# --- FUNCIÓN DE CIERRE ---
al_cerrar() {
    echo ""
    echo "🛑 El servidor se ha detenido."
    
    # 1. Sincronizamos INMEDIATAMENTE al cerrar para guardar el progreso cruzado
    sincronizar_cuentas
    
    echo "🔌 Desconectando Playit..."
    pkill -f playit
    
    # Pregunta de Backup
    echo ""
    echo "❓ ¿Quieres subir una COPIA DE SEGURIDAD a GitHub? (s/n)"
    read -r -n 1 respuesta
    echo "" 

    if [[ "$respuesta" =~ ^[sS]$ ]]; then
        echo "📦 INICIANDO BACKUP (Hora Colombia)..."
        cd "$CARPETA_PRINCIPAL"
        if ! command -v zip &> /dev/null; then sudo apt-get update -qq && sudo apt-get install -y zip -qq; fi
        if [ ! -d "server/backups" ]; then mkdir -p server/backups; fi

        FECHA=$(TZ="America/Bogota" date '+%Y-%m-%d_%I-%M-%p')
        NOMBRE_BASE="server/backups/backup_$FECHA.zip"

        zip -r -s 90m -q "$NOMBRE_BASE" server/world server/world_nether server/world_the_end
        git add server/backups/backup_*
        git commit -m "Backup Colombia: $FECHA"
        git push origin main
        echo "✅ ¡Backup guardado!"
    else
        echo "💨 Salida rápida: Sin backup."
    fi
}

trap al_cerrar EXIT

# --- INICIO ---
echo "---------------------------------------"
echo "🟢 INICIANDO SERVIDOR (Sincronización Bidireccional)"
echo "---------------------------------------"

# 1. Sincronizamos AL ENTRAR para cargar la última partida (sea cual sea)
sincronizar_cuentas
echo "---------------------------------------"

echo "📡 Arrancando Playit..."
playit > playit_log.txt 2>&1 &
echo "⏳ Esperando túnel (5s)..."
sleep 5

if [ -d "server" ]; then
    cd server
    echo "🎮 Servidor ONLINE (12GB)"
    java -Xms12G -Xmx12G -jar server.jar nogui
else
    echo "❌ Error: No encuentro la carpeta server."
fi
