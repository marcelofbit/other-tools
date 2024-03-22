import subprocess
import sys
import re
import fileinput
import socket
import glob

# Configurações
DB_ROOT_PASSWORD = 'fn-wanguardfg'  
DB_NAME = 'andrisoft'  
DB_USER_PASSWORD = 'fn-wanguardfg'  
PHP_TIMEZONE = 'America/Sao_Paulo'  
NTP_SERVER = 'pool.ntp.br'  
INFLUXDB_VERSION = '1.8.10'  
ANDRISOFT_GPG_KEY_URL = 'https://www.andrisoft.com/andrisoft.gpg.key'
DEBIAN_VERSION = 'bullseye'

# Funções
def run_command(command, input_data=None, capture_output=False, check=True):
    """Executa um comando no shell com a opção de passar dados para stdin."""
    try:
        result = subprocess.run(
            command, 
            shell=True, 
            input=input_data, 
            text=True,
            capture_output=capture_output,
            check=check
        )
        return result
    except subprocess.CalledProcessError as e:
        print(f"Erro ao executar o comando {command}: {e}", file=sys.stderr)
        sys.exit(1)

def update_php_config(timezone):
    """Atualiza o fuso horário em todos os arquivos php.ini encontrados para Apache e CLI."""
    php_ini_paths = glob.glob('/etc/php/*/apache2/php.ini') + glob.glob('/etc/php/*/cli/php.ini')
    for php_ini_path in php_ini_paths:
        update_config_file(php_ini_path, '^;?date.timezone =.*', f'date.timezone = "{timezone}"')
        print(f"Atualizado {php_ini_path} com timezone {timezone}")


def update_config_file(filepath, pattern, subst):
    """Atualiza um arquivo de configuração substituindo linhas que combinam com um padrão."""
    with fileinput.input(files=(filepath,), inplace=True) as file:
        for line in file:
            print(re.sub(pattern, subst, line), end='')

def get_internal_ip():
    """Obtém o endereço IP interno do host."""
    return socket.gethostbyname(socket.gethostname())


def install_database(db_password):
    """Instala o banco de dados do Wanguard, fornecendo a senha quando solicitado pelo script."""
    print("Instalando o banco de dados do Wanguard...")
    run_command(f'echo "{db_password}" | /opt/andrisoft/bin/install_console')


def configure_wansupervisor(console_ip, db_password):
    """Configura o serviço WANsupervisor, fornecendo o IP do console e a senha do banco de dados."""
    print("Configurando o serviço WANsupervisor...")
    run_command(f'echo -e "{console_ip}\n{db_password}" | /opt/andrisoft/bin/install_supervisor')
    run_command('systemctl start WANsupervisor')
    run_command('systemctl enable WANsupervisor')


def main():
    internal_ip = get_internal_ip()
    print(f"IP interno detectado: {internal_ip}")


    run_command('apt update')
    run_command('apt install apt-transport-https wget gnupg -y')
    run_command(f'wget -qO - {ANDRISOFT_GPG_KEY_URL} | gpg --dearmor -o /usr/share/keyrings/andrisoft-archive-keyring.gpg')
    with open('/etc/apt/sources.list.d/andrisoft.list', 'w') as f:
        f.write(f"deb [signed-by=/usr/share/keyrings/andrisoft-archive-keyring.gpg] https://www.andrisoft.com/files/debian11 {DEBIAN_VERSION} main\n")


    run_command('apt update')
    run_command('apt install wanconsole -y')


    update_config_file('/etc/systemd/timesyncd.conf', '^#?NTP=', f'NTP={NTP_SERVER}')
    run_command('timedatectl set-ntp true')


    update_config_file('/etc/mysql/mariadb.conf.d/50-server.cnf', '^bind-address', '#bind-address')
    run_command('systemctl restart mariadb.service')


    for version in ['7.4', '7.3', '7.2']:  
#        update_config_file(f'/etc/php/{version}/apache2/php.ini', '^;?date.timezone =', f'date.timezone = "{PHP_TIMEZONE}"')
 #       update_config_file(f'/etc/php/{version}/cli/php.ini', '^;?date.timezone =', f'date.timezone = "{PHP_TIMEZONE}"')
        update_php_config(PHP_TIMEZONE)

    run_command('systemctl restart apache2.service')

    
    install_database(DB_USER_PASSWORD)

    
    configure_wansupervisor(internal_ip, DB_USER_PASSWORD)


    INFLUXDB_DEB_URL = f'https://dl.influxdata.com/influxdb/releases/influxdb_{INFLUXDB_VERSION}_amd64.deb'
    run_command(f'wget -qO influxdb_{INFLUXDB_VERSION}_amd64.deb {INFLUXDB_DEB_URL}')
    run_command(f'dpkg -i influxdb_{INFLUXDB_VERSION}_amd64.deb')
    run_command('cp /etc/influxdb/influxdb.conf /etc/influxdb/influxdb.conf.backup')
    run_command('cp /opt/andrisoft/etc/influxdb.conf /etc/influxdb/influxdb.conf')
    run_command('systemctl restart influxdb.service')
    run_command('/opt/andrisoft/bin/install_influxdb')


    print("Instalação do Wanguard concluída com sucesso!")

if __name__ == '__main__':
    main()
