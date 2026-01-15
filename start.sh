#!/bin/bash

# --- CONFIGURACIÓN DE IDENTIDADES (¡CAMBIA ESTO!) ---
# Pon aquí el nombre EXACTO del archivo .dat de tu cuenta de Java (sin la ruta, solo el nombre)
UUID_JAVA="af334b6e-99af-345f-bdef-5e86f82e3ded.dat"

# Pon aquí el nombre EXACTO del archivo .dat de tu cuenta de Bedrock
UUID_BEDROCK="c968f818-ff25-4de4-a70b-e399afdd7968.dat"
# ----------------------------------------------------

CARPETA_PRINCIPAL=$(pwd)
RUTA_DATA="server/world/playerdata"

# --- FUNCIÓN DE SINCRONIZACIÓN AL CERRAR ---
sincronizar_salida() {
    echo "🔄 Verificando sincronización de cuentas..."
    
    if [ -f "$RUTA_DATA/$UUID_BEDROCK" ] && [ -f "$RUTA_DATA/$UUID_JAVA" ]; then
        # Comparamos: ¿Es el archivo de Bedrock más nuevo que el de Java?
        if [ "$RUTA_DATA/$UUID_BEDROCK" -nt "$RUTA_DATA/$UUID_JAVA" ]; then
            echo "📱 Detectado progreso en Bedrock. Sincronizando hacia Java..."
            cp "$RUTA_DATA/$UUID_BEDROCK" "$RUTA_DATA/$UUID_JAVA"
            echo "✅ Progreso guardado en la cuenta maestra."
        else
            echo "💻 La cuenta maestra (Java) ya está actualizada."
        fi
    fi
}

# --- FUNCIÓN DE CIERRE GENERAL ---
al_cerrar() {
    echo ""
    echo "🛑 El servidor se ha detenido."
    
    # 1. Ejecutamos la sincronización ANTES del backup
    sincronizar_salida
    
    echo "🔌 Desconectando Playit..."
    pkill -f playit
    
    # Pregunta de Backup
    echo ""
    echo "❓ ¿Quieres subir una COPIA DE SEGURIDAD a GitHub? (s/n)"
    read -r -n 1 respuesta
    echo "" 

    if [[ "$respuesta" =~ ^[sS]$ ]]; then
        echo "📦 INICIANDO BACKUP (Hora Colombia)..."
        echo "---------------------------------------------"
        
        cd "$CARPETA_PRINCIPAL"
        if ! command -v zip &> /dev/null; then
            sudo apt-get update -qq && sudo apt-get install -y zip -qq
        fi
        if [ ! -d "server/backups" ]; then mkdir -p server/backups; fi

        FECHA=$(TZ="America/Bogota" date '+%Y-%m-%d_%I-%M-%p')
        NOMBRE_BASE="server/backups/backup_$FECHA.zip"

        echo "🗜️ Creando archivo: $NOMBRE_BASE"
        zip -r -s 90m -q "$NOMBRE_BASE" server/world server/world_nether server/world_the_end
        
        echo "☁️ Subiendo a GitHub..."
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
echo "🟢 INICIANDO SERVIDOR (Modo Sincronización)"
echo "---------------------------------------"

# 1. SINCRONIZACIÓN DE ENTRADA (Java -> Bedrock)
# Antes de arrancar, nos aseguramos que Bedrock tenga la última copia de Java
echo "🔄 Sincronizando inventarios (Java -> Bedrock)..."
if [ -f "$RUTA_DATA/$UUID_JAVA" ]; then
    cp "$RUTA_DATA/$UUID_JAVA" "$RUTA_DATA/$UUID_BEDROCK"
    echo "✅ Cuenta de Bedrock actualizada con datos de Java."
else
    echo "⚠️ Advertencia: No encuentro el archivo de datos de Java."
fi
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
