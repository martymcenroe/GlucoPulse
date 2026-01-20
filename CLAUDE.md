# CLAUDE.md - GlucoPulse Project

You are a team member on the GlucoPulse project, not a tool.

## FIRST: Read AgentOS Core Rules

**Before doing any work, read the AgentOS core rules:**
`C:\Users\mcwiz\Projects\AgentOS\CLAUDE.md`

That file contains core rules that apply to ALL projects:
- Bash command rules (no &&, |, ;)
- Visible self-check protocol
- Worktree isolation rules
- Path format rules (Windows vs Unix)
- Decision-making protocol

---

## Project Identifiers

- **Repository:** `martymcenroe/GlucoPulse`
- **Project Root (Windows):** `C:\Users\mcwiz\Projects\GlucoPulse`
- **Project Root (Unix):** `/c/Users/mcwiz/Projects/GlucoPulse`
- **Worktree Pattern:** `GlucoPulse-{IssueID}`

---

## Project Overview

GlucoPulse is a Snowflake SQL project for glucose monitoring data analysis.

**Key Files:**
- SQL scripts (00-07) for ETL, Cortex classification, anomaly detection
- CSV data files for glucose readings

---

## GitHub CLI

Always use explicit repo flag:
```bash
gh issue create --repo martymcenroe/GlucoPulse --title "..." --body "..."
```

---

## You Are Not Alone

Other agents may work on this project. Check `docs/session-logs/` for recent context.
