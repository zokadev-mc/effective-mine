#!/bin/bash

# --- FUNCIÓN DE LIMPIEZA (El Exterminador) ---
cleanup() {
    echo ""
    echo "🛑 Detectando cierre..."
    echo "🔫 Ejecutando orden: MATAR a Playit..."
    pkill -f playit
    echo "✅ Playit ha sido eliminado. Todo limpio."
}

# Esta línea es la magia:
# "trap" significa que si este script termina por CUALQUIER razón
# (exit, error, ctrl+c, o fin del server), ejecutará la función 'cleanup'
trap cleanup EXIT

# --- INICIO ---
echo "---------------------------------------"
echo "🚀 Arrancando sistema..."
echo "---------------------------------------"

# 1. Iniciar Playit
# Lo mandamos al fondo (&) y silenciamos la salida para no ensuciar
playit > playit_log.txt 2>&1 &
echo "📡 Playit buscando túnel..."
sleep 5 # Damos 5 segundos para que conecte bien

# 2. Iniciar Minecraft
echo "🎮 Arrancando Minecraft 12GB..."
echo "   (Escribe 'stop' para apagar todo correctamente)"
echo "---------------------------------------"

cd server
java -Xmx12G -Xms12G -jar server.jar nogui

# Cuando java termine, el script llegará al final
# y se activará automáticamente la trampa 'cleanup' de arriba.
