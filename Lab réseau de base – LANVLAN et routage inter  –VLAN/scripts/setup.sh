#!/bin/bash
# ==========================================================
# 🚀 Script d’installation du lab : fortigate-lan-dmz-wan
# Auteur : Landu Tamba Simplice
# ==========================================================

LAB_NAME="Lab réseau de base – LANVLAN et routage inter –VLAN"
LAB_PATH="/opt/unetlab/labs/$LAB_NAME"

# --- Couleurs ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# --- Fonctions ---
cleanup() {
  echo -e "${YELLOW}🗑️ Suppression du lab existant : ${LAB_PATH}${NC} ..."
  rm -rf "$LAB_PATH"
  echo -e "${GREEN}✅ Nettoyage terminé.${NC}"
  /opt/unetlab/wrappers/unl_wrapper -a fixpermissions
  exit 0
}

# ==========================================================

# Détecter l'option --cleanup
if [[ "$1" == "--cleanup" ]]; then
  cleanup
fi

echo -e "\n${BLUE}=== Déploiement du lab : ${LAB_NAME} ===${NC}"

# 1. Création du dossier du lab dans EVE-NG
if [ ! -d "$LAB_PATH" ]; then
  echo -e "${GREEN}📂 Création du dossier ${LAB_PATH} ...${NC}"
  mkdir -p "$LAB_PATH"
else
  read -p "${YELLOW}⚠️ Le dossier '$LAB_PATH' existe déjà. Voulez-vous le supprimer et continuer ? (oui/non) ${NC}" -n 4 -r
  echo
  if [[ $REPLY =~ ^[oO][uU][iI]$ ]]
  then
    echo -e "${YELLOW}🗑️ Suppression du dossier existant...${NC}"
    rm -rf "$LAB_PATH"
    mkdir -p "$LAB_PATH"
  else
    echo -e "${RED}Opération annulée.${NC}"
    exit 0
  fi
fi

# 2. Copie du fichier de topologie .unl
if [ -f "../topology.unl" ]; then
  echo -e "${GREEN}📑 Copie du fichier topology.unl ...${NC}"
  cp ../topology.unl "$LAB_PATH/$LAB_NAME.unl"
else
  echo -e "${RED}❌ Erreur: Fichier topology.unl introuvable dans ../. Le déploiement ne peut pas continuer.${NC}" >&2
  exit 1
fi

# 3. Copie des configurations
if [ -d "../configs" ]; then
  echo -e "${GREEN}🔧 Copie des fichiers de configuration ...${NC}"
  mkdir -p "$LAB_PATH/configs"
  cp -r ../configs/* "$LAB_PATH/configs/"
else
  echo -e "${RED}❌ Erreur: Dossier configs/ introuvable. Le déploiement ne peut pas continuer.${NC}" >&2
  exit 1
fi

# 4. Copie de l’image de topologie (optionnel)
if [ -f "../topology.png" ]; then
  echo -e "${GREEN}🖼️  Copie de l’image topology.png ...${NC}"
  cp ../topology.png "$LAB_PATH/"
fi

# 5. Fix des permissions (obligatoire pour EVE-NG)
echo -e "${BLUE}🔒 Application des permissions EVE-NG ...${NC}"
/opt/unetlab/wrappers/unl_wrapper -a fixpermissions

echo -e "${GREEN}✅ Installation terminée.${NC}"
echo -e "${BLUE}➡️ Connectez-vous à l’UI d’EVE-NG et ouvrez : ${LAB_NAME}${NC}"
