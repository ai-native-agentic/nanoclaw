# NANOCLAW - KNOWLEDGE BASE

**Generated:** 2026-03-10
**Commit:** cfabdd8
**Branch:** main

## OVERVIEW

Container-isolated AI assistant — Claude agents run in separate Linux containers (Apple Container/Docker) with filesystem isolation. Built for individual users with bespoke customization via Claude Code. Multi-channel (WhatsApp, Telegram, Slack, Discord, Gmail), skill-based architecture, 34.9k tokens (17% of context window). First to support Agent Swarms.

Stack: Node.js 20+, TypeScript, SQLite, pino, better-sqlite3, YAML, Zod

## STRUCTURE

nanoclaw/
├── assets/
├── config-examples/
├── container/
│   ├── agent-runner/
│   ├── skills/
├── docs/
├── groups/
│   ├── global/
│   └── main/
├── launchd/
├── repo-tokens/
│   ├── examples/
│   └── README.md
├── scripts/
├── setup/
│   ├── index.ts
├── skills-engine/
│   ├── __tests__/
│   ├── index.ts
├── src/
│   ├── channels/
│   ├── index.ts
├── AGENTS.md
├── README.md
├── package.json

## WHERE TO LOOK

| Task | Location | Notes |
|------|----------|-------|
| Main orchestrator | `src/index.ts` | Message loop, state management, agent dispatch |
| Container spawning | `src/container-runner.ts` | Spawn isolated containers with mounts |
| Channel setup | `src/channels/registry.ts` | Self-registering channel system |
| Message routing | `src/router.ts` | Outbound message formatting per channel |
| IPC tasks | `src/ipc.ts` | Cross-container communication |
| Scheduled tasks | `src/task-scheduler.ts` | Cron job execution |
| Database ops | `src/db.ts` | SQLite wrapper (better-sqlite3) |
| Mount security | `src/mount-security.ts` | Path validation for container mounts |
| Container runtime | `src/container-runtime.ts` | Abstract backend (Apple Container/Docker) |
| Group memory | `groups/{name}/CLAUDE.md` | Per-group context isolation |
| Agent tools | `container/skills/` | Browser automation + custom tools |
| Setup wizard | `setup/index.ts` | First-time configuration |

## CONVENTIONS

### Container Isolation
- Each group runs agents in separate containers
- Filesystem mounts: explicit whitelist only
- No shared memory between groups
- Bash commands execute inside container, not on host

### Skill System
- Skills self-register at startup via `channels/registry.ts`
- Slash commands: `/setup`, `/customize`, `/debug`, `/update-nanoclaw`, `/qodo-pr-resolver`, `/get-qodo-rules`
- Apply skills: `npx tsx scripts/apply-skill.ts .claude/skills/{skill-name}`

### Channel Architecture
```typescript
// Channels are skills that self-register
export const whatsappChannel: Channel = {
  name: 'whatsapp',
  start: async (config) => { /* ... */ },
  send: async (message) => { /* ... */ }
};
```

### Group Isolation
- Each group: separate CLAUDE.md memory file
- No cross-group data leakage
- Group folder mounted read-write in container

### Database Schema
- SQLite for persistent state
- better-sqlite3 for sync API
- Schema in `src/db.ts`

## ANTI-PATTERNS (THIS PROJECT)

| Forbidden | Why | Reference |
|-----------|-----|-----------|
| Running commands on host OS | Security — always exec in container | `container-runner.ts` isolation |
| Mounting entire home directory | Violates principle of least privilege | `mount-security.ts` |
| Sharing memory across groups | Breaks isolation guarantee | Architecture doc |
| Configuration sprawl | Customization = code changes, not YAML | `README.md` philosophy |
| Monolithic features | Keep codebase small + understandable | 34.9k token budget |
| Skipping container rebuild after skill changes | Stale build cache | `CLAUDE.md` troubleshooting |

## PROVEN RESULTS

**Production Deployment**:
- First AI assistant with Agent Swarms (team collaboration)
- Container isolation: true OS-level security (not permission checks)
- Multi-channel: WhatsApp, Telegram, Slack, Discord, Gmail
- Codebase size: 34.9k tokens (vs OpenClaw's 500k LOC)
- Version: 1.2.10 (NPM package)

**Security Model**:
- Containers: Apple Container (macOS) or Docker (Linux)
- Filesystem: explicit mount whitelist per group
- No shared state between agents

## COMMANDS

```bash
pnpm auth                           # tsx src/whatsapp-auth.ts
pnpm build                           # tsc
pnpm dev                           # tsx src/index.ts
pnpm format                           # prettier --write "src/**/*.ts"
pnpm format:check                           # prettier --check "src/**/*.ts"
pnpm format:fix                           # prettier --write "src/**/*.ts"
pnpm prepare                           # husky
pnpm setup                           # tsx setup/index.ts
pnpm start                           # node dist/index.js
pnpm test                           # vitest run
pnpm test:watch                           # vitest
pnpm typecheck                           # tsc --noEmit
```

## NOTES

- **WhatsApp skill**: Separate since recent versions — run `/add-whatsapp` to install
- **Container cache**: `--no-cache` doesn't invalidate COPY steps; prune builder volume for clean rebuild
- **Agent Swarms**: Unique feature for multi-agent collaboration in chat
- **Customization philosophy**: Fork repo + modify code (not YAML configs)
- **Claude Code native**: No installation wizard — Claude guides setup via `/setup`
- **Group memory**: Isolated CLAUDE.md per group prevents context bleeding
