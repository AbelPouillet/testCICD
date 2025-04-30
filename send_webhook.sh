#!/bin/bash

cd "$(git rev-parse --show-toplevel)"
# Variables
NGROK_URL="https://5a08-2a01-e0a-ba9-4c40-358b-dff0-42e2-58c8.ngrok-free.app"
WEBHOOK_URL="$NGROK_URL/webhook-test/6a454f38-091e-44be-ba6f-eeb5b8dc9deb"  # Remplacez par votre URL n8n

LAST_COMMIT=$(git log -1 --pretty=format:"%H")
PREVIOUS_COMMIT=$(git log -2 --pretty=format:"%H" | tail -n1) # Récupère l'avant-dernier commit
COMMIT_MESSAGE=$(git log -1 --pretty=format:"%s" 2>/dev/null || echo "No commit message")
AUTHOR=$(git log -1 --pretty=format:"%an" 2>/dev/null || echo "No author")
DIFF=$(git diff $PREVIOUS_COMMIT $LAST_COMMIT)
# Construire le JSON
JSON=$(jq -n \
  --arg commit "$LAST_COMMIT" \
  --arg message "$COMMIT_MESSAGE" \
  --arg author "$AUTHOR" \
  --arg diff "$DIFF" \
  '{
    commit: $commit,
    message: $message,
    author: $author,
    diff: $diff
  }')

# Envoyer la requête POST
curl -X POST -H "Content-Type: application/json" -d "$JSON" "$WEBHOOK_URL"