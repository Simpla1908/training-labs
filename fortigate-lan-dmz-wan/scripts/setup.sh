## 📜 `scripts/setup.sh`

```bash
#!/bin/bash
echo "=== Déploiement du lab FortiGate LAN/DMZ/WAN ==="

LAB_PATH="/opt/unetlab/labs/fortigate-lan-dmz-wan"
mkdir -p $LAB_PATH/configs
cp ../configs/*.conf $LAB_PATH/configs/

echo "➡️ Configurations copiées dans $LAB_PATH/configs"
echo "➡️ Importez la topologie dans EVE-NG et démarrez les VMs."
```

---