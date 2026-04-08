# Cascade Chat Conversation

  Note: _This is purely the output of the chat conversation and does not contain any raw data, codebase snippets, etc. used to generate the output._

### User Input

@[/home/robin/forgejo/HelloWord/README.md:L55-L58] is this portion of the @[README.md] accurate? I thought it ONLY applied to debug build (and therefore is not representative of *anything* in production so a) should not be the main path shown in the @[README.md] and b) ideally should be entirely deprecated with a global rule key learning that every effort should line up collinearly on the same trajectory--a debug that debugs a process not used in production is anti-productive

### Planner Response

Let me read the README and understand the current architecture before answering.

*Viewed [README.md](file:///home/robin/forgejo/HelloWord/README.md) *

*Viewed [PROJECT_INDEX.md](file:///home/robin/forgejo/HelloWord/PROJECT_INDEX.md) *

*Viewed [PROJECT_INDEX.json](file:///home/robin/forgejo/HelloWord/PROJECT_INDEX.json) *

### Planner Response

Let me verify how production builds actually access data — whether they use the Express API or something else.

*Viewed [webSqlAdapter.ts](file:///home/robin/forgejo/HelloWord/src/core/services/webSqlAdapter.ts) *

*Viewed [liturgicalEngineInterface.web.ts](file:///home/robin/forgejo/HelloWord/src/core/services/liturgicalEngineInterface.web.ts) *

*Viewed [nativeDataAdapter.ts](file:///home/robin/forgejo/HelloWord/src/core/services/nativeDataAdapter.ts) *

*Viewed [storageAdapter.ts](file:///home/robin/forgejo/HelloWord/src/core/services/storageAdapter.ts) *

### Planner Response

Let me also check the dev script to see how the API is wired in.

*Viewed [package.json](file:///home/robin/forgejo/HelloWord/package.json) *

### Planner Response

Your instinct is correct — and the situation is actually **worse than you think**. Let me confirm with one more check:

*Grep searched codebase*

*Grep searched codebase*

### Planner Response

## Confirmed: The Express API Server is Dead Code

Your suspicion is correct, and the reality is actually more extreme than "debug-only":

**The [ApiAdapter](file:///home/robin/forgejo/HelloWord/src/core/services/storageAdapter.ts:54:0-136:1) class is never instantiated.** The [createStorageAdapter()](file:///home/robin/forgejo/HelloWord/src/core/services/storageAdapter.ts:144:0-197:1) factory at `@/home/robin/forgejo/HelloWord/src/core/services/storageAdapter.ts:151-198` has exactly two branches:
- `window.__TAURI__` → [NativeDataAdapter](file:///home/robin/forgejo/HelloWord/src/core/services/nativeDataAdapter.ts:111:0-560:1) (direct SQLite via tauri-plugin-sql)
- Otherwise → [WebSqlAdapter](file:///home/robin/forgejo/HelloWord/src/core/services/webSqlAdapter.ts:30:0-461:1) (sql.js WASM, fetches `liturgical.db` from `public/`)

Neither branch creates an [ApiAdapter](file:///home/robin/forgejo/HelloWord/src/core/services/storageAdapter.ts:54:0-136:1). The variable `_apiAdapter` at line 142 is declared but **never assigned anywhere**. Since the Session 17 [WebSqlAdapter](file:///home/robin/forgejo/HelloWord/src/core/services/webSqlAdapter.ts:30:0-461:1) rewrite, the Express API server on `:9837` is not used by **any** code path — not production, not dev, not even `npm run tauri:dev` (which still starts it via `npm-run-all` but nothing connects to it).

### What the README diagram claims vs. reality

| | README diagram (L39-65) | Actual production |
|---|---|---|
| **Web/PWA** | App → Express API :9837 → SQLite | App → sql.js WASM → `public/liturgical.db` |
| **Android** | App → Express API :9837 → SQLite | App → tauri-plugin-sql → bundled `liturgical.db` |
| **Desktop** | App → Express API :9837 → SQLite | App → tauri-plugin-sql → bundled `liturgical.db` |

The API server and [ApiAdapter](file:///home/robin/forgejo/HelloWord/src/core/services/storageAdapter.ts:54:0-136:1) are dead code. The `npm run dev:api` script starts a process nothing talks to.

*Asked user a question*

*Updated todo list*

### Planner Response

Let me gather the remaining context needed for a complete architecture document and plan.

*Viewed [CHECKLIST.md](file:///home/robin/forgejo/HelloWord/CHECKLIST.md) *

*Viewed [CLAUDE.md](file:///home/robin/forgejo/HelloWord/CLAUDE.md) *

*Viewed [AGENTS.md](file:///home/robin/forgejo/HelloWord/AGENTS.md) *

### Planner Response

Now I have all the context needed. Let me also check the remaining CHECKLIST.md content and recent git history.

*Viewed [CHECKLIST.md](file:///home/robin/forgejo/HelloWord/CHECKLIST.md) *

*User accepted the command `git log --oneline -n 20`*

*Edited relevant file*

*Updated todo list*

### Planner Response

Plan saved to [/home/robin/.windsurf/plans/api-deprecation-cleanup-f04104.md](file:///home/robin/.windsurf/plans/api-deprecation-cleanup-f04104.md:0:0-0:0). Here's the summary:

## Plan: Express API Server Deprecation & Collinear Rule

**8 tasks across 2 phases:**

### Phase A — Architecture doc
- Write `DOCS/ARCHITECTURE/API-DEPRECATION.md` with full entity table and rationale

### Phase B — Cleanup (8 checklist tasks)

| Task | Scope |
|------|-------|
| **13.1** | Remove [ApiAdapter](file:///home/robin/forgejo/HelloWord/src/core/services/storageAdapter.ts:54:0-136:1) class + `_apiAdapter` variable from [storageAdapter.ts](file:///home/robin/forgejo/HelloWord/src/core/services/storageAdapter.ts:0:0-0:0) |
| **13.2** | Fix error message in `nativeDataAdapter.ts:46` referencing dead ApiAdapter |
| **13.3** | Simplify [package.json](file:///home/robin/forgejo/HelloWord/package.json:0:0-0:0) scripts — remove `dev:api`, simplify `tauri:dev`/`android:dev`/`ios:dev` to not start Express |
| **13.4** | Rewrite README architecture diagram to show actual dual-path (sql.js WASM / tauri-plugin-sql) |
| **13.5** | Update [PROJECT_INDEX.md](file:///home/robin/forgejo/HelloWord/PROJECT_INDEX.md:0:0-0:0) + [PROJECT_INDEX.json](file:///home/robin/forgejo/HelloWord/PROJECT_INDEX.json:0:0-0:0) (paired) |
| **13.6** | Update [CLAUDE.md](file:///home/robin/forgejo/HelloWord/CLAUDE.md:0:0-0:0) — reclassify liturgical-api as corpus-build tool |
| **13.7** | Add **collinear-trajectory rule** to [CLAUDE.md](file:///home/robin/forgejo/HelloWord/CLAUDE.md:0:0-0:0), [AGENTS.md](file:///home/robin/forgejo/HelloWord/AGENTS.md:0:0-0:0), and global memory |
| **13.8** | Verify: build, grep for dead references |

### What stays
- `liturgical-api/` directory (corpus builder + manual testing tool)
- `liturgical.db` (the actual corpus DB, copied to `public/` at build time)

### The new global rule (13.7)
> **Debug infrastructure must be collinear with production.** Every dev tool must exercise the same code paths used in production. A debug process that tests infrastructure not used in production is anti-productive — it creates false confidence and maintenance drag.

Review the full plan at [/home/robin/.windsurf/plans/api-deprecation-cleanup-f04104.md](file:///home/robin/.windsurf/plans/api-deprecation-cleanup-f04104.md:0:0-0:0). When you're ready, I'll begin implementation.

### User Input

I recall from a previous discussion there may be still-used components cohabitating with the previous/misguided api's folder that are needd that prevented the folder from simply being pruned. I have a codemap of the environment around @[public/liturgical.db] being mapped to verify this first. 

On a seond note, would you also create a global rule that entities naming, such as 'liturgical.db' as a filename or 'ActualLiturgical....': they should 1) follow a convention that, when implemented as an SOP, makes naming predictably-meaningful and not 'relative' to ('ActualLiturgicalEngine.tsx' is only meaningful in relation to 'NotReally.tsx' or other meaningless references); and 2) that the convention should be maximally-efficient AND semantically-predictably meaningful ('wasmTauriSQLPropersEngine.tsx' would be great, etc). In terms of the modern CLAUDE.md structure, I would guess this should be contained in a "CONVENTIONS.md" file that is referenced (not conditionally) but not contained in the main CLAUDE.md (so it is organized and modular but not cluttered or conditional); on the other hand, BUILD_CONVENTIONS.md would be referenced conditionally in CLAUDE.md such that it does not waste token quota or processing unless CLAUDE.md is being read within context of a session concerned with building--do you agree? 

@[liturgical.db: Build Pipeline, Multi-Platform Loading, and Query Execution] is the codemap surrounding liturgical.db (e.g. I would suggest a more semantically-meaningful and predictably-systematic for a nomenclature, such as SQLitedbLatinEngMissalLiteraryComponents.db  perhaps?)

### Planner Response

Let me first investigate what's still used from `liturgical-api/` before asking questions.

*Grep searched codebase*

*Grep searched codebase*

*Grep searched codebase*

*Grep searched codebase*

*Grep searched codebase*

*Listed directory [liturgical-api](file:///home/robin/forgejo/HelloWord/liturgical-api) *

*Listed directory [lib](file:///home/robin/forgejo/HelloWord/liturgical-api/lib) *

*Listed directory [scripts](file:///home/robin/forgejo/HelloWord/liturgical-api/scripts) *

*Grep searched codebase*

*Grep searched codebase*

*Grep searched codebase*

### Planner Response

Good — the investigation confirms the dependency. Let me check one more thing about the build-corpus dependencies.

*Grep searched codebase*

*Grep searched codebase*

### Planner Response

## Investigation Results

Here's what I found about [liturgical-api/](file:///home/robin/forgejo/HelloWord/liturgical-api:0:0-0:0) dependencies:

### What's still used (cannot prune)

| File | Used by | Purpose |
|------|---------|---------|
| `assets/liturgical.db` | `package.json:11` (`prebuild`), `package.json:27` (`android:copy-dist`) | Canonical corpus DB — copied to `public/` and Android assets |
| [scripts/build-corpus.js](file:///home/robin/forgejo/HelloWord/liturgical-api/scripts/build-corpus.js:0:0-0:0) | Manual rebuild of corpus | Transforms DO `.txt` → SQLite |
| [lib/do-parser.js](file:///home/robin/forgejo/HelloWord/liturgical-api/lib/do-parser.js:0:0-0:0) | `build-corpus.js:22` | Parser for DO file format |
| [lib/do-resolver.js](file:///home/robin/forgejo/HelloWord/liturgical-api/lib/do-resolver.js:0:0-0:0) | `build-corpus.js:23` | Macro/cross-ref resolution during build |

### Dead runtime code (only used by Express server)

| File | Required by | Dead? |
|------|-------------|-------|
| [liturgical-api.js](file:///home/robin/forgejo/HelloWord/liturgical-api/liturgical-api.js:0:0-0:0) | Nothing (it IS the server) | ✅ Dead |
| [lib/calendar.js](file:///home/robin/forgejo/HelloWord/liturgical-api/lib/calendar.js:0:0-0:0) | `liturgical-api.js:13` only | ✅ Dead |
| [lib/corpus-db.js](file:///home/robin/forgejo/HelloWord/liturgical-api/lib/corpus-db.js:0:0-0:0) | `liturgical-api.js:12` only | ✅ Dead |
| [lib/cross-ref.js](file:///home/robin/forgejo/HelloWord/liturgical-api/lib/cross-ref.js:0:0-0:0) | `liturgical-api.js:14` only | ✅ Dead |
| [lib/db.js](file:///home/robin/forgejo/HelloWord/liturgical-api/lib/db.js:0:0-0:0) | `liturgical-api.js:15`, [corpus-db.js](file:///home/robin/forgejo/HelloWord/liturgical-api/lib/corpus-db.js:0:0-0:0) | ✅ Dead |
| [lib/parser.js](file:///home/robin/forgejo/HelloWord/liturgical-api/lib/parser.js:0:0-0:0), [lib/resolver.js](file:///home/robin/forgejo/HelloWord/liturgical-api/lib/resolver.js:0:0-0:0) | Unknown — possibly legacy duplicates of `do-parser`/`do-resolver` | Likely dead |

The folder **cannot be simply deleted** because `prebuild` and `android:copy-dist` both copy `liturgical-api/assets/liturgical.db`. But the runtime API code is cleanly separable.

Before I write the full plan, a few questions:

*Asked user a question*

*Asked user a question*

### Planner Response

Let me locate the other tool config files on this machine.

*Searched filesystem*

*Searched filesystem*

*Searched filesystem*

*User accepted the command `find /home/robin -maxdepth 3 -name '.clinerules*' -o -name '.roomodes*' -o -name '.roo*' -o -name 'AGENTS.md' -o -name '.cursorrules' -o -name '.windsurfrules' 2>/dev/null | head -30`*

*User accepted the command `find /home/robin -maxdepth 2 -name '.claude' -type d 2>/dev/null | head -10`*

*User accepted the command `ls -la /home/robin/.claude/ 2>/dev/null && cat /home/robin/.claude/settings.json 2>/dev/null || echo "No global claude settings found"`*

*User accepted the command `find /home/robin/.claude -type f -name '*.md' 2>/dev/null | head -10`*

*User accepted the command `find /home/robin -maxdepth 2 -name 'CONVENTIONS.md' -o -name 'BUILD_CONVENTIONS.md' 2>/dev/null | head -10`*

*Viewed [CLAUDE.md](file:///home/robin/.claude/CLAUDE.md) *

*Updated todo list*

*Viewed [CLAUDE.md](file:///home/robin/.claude/CLAUDE.md) *

### Planner Response

Now let me write the comprehensive plan integrating all three concerns.

*Edited relevant file*

### User Input

just a note that i got sa notification that we've used 93% of quota until april 12th. I think i have some prepaid credit that is worth using towards this effort but also to save state soon 

### Planner Response

Understood — let me save state now by writing the plan file with all findings so nothing is lost if the session ends.

*Edited relevant file*

### Planner Response

Let me save the critical findings to persistent memory so nothing is lost across sessions.

### Planner Response

State is saved. Here's where we stand:

**Saved to persistent memory:**
- [liturgical-api/](file:///home/robin/forgejo/HelloWord/liturgical-api:0:0-0:0) dependency analysis (what's dead vs essential)
- Full pending execution plan with all user decisions

**Saved to disk:**
- [/home/robin/.windsurf/plans/conventions-and-api-cleanup-f04104.md](file:///home/robin/.windsurf/plans/conventions-and-api-cleanup-f04104.md:0:0-0:0) — complete plan with investigation findings, execution order, and all tool config locations

**Nothing has been implemented yet.** The plan is ready to execute from step 1 whenever you resume. You can pick this up in a new session — the plan file and memories have everything needed to continue without re-investigating.

*Updated todo list*

### Planner Response

Ready when you are. The plan and all findings are saved to both disk and memory — you can resume this in a fresh session without losing context. Just say "go" or confirm the plan when you're ready to implement.

### User Input

Ok conrtinue implementing the global efforts so that I dont forget to come back to it, and that it would automatically apply, going forward. 

*Updated todo list*

### Planner Response

Starting implementation. Step 5: Create the global naming conventions file.

*Edited relevant file*

### Planner Response

Step 5 done. Now step 6: Create BUILD_CONVENTIONS.md.

*Edited relevant file*

### Planner Response

Step 6 done. Now step 7: Update the global Claude Code CLI [CLAUDE.md](file:///home/robin/github/CLAUDE.md:0:0-0:0) with references and the collinear rule.

*Viewed [CLAUDE.md](file:///home/robin/.claude/CLAUDE.md) *

*Edited relevant file*

### Planner Response

Step 7 done. Now step 8: Update Windsurf global memory with the naming convention and collinear rule.

### Planner Response

Step 8 done. Now step 9: Update the HelloWord project [CLAUDE.md](file:///home/robin/github/CLAUDE.md:0:0-0:0) and [AGENTS.md](file:///home/robin/forgejo/HelloWord/AGENTS.md:0:0-0:0) with references.

*Viewed [CLAUDE.md](file:///home/robin/forgejo/HelloWord/CLAUDE.md) *

*Edited relevant file*

### Planner Response

Now update [AGENTS.md](file:///home/robin/forgejo/HelloWord/AGENTS.md:0:0-0:0):

*Viewed [AGENTS.md](file:///home/robin/forgejo/HelloWord/AGENTS.md) *

*Edited relevant file*

*Updated todo list*

### Planner Response

Now let me update the Windsurf global memory to match the new AGENTS.md content (since the system-loaded memory for AGENTS.md is stale):

*Updated todo list*

### Planner Response

Let me quickly verify the cross-references are consistent.

*User accepted the command `echo "=== Global CLAUDE.md references ===" && grep -n "CONVENTIONS\|BUILD_CONVENTIONS\|collinear\|COLLINEAR" /home/robin/.claude/CLAUDE.md | head -10 && echo "" && echo "=== HelloWord CLAUDE.md references ===" && grep -n "CONVENTIONS\|BUILD_CONVENTIONS\|collinear\|COLLINEAR" /home/robin/forgejo/HelloWord/CLAUDE.md | head -10 && echo "" && echo "=== HelloWord AGENTS.md references ===" && grep -n "CONVENTIONS\|BUILD_CONVENTIONS\|collinear\|Collinear\|COLLINEAR" /home/robin/forgejo/HelloWord/AGENTS.md | head -10 && echo "" && echo "=== Files exist check ===" && ls -la /home/robin/.claude/CONVENTIONS.md /home/robin/.claude/BUILD_CONVENTIONS.md 2>&1`*

### Planner Response

All cross-references are consistent. Let me finalize.

*Updated todo list*

### Planner Response

## Summary: Global Rules Implementation Complete

### What was created/modified

| File | Action | Purpose |
|------|--------|---------|
| [/home/robin/.claude/CONVENTIONS.md](file:///home/robin/.claude/CONVENTIONS.md:0:0-0:0) | **Created** | Global naming & entity convention SOP — file naming formula, anti-patterns, class/module rules, database asset naming, collinear debug/production rule |
| [/home/robin/.claude/BUILD_CONVENTIONS.md](file:///home/robin/.claude/BUILD_CONVENTIONS.md:0:0-0:0) | **Created** | Build conventions (conditional load) — script naming, artifact naming, CI workflow naming, dist directory conventions |
| [/home/robin/.claude/CLAUDE.md](file:///home/robin/.claude/CLAUDE.md:0:0-0:0) | **Updated** | Added companion documents section (unconditional + conditional refs) + collinear debug/production rule section |
| [/home/robin/forgejo/HelloWord/CLAUDE.md](file:///home/robin/forgejo/HelloWord/CLAUDE.md:0:0-0:0) | **Updated** | Added companion documents refs + collinear rule + known violation note about dead Express API |
| [/home/robin/forgejo/HelloWord/AGENTS.md](file:///home/robin/forgejo/HelloWord/AGENTS.md:0:0-0:0) | **Updated** | Added companion documents refs + collinear rule + fixed "AGNENT" typo |
| **Windsurf global memory** | **Updated** | 3 new memories: naming convention SOP, dependency analysis, pending plan |

### How it works going forward

- **Claude Code CLI** reads `~/.claude/CLAUDE.md` automatically → sees [CONVENTIONS.md](file:///home/robin/.claude/CONVENTIONS.md:0:0-0:0) reference → loads naming rules every session
- **Windsurf** picks up the global memory with the convention summary
- **HelloWord project** agents see the rules in both [CLAUDE.md](file:///home/robin/github/CLAUDE.md:0:0-0:0) and [AGENTS.md](file:///home/robin/forgejo/HelloWord/AGENTS.md:0:0-0:0)
- **BUILD_CONVENTIONS.md** loads only when sessions involve build/CI/deploy (token-efficient)

### Still pending (separate session)

- **Phase 13: API deprecation code cleanup** — remove [ApiAdapter](file:///home/robin/forgejo/HelloWord/src/core/services/storageAdapter.ts:54:0-136:1), simplify dev scripts, rewrite README diagram. Full plan saved at [/home/robin/.windsurf/plans/conventions-and-api-cleanup-f04104.md](file:///home/robin/.windsurf/plans/conventions-and-api-cleanup-f04104.md:0:0-0:0)
- **Manual propagation** to other project CLAUDE.md files (18 repos listed in the plan file)
- **Codemap Trace 6** (API Server) should be marked deprecated after cleanup