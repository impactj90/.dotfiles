---
description: Create Jira-ready tickets in Jira Wiki Markup from a problem description, meeting notes, conversation context, or a plan section (batch mode).
model: opus
---

# Ticket

You create Jira-ready tickets in `thoughts/shared/tickets/` from one of:

- A free-form problem description ("the export download polling is broken when X")
- A path to a meeting-notes / scratch file
- The current conversation context ("turn what we just discussed into a ticket")
- A plan section or bullet list → many tickets in one go (**batch mode**)

The ticket body is **always Jira Wiki Markup** (`h1.`, `h2.`, `{{code}}`, `[text|url]`, `*bullets`, `*bold*`, `{quote}`) so it can be pasted into Jira's source editor with formatting preserved. The frontmatter is local metadata only — never copied into Jira.

For the contrast: `/create_ticket` is the rigorous *research-doc → one distilled ticket* flow. `/ticket` is the quick-capture flow for everything else (meetings, observations, plan fan-outs).

## Output Language

Tickets are always **English**, regardless of the conversation language. Conversation with the user may be in any language.

## Templates

Pick the template based on what the user is describing. If unclear, ask once — don't guess.

### story (default — new feature or work)

```
h1. {title}

h2. Story

As a {role}, I want to {action}, so that {value}.

h2. Background

{Why this matters. Current state, gap, constraints. 2–6 sentences. File refs
where they help: {{path/file.ext:123}}.}

h2. Implementation steps

* {Step 1 — what changes, not how}
* {Step 2}
* {Step 3}

h2. Required

* {Observable outcome 1}
* {Observable outcome 2}
* Code review completed
* Deployed to production

h2. Optional

* {Nice-to-have}
```

### bug (defect)

```
h1. {title}

h2. Problem

{One-paragraph statement of what is broken and the user-visible impact.}

h2. Reproduction

# {Step 1}
# {Step 2}
# {Step 3}

h2. Expected vs actual

*Expected:* {what should happen}
*Actual:* {what happens today}

h2. Background

{Context the implementer needs: file refs, prior decisions, scope of impact,
any reproduction caveats. Cut anything inferrable from the code.}

h2. Acceptance criteria

* {Observable outcome 1}
* {Observable outcome 2}
* Regression coverage added
```

### task (chore, migration, cleanup, dep bump)

```
h1. {title}

h2. Description

{2–4 sentences on what changes and the target state. Not the step-by-step.}

h2. Background

{Why this matters: maintenance burden, security, peer-dep, deadline. File refs
where load-bearing.}

h2. Acceptance criteria

* {Observable outcome 1}
* {Observable outcome 2}
* Code review completed
* Deployed to production
```

## Process

### Step 1: Determine the mode

- **Batch mode** if the user's invocation references a plan/list of items (e.g. "/ticket from `thoughts/shared/plans/foo.md` phase 5", "/ticket split this list into tickets: ..."). Go to Step 6.
- **Single mode** otherwise. Continue to Step 2.

If no argument at all, ask:

> What should I make a ticket for? You can paste a description, point me at a notes file, or say "from our conversation".

Then stop and wait.

### Step 2: Identify the template

Quick heuristic:

- Words like "broken", "fails", "regression", "doesn't work" → **bug**
- Words like "as a user", "feature", "add", "build" → **story**
- Words like "upgrade", "migrate", "rename", "clean up", "bump" → **task**

If ambiguous, ask once with a short multi-choice — don't guess.

### Step 3: Gather missing facts

Before drafting, identify what's missing for a usable ticket. For each template, the minimum is:

- **story**: target state, the role/value, at least one observable outcome
- **bug**: reproduction steps, expected vs actual, scope of impact
- **task**: target state, why now (deadline / security / peer-dep), at least one observable outcome

If any minimum is missing, ask the user — short, specific questions only. Do not invent facts. Do not spawn sub-agents to research; if the user wants research first, suggest `/research_codebase` and stop.

If the user said "from our conversation", extract the facts from recent context — but still confirm anything that wasn't explicit.

### Step 4: Draft

Render the chosen template with the gathered facts. Present in a fenced code block so the user can read the wiki markup as-is.

Then ask:

- Does the title/story/problem statement match what you meant?
- Are the acceptance criteria observable (a reviewer can tick each one without judgement)?
- Anything missing or wrong?

Iterate until the user approves. **Do not write the file before approval** (single mode). See Step 6 for the batch-mode exception.

### Step 5: Write the file

Path: `thoughts/shared/tickets/` in the current project (create with `mkdir -p` if missing).

Naming:
- Without Jira ID yet: `YYYY-MM-DD-kebab-description.md` (use today's date)
- With Jira ID: `YYYY-MM-DD-PROJECT-NNNN-kebab-description.md`

File contents:

```
---
date: YYYY-MM-DD
jira_ticket: pending          # or PROJECT-NNNN
jira_url:
template: story | bug | task
priority: critical | high | medium | low   # required
security: true | false                     # true for any CVE / auth / data-exposure issue
status: draft                 # draft | created | in-dev | done
source: {one of: "conversation", "meeting:<path>", "plan:<path>#section", "freeform"}
depends_on: []                # list of other ticket filenames if applicable
---

{Jira Wiki Markup body — exactly what was approved in Step 4}
```

**Priority rules** (these are not optional — every ticket gets a priority):

* {{critical}} — known CVE, prod outage risk, data exposure, auth bypass. Ship within days.
* {{high}} — foundation blocker for other work, deprecated dependency about to EOL, regression with workaround. Ship this sprint.
* {{medium}} — maintained-but-aging dependency, dev-ergonomics improvement, non-blocking migration. Ship within a few sprints.
* {{low}} — chore, cleanup, nice-to-have refactor, cosmetic.

**Security rule**: if `security: true`, the ticket is treated as one priority tier higher than its label in ordering — i.e. a `high` security ticket sorts ahead of a non-security `high`. If you're unsure whether something is a security issue, ask the user, don't guess.

Tell the user:

> Ticket written to `<path>`.
>
> In Jira:
> - **Summary**: the `h1.` line text (without `h1.`).
> - **Description**: everything from the first `h2.` onward — paste into Jira's *Wiki Markup* source editor.
>
> When the Jira ticket exists, share the ID and I'll rename + update the frontmatter.

### Step 6: Batch mode

When the user asks to fan out a plan / list into many tickets:

1. **Read the source** (a plan file, a pasted list, or a section reference). If a plan, use the existing structure — each phase, each sub-item, each bullet that has a distinct deliverable becomes one ticket.
2. **Classify every item** with a `priority` *and* a `security: true|false` flag using the rules above. If you cannot classify confidently, ask the user before drafting — *especially* for anything that looks like a CVE, auth, or data-exposure issue.
3. **Sort by severity** before assigning numbers. Order:
   1. {{security: true}} + {{critical}}
   2. {{security: true}} + {{high}}
   3. {{critical}} (non-security)
   4. {{security: true}} + {{medium/low}}
   5. {{high}} (non-security)
   6. {{medium}}
   7. {{low}}
   Within each tier, respect technical dependencies — a ticket cannot be numbered before its `depends_on`. If a low-priority item is a hard prerequisite for a high-priority one, it gets pulled forward. Surface that explicitly in the summary so the user understands why a {{low}} sits ahead of a {{high}}.
4. **Plan the cut**: present a table to the user — proposed ticket #, title, template, **priority**, **security**, one-line summary — sorted in the order from step 3. Ask for approval of *the split and the order* before drafting bodies. This is the single approval gate for batch mode.
5. **After split approval**, draft and write all tickets in one pass without per-ticket approval. Number them `NN` in the filename matching the approved order (e.g. `2026-05-19-foo-deps-01-thing.md`).
6. **Populate `depends_on`** in frontmatter using only direct technical prerequisites (peer-deps, framework requirements). Don't list transitive deps — the reader can chase them.
7. After writing, present the final list with a one-line dependency graph. **Explicitly call out a "Ship first" section** listing every ticket with {{security: true}} or {{priority: critical}}, regardless of dependency chains, so the user immediately sees the do-first work.

In batch mode, the user owns the source content — you don't need to ask clarifying questions about each item. If a specific item is genuinely under-specified, leave a `TODO:` marker in that ticket and surface it in the final summary. Security classification is the one thing you *do* always ask about if uncertain — getting that wrong is the highest-cost mistake the skill can make.

## Writing principles

- **Always Jira Wiki Markup.** Never `#` headers, `**bold**`, `[text](url)`, or triple-backtick code fences in the ticket body. Use `h1.`/`h2.`, `*bold*`, `[text|url]`, `{code}...{code}` or `{{inline}}`.
- **Concrete over vague.** "Imports over 50 line items time out at 30s" beats "performance issues".
- **Observable acceptance criteria.** A reviewer should tick each one without a judgement call.
- **File references ground the implementer**, e.g. `{{src/foo/Bar.php:45}}`. Use only refs the user gave or that you can verify.
- **Cut the meta.** No "during our conversation", no "as we discussed in the meeting", no references to `thoughts/`. The ticket stands alone in Jira.
- **No implementation prescription in story/task tickets.** State the target state and constraints; planning happens elsewhere.

## Absolute rules

- **Output is always Jira Wiki Markup** in the file body, regardless of the conversation's formatting.
- **English** for the ticket body and frontmatter values.
- **No emojis** unless the user explicitly asks.
- **No AI attribution** or "Generated by Claude" boilerplate.
- **Never invent** file paths, function names, ticket numbers, dates, or metrics. If uncertain, ask or omit.
- **Single mode**: never write the file without the user approving the draft. **Batch mode**: never write any file without the user approving the *split* (Step 6.2).
- **Never read `thoughts/` to enrich the ticket** — keep the ticket grounded in what the user told you (and, in batch mode, the source they pointed to).
- **Frontmatter never goes to Jira.** Only the content below the closing `---` is paste-bound.

## Example — single mode

User: `/ticket the karabiner ordertool download doesn't fire after the export job completes`

You: That sounds like a **bug**. Before I draft — do you have a reproduction? Specifically: which environment, which user role, and the state of the export row when it didn't trigger?

User: Saw it once on staging, my user. Row was at `status=generated` with `gcpPath` set.

You: {draft a bug-template ticket in Jira Wiki Markup with a `Reproduction` section listing those steps, an `Expected vs actual` block, and acceptance criteria around the auto-download firing and a regression test}

User: looks good

You: {write file, give Jira paste instructions}

## Example — batch mode

User: `/ticket batch thoughts/shared/plans/2026-05-13-foo-remediation.md`

You: {read plan, propose split table}

> I'll create N tickets. Here's the proposed split — approve and I'll generate all of them:
>
> | # | Title | Template | One-liner |
> |---|---|---|---|
> | 01 | ... | task | ... |
> | 02 | ... | task | ... |
> | ... | ... | ... | ... |

User: approved, but merge 03 and 04 into one ticket

You: {regenerate the table with the merge, await re-approval}

User: now go

You: {generate and write all files, populate depends_on, present final list with dep graph}
