#!/bin/bash

# 1. Instalar Playit (Túnel)
curl -SsL https://playit-cloud.github.io/ppa/key.gpg | sudo apt-key add -
sudo curl -SsL -o /etc/apt/sources.list.d/playit-cloud.list https://playit-cloud.github.io/ppa/playit-cloud.list
sudo apt update
sudo apt install playit -y

# 2. Crear el script de arranque con 12GB RAM
# (Esto asume que tu carpeta se llama 'server', si no, lo crea donde esté)
if [ -d "server" ]; then
    cd server
fi

# Aquí creamos el comando corto para encender
echo "java -Xmx12G -Xms12G -jar server.jar nogui" > prender.sh
chmod +x prender.sh

echo "---------------------------------------------------"
echo "¡INSTALACIÓN DE PLAYIT COMPLETADA!"
echo "---------------------------------------------------"
