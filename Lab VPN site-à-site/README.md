
# Lab : VPN Site-à-Site

## 🎯 Objectifs
- Mettre en place une topologie réseau avec deux FortiGate.
- Configurer un VPN IPsec site-à-site entre deux FortiGate.
- Assurer la connectivité entre les réseaux locaux (LAN) via le tunnel VPN.
- Vérifier le fonctionnement du tunnel VPN.

## 📦 Prérequis
- Un émulateur réseau (EVE-NG, GNS3 ) avec les images suivantes :
  - FortiGate (FortiOS)
  - Windows 10 (pour PC1, PC2, PC3)
  - Switch Ethernet (IOS L2)

## 📌 Topologie
![Topology](topology.png)

## 🖧 Plan IP

| Réseau | Plage d'adresses IP | Passerelle |
|---|---|---|
| LAN1 | 192.168.1.0/24 | 192.168.1.1 |
| LAN2 | 192.168.2.0/24 | 192.168.2.1 |
| WAN | 10.0.0.0/24 | N/A |

### Adresses IP des équipements

| Appareil | Interface | Zone/Réseau   | Adresse IP    | Passerelle    |
|----------|-----------|---------------|---------------|---------------|
| PC1      | e0        | LAN1          | 192.168.1.10  | 192.168.1.1   |
| PC2      | e0        | LAN2          | 192.168.2.10  | 192.168.2.1   |
| PC3      | eth0      | LAN2          | 192.168.2.11  | 192.168.2.1   |
| FortiGate1 | port1     | LAN1          | 192.168.1.1   | N/A           |
| FortiGate1 | port2     | WAN           | 10.0.0.1      | N/A           |
| FortiGate2 | port1     | LAN2          | 192.168.2.1   | N/A           |
| FortiGate2 | port2     | WAN           | 10.0.0.2      | N/A           |

## 🔧 Instructions de Configuration (Exemples)

### 1. Configuration initiale des FortiGate

#### FortiGate1
```fortios
config system interface
  edit "port1"
    set mode static
    set ip 192.168.1.1/24
    set allowaccess ping https ssh http telnet
    set description "Interface LAN1"
  next
  edit "port2"
    set mode static
    set ip 10.0.0.1/24
    set allowaccess ping https ssh http telnet
    set description "Interface WAN vers FortiGate2"
  next
end

config router static
  edit 1
    set dst 192.168.2.0/24
    set gateway 10.0.0.2
    set device "port2"
  next
end

config firewall policy
  edit 1
    set name "LAN1_to_WAN"
    set srcintf "port1"
    set dstintf "port2"
    set srcaddr "all"
    set dstaddr "all"
    set action accept
    set schedule "always"
    set service "ALL"
    set nat enable
  next
  edit 2
    set name "WAN_to_LAN1"
    set srcintf "port2"
    set dstintf "port1"
    set srcaddr "all"
    set dstaddr "all"
    set action accept
    set schedule "always"
    set service "ALL"
  next
end
```

#### FortiGate2
```fortios
config system interface
  edit "port1"
    set mode static
    set ip 192.168.2.1/24
    set allowaccess ping https ssh http telnet
    set description "Interface LAN2"
  next
  edit "port2"
    set mode static
    set ip 10.0.0.2/24
    set allowaccess ping https ssh http telnet
    set description "Interface WAN vers FortiGate1"
  next
end

config router static
  edit 1
    set dst 192.168.1.0/24
    set gateway 10.0.0.1
    set device "port2"
  next
end

config firewall policy
  edit 1
    set name "LAN2_to_WAN"
    set srcintf "port1"
    set dstintf "port2"
    set srcaddr "all"
    set dstaddr "all"
    set action accept
    set schedule "always"
    set service "ALL"
    set nat enable
  next
  edit 2
    set name "WAN_to_LAN2"
    set srcintf "port2"
    set dstintf "port1"
    set srcaddr "all"
    set dstaddr "all"
    set action accept
    set schedule "always"
    set service "ALL"
  next
end
```

### 2. Configuration du VPN IPsec Site-à-Site

#### FortiGate1
```fortios
config vpn ipsec phase1-interface
  edit "VPN-FG1-FG2"
    set type static
    set interface "port2"
    set remote-gw 10.0.0.2
    set psksecret your_preshared_key
    set proposal aes256-sha256 aes192-sha256 aes128-sha256
    set dpd-retrycount 3
    set dpd-retryinterval 5
  next
end

config vpn ipsec phase2-interface
  edit "VPN-FG1-FG2_Ph2"
    set phase1name "VPN-FG1-FG2"
    set proposal aes256-sha256 aes192-sha256 aes128-sha256
    set pfs enable
    set src-subnet 192.168.1.0/24
    set dst-subnet 192.168.2.0/24
  next
end

config firewall policy
  edit 3
    set name "LAN1_to_LAN2_VPN"
    set srcintf "port1"
    set dstintf "VPN-FG1-FG2"
    set srcaddr "all"
    set dstaddr "all"
    set action accept
    set schedule "always"
    set service "ALL"
    set nat disable
  next
  edit 4
    set name "LAN2_to_LAN1_VPN"
    set srcintf "VPN-FG1-FG2"
    set dstintf "port1"
    set srcaddr "all"
    set dstaddr "all"
    set action accept
    set schedule "always"
    set service "ALL"
  next
end
```

#### FortiGate2
```fortios
config vpn ipsec phase1-interface
  edit "VPN-FG2-FG1"
    set type static
    set interface "port2"
    set remote-gw 10.0.0.1
    set psksecret your_preshared_key
    set proposal aes256-sha256 aes192-sha256 aes128-sha256
    set dpd-retrycount 3
    set dpd-retryinterval 5
  next
end

config vpn ipsec phase2-interface
  edit "VPN-FG2-FG1_Ph2"
    set phase1name "VPN-FG2-FG1"
    set proposal aes256-sha256 aes192-sha256 aes128-sha256
    set pfs enable
    set src-subnet 192.168.2.0/24
    set dst-subnet 192.168.1.0/24
  next
end

config firewall policy
  edit 3
    set name "LAN2_to_LAN1_VPN"
    set srcintf "port1"
    set dstintf "VPN-FG2-FG1"
    set srcaddr "all"
    set dstaddr "all"
    set action accept
    set schedule "always"
    set service "ALL"
    set nat disable
  next
  edit 4
    set name "LAN1_to_LAN2_VPN"
    set srcintf "VPN-FG2-FG1"
    set dstintf "port1"
    set srcaddr "all"
    set dstaddr "all"
    set action accept
    set schedule "always"
    set service "ALL"
  next
end
```

### 3. Configuration des Clients (Exemples)

- **PC1 (LAN1):**
  - IP Address: `192.168.1.10`
  - Subnet Mask: `255.255.255.0`
  - Default Gateway: `192.168.1.1`

- **PC2 (LAN2):**
  - IP Address: `192.168.2.10`
  - Subnet Mask: `255.255.255.0`
  - Default Gateway: `192.168.2.1`

- **PC3 (LAN2):**
  - IP Address: `192.168.2.11`
  - Subnet Mask: `255.255.255.0`
  - Default Gateway: `192.168.2.1`

## ✅ Résultats attendus

- Le tunnel VPN IPsec entre FortiGate1 et FortiGate2 doit être établi et actif.
- Les machines PC1 (LAN1), PC2 (LAN2) et PC3 (LAN2) peuvent communiquer entre elles via le tunnel VPN (ex: ping de PC1 vers PC2 et PC3, et vice-versa).
- Vérifier l'état du VPN sur les FortiGate (commande `diagnose vpn tunnel list` ou via l'interface graphique).

## 💡 Explication du VPN Site-à-Site

Un VPN (Virtual Private Network) Site-à-Site est une connexion sécurisée établie entre deux réseaux locaux distincts, généralement situés à des emplacements géographiques différents. Contrairement à un VPN client-à-site qui permet à un utilisateur individuel d'accéder à un réseau distant, le VPN site-à-site connecte des réseaux entiers, permettant aux hôtes de chaque réseau de communiquer de manière sécurisée comme s'ils faisaient partie du même réseau privé.

### Comment ça marche ?

Le processus de mise en place d'un VPN IPsec site-à-site implique généralement deux phases :

1.  **Phase 1 (IKE Phase 1 - Internet Key Exchange)** :
    -   L'objectif principal de cette phase est d'établir un canal de communication sécurisé (SA - Security Association) entre les deux passerelles VPN (ici, les FortiGate). Ce canal est utilisé pour échanger en toute sécurité les clés qui seront utilisées pour chiffrer les données dans la Phase 2.
    -   Elle implique l'authentification des passerelles (généralement via une clé pré-partagée - PSK ou des certificats) et la négociation des algorithmes de chiffrement, d'authentification et de hachage (par exemple, AES256, SHA256) pour sécuriser le canal IKE lui-même.
    -   Un groupe Diffie-Hellman est utilisé pour générer une clé secrète partagée sans l'échanger sur le réseau, assurant ainsi la *Perfect Forward Secrecy* (PFS), ce qui signifie qu'une compromission de la clé à long terme n'affectera pas la sécurité des sessions passées.

2.  **Phase 2 (IKE Phase 2 - IPsec Security Association)** :
    -   Une fois le canal sécurisé de la Phase 1 établi, la Phase 2 est responsable de la négociation des paramètres de sécurité pour le tunnel de données réel.
    -   Elle définit comment le trafic IP sera protégé, y compris les protocoles (ESP - Encapsulating Security Payload ou AH - Authentication Header), les algorithmes de chiffrement et d'authentification pour les données utilisateur, et les sous-réseaux qui seront inclus dans le tunnel VPN.
    -   Un nouveau groupe Diffie-Hellman peut être utilisé pour garantir la PFS pour les clés de la Phase 2 également.

### Composants Clés :

-   **Passerelles VPN** : Les dispositifs (comme les FortiGate) qui initient, terminent et gèrent les tunnels VPN.
-   **Clé Pré-partagée (PSK)** : Un secret partagé entre les deux passerelles pour l'authentification en Phase 1.
-   **Politiques de pare-feu** : Des règles sont nécessaires sur chaque FortiGate pour autoriser le trafic à travers le tunnel VPN et pour permettre l'établissement du tunnel lui-même (UDP ports 500 et 4500).
-   **Routes statiques ou dynamiques** : Pour que les FortiGate sachent comment acheminer le trafic destiné au réseau distant via le tunnel VPN.

En résumé, un VPN site-à-site fournit un moyen robuste et sécurisé de connecter des bureaux distants ou des centres de données, en protégeant les données en transit contre l'interception et la falsification.

## ✍️ Auteur : **Landu Tamba Simplice**
