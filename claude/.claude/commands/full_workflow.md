---
description: Full workflow: research → plan → implement → test
model: opus
---

# Full Workflow

Orchestrates the complete development cycle by spawning sub-agents for each phase. Each sub-agent has isolated context and communicates via files.

## CRITICAL: You MUST use the Task tool to spawn sub-agents

Do NOT execute the commands yourself. Use the `Task` tool to spawn a separate agent for each phase. This ensures fresh context per phase.

## CRITICAL: Open-Questions Gate (STOP for the user)

Sub-agents run in isolated context and **cannot talk to the user**. They must therefore NEVER silently guess when something is ambiguous. The orchestrator (you, in the main context) is the ONLY place that can talk to the user, so you own the gate.

**The rule:** After every phase, before spawning the next one, check whether the phase surfaced any blocking open questions. If it did, **STOP the workflow completely** and get the answers from the user. Do NOT spawn the next phase, do NOT make assumptions on the user's behalf, do NOT continue "and we can revisit later". Nothing proceeds until the user has answered.

**What counts as a blocking open question:** anything that would materially change the research scope, the plan's approach, the data model, the acceptance criteria, or the implementation — and that cannot be resolved with high confidence from the codebase itself. Cosmetic or trivially-defaulted choices are NOT blocking; do not stop for those.

**How each sub-agent must report open questions:** every sub-agent prompt below instructs the agent to return, INSTEAD of its completion marker, a block of the form:

```
NEEDS_CLARIFICATION
<numbered list of concrete questions, each with the options/tradeoffs the agent sees and, if any, a recommended default>
```

**How you (orchestrator) handle `NEEDS_CLARIFICATION`:**

1. STOP. Mark the current todo as blocked (not complete).
2. Present the questions to the user with the `AskUserQuestion` tool (one entry per question, offering the options the sub-agent surfaced plus its recommendation as the first option). If the questions do not fit that tool's format, ask them in plain prose and wait.
3. **Wait for the user's real answers.** Do not proceed on a timeout, do not answer for them.
4. Re-spawn the SAME phase's sub-agent, appending a `USER CLARIFICATIONS` section (the questions + the user's answers verbatim) to its prompt so it no longer has to guess.
5. If the re-spawned agent surfaces *further* open questions, repeat this gate. Only move on once a phase returns its real completion marker with no open questions.

This gate applies to Phase 0 (input), Phase 1 (research), Phase 2 (plan), and Phase 3 (implementation).

## When this command is invoked:

### 0. Process Input (and first gate)

- Read any referenced files FULLY (no limit/offset)
- Extract ticket ID if present (e.g., ENG-1234)
- Note today's date (YYYY-MM-DD format)
- Store as `USER_INPUT`, `TICKET_ID`, `TODAY`
- Expected file pattern: `{TODAY}-{TICKET_ID}-description.md`
- **Gate:** If the request itself is ambiguous or underspecified in a way that would change what gets researched or built, STOP now and ask the user (per the Open-Questions Gate above) BEFORE spawning any sub-agent. Fold the answers into `USER_INPUT`.

### 1. Create Tracking Todo

Use TodoWrite to create:

```
- [ ] Phase 1: Research (spawn sub-agent)
- [ ] Phase 2: Plan (spawn sub-agent)
- [ ] Phase 3: Implement (spawn sub-agent)
- [ ] Phase 4: Run tests
```

### 2. Phase 1: Research Sub-Agent

**USE THE TASK TOOL** to spawn a sub-agent:

```
Task(
  description: "Research codebase for: {USER_INPUT}",
  prompt: """
You are a research agent. Execute the /research_codebase command.

YOUR INPUT:
{USER_INPUT}

YOUR TASK:
Follow the ~/.claude/commands/research_codebase.md instructions exactly:
1. Analyze and decompose the research question
2. Use codebase-locator, codebase-analyzer, pattern-finder agents
3. Document ONLY what exists - no improvement suggestions
4. Write the research document to thoughts/shared/research/

OPEN QUESTIONS - DO NOT GUESS:
You cannot talk to the user. If you hit an ambiguity that would materially
change the research scope or conclusions and that you CANNOT resolve with
high confidence from the codebase, DO NOT assume an answer and DO NOT
write a final document. Instead respond with ONLY:

NEEDS_CLARIFICATION
1. <question> - options/tradeoffs you see; recommended default if any
2. <question> - ...

WHEN COMPLETE (only if there are no blocking open questions):
Respond with ONLY this line:
RESEARCH_COMPLETE: <full path to created file>
"""
)
```

**Wait for the Task to complete, then apply the Open-Questions Gate:**

- If the response is `NEEDS_CLARIFICATION`, follow the gate: STOP, ask the user, wait for answers, then re-spawn this same research sub-agent with a `USER CLARIFICATIONS` section appended. Do NOT continue to Phase 2.
- Only once the response is `RESEARCH_COMPLETE: <path>` do you proceed.

**CRITICAL - Extract the exact file path:**

1. The sub-agent response will contain: `RESEARCH_COMPLETE: <path>`
2. Parse the EXACT path from this response (e.g., `thoughts/shared/research/2025-01-24-ENG-1234-feature.md`)
3. Store this as `RESEARCH_PATH` - you will use this EXACT path in Phase 2
4. Verify the file exists using: `ls -la {RESEARCH_PATH}`
5. Open the file and read its "Open Questions" / "Offene Fragen" section (if any). If it contains unresolved BLOCKING questions, apply the Open-Questions Gate before moving on, even if the agent returned `RESEARCH_COMPLETE`.

Update todo: `- [x] Phase 1: Research (spawn sub-agent)`

### 3. Phase 2: Planning Sub-Agent

**USE THE TASK TOOL** to spawn a sub-agent.

**IMPORTANT:** Use the EXACT `RESEARCH_PATH` from Phase 1 - do NOT use a placeholder or guess the filename.

```
Task(
  description: "Create implementation plan based on research",
  prompt: """
You are a planning agent. Execute the /create_plan command.

YOUR INPUT:
Read this research document FULLY: {RESEARCH_PATH}

NOTE: This is the exact file created by the research phase. Read it completely before proceeding.

YOUR TASK:
Follow the ~/.claude/commands/create_plan.md instructions exactly:
1. Read the research document completely
2. Analyze and verify understanding
3. Research code patterns with sub-agents
4. Create a detailed plan with phases and verification steps
5. Write the plan to thoughts/shared/plans/

OPEN QUESTIONS - DO NOT GUESS:
The /create_plan process is normally interactive, but you cannot talk to the
user here. If a design decision would materially change the plan's approach,
data model, scope, or acceptance criteria and you CANNOT resolve it with high
confidence, DO NOT pick an answer yourself and DO NOT write a final plan.
Instead respond with ONLY:

NEEDS_CLARIFICATION
1. <question> - options/tradeoffs you see; recommended default if any
2. <question> - ...

WHEN COMPLETE (only if there are no blocking open questions):
Respond with ONLY this line:
PLAN_COMPLETE: <full path to created file>
"""
)
```

**Wait for the Task to complete, then apply the Open-Questions Gate:**

- If the response is `NEEDS_CLARIFICATION`, follow the gate: STOP, ask the user, wait for answers, then re-spawn this same planning sub-agent with a `USER CLARIFICATIONS` section appended (and the same `RESEARCH_PATH`). Do NOT continue to Phase 3.
- Only once the response is `PLAN_COMPLETE: <path>` do you proceed.

**CRITICAL - Extract the exact file path:**

1. The sub-agent response will contain: `PLAN_COMPLETE: <path>`
2. Parse the EXACT path from this response (e.g., `thoughts/shared/plans/2025-01-24-ENG-1234-feature.md`)
3. Store this as `PLAN_PATH` - you will use this EXACT path in Phase 3
4. Verify the file exists using: `ls -la {PLAN_PATH}`
5. Open the file and read its "Open Questions" / "Offene Fragen" section (if any). If it contains unresolved BLOCKING questions, apply the Open-Questions Gate before moving on, even if the agent returned `PLAN_COMPLETE`.

Update todo: `- [x] Phase 2: Plan (spawn sub-agent)`

### 4. Phase 3: Implementation Sub-Agent

**USE THE TASK TOOL** to spawn a sub-agent.

**IMPORTANT:** Use the EXACT `PLAN_PATH` from Phase 2 - do NOT use a placeholder or guess the filename.

```
Task(
  description: "Implement the plan",
  prompt: """
You are an implementation agent. Execute the /implement_plan command.

YOUR INPUT:
Read this plan FULLY: {PLAN_PATH}

NOTE: This is the exact file created by the planning phase. Read it completely before proceeding.

YOUR TASK:
Follow the ~/.claude/commands/implement_plan.md instructions exactly:
1. Read the plan completely
2. Implement phase by phase
3. Run automated verification after each phase
4. Stop at manual verification steps

OPEN QUESTIONS - DO NOT GUESS:
If the plan turns out to be wrong, contradictory, or under-specified in a way
that forces a real decision (not a trivial default), DO NOT invent an approach
and keep coding. Stop implementing and respond with ONLY:

NEEDS_CLARIFICATION
1. <question> - what the plan says vs. what you found; options; recommended default if any
2. <question> - ...

WHEN COMPLETE (only if there were no blocking open questions):
Respond with:
IMPLEMENTATION_COMPLETE
Phases completed: <list>
Tests: <PASSED/FAILED>
Manual verification pending: <list>
"""
)
```

**Wait for the Task to complete, then apply the Open-Questions Gate:**

- If the response is `NEEDS_CLARIFICATION`, follow the gate: STOP, ask the user, wait for answers. Then decide with the user whether to (a) re-spawn the implementation sub-agent with a `USER CLARIFICATIONS` section, or (b) go back and update the plan first. Do NOT continue to Phase 4.
- Only once the response is `IMPLEMENTATION_COMPLETE` do you proceed.

Update todo: `- [x] Phase 3: Implement (spawn sub-agent)`

### 5. Phase 4: Final Tests

Run directly (no sub-agent needed):

```bash
make test
```

Update todo: `- [x] Phase 4: Run tests`

### 6. Present Summary

```
═══════════════════════════════════════════════════════════
✅ WORKFLOW COMPLETE
═══════════════════════════════════════════════════════════

📄 Research:  {RESEARCH_PATH}
📋 Plan:      {PLAN_PATH}
🧪 Tests:     [PASSED/FAILED]

Manual verification pending:
- [ ] [items from implementation response]
```

---

## Error Handling

If a Task fails:

1. Stop the workflow immediately
2. Show which phases completed successfully
3. Show the error from the failed Task
4. Ask: "Should I retry this phase or would you like to intervene manually?"

## Resuming

`/full_workflow --from-research <path>`:

- Skip phase 1, use provided research file, spawn sub-agent for phase 2

`/full_workflow --from-plan <path>`:

- Skip phases 1 and 2, spawn sub-agent for phase 3 only

---

## Important Notes

- **ALWAYS use the Task tool** - never execute commands directly in main context
- Each Task runs in **isolated context** (like a fresh conversation)
- Files in thoughts/shared/ are the **communication channel** between agents
- Wait for each Task to **fully complete** before starting the next
- **Never spawn the next phase while a `NEEDS_CLARIFICATION` from the current phase is unanswered** - the Open-Questions Gate always wins over "keep moving"
- The main orchestrator only **coordinates** - sub-agents do the actual work
