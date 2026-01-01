#!/bin/bash

# 0. Guardamos la ubicación exacta de la carpeta principal al empezar
CARPETA_PRINCIPAL=$(pwd)

# --- FUNCIÓN DE CIERRE ---
# Esta función SOLO se ejecuta cuando el servidor de Minecraft se apaga (cuando el script termina)
al_cerrar() {
    echo ""
    echo "🛑 El servidor se ha detenido (comando stop detectado)."
    echo "🔌 Desconectando Playit..."
    pkill -f playit
    
    echo "📦 INICIANDO COPIA DE SEGURIDAD AUTOMÁTICA..."
    echo "---------------------------------------------"

# 1. Añadimos los mundos al paquete
    # (Añadimos world, world_nether y world_the_end)
    # CORRECCIÓN: Volvemos a la carpeta principal antes de usar git
    # Así el comando 'git add server/world' funcionará perfectamente.
    cd "$CARPETA_PRINCIPAL"
    
    git add server/world server/world_nether server/world_the_end

# 2. Guardamos los cambios con la fecha y hora actual
    fecha=$(date '+%Y-%m-%d %H:%M:%S')
    git commit -m "Backup automático: $fecha"

# 3. Enviamos a la nube
    echo "☁️ Subiendo a GitHub..."
    git push origin main

    echo "---------------------------------------------"
    echo "✅ Todo apagado correctamente."
}

# La trampa: Si el script termina (EXIT), ejecuta la función 'al_cerrar'
trap al_cerrar EXIT

# --- INICIO ---
echo "---------------------------------------"
echo "🟢 INICIANDO SECUENCIA"
echo "---------------------------------------"

# 1. Iniciar Playit primero
echo "📡 Arrancando Playit"
# Lo mandamos al fondo (&) sin matar nada previo
playit > playit_log.txt 2>&1 &

# Importante: Esperamos 5 segundos para asegurar que el túnel se cree antes de seguir
echo "⏳ Esperando conexión del túnel..."
sleep 5

# 2. Iniciar el Servidor
if [ -d "server" ]; then
    cd server
    echo "🎮 Iniciando Servidor..."
    echo "   (Escribe 'stop' en la consola para apagar y guardar)"
    echo "---------------------------------------"
    
    # Arrancamos Java. El script se quedará "pausado" en esta línea hasta que el server se cierre.
    java -Xms12G -Xmx12G -jar server.jar nogui
else
    echo "❌ Error: No encuentro la carpeta server."
fi

# Cuando el java termina (porque escribiste stop), el script sigue y llega al final,
# activando automáticamente la trampa 'al_cerrar'.
