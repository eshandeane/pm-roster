---
name: executive-morning-briefing
description: Daily executive briefing: scans Gmail, Slack, Jira, and Circleback then DMs a prioritized action list to Eshan on Slack
---

You are running the daily executive morning briefing for Eshan Deane (eshan@cutanddry.com). Your job is to scan four sources, identify what needs attention, synthesize a concise executive briefing, and deliver it as a Slack DM to Eshan.

## Step 1 — Gather from all four sources (run in parallel where possible)

**Gmail** — Search for emails from the last 24 hours that are unread OR starred/important, limited to the Primary tab only. Use `gmail_search_messages` with queries like `is:unread newer_than:1d category:primary` and `is:starred newer_than:1d category:primary`. For each result, use `gmail_read_message` to get the subject, sender, and a brief summary of what action (if any) is needed.

**Slack** — Use `slack_search_public_and_private` to find messages from the last 24 hours where Eshan was @mentioned. Also look for any unread direct messages by searching for DMs. Focus on messages that seem to require a response or decision.

**Jira** — Use `searchJiraIssuesUsingJql` with a JQL query like `assignee = currentUser() AND statusCategory != Done ORDER BY duedate ASC` to find all open issues assigned to Eshan. Flag anything that is overdue (duedate < now()) or marked as high/critical priority.

**Circleback** — Use `SearchActionItems` to find action items assigned to Eshan from recent meetings (last 7 days). Also use `ReadMeetings` or `SearchMeetings` to check for any follow-ups from the most recent meetings.

## Step 2 — Synthesize the briefing

Compile everything into a single structured briefing. Organize it clearly under these sections:

1. **🚨 Needs Immediate Attention** — Things that are overdue, urgent, or time-sensitive today
2. **📧 Email** — Unread/flagged emails requiring a reply or action (list top 5 max, most important first)
3. **💬 Slack** — @mentions or DMs awaiting response
4. **🎫 Jira** — Assigned issues, highlighting anything overdue or blocked
5. **📝 Meeting Follow-ups** — Action items from Circleback

For each item include: what it is, who it's from (if relevant), and the suggested action (reply, review, complete, etc.).

Keep the tone sharp and executive — no fluff. Bullet points, not paragraphs.

## Step 3 — Deliver via Slack DM

1. Use `slack_send_message` to post the briefing to the #clawd channel (channel ID: `C0ARHM91TKQ`).
3. Start the message with: `*📋 Executive Briefing — [Today's Date]*`

## Success criteria
- The briefing was sent as a Slack DM to Eshan
- All four sources were checked
- The message is clear, actionable, and under ~40 lines
- If a source returns no items, note "Nothing new" for that section rather than skipping it

## PM OS Handoff

After posting, append suggested next actions only if warranted:

*→ Suggested next steps:*
- If 3+ overdue Jira items: `→ /prioritize` to LNO-classify and cut what doesn't matter
- If a recurring blocker appeared again: `→ /decision-doc` to make the call and stop revisiting it
- If a customer email thread needs a response with context: `→ /slack-message` to draft it
- If nothing urgent: omit this section
