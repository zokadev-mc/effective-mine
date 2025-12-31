#!/bin/bash

# 1. Matanza inicial (Para evitar el error "Address already in use")
# Esto asegura que no haya un server viejo bloqueando el puerto.
echo "🧹 Limpiando procesos zombies..."
pkill -f playit
pkill -f java
sleep 2

# 2. Iniciar Playit
echo "🚀 Arrancando Playit..."
playit > playit_log.txt 2>&1 &

# 3. Comprobación y Corrección de EULA (Causa #1 de apagado)
if [ -d "server" ]; then
    cd server
    # Forzamos que el EULA sea true, por si acaso se reinició
    echo "eula=true" > eula.txt
else
    echo "❌ ERROR: No encuentro la carpeta 'server'."
    exit 1
fi

# 4. Iniciar Minecraft
echo "🎮 Iniciando Servidor..."
echo "----------------------------------------------"
# Ejecutamos el server
java -Xmx12G -Xms12G -jar server.jar nogui

# 5. DIAGNÓSTICO POST-MUERTE
# Si el script llega aquí, es porque el servidor se cerró.
echo "----------------------------------------------"
echo "🔴 EL SERVIDOR SE DETUVO."
echo "🔎 Buscando la causa en el registro (logs/latest.log)..."
echo "----------------------------------------------"

if [ -f "logs/latest.log" ]; then
    # Muestra las últimas 15 líneas del error real
    tail -n 15 logs/latest.log
else
    echo "⚠️ No se encontró archivo de log. El servidor ni siquiera arrancó."
fi

echo "----------------------------------------------"
echo "🛑 Presiona ENTER para terminar..."
read input
