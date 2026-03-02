#!/bin/bash
set -e

# Vérifier que IMAGE_TAG existe
: "${IMAGE_TAG:?IMAGE_TAG is not set}"

# Supprimer le "v" si présent
NEW_VERSION=$(echo "$IMAGE_TAG" | sed 's/^v//')

echo "Persisting version: $NEW_VERSION"

# Mettre à jour le fichier VERSION
echo "$NEW_VERSION" > VERSION

# Config Git (important pour CI)
git config user.email "ci@jenkins.com"
git config user.name "Jenkins CI"

# Ajouter et commit seulement si changement
git add VERSION
git commit -m "Bump version to v$NEW_VERSION [skip ci]" || echo "No changes to commit"

# Pousser vers le repository
git push origin main

echo "Version persisted successfully ✅"
