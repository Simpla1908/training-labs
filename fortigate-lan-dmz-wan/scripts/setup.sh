#!/bin/bash
# ==========================================================
# 🚀 Script d’installation du lab : fortigate-lan-dmz-wan
# Auteur : Landu Tamba Simplice
# ==========================================================

LAB_NAME="fortigate-lan-dmz-wan"
LAB_PATH="/opt/unetlab/labs/$LAB_NAME"

echo "=== Déploiement du lab : $LAB_NAME ==="

# 1. Création du dossier du lab dans EVE-NG
if [ ! -d "$LAB_PATH" ]; then
  echo "📂 Création du dossier $LAB_PATH ..."
  mkdir -p "$LAB_PATH"
else
  echo "⚠️  Le dossier $LAB_PATH existe déjà. Les fichiers seront écrasés."
fi

# 2. Copie du fichier de topologie .unl
if [ -f "../topology.unl" ]; then
  echo "📑 Copie du fichier topology.unl ..."
  cp ../topology.unl "$LAB_PATH/$LAB_NAME.unl"
else
  echo "❌ Fichier topology.unl introuvable dans ../"
  exit 1
fi

# 3. Copie des configurations
if [ -d "../configs" ]; then
  echo "🔧 Copie des fichiers de configuration ..."
  mkdir -p "$LAB_PATH/configs"
  cp -r ../configs/* "$LAB_PATH/configs/"
else
  echo "⚠️  Aucun dossier configs/ trouvé. Étape ignorée."
fi

# 4. Copie de l’image de topologie (optionnel)
if [ -f "../topology.png" ]; then
  echo "🖼️  Copie de l’image topology.png ..."
  cp ../topology.png "$LAB_PATH/"
fi

# 5. Fix des permissions (obligatoire pour EVE-NG)
echo "🔒 Application des permissions EVE-NG ..."
/opt/unetlab/wrappers/unl_wrapper -a fixpermissions

echo "✅ Installation terminée."
echo "➡️ Connectez-vous à l’UI d’EVE-NG et ouvrez : $LAB_NAME"
