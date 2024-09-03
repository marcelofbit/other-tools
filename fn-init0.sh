#!/bin/bash
# Versão: 1.56
# Autor: Marcelo Fenner Bitencourt - marcelo@fellnner.com.br
# Data: 19-08-2023
# Descrição: Script para inicialização e configuração de containers
# Uso: Execute este script como root ou com permissões adequadas
# Nota: Certifique-se de ter as dependências necessárias instaladas
# Variaveis: Voce pode personalizar a instalaçao usando variaveis globais
# -----------------------------------------
clear
USER_LINUX=$whoami 

LOG_FILE="fn-install.log"


log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a $LOG_FILE
}

EX_DATE="$(date -d 'now + 5 minutes' '+%Y-%m-%d %H:%M:%S')"
chage -E "$EX_DATE" fn-install23
if [ $? -eq 0 ]; then
    log "Configurando usuario: $USER_LINUX $EX_DATE"
else
    log "Erro conta fn-install23 - informe o problema para equipe de desenvolvimento"
    exit 1
fi
echo ""
echo ""
echo ""


echo "                                                           ███████╗███╗   ██╗          "
echo "                                                           ██╔════╝████╗  ██║          "
echo "                                                 █████╗    █████╗  ██╔██╗ ██║    █████╗"
echo "                                                 ╚════╝    ██╔══╝  ██║╚██╗██║    ╚════╝"
echo "                                                           ██║     ██║ ╚████║          "
echo "                                                           ╚═╝     ╚═╝  ╚═══╝          Iniciando Instalador ..."
echo "                                                                                    Faça o login para continuar  "
echo ""
echo ""
echo ""

URL="https://raw.github.com/marcelofbit/fn-iso-auto-docker/releases/latest/download/fn-install-build"

while true; do
    
    echo -n "Por favor, digite o seu token do GitHub (ou 'sair' para cancelar): "
    echo ""
    read  TOKEN


    if [ "$TOKEN" = "sair" ]; then
        log "Operação cancelada pelo usuário."
        echo ""
        exit 0
    fi


    APP=$(mktemp /tmp/XXXXXX)


    curl -H "Authorization: token $TOKEN" -L $URL -o $APP
    if [ $? -ne 0 ]; then
        log "Erro ao baixar o script do GitHub - Verifique seu Token"
        echo ""
        echo "Login não autorizado. Por favor, tente novamente."
        echo ""
        continue
    fi


    chmod +x $APP


    $APP
    if [ $? -ne 0 ]; then
        log "Erro ao executar o script baixado."
        echo ""
        exit 1
    fi


    rm -f $APP
    log "Script executado com sucesso"
    echo ""


    unset TOKEN
    exit 0
done
