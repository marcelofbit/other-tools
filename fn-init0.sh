#!/bin/bash

#                                                            ███████╗███╗   ██╗          
#                                                            ██╔════╝████╗  ██║          
#                                                  █████╗    █████╗  ██╔██╗ ██║    █████╗
#                                                  ╚════╝    ██╔══╝  ██║╚██╗██║    ╚════╝
#                                                            ██║     ██║ ╚████║          
#                                                            ╚═╝     ╚═╝  ╚═══╝          Iniciando Instalador ...
#                                                                                     Faça o login para continuar  
#                                                                                        
                                                                                   

# URL do arquivo que você quer baixar
URL="https://raw.githubusercontent.com/marcelofbit/fn-iso-auto-docker-init/main/fn-init.sh"

# Solicitar o token do GitHub ao usuário
echo -n "Por favor, digite o token do GitHub: "
read -s TOKEN
echo ""

# Criar um nome temporário aleatório para o arquivo baixado
ARQUIVO_TEMP=$(mktemp /tmp/XXXXXX.sh)

# Baixar o arquivo usando curl
curl -H "Authorization: token $TOKEN" -L $URL -o $ARQUIVO_TEMP

# Tornar o arquivo baixado executável
chmod +x $ARQUIVO_TEMP

# Executar o arquivo baixado
$ARQUIVO_TEMP

# Remover o arquivo baixado
rm -f $ARQUIVO_TEMP

# Limpar a variável TOKEN
unset TOKEN
logout
