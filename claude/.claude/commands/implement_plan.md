---
description: Implement technical plans from thoughts/shared/plans with verification
---

# Implement Plan

You are tasked with implementing an approved technical plan from `thoughts/shared/plans/`. These plans contain phases with specific changes and success criteria.

## Getting Started

When given a plan path:
- **Check `status:` in the plan's frontmatter first.**
  - `draft` - STOP. The plan has not been approved. Show the user its TL;DR and
    ask them to approve it (which sets `status: ready`) before you write code.
  - `ready` - set it to `implementing` and proceed.
  - `implementing` - a previous run was interrupted; pick up at the first
    unchecked item.
  - `implemented` - already done. Ask what the user actually wants before
    touching anything.
  - missing - a legacy plan from before the convention. Add
    `status: implementing` and carry on.
- Read the plan completely and check for any existing checkmarks (- [x])
- Read the original ticket and all files mentioned in the plan
- **Read files fully** - never use limit/offset parameters, you need complete context
- Think deeply about how the pieces fit together
- Create a todo list to track your progress
- Start implementing if you understand what needs to be done

If no plan path provided, ask for one.

## Implementation Philosophy

Plans are carefully designed, but reality can be messy. Your job is to:
- Follow the plan's intent while adapting to what you find
- Implement each phase fully before moving to the next
- Verify your work makes sense in the broader codebase context
- Update checkboxes in the plan as you complete sections

When things don't match the plan exactly, think about why and communicate clearly. The plan is your guide, but your judgment matters too.

If you encounter a mismatch:
- STOP and think deeply about why the plan can't be followed
- Present the issue clearly:
  ```
  Issue in Phase [N]:
  Expected: [what the plan says]
  Found: [actual situation]
  Why this matters: [explanation]

  How should I proceed?
  ```

## Verification Approach

After implementing a phase:
- Run the exact commands listed in that phase's "Automated Verification" section
- **If a listed command does not exist in this repo, STOP.** Do not silently
  substitute something else and carry on - a wrong verification command means
  the phase was never actually verified. Find the real command (check
  `package.json` scripts, `Makefile` targets, `justfile`, `CLAUDE.md`), run it,
  and correct the plan file so the remaining phases do not repeat the error.
- Respect any command the project forbids (`CLAUDE.md`, project memory, or the
  user) - e.g. full-project builds or typechecks that exhaust memory. Note that
  CI or the deploy platform covers those instead.
- Fix any issues before proceeding
- Update your progress in both the plan and your todos
- Check off completed items in the plan file itself using Edit
- **Pause for human verification**: After completing all automated verification for a phase, pause and inform the human that the phase is ready for manual testing. Use this format:
  ```
  Phase [N] Complete - Ready for Manual Verification

  Automated verification passed:
  - [List automated checks that passed]

  Please perform the manual verification steps listed in the plan:
  - [List manual verification items from the plan]

  Let me know when manual testing is complete so I can proceed to Phase [N+1].
  ```

If instructed to execute multiple phases consecutively, skip the pause until the last phase. Otherwise, assume you are just doing one phase.

do not check off items in the manual testing steps until confirmed by the user.


## If You Get Stuck

When something isn't working as expected:
- First, make sure you've read and understood all the relevant code
- Consider if the codebase has evolved since the plan was written
- Present the mismatch clearly and ask for guidance

Use sub-tasks sparingly - mainly for targeted debugging or exploring unfamiliar territory.

## Resuming Work

If the plan has existing checkmarks:
- Trust that completed work is done
- Pick up from the first unchecked item
- Verify previous work only if something seems off

## When All Phases Are Done

1. Set `status: implemented` in the plan's frontmatter.
2. Report back in the message itself - assume the user reads the message and not
   the plan file:
   ```
   Implemented: <plan title>  (thoughts/shared/plans/<file>.md -> status: implemented)

   Done: <one line per phase>
   Verified: <the commands you actually ran, and their result>
   Deviations from the plan: <what you had to do differently, or "none">
   Still needs manual verification: <list, or "nothing">
   ```
3. If you stopped early, leave `status: implementing` and say exactly which phase
   you got to and why you stopped.

Remember: You're implementing a solution, not just checking boxes. Keep the end goal in mind and maintain forward momentum.
