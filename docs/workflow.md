# How we work

Two people, one repo. Three layers, and each thing lives in exactly one of them.

| Layer | Tool | Holds |
|---|---|---|
| Conversation, presence | **Discord** | "what are you on?", links, screenshots, quick decisions in the moment |
| **State** — what to build, what's in progress, what shipped | **GitHub Issues + PRs** | the only answer to "is this done?" |
| Execution | **OpenCode sessions** | code, tests, PRs |

If a decision exists only in Discord, it does not exist. Messages are searchable but not citable, and editing one rewrites history. **Anything that must survive goes in the repo** — `docs/design.md` and `docs/WEEK_1_EXECUTION_PLAN.md` are the pattern.

## Channels

Four. More than that is overhead for a team of two.

| Channel | For | Not for |
|---|---|---|
| `#dev` | day-to-day, repo activity, "can you look at this" | decisions, backlogs |
| `#ci` | workflow results from the `Discord` job — failures and releases only | every push, every green check |
| `#decisions` | the *pointer* to a decision, with the repo link | the decision itself |
| `#random` | everything else | — |

`#dev` gets the official GitHub app:

```
/github subscribe hawkaii/dharmaScroll issues pulls releases
```

That covers issue/PR activity and link unfurling. It does not create issues from Discord — file them on GitHub, and paste the link back.

## Issues

- Title says the outcome, not the activity: "Share card renders at 1080×1920", not "work on share card".
- Body: what is true now, what should be true, how we will know (a command, a screenshot, a test name).
- Labels: `ui`, `api`, `content`, `bug`, `chore`. One area label each.
- Milestone = the week. No sprints, no story points.
- Project board columns: **Now** (someone is on it today), **Next** (agreed, not started), **Done**.

A PR closes its issue with `Closes #12`. If a PR has no issue, the PR body is the issue — say what changes and why.

## What CI notifies, and what it does not

The `Discord` job in `.github/workflows/build.yml` posts on **failure** and on **release**, nothing else.

That is deliberate. A channel that fires on every push gets muted, and a muted channel is how a real failure goes unnoticed for a day. Failure gets a red embed with the branch and which job broke; a release gets a link to the Releases page, where the APKs live.

Without the `DISCORD_WEBHOOK_URL` secret the job passes silently — `nofail` and `ack_no_webhook` are set, so a missing secret can never turn a green build red.

## OpenCode notifications

`opencode-discord-noti@1.1.0` posts to the same webhook when a session needs a human: a finished turn, a pending permission, a question form. It is **outbound only** — nothing in Discord can run an agent, push a branch, or spend money. A chat message must never be able to do that.

It lives in the global config (`~/.config/opencode/opencode.json`), not this repo, because it is a personal convenience rather than a project dependency.

The webhook URL is a **bearer token**: anyone holding it can post to the channel. Keep it in `~/.secrets/discord-webhook` and the GitHub secret, never in a committed file.

**Privacy:** these notifications include assistant text, session titles, and permission details. Fine on a private server; it becomes a leak the moment a guest joins that channel.

## Setup, once

```bash
# 1. Discord: channel → Edit Channel → Integrations → Webhooks → New → Copy URL

# 2. Local secret (never in a repo)
mkdir -p ~/.secrets && chmod 700 ~/.secrets
printf '%s' 'https://discord.com/api/webhooks/…' > ~/.secrets/discord-webhook
chmod 600 ~/.secrets/discord-webhook

# 3. CI secret
gh secret set DISCORD_WEBHOOK_URL --repo hawkaii/dharmaScroll < ~/.secrets/discord-webhook
```

Shell exports it for OpenCode:

```bash
export DISCORD_WEBHOOK_URL="$(cat ~/.secrets/discord-webhook 2>/dev/null)"
```

Restart after changing it — plugin options are captured at setup:

```bash
opencode service restart
```

## Verify

```bash
curl -sS -o /dev/null -w '%{http_code}\n' \
  -H 'Content-Type: application/json' \
  -d '{"content":"webhook test"}' "$DISCORD_WEBHOOK_URL"
```

`204` is success; `401`/`404` means the webhook was deleted or rotated.

## Two people, one checkout

Two sessions in one working tree is a bug, even when the files never overlap: one `.git`, so a `git add -A` sweeps up the other person's half-finished work. Use a worktree per parallel task, and stage explicit paths, never `git add -A` from the repo root.
