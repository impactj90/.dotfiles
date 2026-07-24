---
description: Show implementation plans grouped by status (draft / ready / implementing / implemented)
---

# Plans

Show what is actually open in `thoughts/shared/plans/`.

## When invoked

1. Run the index script:

   ```bash
   ~/.claude/scripts/plan-index.sh
   ```

   With an argument to filter: `~/.claude/scripts/plan-index.sh ready`
   (`draft`, `ready`, `implementing`, `implemented`, `abandoned`, `other`, `none`).

2. **Summarize, don't dump.** The raw output can be hundreds of lines. Report:
   - the count per status
   - every plan in `draft` and `implementing` by name - those are the ones with
     unfinished business attached to them
   - `ready` plans only if the user asked for them or there are fewer than ~10
   - never list the `none` group item by item; just say how many there are

3. If the user names a plan, read it and give them the **TL;DR section** plus its
   current status. Do not summarize the whole plan unless asked.

## Status lifecycle

```
draft ──► ready ──► implementing ──► implemented
  │                                      
  └──────────────► abandoned
```

- `draft` - being written, not signed off. Code must not be written against it.
- `ready` - reviewed and approved by the user. Implementation may start.
- `implementing` - `/implement_plan` is working through it right now.
- `implemented` - all phases done and verified.
- `abandoned` - dropped or superseded. Say why in the plan body.

`none` and `other` are legacy: plans written before the convention existed.
Do not mass-rewrite them. If you happen to touch such a plan for another
reason and its real state is obvious from the plan body or git history, set the
right status while you are there.
