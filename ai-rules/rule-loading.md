# Rule Loading

Load rules in this order:
1. Read `AGENTS.md`.
2. Read `ai-rules/ocbc-watch-rules.md`.
3. If task is scoped to a feature target, inspect that feature’s `Screen`, `Models`, `Components`, and `Stores`.

Apply the smallest relevant rule set for the current task. Do not add new abstractions unless they improve reuse across at least two features.

