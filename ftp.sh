#!/bin/bash

# Script para criar usuário FTP no ProFTPD
apt -y install proftpd

echo "########################################################"
read -p "Digite o username ser criado: " username
echo "########################################################"
read -p "Digite a senha do usuário: " password
echo "########################################################"

# Configurações
ftp_root="/"
user_group="www-data"
proftpd_conf_dir="/etc/proftpd/conf.d"
user_conf_file="$proftpd_conf_dir/$username.conf"

# Criação do usuário sem pasta home
useradd -M -N -s /bin/false -g "$user_group" "$username"
echo -e "$password\n$password" | passwd "$username" > /dev/null  # Redireciona a saída para /dev/null para ocultar a saída padrão

# Criação do arquivo de configuração específico para o usuário
echo -e "\n<Directory $ftp_root>\n  UploadOnCreate on\n  ForceGroup $user_group\n  ForceUser $username\n</Directory>" > "$user_conf_file"

# Reinicia o ProFTPD
systemctl restart proftpd

# Exibe uma mensagem formatada
echo -e "\n#################################################"
echo -e "## Usuário FTP criado com sucesso:"
echo -e "## Usuário: $username"
echo -e "## Diretório FTP: $ftp_root"
echo -e "## Grupo: $user_group"
