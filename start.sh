#!/bin/bash

# --- ⚙️ CONFIGURACIÓN DE IDENTIDADES (¡CAMBIA ESTO!) ---
# Nombre EXACTO del archivo .dat de tu cuenta de Java
UUID_JAVA="TU_UUID_JAVA.dat"

# Nombre EXACTO del archivo .dat de tu cuenta de Bedrock
UUID_BEDROCK="TU_UUID_BEDROCK.dat"
# -------------------------------------------------------

# Guardamos la ubicación de la casa (raíz) al empezar
CARPETA_PRINCIPAL=$(pwd)
RUTA_DATA="server/world/playerdata"

# --- FUNCIÓN MAESTRA DE SINCRONIZACIÓN ---
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
            echo "✅ Ambas cuentas están sincronizadas."
        fi
    else
        echo "⚠️ Alerta: No encuentro los archivos en: $RUTA_DATA"
    fi
}

# --- FUNCIÓN DE CIERRE ---
al_cerrar() {
    # [CORRECCIÓN CRÍTICA] Volvemos a la raíz ANTES de hacer nada
    cd "$CARPETA_PRINCIPAL"

    echo ""
    echo "🛑 El servidor se ha detenido."
    
    # Ahora que estamos en la raíz, la ruta 'server/world/...' sí existe
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
echo "🟢 INICIANDO SERVIDOR"
echo "---------------------------------------"

# Sincronizamos al entrar (Aquí ya estamos en la raíz, así que funciona bien)
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
