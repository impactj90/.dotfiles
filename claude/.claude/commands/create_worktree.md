---
description: Create + provision a runnable git worktree for a branch (terp workflow - plain git, no humanlayer)
---

Create a separate git worktree so a ticket can be implemented AND run in parallel,
without disturbing the main checkout's uncommitted work. By the end the worktree
is fully runnable on its own port against the shared local Supabase.

ARGUMENTS: a short branch slug (e.g. `deterministic-assistant-v1`). Optionally a
plan path.

## Conventions (this repo)

- Worktree path: `~/wt/terp/<branch_slug>`
- Branch name: `feat/<branch_slug>` (off `staging` by default; ask if `master`).
- NO `hack/create_worktree.sh`, NO `humanlayer` - plain `git worktree`.
- `.env` and `.env.local` are GITIGNORED -> not in the worktree -> must be copied.
- `thoughts/` is in-repo: TRACKED docs appear automatically; UNTRACKED ones
  (fresh plan/research/ticket) must be copied (step 4).
- Dev port: the `dev` script hardcodes `-p 3001`. The worktree runs on the next
  free port (3002, 3003, ...) via `pnpm exec next dev --turbopack -p <port>`.
- Supabase: ONE local stack (fixed ports, `project_id="terp"`), SHARED by all
  worktrees. Do NOT start a second stack; both apps use the same dev DB.

## Steps

1. Confirm slug, base branch (`staging` default), plan path.

2. Create the worktree:
   ```bash
   mkdir -p ~/wt/terp
   git -C /home/tolga/projects/terp worktree add -b feat/<slug> ~/wt/terp/<slug> staging
   git -C /home/tolga/projects/terp worktree list
   ```

3. Provision it (env + port + deps + prisma client). Run as one block:
   ```bash
   SRC=/home/tolga/projects/terp
   DST=~/wt/terp/<slug>
   cp "$SRC/.env" "$DST/.env"
   cp "$SRC/.env.local" "$DST/.env.local"
   # pick the next free port starting at 3002: skip ports already configured in
   # OTHER worktrees' .env.local AND ports currently listening
   USED=$(grep -rhoE 'NEXT_PUBLIC_APP_URL=http://127.0.0.1:[0-9]+' ~/wt/terp/*/.env.local 2>/dev/null | grep -oE '[0-9]+$')
   PORT=3002
   while echo "$USED" | grep -qx "$PORT" || ss -ltn 2>/dev/null | grep -q ":$PORT "; do PORT=$((PORT+1)); done
   echo "worktree port: $PORT"
   sed -i "s#NEXT_PUBLIC_APP_URL=http://127.0.0.1:3001#NEXT_PUBLIC_APP_URL=http://127.0.0.1:$PORT#" "$DST/.env.local"
   ( cd "$DST" && pnpm install && pnpm db:generate )
   echo "Run it:  cd $DST && pnpm exec next dev --turbopack -p $PORT"
   ```

4. Copy any UNTRACKED thoughts docs for this ticket (check
   `git -C /home/tolga/projects/terp status --short -- thoughts/` first):
   ```bash
   cp /home/tolga/projects/terp/thoughts/shared/plans/<plan>.md       ~/wt/terp/<slug>/thoughts/shared/plans/
   cp /home/tolga/projects/terp/thoughts/shared/research/<research>.md ~/wt/terp/<slug>/thoughts/shared/research/
   cp /home/tolga/projects/terp/thoughts/shared/tickets/<ticket>.md    ~/wt/terp/<slug>/thoughts/shared/tickets/
   ```
   Verify the worktree's `git status --short` shows only the intended untracked
   docs (the main checkout's other uncommitted changes must NOT appear there).

5. Tell the user how to run / implement:
   ```bash
   # Supabase: start ONCE from any checkout if not already up
   pnpm db:start

   cd ~/wt/terp/<slug>
   pnpm exec next dev --turbopack -p <PORT>      # the port printed in step 3
   claude   # then: /implement_plan thoughts/shared/plans/<plan>.md
   ```

## Notes / gotchas

- The worktree app on `:<PORT>` hits the SAME local Supabase DB as `:3001`.
- After a schema change: `npx supabase migration up` (applies pending migrations
  NON-destructively to the shared DB), then `pnpm db:generate` and RESTART the
  worktree dev server (PrismaClient is cached on `globalThis`).
- Do NOT `pnpm db:reset` in a worktree casually - it WIPES the shared dev DB
  (both apps' data). Use `supabase migration up` instead.
- Use ONLY relative paths (`thoughts/shared/...`) inside `/implement_plan`.
- Clean up when done: `git worktree remove ~/wt/terp/<slug>`.
