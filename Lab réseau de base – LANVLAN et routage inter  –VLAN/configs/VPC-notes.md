# Configuration de VPC (VLAN 30)

## Paramètres IP
- **Adresse IP:** `192.168.30.10`
- **Masque de sous-réseau:** `255.255.255.0`
- **Passerelle par défaut:** `192.168.30.1`

## Instructions
1. Entrez en mode de configuration du VPC.
2. Utilisez la commande suivante pour configurer l'adresse IP, le masque de sous-réseau et la passerelle par défaut :
   ```
   ip 192.168.30.10 255.255.255.0 192.168.30.1
   ```
3. Vérifiez la connectivité en pingant la passerelle par défaut (`192.168.30.1`) et d'autres périphériques du VLAN 30.
