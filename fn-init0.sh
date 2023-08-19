#!/bin/bash

echo "                                                           ███████╗███╗   ██╗          "
echo "                                                           ██╔════╝████╗  ██║          "
echo "                                                 █████╗    █████╗  ██╔██╗ ██║    █████╗"
echo "                                                 ╚════╝    ██╔══╝  ██║╚██╗██║    ╚════╝"
echo "                                                           ██║     ██║ ╚████║          "
echo "                                                           ╚═╝     ╚═╝  ╚═══╝          Iniciando Instalador ..."
echo "                                                                                    Faça o login para continuar  "
echo "                                 
                                                                                   


URL="https://raw.githubusercontent.com/marcelofbit/fn-iso-auto-docker-init/main/fn-init.sh"


echo -n "Por favor, digite o token do GitHub: "
read -s TOKEN
echo ""

ARQUIVO_TEMP=$(mktemp /tmp/XXXXXX.sh)


curl -H "Authorization: token $TOKEN" -L $URL -o $ARQUIVO_TEMP


chmod +x $ARQUIVO_TEMP


$ARQUIVO_TEMP


rm -f $ARQUIVO_TEMP

unset TOKEN
exit
