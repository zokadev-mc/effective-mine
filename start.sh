#!/bin/bash

# --- FUNCIÓN DE CIERRE ---
# Esta función SOLO se ejecuta cuando el servidor de Minecraft se apaga (cuando el script termina)
al_cerrar() {
    echo ""
    echo "🛑 El servidor se ha detenido (comando stop detectado)."
    echo "🔌 Desconectando Playit..."
    pkill -f playit
    echo "✅ Todo apagado correctamente."
}

# La trampa: Si el script termina (EXIT), ejecuta la función 'al_cerrar'
trap al_cerrar EXIT

# --- INICIO ---
echo "---------------------------------------"
echo "🟢 INICIANDO SECUENCIA"
echo "---------------------------------------"

# 1. Iniciar Playit primero
echo "📡 Arrancando Playit en segundo plano..."
# Lo mandamos al fondo (&) sin matar nada previo
playit > playit_log.txt 2>&1 &

# Importante: Esperamos 5 segundos para asegurar que el túnel se cree antes de seguir
echo "⏳ Esperando conexión del túnel..."
sleep 5

# 2. Iniciar el Servidor
if [ -d "server" ]; then
    cd server
    echo "🎮 Iniciando Minecraft..."
    echo "   (Recuerda: Escribe 'stop' en la consola para apagar y guardar)"
    echo "---------------------------------------"
    
    # Arrancamos Java. El script se quedará "pausado" en esta línea hasta que el server se cierre.
    java -Xmx12G -Xms12G -jar server.jar nogui
else
    echo "❌ Error: No encuentro la carpeta server."
fi

# Cuando el java termina (porque escribiste stop), el script sigue y llega al final,
# activando automáticamente la trampa 'al_cerrar'.
