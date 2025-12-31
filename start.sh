#!/bin/bash

# Función para matar playit solo al final
cleanup() {
    echo ""
    echo "🛑 CERRANDO TODO..."
    pkill -f playit
    echo "✅ Playit desconectado."
}
trap cleanup EXIT

echo "---------------------------------------"
echo "🔍 MODO DIAGNÓSTICO DE INICIO"
echo "---------------------------------------"

# 1. Iniciar Playit
echo "🚀 Arrancando Playit en segundo plano..."
playit > playit_log.txt 2>&1 &
sleep 5

# 2. Comprobaciones de seguridad antes de arrancar Java
echo "📂 Verificando archivos..."

if [ ! -d "server" ]; then
    echo "❌ ERROR FATAL: No encuentro la carpeta 'server'."
    echo "   (Estás en: $(pwd))"
    echo "   Revisa si la carpeta se llama diferente."
    exit 1
fi

cd server

if [ ! -f "server.jar" ]; then
    echo "❌ ERROR FATAL: No encuentro 'server.jar' dentro de la carpeta server."
    echo "   Archivos encontrados aquí: $(ls)"
    exit 1
fi

# 3. Intentar arrancar Minecraft
echo "🎮 Intentando arrancar Java con 12GB..."
echo "⚠️ SI FALLA AQUÍ, ES PROBABLEMENTE POR FALTA DE RAM REAL ⚠️"
echo "---------------------------------------"

# Ejecutamos Java
java -Xmx12G -Xms12G -jar server.jar nogui

# 4. Pausa final para leer errores
echo "---------------------------------------"
echo "🔴 El servidor se ha detenido."
echo "👀 Lee el error de arriba (si lo hay)."
echo "⌨️  PRESIONA ENTER PARA APAGAR Y SALIR..."
read input
