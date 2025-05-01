#!/bin/bash

cd "$(git rev-parse --show-toplevel)"
# Variables
NGROK_URL="https://f5f9-2a01-e0a-ba9-4c40-ec81-ceb9-b8ac-cf33.ngrok-free.app"
WEBHOOK_URL="$NGROK_URL/webhook-test/6a454f38-091e-44be-ba6f-eeb5b8dc9deb"  # Remplacez par votre URL n8n

LAST_COMMIT=$(git log -1 --pretty=format:"%H")
FILES_CHANGED=$(git show --name-status --oneline "$LAST_COMMIT")
COMMIT_MESSAGE=$(git log -1 --pretty=format:"%s")
AUTHOR=$(git log -1 --pretty=format:"%an" 2>/dev/null || echo "No author")
DIFF=$(git show "$LAST_COMMIT")
# Construire le JSON
JSON=$(jq -n \
  --arg commit "$LAST_COMMIT" \
  --arg message "$COMMIT_MESSAGE" \
  --arg author "$AUTHOR" \
  --arg diff "$DIFF" \
  --arg files "$FILES_CHANGED" \
  '{
    commit: $commit,
    message: $message,
    author: $author,
    diff: $diff,
    files: $files
  }')

# Envoyer la requête POST
curl -X POST -H "Content-Type: application/json" -d "$JSON" "$WEBHOOK_URL"