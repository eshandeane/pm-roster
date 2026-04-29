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
| **Meeting Intelligence** | Processes Circleback meeting emails, extracts escalations and feature requests, creates/comments on Jira tickets automatically | Triggered on new Circleback emails |

---

## How it Works

Each agent is a prompt file. You can run them two ways:

**1. As a slash command (interactive)** — trigger manually from Claude Code by typing `/briefing`, `/buzz`, etc.

**2. As a scheduled routine (autonomous)** — set up as a Claude Code Routine (CCR) on [claude.ai/code/routines](https://claude.ai/code/routines) to run on a cron schedule with your MCP connections attached.

---

## Installation

### Slash Commands

Copy the `commands/` files into your global Claude Code commands directory:

```bash
cp commands/*.md ~/.claude/commands/
```

Then type `/briefing`, `/buzz`, `/gameplan`, etc. in any Claude Code session.

### Skills

Copy the `skills/` files into your Claude Code skills directory:

```bash
mkdir -p ~/.claude/skills/pm-roster
cp skills/*.md ~/.claude/skills/pm-roster/
```

### Scheduled Routines

The agents are designed to run autonomously on a schedule via Claude Code Routines. To set them up:

1. Go to [claude.ai/code/routines](https://claude.ai/code/routines)
2. Create a new routine for each agent
3. Paste the prompt from the corresponding `skills/` file
4. Set the cron schedule (see table above)
5. Attach the MCP connectors the agent needs (see Requirements below)

The prompts in `skills/` are the exact prompts used in the routines — they are self-contained and ready to paste.

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
| Meeting Intelligence | Gmail, Circleback, Atlassian (Jira), Slack |

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
│   ├── meeting-intelligence.md
│   ├── recap.md
│   ├── spotlight.md
│   └── warmup.md
└── commands/        # Claude Code slash command wrappers — copy to ~/.claude/commands/
    ├── briefing.md
    ├── buzz.md
    ├── checkpoint.md
    ├── gameplan.md
    ├── meeting-intelligence.md
    ├── recap.md
    ├── spotlight.md
    └── warmup.md
```

---

## Can Anyone Use This?

Yes, with customization. The prompts are portable — copy them, update the context fields, and they work with any Claude Code setup.

The scheduled routines are not directly exportable from claude.ai. You set them up manually by pasting the prompts into new routines at [claude.ai/code/routines](https://claude.ai/code/routines) and attaching your own MCP connections.

You do not need a specific repo or codebase — these agents work entirely through MCP integrations (Slack, Gmail, Jira, Circleback, etc.).
