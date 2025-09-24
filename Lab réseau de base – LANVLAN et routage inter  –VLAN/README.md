
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

## ✍️ Auteur : **Landu Tamba Simplice**
