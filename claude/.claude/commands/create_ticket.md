---
description: Distill a research document into a Jira-ready ticket with Description / Background / Acceptance Criteria
model: opus
---

# Create Ticket

You create a Jira-ready ticket in `thoughts/shared/tickets/` by distilling an existing research document (produced by `/research_codebase`) into a compact, self-contained ticket.

The ticket body must be **copy-paste ready for Jira** and **self-contained**: it must NOT reference the `thoughts/` directory, the research document, or any workflow artifact. A developer reading the ticket in Jira must be able to understand the problem and the expected outcome without access to anything outside Jira.

## Philosophy

The research is thorough; the ticket is compact. The research document contains everything that was learned during investigation. The ticket contains only what a developer needs to start work: what needs to change, why it matters, and how to recognize "done".

You throw away most of the research. That is the point. The ticket is a distilled artifact, not a summary of the investigation.

**Tickets are minimal: "AI-ready" and "just enough" instead of detail overload.** A ticket is "AI-ready" and "Ready for Sprint": as short as possible but complete - no code samples, no long descriptions, no deep discussion in the ticket. Only the bare essentials: what to change, why, and how to recognize "done". No complex details, no exhaustive context, no edge-case catalogs, no more than one or two file references. When in doubt whether a detail belongs in the ticket: it does not.

## Required Argument

This command **requires a path to a research document** as its argument.

Example invocations:
```
/create_ticket thoughts/shared/research/2026-04-21-excel-parser-quantity.md
/create_ticket thoughts/shared/research/2026-04-21-excel-parser-quantity.md P2PMER
```

If invoked without a research path, respond with:

```
I need a research document to distill into a ticket.

Usage: /create_ticket <path-to-research-doc> [JIRA_PROJECT_PREFIX]

Example:
  /create_ticket thoughts/shared/research/2026-04-21-excel-parser-quantity.md P2PMER

If you don't have a research document yet, run `/research_codebase` first.
```

Then stop and wait. Do not accept a free-form problem description in place of a research document.

## Output Language

Tickets are always **English**, regardless of the conversation language. Titles, section contents, acceptance criteria — all English. Conversation with the user may be in any language.

## Process

### Step 1: Read the Research Document

Read the provided research document **FULLY** using the Read tool without `limit`/`offset` parameters. You need the complete content before drafting.

If the file does not exist, does not appear to be a research document, or is empty, stop and tell the user — do not invent content or fall back to a free-form draft.

### Step 2: Extract the Ticket-Relevant Signal

From the research, identify:

- **The target state** — what should change or be built (becomes the Description)
- **The current gap / problem** and its impact — who is affected, how often, what breaks (becomes Background)
- **Concrete file references** (`path/file.ext:123`) that anchor the problem and the affected area (becomes Background)
- **Constraints and prior decisions** the solution must respect (becomes Background)
- **Observable outcomes** that indicate the work is done (becomes Acceptance Criteria)

Ignore:
- Architectural deep-dives, exploratory notes, and tangential findings
- Historical context that is interesting but not load-bearing for the implementer
- Implementation step-by-step (that belongs in the plan, not the ticket)

**Verification is optional**: if the research document cites a file or line reference you are about to put in the ticket and it looks suspicious, spot-check with `Read` or `Grep` before including it. Do not spawn broad sub-agent research — the research is already done.

### Step 3: Clarify the Problem (only if needed)

If the research document does not contain a clear **problem statement** (only implementation notes or architectural observations), STOP and ask the user:

> "The research doesn't spell out the problem clearly. Before I draft: what problem does this ticket solve, and who is affected?"

Do not proceed without a problem statement. A ticket without a problem forces the implementer to guess intent.

### Step 4: Distill Into a Ticket Draft

Present the draft to the user before writing anything to disk. Use exactly these three sections:

```markdown
## Draft Ticket

**Title:** [Action-oriented, max ~80 chars]

---

# [Title]

## Description

[What needs to change or be built. 1-3 sentences. Describe the
target state; do not describe the step-by-step implementation.]

## Background

[Why this matters. 2-4 sentences maximum: the current gap and its impact,
plus at most one constraint or prior decision if load-bearing. At most one
or two file references, only if they save real search time. Cut everything
a competent developer could infer directly from the code.]

## Acceptance Criteria

- [ ] [Observable, testable outcome]
- [ ] [Observable, testable outcome]

[2-4 criteria maximum. Only outcomes that define "done", not a test catalog.]
```

### Step 5: Iterate

Ask the user:
- Does the Description capture the right target state?
- Is the Background accurate, and does it avoid forcing the reader to dig elsewhere?
- Are the Acceptance Criteria observable? Could a reviewer check each one without judgement calls?

Refine until the user approves. Do not write the file before approval.

### Step 6: Write the File

**Location:** `thoughts/shared/tickets/` (create with `mkdir -p` if it does not exist).

**Naming:**
- With ticket number: `YYYY-MM-DD-PROJECT-NNNN-kebab-description.md`
  - Example: `2026-04-21-P2PMER-912-detect-quantity-column-by-header.md`
- Without ticket number: `YYYY-MM-DD-kebab-description.md`

Use today's date and the Jira project prefix from the command argument (or ask if none was provided — do not guess).

**File contents:**

```markdown
---
date: YYYY-MM-DD
jira_ticket: PROJECT-NNNN          # or: pending
jira_url:                          # fill in after creating in Jira
source_research: thoughts/shared/research/YYYY-MM-DD-...-...md
status: draft                      # draft | created | in-dev | done
---

# [Title]

## Description
...

## Background
...

## Acceptance Criteria
- [ ] ...
```

The frontmatter is **local metadata** — it must NOT be copied into Jira. `source_research` links back to the research doc for your own records. Everything below the closing `---` of the frontmatter is the Jira content.

### Step 7: Hand Off to Jira

After writing the file, tell the user exactly how to paste it:

> "Ticket written to `<path>`.
>
> In Jira:
> - **Summary** field: the title text (line starting with `# `, without the `#`).
> - **Description** field: everything from `## Description` downward.
>
> Once the Jira ticket exists, share the ticket ID/URL and I'll update the filename and frontmatter."

If the user shares the Jira ID afterwards:
- Rename the file to include `PROJECT-NNNN` in the name
- Update `jira_ticket`, `jira_url`, and `status: created` in frontmatter

## Writing Principles

The ticket will be read by humans in Jira and by LLMs (if the user later feeds it to `/create_plan` or `/implement_plan`). Write so both can act on it.

- **As short as possible, but complete.** "AI-ready" and "Ready for Sprint": no code samples, no long descriptions, no deep discussion in the ticket.
- **Concrete over vague.** "Imports with more than 50 line items time out after 30s" beats "Large imports have performance issues."
- **Observable acceptance criteria.** "Orders with 200 line items import in under 10s" beats "Performance is improved."
- **File references ground the LLM.** `src/foo/Bar.php:45` lets a later planning agent find the code instantly. Use only references that appear in the research doc (or that you verified yourself).
- **Do not prescribe implementation.** The ticket states the target state and why. How to get there is decided during planning and implementation.
- **Cut the research trail.** The reader should not feel they are reading a summary of an investigation. They should feel they are reading a crisp, decided ticket.

## Absolute Rules

- **Requires a research document path as argument.** Refuse to proceed without it.
- **No `thoughts/` references in the ticket body.** Frontmatter only (`source_research`).
- **No meta-references** to research, investigation, prior Claude sessions, or the workflow. No "during research we found", "see attached analysis", etc.
- **English, always**, for the ticket body, title, and frontmatter values.
- **No emojis** unless the user explicitly requests them.
- **No code samples in the ticket body.** Describe behaviour, not code.
- **No AI attribution, Claude notes, or boilerplate** in the ticket body.
- **Never invent file paths, function names, ticket numbers, or metrics.** If uncertain, omit or ask.
- **Never write the file without the user's explicit approval** of the draft.
- **Use exactly the three sections** — Description, Background, Acceptance Criteria. No extra sections unless the user explicitly asks.

## Example: From Research to Ticket

Research excerpt (verbose, exploratory):

> The Excel parser in `src/purchase/Parser.php:120` reads line items by column index, but the layout of "quantity" varies between vendor templates. Some vendors put quantity in column E, others in G. Currently we hard-code column E. About 15% of vendor imports silently drop quantity because of this — the row is imported with quantity 0, and downstream order processing later treats it as a zero-quantity line, requiring manual correction. Test fixtures for the parser live in `src/purchase/templates/`. A similar header-name detection already exists in `src/purchase/InvoiceParser.php:88` and can serve as a pattern.

Distilled ticket:

```markdown
# Detect Excel quantity column by header name

## Description

Replace the fixed-column-index lookup for "quantity" in the vendor Excel parser
with header-name detection, so imports succeed across all current vendor
templates and fail loudly when no quantity column is present.

## Background

The current parser (`src/purchase/Parser.php:120`) reads quantity from a
hard-coded column index (E). Several active vendor templates place quantity in
column G instead, which causes roughly 15% of vendor imports to silently record
quantity 0. Downstream order processing then treats these as zero-quantity
lines, and the problem is typically caught only after the order has been worked
on manually.

A similar header-name detection is already used by
`src/purchase/InvoiceParser.php:88` and can serve as the reference pattern.
Vendor template fixtures live in `src/purchase/templates/`.

## Acceptance Criteria

- [ ] The parser locates the quantity column by matching header text, not column index
- [ ] All active vendor templates import with correct quantities (verified against the fixtures)
- [ ] An import where no quantity column can be identified fails with a clear error
      instead of silently producing quantity-0 rows
- [ ] Regression test covers the vendor templates in `src/purchase/templates/`
```

Notice what is absent: no mention of "research", no `thoughts/` paths, no percentages or metrics beyond what the source material supports, no implementation steps. Ready to paste into Jira.
