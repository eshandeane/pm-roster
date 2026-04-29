#!/bin/bash

set -e

echo ""
echo "PM Roster — Install Script"
echo "=========================="
echo "This will install 7 PM agents as Claude Code slash commands."
echo "You'll need to set up the scheduled routines manually on claude.ai/code/routines after this."
echo ""

# --- Collect config ---

read -p "Your full name (e.g. Jane Smith): " USER_NAME
read -p "Your work email: " USER_EMAIL
read -p "Slack channel name for agent output (e.g. #pm-alerts): " SLACK_CHANNEL
read -p "Slack channel ID (e.g. C0ARHM91TKQ — find it in Slack channel settings): " SLACK_CHANNEL_ID
read -p "Jira site domain (e.g. yourcompany.atlassian.net): " JIRA_DOMAIN
read -p "Jira onboarding project key (e.g. OPS, ONBOARD): " JIRA_PROJECT_1
read -p "Jira feature requests project key (e.g. FEAT, DFR): " JIRA_PROJECT_2
read -p "GitHub org/repo for Spotlight (e.g. myorg/myrepo): " GITHUB_REPO
read -p "Company name (e.g. Acme Corp): " COMPANY_NAME
read -p "Company description (e.g. B2B SaaS platform for X): " COMPANY_DESC

echo ""
echo "Installing with these settings:"
echo "  Name:         $USER_NAME"
echo "  Email:        $USER_EMAIL"
echo "  Slack:        $SLACK_CHANNEL ($SLACK_CHANNEL_ID)"
echo "  Jira site:    $JIRA_DOMAIN"
echo "  Jira projects: $JIRA_PROJECT_1, $JIRA_PROJECT_2"
echo "  GitHub repo:  $GITHUB_REPO"
echo "  Company:      $COMPANY_NAME — $COMPANY_DESC"
echo ""
read -p "Looks good? (y/n): " CONFIRM
if [[ "$CONFIRM" != "y" ]]; then
  echo "Aborted."
  exit 1
fi

# --- Create temp working dir with substituted files ---

TMPDIR=$(mktemp -d)
cp -r skills/. "$TMPDIR/"

echo ""
echo "Applying your settings to all skill files..."

for file in "$TMPDIR"/*.md; do
  # Name and email
  sed -i.bak "s/Eshan Deane/$USER_NAME/g" "$file"
  sed -i.bak "s/eshan@cutanddry\.com/$USER_EMAIL/g" "$file"

  # Slack
  sed -i.bak "s/#clawd/$SLACK_CHANNEL/g" "$file"
  sed -i.bak "s/C0ARHM91TKQ/$SLACK_CHANNEL_ID/g" "$file"
  sed -i.bak "s/#eshan-ai/$SLACK_CHANNEL/g" "$file"

  # Jira
  sed -i.bak "s/getcodify\.atlassian\.net/$JIRA_DOMAIN/g" "$file"
  sed -i.bak "s/project = DOT/project = $JIRA_PROJECT_1/g" "$file"
  sed -i.bak "s/project = DFR/project = $JIRA_PROJECT_2/g" "$file"
  sed -i.bak "s/project in (DOT, DFR)/project in ($JIRA_PROJECT_1, $JIRA_PROJECT_2)/g" "$file"
  sed -i.bak "s/\bDOT\b/$JIRA_PROJECT_1/g" "$file"
  sed -i.bak "s/\bDFR\b/$JIRA_PROJECT_2/g" "$file"

  # GitHub
  sed -i.bak "s|getcodify/fde-platform|$GITHUB_REPO|g" "$file"

  # Company
  sed -i.bak "s/Cut+Dry/$COMPANY_NAME/g" "$file"
  sed -i.bak "s/B2B food distribution SaaS/$COMPANY_DESC/g" "$file"

  # Clean up backups
  rm -f "$file.bak"
done

# --- Install to ~/.claude ---

SKILLS_DIR="$HOME/.claude/skills/pm-roster"
COMMANDS_DIR="$HOME/.claude/commands"

mkdir -p "$SKILLS_DIR"
mkdir -p "$COMMANDS_DIR"

echo "Copying skills to $SKILLS_DIR..."
cp "$TMPDIR"/*.md "$SKILLS_DIR/"

echo "Copying commands to $COMMANDS_DIR..."
for file in commands/*.md; do
  skill_name=$(basename "$file")
  # Apply same substitutions to command wrappers
  cp "$file" "$TMPDIR/cmd_$skill_name"
  sed -i.bak "s/Eshan Deane/$USER_NAME/g" "$TMPDIR/cmd_$skill_name"
  sed -i.bak "s/eshan@cutanddry\.com/$USER_EMAIL/g" "$TMPDIR/cmd_$skill_name"
  sed -i.bak "s/#clawd/$SLACK_CHANNEL/g" "$TMPDIR/cmd_$skill_name"
  sed -i.bak "s/C0ARHM91TKQ/$SLACK_CHANNEL_ID/g" "$TMPDIR/cmd_$skill_name"
  sed -i.bak "s/#eshan-ai/$SLACK_CHANNEL/g" "$TMPDIR/cmd_$skill_name"
  sed -i.bak "s/getcodify\.atlassian\.net/$JIRA_DOMAIN/g" "$TMPDIR/cmd_$skill_name"
  sed -i.bak "s/Cut+Dry/$COMPANY_NAME/g" "$TMPDIR/cmd_$skill_name"
  rm -f "$TMPDIR/cmd_$skill_name.bak"
  cp "$TMPDIR/cmd_$skill_name" "$COMMANDS_DIR/$skill_name"
done

# --- Cleanup ---
rm -rf "$TMPDIR"

# --- Done ---

echo ""
echo "✓ Installed 7 agents to ~/.claude/skills/pm-roster/"
echo "✓ Installed 7 slash commands to ~/.claude/commands/"
echo ""
echo "You can now use these slash commands in Claude Code:"
echo "  /briefing      Daily executive briefing"
echo "  /warmup        Pre-meeting context brief"
echo "  /recap         Post-meeting capture"
echo "  /buzz          Weekly user sentiment"
echo "  /checkpoint    Weekly roadmap status"
echo "  /gameplan      Weekly priority setting"
echo "  /spotlight     Weekly changelog"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "NEXT: Set up scheduled routines on claude.ai"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Go to: https://claude.ai/code/routines"
echo "Connect MCPs at: https://claude.ai/customize/connectors"
echo ""
echo "Create one routine per agent. Paste the prompt from ~/.claude/skills/pm-roster/<agent>.md"
echo "Use these cron schedules (all times in your local timezone):"
echo ""
echo "  briefing.md         Mon-Fri, 11am        →  30 5 * * 1-5  (UTC+5:30)"
echo "  warmup.md           Mon-Fri, 8am + 2pm   →  30 2 * * 1-5  and  30 8 * * 1-5"
echo "  recap.md            Mon-Fri, 11am+4pm+11pm → 30 5,10,17 * * 1-5"
echo "  buzz.md             Monday, 8am          →  30 2 * * 1"
echo "  checkpoint.md       Monday, 8:30am       →  0 3 * * 1"
echo "  gameplan.md         Sunday, 8pm          →  30 14 * * 0"
echo "  spotlight.md        Mon-Fri, 4pm         →  30 10 * * 1-5  (self-limits to Fridays)"
echo ""
echo "Required MCP connections per agent:"
echo "  briefing        Gmail, Slack, Atlassian, Circleback"
echo "  warmup          Google Calendar, Circleback, Gmail, Atlassian, Slack"
echo "  recap           Google Calendar, Circleback, Atlassian, Slack"
echo "  buzz            Circleback, Slack, Gmail, Atlassian"
echo "  checkpoint      Atlassian, Slack"
echo "  gameplan        Atlassian, Google Calendar, Slack"
echo "  spotlight       Slack"
echo ""
echo "Done. PM Roster is ready."
