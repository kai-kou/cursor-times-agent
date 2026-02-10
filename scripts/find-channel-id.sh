#!/usr/bin/env bash
# チャンネルID検索ヘルパー
# Usage: ./find-channel-id.sh [keyword]
set -euo pipefail

if [[ -z "${SLACK_BOT_TOKEN:-}" ]]; then
  echo "Error: SLACK_BOT_TOKEN が設定されていません" >&2
  exit 1
fi

KEYWORD="${1:-}"

if [[ -z "$KEYWORD" ]]; then
  echo "Usage: $0 <channel-name-keyword>"
  echo ""
  echo "Examples:"
  echo "  $0 times        # 'times' を含むチャンネルを検索"
  echo "  $0 kai          # 'kai' を含むチャンネルを検索"
  exit 0
fi

curl -s "https://slack.com/api/conversations.list?types=public_channel,private_channel&limit=500" \
  -H "Authorization: Bearer ${SLACK_BOT_TOKEN}" | \
  python3 -c "
import sys, json
data = json.load(sys.stdin)
if not data.get('ok'):
    print(f\"Error: {data.get('error', 'unknown')}\", file=sys.stderr)
    sys.exit(1)
keyword = '${KEYWORD}'.lower()
channels = [c for c in data.get('channels', []) if keyword in c['name'].lower()]
if channels:
    print(f'Found {len(channels)} channel(s):')
    print()
    for c in sorted(channels, key=lambda x: x['name']):
        members = c.get('num_members', '?')
        print(f\"  {c['id']}  #{c['name']}  ({members} members)\")
else:
    print(f'No channels matching \"{keyword}\"')
"
