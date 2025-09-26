
# Lab : Réseau de base – LAN, VLAN et Routage Inter-VLAN

## 🎯 Objectifs
- Mettre en place une topologie réseau avec des VLANs.
- Configurer un switch Cisco pour les VLANs et le trunking.
- Configurer un routeur Cisco pour le routage inter-VLAN (Router-on-a-stick).
- Vérifier la connectivité entre les différents VLANs.

## 📦 Prérequis
- Un émulateur réseau (EVE-NG, GNS3, Packet Tracer, etc.) avec les images suivantes :
  - Switch Cisco (IOS L2)
  - Routeur Cisco (IOS L3)
  - Windows Server 2022
  - Windows 10
  - Un PC virtuel générique (VPC)

## 📌 Topologie
![Topology](topology.png)

## 🖧 Plan IP

| VLAN ID | Zone       | Réseau IP      | Passerelle (Router Sub-interface) |
|---------|------------|----------------|---------------------------------|
| 10      | IT         | 192.168.10.0/24| 192.168.10.1                    |
| 20      | COMMERCIAL | 192.168.20.0/24| 192.168.20.1                    |
| 30      | RH         | 192.168.30.0/24| 192.168.30.1                    |

### Adresses IP des équipements

| Appareil       | Interface | VLAN | Adresse IP    | Passerelle      |
|----------------|-----------|------|---------------|-----------------|
| WinServer2022  | e0        | 10   | 192.168.10.10 | 192.168.10.1    |
| Windows10      | e0        | 20   | 192.168.20.10 | 192.168.20.1    |
| VPC            | eth0      | 30   | 192.168.30.10 | 192.168.30.1    |
| Switch_Cisco   | e0/0      | 10   | N/A           | N/A             |
| Switch_Cisco   | e0/1      | 20   | N/A           | N/A             |
| Switch_Cisco   | e0/2      | 30   | N/A           | N/A             |
| Switch_Cisco   | e0/3      | Trunk| N/A           | N/A             |
| Router_Cisco   | fa0/0.10  | 10   | 192.168.10.1  | N/A             |
| Router_Cisco   | fa0/0.20  | 20   | 192.168.20.1  | N/A             |
| Router_Cisco   | fa0/0.30  | 30   | 192.168.30.1  | N/A             |

## 🔧 Instructions de Configuration (Exemples)

### 1. Configuration du Switch Cisco

```cisco
enable
configure terminal
vlan 10
 name IT
vlan 20
 name COMMERCIAL
vlan 30
 name RH
!
interface Ethernet0/0
 switchport mode access
 switchport access vlan 10
!
interface Ethernet0/1
 switchport mode access
 switchport access vlan 20
!
interface Ethernet0/2
 switchport mode access
 switchport access vlan 30
!
interface Ethernet0/3
 switchport mode trunk
 switchport trunk encapsulation dot1q
!
end
copy running-config startup-config
```

### 2. Configuration du Routeur Cisco (Routage Inter-VLAN)

```cisco
enable
configure terminal
interface FastEthernet0/0
 no ip address
 no shutdown
!
interface FastEthernet0/0.10
 encapsulation dot1Q 10
 ip address 192.168.10.1 255.255.255.0
!
interface FastEthernet0/0.20
 encapsulation dot1Q 20
 ip address 192.168.20.1 255.255.255.0
!
interface FastEthernet0/0.30
 encapsulation dot1Q 30
 ip address 192.168.30.1 255.255.255.0
!
end
copy running-config startup-config
```

### 3. Configuration des Clients (Exemples)

- **WinServer2022 (VLAN 10):**
  - IP Address: `192.168.10.10`
  - Subnet Mask: `255.255.255.0`
  - Default Gateway: `192.168.10.1`

- **Windows10 (VLAN 20):**
  - IP Address: `192.168.20.10`
  - Subnet Mask: `255.255.255.0`
  - Default Gateway: `192.168.20.1`

- **VPC (VLAN 30):**
  - IP Address: `192.168.30.10`
  - Subnet Mask: `255.255.255.0`
  - Default Gateway: `192.168.30.1`
  
  (On a VPC, you might use commands like `ip 192.168.30.10 255.255.255.0 192.168.30.1`)

## ✅ Résultats attendus

- Les machines au sein du même VLAN (ex: WinServer2022 et tout autre appareil dans VLAN 10) peuvent communiquer entre elles.
- Les machines de différents VLANs (ex: WinServer2022 en VLAN 10 et Windows10 en VLAN 20) peuvent communiquer via le routeur.
- Les pings entre toutes les machines devraient fonctionner après une configuration correcte.

## 💡 Explication du LAN, VLAN et Routage Inter-VLAN

### LAN (Local Area Network)
Un LAN est un réseau informatique qui connecte des appareils au sein d'une zone géographique limitée, comme une maison, un bureau ou un campus. Les LANs sont caractérisés par des débits de données élevés et sont généralement basés sur la technologie Ethernet. Tous les appareils d'un même LAN peuvent communiquer directement entre eux.

### VLAN (Virtual Local Area Network)
Un VLAN est une méthode de segmentation logique d'un réseau local physique en plusieurs domaines de diffusion distincts. Cela signifie que des appareils connectés au même commutateur physique, ou à des commutateurs différents, peuvent être regroupés dans le même VLAN et communiquer comme s'ils étaient sur le même segment de réseau, même s'ils ne sont pas physiquement connectés au même port ou au même commutateur. Les VLANs améliorent la sécurité, simplifient l'administration du réseau et optimisent les performances en réduisant la taille des domaines de diffusion.

- **Segmentation Logique**: Les VLANs permettent de diviser un réseau physique en plusieurs réseaux logiques.
- **Isolation**: Le trafic d'un VLAN est isolé du trafic des autres VLANs, augmentant ainsi la sécurité.
- **Flexibilité**: Les utilisateurs peuvent être déplacés physiquement sans avoir à reconfigurer le réseau câblé, car leur appartenance au VLAN est logique.
- **Amélioration des performances**: Réduit la taille des domaines de diffusion, ce qui diminue le trafic inutile et améliore les performances du réseau.

### Routage Inter-VLAN (Router-on-a-stick)
Le routage inter-VLAN est le processus de communication entre différents VLANs. Puisque les VLANs sont des domaines de diffusion séparés, un routeur ou un commutateur de couche 3 est nécessaire pour permettre aux appareils de différents VLANs de communiquer entre eux. Le concept de "Router-on-a-stick" est une méthode courante pour réaliser le routage inter-VLAN, en utilisant une seule interface physique sur un routeur pour acheminer le trafic entre plusieurs VLANs.

#### Comment fonctionne le Router-on-a-stick ?
1.  **Interface Trunk sur le Switch**: Le port du commutateur connecté au routeur est configuré comme un port trunk, capable de transporter le trafic de tous les VLANs configurés. Il utilise le protocole IEEE 802.1Q pour marquer les trames Ethernet avec leur ID de VLAN respectif.
2.  **Sous-interfaces sur le Routeur**: Le routeur est configuré avec une sous-interface logique pour chaque VLAN. Chaque sous-interface est associée à un VLAN spécifique et configurée avec une adresse IP qui agit comme passerelle par défaut pour ce VLAN.
3.  **Encapsulation**: Le routeur utilise l'encapsulation 802.1Q sur chaque sous-interface pour identifier et séparer le trafic des différents VLANs. Lorsque le trafic arrive du commutateur sur l'interface physique trunkée, le routeur examine l'étiquette 802.1Q pour déterminer à quel VLAN il appartient. Il décapcule ensuite la trame, prend une décision de routage basée sur l'adresse IP de destination, puis encapsule à nouveau la trame avec l'étiquette du VLAN de destination avant de la renvoyer au commutateur (si la destination est un autre VLAN connecté au même routeur) ou de l'acheminer vers une autre interface (si la destination est hors du routeur).

Le Router-on-a-stick est une solution économique et efficace pour le routage inter-VLAN, particulièrement adaptée aux petits et moyens réseaux où un commutateur de couche 3 dédié ne serait pas justifié.

## ✍️ Auteur : **Landu Tamba Simplice**
