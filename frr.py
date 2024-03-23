import subprocess
import argparse

def run_command(command):
    try:
        subprocess.run(command, shell=True, check=True)
    except subprocess.CalledProcessError as e:
        print(f"Erro ao executar o comando {command}: {e}")
        raise

def install_and_configure_frr(asn, peer_ip):
    # Instalar pacotes necessários
    run_command("apt install curl apt-transport-https gnupg2 lsb-release tree net-tools -y")
    run_command("curl -s https://deb.frrouting.org/frr/keys.asc | apt-key add -")
    run_command("echo deb https://deb.frrouting.org/frr $(lsb_release -s -c) frr-stable | tee -a /etc/apt/sources.list.d/frr.list")
    run_command("apt update")
    run_command("apt install frr frr-doc frr-pythontools frr-rpki-rtrlib frr-snmp -y")

    # Backup de arquivos de configuração do FRR
    run_command("mkdir -p /etc/frr/backups")
    run_command("cp /etc/frr/daemons /etc/frr/backups/")
    run_command("cp /etc/frr/frr.conf /etc/frr/backups/")
    run_command("cp /etc/frr/vtysh.conf /etc/frr/backups/")
    run_command("cp /etc/frr/support_bundle_commands.conf /etc/frr/backups/")

    # Configurar FRR
    frr_conf = f"""
log syslog informational
no ipv6 forwarding
service integrated-vtysh-config
!
password wanguard
enable password wanguard
!
router bgp {asn}
 no bgp network import-check
 neighbor {peer_ip} remote-as {asn}
 !
 address-family ipv4 unicast
  neighbor {peer_ip} route-map WANGUARD-IN in
  neighbor {peer_ip} route-map WANGUARD-OUT out
 exit-address-family
exit
!
route-map WANGUARD-IN deny 100
exit
!
route-map WANGUARD-OUT permit 10
exit
!
route-map WANGUARD-OUT deny 100
exit
    """
    with open('/etc/frr/frr.conf', 'w') as f:
        f.write(frr_conf)

    # Atualizar arquivo daemons
    daemons_config = """
bgpd=yes
ospfd=no
ospf6d=no
ripd=no
ripngd=no
isisd=no
pimd=no
pim6d=no
ldpd=no
nhrpd=no
eigrpd=no
babeld=no
sharpd=no
pbrd=no
bfdd=no
fabricd=no
vrrpd=no
pathd=no

vtysh_enable=yes
zebra_options="  -A 0.0.0.0 -s 90000000"
mgmtd_options="  -A 127.0.0.1"
bgpd_options="   -A 0.0.0.0"
ospfd_options="  -A 127.0.0.1"
ospf6d_options=" -A ::1"
ripd_options="   -A 127.0.0.1"
ripngd_options=" -A ::1"
isisd_options="  -A 127.0.0.1"
pimd_options="   -A 127.0.0.1"
pim6d_options="  -A ::1"
ldpd_options="   -A 127.0.0.1"
nhrpd_options="  -A 127.0.0.1"
eigrpd_options=" -A 127.0.0.1"
babeld_options=" -A 127.0.0.1"
sharpd_options=" -A 127.0.0.1"
pbrd_options="   -A 127.0.0.1"
staticd_options="-A 127.0.0.1"
bfdd_options="   -A 127.0.0.1"
fabricd_options="-A 127.0.0.1"
vrrpd_options="  -A 127.0.0.1"
pathd_options="  -A 127.0.0.1"
    """
    with open('/etc/frr/daemons', 'w') as f:
        f.write(daemons_config)

    # Reiniciar serviço FRR
    run_command("systemctl restart frr")

# Configuração do argparse para aceitar argumentos de linha de comando
parser = argparse.ArgumentParser(description='Instala e configura o FRR.')
parser.add_argument('asn', type=str, help='Autonomous System Number para configuração do BGP.')
parser.add_argument('peer_ip', type=str, help='Endereço IP do peer BGP.')

# Parse dos argumentos
args = parser.parse_args()

# Chamada da função com argumentos da linha de comando
install_and_configure_frr(args.asn, args.peer_ip)
