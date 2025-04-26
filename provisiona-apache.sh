#!/bin/bash

# ----------------------------------------------------------------------------
# Script: provisiona-apache.sh
# Descrição: Provisiona automaticamente um servidor web Apache com configurações básicas
# Versão: 2.0
# Autor: Seu Nome
# ----------------------------------------------------------------------------

# Verifica se o script está sendo executado como root
if [ "$(id -u)" != "0" ]; then
    echo -e "\033[1;31mERRO: Este script deve ser executado como root!\033[0m" 1>&2
    exit 1
fi

# Atualiza repositórios
echo -e "\033[1;36mAtualizando repositórios...\033[0m"
apt-get update -qq

# Instala o Apache
echo -e "\033[1;36mInstalando Apache...\033[0m"
apt-get install apache2 -y

# Habilita módulos essenciais
echo -e "\033[1;36mConfigurando módulos...\033[0m"
a2enmod rewrite
a2enmod headers

# Cria diretório padrão para o site
echo -e "\033[1;36mCriando estrutura de diretórios...\033[0m"
mkdir -p /var/www/meusite.com/public_html
chown -R www-data:www-data /var/www/meusite.com/public_html
chmod -R 755 /var/www

# Cria página HTML de teste
echo -e "\033[1;36mCriando página de teste...\033[0m"
cat > /var/www/meusite.com/public_html/index.html <<EOF
<!DOCTYPE html>
<html>
<head>
    <title>Site Provisionado Automaticamente</title>
    <style>
        body { font-family: Arial, sans-serif; text-align: center; margin-top: 50px; }
        h1 { color: #2e8b57; }
    </style>
</head>
<body>
    <h1>Servidor Apache Funcionando!</h1>
    <p>Este servidor foi provisionado automaticamente.</p>
</body>
</html>
EOF

# Configura virtual host
echo -e "\033[1;36mConfigurando virtual host...\033[0m"
cat > /etc/apache2/sites-available/meusite.com.conf <<EOF
<VirtualHost *:80>
    ServerAdmin admin@meusite.com
    ServerName meusite.com
    ServerAlias www.meusite.com
    DocumentRoot /var/www/meusite.com/public_html
    ErrorLog \${APACHE_LOG_DIR}/error.log
    CustomLog \${APACHE_LOG_DIR}/access.log combined
    <Directory /var/www/meusite.com/public_html>
        Options -Indexes +FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>
EOF

# Habilita o site e desabilita o default
echo -e "\033[1;36mAtivando configurações...\033[0m"
a2dissite 000-default.conf
a2ensite meusite.com.conf

# Configurações de segurança básica
echo -e "\033[1;36mAplicando configurações de segurança...\033[0m"
echo "ServerTokens Prod" >> /etc/apache2/conf-available/security.conf
echo "ServerSignature Off" >> /etc/apache2/conf-available/security.conf

# Reinicia o Apache
echo -e "\033[1;36mReiniciando Apache...\033[0m"
systemctl restart apache2

# Habilita o Apache para iniciar com o sistema
systemctl enable apache2

# Instala firewall (ufw) e abre portas
echo -e "\033[1;36mConfigurando firewall...\033[0m"
apt-get install ufw -y
ufw allow 80/tcp
ufw allow 443/tcp
ufw --force enable

# Mostra mensagem final
IP_SERVIDOR=$(hostname -I | awk '{print $1}')
echo -e "\033[1;32m\nProvisionamento concluído com sucesso!\033[0m"
echo -e "\033[1;33mAcesse o servidor em:\033[0m"
echo -e "Local: http://localhost"
echo -e "Rede: http://$IP_SERVIDOR"
echo -e "\033[1;33m\nArquivos do site estão em: /var/www/meusite.com/public_html\033[0m"
