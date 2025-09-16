## 📜 `configs/WIN-SERVER22-notes.md`

```markdown
# Windows Server 2022 (192.168.10.10)

## Rôles à installer
- Active Directory Domain Services
- DNS
- DHCP

## Étapes
1. Promouvoir le serveur en contrôleur de domaine
   - Domaine : `entreprise.local`
2. Configurer DNS
   - Résolution interne pour `entreprise.local`
3. Configurer DHCP
   - Scope : `192.168.10.50 - 192.168.10.200`
   - Passerelle : `192.168.10.1`
```

---