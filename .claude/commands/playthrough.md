# Persona Playthrough Loop

You are running a simulated playthrough of the treasure hunt platform from the perspective of conference attendees. Each persona in `.claude/personas/` represents a real type of user who will use this app at RubyConf Austria 2026.

## How it works

For each persona (01 through 10), do the following:

### 1. Load the persona
Read the persona file from `.claude/personas/`. Internalize their role, device, playstyle, behavior patterns, and pain points.

### 2. Walk through the app as that persona
Simulate their journey by reading the actual view templates, controllers, and routes. Follow the flow they would take:

- **Landing page** (`/`) — First impression. What do they see? Is it clear what to do?
- **Login** (`/login`) — They received credentials from the conference organizer.
- **Dashboard** (`/dashboard`) — What's the first thing they notice? Is the CTA clear?
- **Team flow** — Do they create a team, join one, or skip? Check `/team/new`, team show page.
- **Hunt selection** — Which hunt do they pick? Is the card informative enough?
- **Adventure gameplay** (`/adventures/:id`) — Read the clue, check location, claim. Is the flow smooth?
- **Hints** — Do they use hints? Is the cooldown clear?
- **Leaderboard** (`/leaderboard`) — Do they check it? Can they find themselves?
- **Endgame** — If they complete a hunt, is the treasure reveal clear? Is the email useful?

### 3. Generate feedback
For each persona, write feedback **in their voice** covering:

- **First impression** (landing + login)
- **Core loop** (clue → navigate → check → claim)
- **Team experience** (if applicable)
- **Pain points** (specific issues they'd hit based on their profile)
- **What they liked**
- **Bugs or UX issues** found by reading the actual code

### 4. Compile results
After all 10 personas, write a summary report to `.claude/personas/playthrough-report.md` with:

- **Per-persona feedback** (condensed, in their voice)
- **Issue tally** — group all issues by category (UX, accessibility, performance, bugs, missing features)
- **Priority matrix** — which issues affect the most personas and are most severe
- **Top 5 recommendations** — actionable fixes ranked by impact

## Rules

- Read the ACTUAL code (views, controllers, routes, models) — don't assume. The feedback must be grounded in what the app actually does.
- Think about edge cases each persona would trigger based on their behavior patterns.
- Be specific: reference file paths, line numbers, and exact UI text when reporting issues.
- Don't fabricate issues — only report what you can verify by reading the code.
- Consider mobile viewport, touch targets, text size, contrast, and load performance.
