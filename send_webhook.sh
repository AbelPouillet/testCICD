#!/bin/bash

cd "$(git rev-parse --show-toplevel)"

# Webhook
NGROK_URL="https://1f9b-2a01-e0a-ba9-4c40-a0d9-7fb4-7892-b01c.ngrok-free.app"
WEBHOOK_URL="$NGROK_URL/webhook-test/6a454f38-091e-44be-ba6f-eeb5b8dc9deb"

# Branche actuelle et distante
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
REMOTE_REF="origin/$CURRENT_BRANCH"

# Récupère les commits poussés
COMMITS=$(git rev-list --reverse "$REMOTE_REF"..HEAD)

# Repo & auteur
REPO_NAME=$(basename -s .git `git config --get remote.origin.url`)
OWNER_NAME=$(git config --get remote.origin.url | sed -E 's#.*[:/]([^/]+)/[^/]+\.git#\1#')

# Création du tableau de commits
COMMITS_JSON="[]"

for COMMIT in $COMMITS; do
  COMMIT_MESSAGE=$(git log -1 --pretty=format:"%s" "$COMMIT")
  AUTHOR=$(git log -1 --pretty=format:"%an" "$COMMIT")
  FILES_CHANGED=$(git show --name-status --oneline "$COMMIT")
  DIFF=$(git show --stat --patch --unified=3 "$COMMIT")

  COMMIT_JSON=$(jq -n \
    --arg commit "$COMMIT" \
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

  COMMITS_JSON=$(echo "$COMMITS_JSON" | jq ". += [$COMMIT_JSON]")
done

# Final JSON
FINAL_JSON=$(jq -n \
  --arg repo "$REPO_NAME" \
  --arg owner "$OWNER_NAME" \
  --arg branch "$CURRENT_BRANCH" \
  --argjson commits "$COMMITS_JSON" \
  '{
    repository: $repo,
    owner: $owner,
    branch: $branch,
    commits: $commits
  }')

# Envoi unique
curl -X POST -H "Content-Type: application/json" -d "$FINAL_JSON" "$WEBHOOK_URL"
