
# Lab : VPN IPsec Site-à-Site FortiGate

## 🎯 Objectifs

* Connecter deux réseaux LAN distants via FortiGate avec un VPN IPsec site-à-site.
* Vérifier la connectivité entre les réseaux locaux.
* Comprendre la configuration de base VPN sur FortiGate.

---

## 📦 Prérequis

* EVE-NG ou GNS3 avec :

  * FortiGate (FortiOS)
  * Windows 10 (PC1 → PC4)
  * Switch L2 (IOS)

---

## 🖧 Topologie

![Topology](topology.png)

---

## 📚 Théorie IPsec (rappel)

### Pourquoi IPsec ?
- Confidentialité: chiffrement du trafic (ESP)
- Intégrité et authenticité: HMAC/AEAD empêche les altérations/usurpations
- Anti-rejeu: numéros de séquence bloquent la relecture de paquets

### Couches et rôles
- IKE (v2 recommandé): négociation/authentification des pairs et des paramètres
- Phase 1 (IKE SA): canal sécurisé de contrôle pour piloter IPsec
- Phase 2 (Child SA/IPsec SA): paramètres de chiffrement pour le trafic utilisateur
- Protocoles: ESP (courant, chiffré), AH (authentifié sans chiffrement, rare)

### Modes et encapsulation
- Mode Tunnel: encapsule l’IP complet → passerelle à passerelle (cas du lab)
- Mode Transport: encapsule la charge utile → hôte à hôte
- NAT-T (UDP/4500): encapsule ESP dans UDP si NAT détecté (sinon IKE UDP/500 + ESP)

### Types de VPN (panorama)
- Site-à-site L3 (IPsec): interconnecte des réseaux LAN via passerelles. Standard en entreprise.
- Accès distant IPsec (IKEv2/EAP): client natif OS, haute sécurité, bon pour postes gérés.
- Accès distant SSL VPN: via navigateur/agent, traverse mieux les pare-feu, idéal BYOD.
- Niveau 2 vs Niveau 3: L2 étend un domaine de broadcast; L3 route des sous-réseaux (préféré et scalable).
- Full tunnel vs Split tunnel: tout le trafic via VPN vs seulement sous-réseaux d’entreprise.
- Overlays courants: VTI/route-based IPsec, GRE-over-IPsec, DMVPN, SD-WAN.
- Quand choisir: SSL pour mobilité/NAT strict; IKEv2 pour clients managés; site-à-site IPsec pour interco LAN.

### Algorithmes typiques
- Chiffrement: AES-128/192/256 (CBC) ou AEAD (AES-GCM)
- Intégrité: SHA1/SHA256/SHA384/SHA512 (HMAC)
- Échange de clés: Diffie-Hellman groupes 14+ (2048 bits) ou ECC (19/20/21)

### Paramètres à aligner entre pairs
- Phase 1: version IKE, DH, chiffrement, intégrité/PRF, auth (PSK/cert), lifetime
- Phase 2: chiffrement, intégrité (ou AEAD), PFS (DH), sous-réseaux, lifetime

### Sélecteurs de trafic (Proxy-ID)
- Définissent LAN source ↔ LAN destination traversant le tunnel
- Doivent correspondre sur les deux FortiGate (ex: 192.168.1.0/24 ↔ 192.168.2.0/24)

### Routage et politiques
- Route-based (interfaces virtuelles IPsec) vs policy-based (héritage). Ce lab utilise route-based.
- Règles firewall: autoriser LAN ↔ interface IPsec, NAT désactivé pour le trafic inter-sites.

### Résilience et MTU
- DPD: détecte pair injoignable et relance
- Rekey: renouvèle les SA avant expiration
- MSS/MTU: overhead IPsec peut nécessiter un ajustement MSS pour éviter fragmentation

### Bonnes pratiques
- Préférer IKEv2 + AES256-GCM + PFS (DH fort)
- PSK robuste ou certificats, rotation périodique
- Sélecteurs minimalistes (moindre privilège), lifetimes cohérentes (ex: P1 28800s, P2 3600s)
- Sur WAN avec NAT: ouvrir UDP/500 et UDP/4500, activer NAT-T

### Dépannage rapide
- Tester connectivité WAN (10.0.0.1 ↔ 10.0.0.2)
- Vérifier propositions P1/P2 (algos/groupes DH) et correspondance des Proxy-ID
- Consulter états SA/journaux IKE/IPsec
- Tester flux entre hôtes autorisés (ping/trace, puis TCP)

---

## 🖥 Plan IP

| Réseau | Plage d'adresses | Passerelle  |
| ------ | ---------------- | ----------- |
| LAN1   | 192.168.1.0/24   | 192.168.1.1 |
| LAN2   | 192.168.2.0/24   | 192.168.2.1 |
| WAN    | 10.0.0.0/24      | N/A         |

| Appareil   | Interface | IP           | Passerelle  |
| ---------- | --------- | ------------ | ----------- |
| PC1        | e0        | 192.168.1.10 | 192.168.1.1 |
| PC2        | e0        | 192.168.2.10 | 192.168.2.1 |
| PC3        | e0        | 192.168.2.11 | 192.168.2.1 |
| PC4        | e0        | 192.168.1.11 | 192.168.1.1 |
| FortiGate1 | port2     | 192.168.1.1  | N/A         |
| FortiGate1 | port3     | 10.0.0.1     | N/A         |
| FortiGate2 | port2     | 192.168.2.1  | N/A         |
| FortiGate2 | port3     | 10.0.0.2     | N/A         |

---

## 🔧 Configuration FortiGate

### 1️⃣ Configuration interfaces et routes

#### FortiGate1

```fortios
config system interface
  edit "port2"
    set mode static
    set ip 192.168.1.1/24
    set allowaccess ping https ssh
  next
  edit "port3"
    set mode static
    set ip 10.0.0.1/24
    set allowaccess ping https ssh
  next
end

config router static
  edit 1
    set dst 192.168.2.0/24
    set gateway 10.0.0.2
    set device "port3"
  next
end
```

#### FortiGate2

```fortios
config system interface
  edit "port2"
    set mode static
    set ip 192.168.2.1/24
    set allowaccess ping https ssh
  next
  edit "port3"
    set mode static
    set ip 10.0.0.2/24
    set allowaccess ping https ssh
  next
end

config router static
  edit 1
    set dst 192.168.1.0/24
    set gateway 10.0.0.1
    set device "port3"
  next
end
```

---

### 2️⃣ Politiques de firewall simplifiées

* Autoriser trafic LAN ↔ WAN et VPN (IKE/ESP)

#### FortiGate1

```fortios
config firewall policy
  edit 1
    set name "LAN1_to_WAN"
    set srcintf "port2"
    set dstintf "port3"
    set action accept
    set schedule "always"
    set service "ALL"
    set nat enable
  next
  edit 2
    set name "WAN_to_LAN1"
    set srcintf "port3"
    set dstintf "port2"
    set action accept
    set schedule "always"
    set service "ALL"
  next
end
```

#### FortiGate2

```fortios
config firewall policy
  edit 1
    set name "LAN2_to_WAN"
    set srcintf "port2"
    set dstintf "port3"
    set action accept
    set schedule "always"
    set service "ALL"
    set nat enable
  next
  edit 2
    set name "WAN_to_LAN2"
    set srcintf "port3"
    set dstintf "port2"
    set action accept
    set schedule "always"
    set service "ALL"
  next
end
```

---

### 3️⃣ Configuration VPN IPsec site-à-site

#### FortiGate1

```fortios
config vpn ipsec phase1-interface
  edit "VPN-FG1-FG2"
    set type static
    set interface "port3"
    set remote-gw 10.0.0.2
    set psksecret "MonSecret123"
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
```

#### FortiGate2

```fortios
config vpn ipsec phase1-interface
  edit "VPN-FG2-FG1"
    set type static
    set interface "port3"
    set remote-gw 10.0.0.1
    set psksecret "MonSecret123"
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
```

---

### 4️⃣ Politiques VPN (LAN ↔ Tunnel)

#### FortiGate1

```fortios
config firewall policy
  edit 3
    set name "LAN1_to_LAN2_VPN"
    set srcintf "port2"
    set dstintf "VPN-FG1-FG2"
    set action accept
    set schedule "always"
    set service "ALL"
    set nat disable
  next
  edit 4
    set name "LAN2_to_LAN1_VPN"
    set srcintf "VPN-FG1-FG2"
    set dstintf "port2"
    set action accept
    set schedule "always"
    set service "ALL"
  next
end
```

#### FortiGate2

```fortios
config firewall policy
  edit 3
    set name "LAN2_to_LAN1_VPN"
    set srcintf "port2"
    set dstintf "VPN-FG2-FG1"
    set action accept
    set schedule "always"
    set service "ALL"
    set nat disable
  next
  edit 4
    set name "LAN1_to_LAN2_VPN"
    set srcintf "VPN-FG2-FG1"
    set dstintf "port2"
    set action accept
    set schedule "always"
    set service "ALL"
  next
end
```

---

## ✅ Vérification

* Tunnel VPN actif : `diagnose vpn tunnel list`
* Test ping entre PC1 ↔ PC2 / PC3 ↔ PC4.

---

