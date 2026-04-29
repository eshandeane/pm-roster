# PM Roster

A set of 8 autonomous AI agents for senior PMs — built on Claude Code. They run on a schedule, monitor your tools, and surface signal to Slack so you spend less time context-switching.

Built by [Eshan Deane](https://github.com/eshandeane), Senior PM at Cut+Dry.

---

## The Agents

| Agent | What it does | Schedule |
|-------|-------------|----------|
| **Briefing** | Daily executive briefing — scans Gmail, Slack, Jira, and Circleback, posts a prioritized action list to Slack | Mon-Fri, 11am |
| **Warmup** | Pre-meeting context brief — pulls last meeting notes, open action items, email threads, and Jira status before each meeting | Mon-Fri, 8am + 2pm |
| **Recap** | Post-meeting capture — extracts decisions, action items, and verbal business logic from Circleback transcripts | Mon-Fri, 11am + 4pm + 11pm |
| **Buzz** | Weekly user sentiment — scans Circleback, Slack, Gmail, and Jira for the past 7 days, surfaces top themes with verbatim quotes | Monday, 8am |
| **Checkpoint** | Weekly roadmap status — compares goals vs actuals, calculates per-account risk scores, generates Monday actions | Monday, 8:30am |
| **Gameplan** | Weekly priority setting — reads Buzz and Checkpoint, pulls Q2 roadmap and calendar, sets exactly 3 priorities for the week | Sunday, 8pm |
| **Spotlight** | Weekly changelog — scans merged PRs, categorizes by audience (ops / eng / external), posts a human-readable summary to Slack | Friday (or last working day) |

---

## How it Works

Each agent is a prompt file. You can run them two ways:

**1. As a slash command (interactive)** — trigger manually from Claude Code by typing `/briefing`, `/buzz`, etc.

**2. As a scheduled routine (autonomous)** — set up as a Claude Code Routine (CCR) on [claude.ai/code/routines](https://claude.ai/code/routines) to run on a cron schedule with your MCP connections attached.

---

## Installation

```bash
git clone https://github.com/eshandeane/pm-roster
cd pm-roster
./install.sh
```

The script asks 10 questions (name, email, Slack channel, Jira projects, GitHub repo, company), applies your settings to every file, and copies everything to `~/.claude/`. Takes about 2 minutes.

After that, it prints a checklist of the routines you need to set up manually on [claude.ai/code/routines](https://claude.ai/code/routines) — one per agent, with the cron schedule and MCP connections for each.

### Manual install (if you prefer)

Copy files directly:

```bash
mkdir -p ~/.claude/skills/pm-roster
cp skills/*.md ~/.claude/skills/pm-roster/
cp commands/*.md ~/.claude/commands/
```

Then find-and-replace the context fields in each file (see Customization below).

---

## Requirements

### MCP Connectors

Each agent requires specific MCP connections. Connect them at [claude.ai/customize/connectors](https://claude.ai/customize/connectors).

| Agent | Required MCPs |
|-------|--------------|
| Briefing | Gmail, Slack, Atlassian (Jira), Circleback |
| Warmup | Google Calendar, Circleback, Gmail, Atlassian (Jira), Slack |
| Recap | Google Calendar, Circleback, Atlassian (Jira), Slack |
| Buzz | Circleback, Slack, Gmail, Atlassian (Jira) |
| Checkpoint | Atlassian (Confluence + Jira), Slack |
| Gameplan | Atlassian (Confluence + Jira), Google Calendar, Slack |
| Spotlight | Slack (GitHub access via WebFetch) |

---

## Customization

The prompts are written for a specific context (Cut+Dry, Eshan's Slack channels, Jira project IDs). Before using, update these fields in each skill file:

- **Your name and email** — replace `Eshan Deane` and `eshan@cutanddry.com`
- **Slack channel** — replace `#clawd` / `C0ARHM91TKQ` with your channel
- **Jira projects** — replace `DOT`, `DFR` with your project keys
- **Jira site** — replace `getcodify.atlassian.net` with your Atlassian domain
- **GitHub repo** — replace `getcodify/fde-platform` in Spotlight with your repo
- **Company context** — replace Cut+Dry-specific references with your company

Each file has clear context at the top — search for the fields above and swap them out.

---

## PM OS Integration (Signal Router)

Every Roster agent now ends with a **PM OS Handoff** section — conditional suggestions for which PM OS skill to run next based on what was found. For example, Buzz surfacing a high-severity theme suggests `/user-research-synthesis`. Checkpoint flagging an at-risk account suggests `/decision-doc`.

On top of that, **Signal Router** is a companion CCR that runs every Monday at 9:30am IST — after Buzz, Checkpoint, and Gameplan have posted. It reads all three outputs, classifies the signals, and pre-populates Confluence draft pages so you start Monday with work already started.

### Signal Router rules

| Rule | Trigger | Draft created in Confluence |
|------|---------|----------------------------|
| A | High severity Buzz theme | User Research Synthesis |
| B | Checkpoint account score 7+ | Decision Doc |
| C | Q2 at risk or behind | Impact Sizing (Q2 recovery) |
| D | Gameplan P1 (always, unless C triggered) | Impact Sizing (P1 opportunity) |
| E | Same root cause in 3+ accounts | Strategy Sprint brief |

Max 3 drafts per week. Signal Router posts links to your Slack channel with one line on why each was triggered.

The Signal Router prompt is not in this repo (it's a standalone CCR). Create it at [claude.ai/code/routines](https://claude.ai/code/routines) with these MCP connections: Slack, Atlassian (Confluence + Jira), Circleback. Schedule: `0 4 * * 1` (Monday 9:30am IST / 4am UTC).

---

## Design Principles

- **Signal over noise** — every agent posts only when there's something worth saying. Silent exit is correct behavior.
- **Verbatim quotes** — agents always pull exact quotes from transcripts, not paraphrases. This matters for Jira tickets and decision logs.
- **Prefer updating over creating** — agents comment on existing Jira tickets before creating new ones.
- **Slack as the interface** — all output goes to a single Slack channel so you have one place to check.

---

## File Structure

```
pm-roster/
├── README.md
├── skills/          # Raw prompt files — paste into CCR routines or skills directory
│   ├── briefing.md
│   ├── buzz.md
│   ├── checkpoint.md
│   ├── gameplan.md
│   ├── recap.md
│   ├── spotlight.md
│   └── warmup.md
└── commands/        # Claude Code slash command wrappers — copy to ~/.claude/commands/
    ├── briefing.md
    ├── buzz.md
    ├── checkpoint.md
    ├── gameplan.md
    ├── recap.md
    ├── spotlight.md
    └── warmup.md
```

---

## Can Anyone Use This?

Yes, with customization. The prompts are portable — copy them, update the context fields, and they work with any Claude Code setup.

The scheduled routines are not directly exportable from claude.ai. You set them up manually by pasting the prompts into new routines at [claude.ai/code/routines](https://claude.ai/code/routines) and attaching your own MCP connections.

You do not need a specific repo or codebase — these agents work entirely through MCP integrations (Slack, Gmail, Jira, Circleback, etc.).
