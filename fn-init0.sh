#!/bin/bash

# Definindo o caminho do log
LOG_FILE="fn-install.log"

# Função para registrar mensagens no log
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a $LOG_FILE
}


EXPIRY_DATE="$(date -d 'now + 5 minutes' '+%Y-%m-%d %H:%M:%S')"
chage -E "$EXPIRY_DATE" fn-install23
if [ $? -eq 0 ]; then
    log " Configurando usuario: $EXPIRY_DATE"
else
    log "Erro conta fn-install23 - informe o problema para equipe de desenvolvimento"
    exit 1
fi

# Mensagens de boas-vindas

echo "                                                           ███████╗███╗   ██╗          "
echo "                                                           ██╔════╝████╗  ██║          "
echo "                                                 █████╗    █████╗  ██╔██╗ ██║    █████╗"
echo "                                                 ╚════╝    ██╔══╝  ██║╚██╗██║    ╚════╝"
echo "                                                           ██║     ██║ ╚████║          "
echo "                                                           ╚═╝     ╚═╝  ╚═══╝          Iniciando Instalador ..."
echo "                                                                                    Faça o login para continuar  "

# URL do script a ser baixado
URL="https://raw.githubusercontent.com/marcelofbit/fn-iso-auto-docker/main/fn-install.sh"

# Solicitando o token do GitHub
echo ""
echo -n "Por favor, digite o seu token do GitHub: "
read  TOKEN
echo ""

# Criando um arquivo temporário para o script
ARQUIVO_TEMP=$(mktemp /tmp/XXXXXX.sh)

# Baixando o script usando cURL
curl -H "Authorization: token $TOKEN" -L $URL -o $ARQUIVO_TEMP
if [ $? -ne 0 ]; then
    log "Erro ao baixar o script do GitHub - Verifique seu Token"
    exit 1
fi

# Tornando o script executável
chmod +x $ARQUIVO_TEMP

# Executando o script
$ARQUIVO_TEMP
if [ $? -ne 0 ]; then
    log "Erro ao executar o script baixado."
    exit 1
fi

# Removendo o arquivo temporário
rm -f $ARQUIVO_TEMP
log "Script executado com sucesso"

# Limpando a variável TOKEN
unset TOKEN

exit 0

