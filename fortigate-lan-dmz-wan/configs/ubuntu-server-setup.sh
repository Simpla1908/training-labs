## 📜 `configs/ubuntu-server-setup.sh`

```bash
#!/bin/bash
# Installation Apache, MariaDB et Zabbix sur Ubuntu

apt update && apt upgrade -y
apt install -y apache2 mariadb-server mariadb-client php php-mysql \
   zabbix-server-mysql zabbix-frontend-php zabbix-apache-conf

systemctl enable apache2 mariadb zabbix-server zabbix-agent
systemctl start apache2 mariadb zabbix-server zabbix-agent

echo "✅ Apache, MariaDB et Zabbix installés."
```

---