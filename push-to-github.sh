#!/bin/bash
# 4600H Toolkit - GitHub Push Helper
# Token TIDAK masuk chat history — dibaca dari file lokal
#
# Cara pakai:
#   1. Simpan token:  echo "ghp_xxxx" > ~/.gh_token
#   2. Jalankan:      bash push-to-github.sh USERNAME_LO
#   3. Revoke token setelah selesai

set -e

USERNAME=$1
REPO="4600h-toolkit"
TOKEN_FILE="$HOME/.gh_token"

if [ -z "$USERNAME" ]; then
    echo "Usage: bash push-to-github.sh USERNAME_LO"
    echo "Contoh: bash push-to-github.sh johndoe"
    exit 1
fi

if [ ! -f "$TOKEN_FILE" ]; then
    echo "Token file tidak ditemukan: $TOKEN_FILE"
    echo ""
    echo "Buat dulu:"
    echo "  echo \"ghp_xxxx\" > ~/.gh_token"
    echo ""
    echo "Bikin token di: https://github.com/settings/tokens"
    echo "Centang hanya 'repo' scope, expiration 7 hari."
    exit 1
fi

TOKEN=$(cat "$TOKEN_FILE" | tr -d '\n')

cd /home/isal/4600h-toolkit

echo "=== Pushing to github.com/$USERNAME/$REPO ==="

# Set remote dengan token
git remote remove origin 2>/dev/null || true
git remote add origin "https://${USERNAME}:${TOKEN}@github.com/${USERNAME}/${REPO}.git"
git branch -M main

# Push
git push -u origin main 2>&1

# Hapus token dari remote URL (security)
git remote remove origin 2>/dev/null || true
git remote add origin "https://github.com/${USERNAME}/${REPO}.git"

echo ""
echo "=============================================="
echo " PUSH SELESAI!"
echo "=============================================="
echo ""
echo " SEKARANG REVOKE TOKEN:"
echo "   https://github.com/settings/tokens"
echo "   Klik token lo -> Delete"
echo ""
echo " Hapus token file:"
echo "   rm ~/.gh_token"
echo "=============================================="
