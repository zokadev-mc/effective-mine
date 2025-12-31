#!/bin/bash

echo "---------------------------------------"
echo "🔵 INICIANDO SISTEMA AUTOMÁTICO"
echo "---------------------------------------"

# 1. Iniciar Playit en segundo plano (oculto)
# Guardamos lo que diga playit en un archivo por si acaso falla algo.
echo "🚀 Arrancando túnel Playit..."
playit > playit_log.txt 2>&1 &
PLAYIT_PID=$! # Esto guarda el ID del proceso de Playit para matarlo luego

# Esperamos 3 segundos para asegurar que conecte
sleep 3
echo "✅ Playit activo (PID: $PLAYIT_PID)"

# 2. Iniciar Minecraft
# Entramos a la carpeta y ejecutamos con 12GB
echo "🎮 Arrancando Servidor Minecraft..."
echo "   (Escribe 'stop' cuando quieras apagar todo)"
echo "---------------------------------------"

cd server
java -Xmx12G -Xms12G -jar server.jar nogui

# 3. Limpieza automática
# El script solo llegará aquí cuando el server de Minecraft se haya cerrado
echo "---------------------------------------"
echo "🔴 El servidor se ha detenido."
echo "🧹 Apagando Playit y limpiando..."
kill $PLAYIT_PID
echo "👋 ¡Todo desconectado! Bye bye."
