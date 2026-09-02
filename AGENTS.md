# AGENTS.md - Workspace Agent Directives

This file specifies project guidelines, architecture, and skill references for all AI coding agents working in this repository.

---

## 1. Quick Reference

- **Framework**: Flutter (Dart `^3.10.0`)
- **Backend / DB**: Supabase Flutter SDK (`^2.0.0`)
- **Rich Editor**: `flutter_quill`
- **Lint / Analysis**: `flutter_lints` (via `analysis_options.yaml`)

---

## 2. Agent Skills Installed

The repository includes specialized on-demand skills located under `.agents/skills/`:

| Skill Name | Location | Focus Area |
| :--- | :--- | :--- |
| **`ponytail`** | [SKILL.md](.agents/skills/ponytail/SKILL.md) | Pragmatic minimalism, YAGNI, anti-overengineering & code bloat reduction |
| **`taste`** | [SKILL.md](.agents/skills/taste/SKILL.md) | Anti "AI-slop" UI, high aesthetics, 8pt spacing system & design polish |
| **`flutter-supabase-expert`** | [SKILL.md](.agents/skills/flutter-supabase-expert/SKILL.md) | Supabase auth, NoteService CRUD, RLS, storage bucket uploads & realtime |
| **`flutter-ui-animation`** | [SKILL.md](.agents/skills/flutter-ui-animation/SKILL.md) | Modern UI design system, Hero transitions, Glassmorphism & micro-interactions |
| **`code-qa-testing`** | [SKILL.md](.agents/skills/code-qa-testing/SKILL.md) | `flutter analyze`, unit/widget test patterns, memory leak prevention |
| **`git-workflow`** | [SKILL.md](.agents/skills/git-workflow/SKILL.md) | Conventional Commits standard (`feat:`, `fix:`, `refactor:`, `docs:`) |

---

## 3. Core Development Rules

1. **Ponytail (Minimalism & YAGNI)**: Enforce strict minimalism (see [.agents/rules/ponytail.md](.agents/rules/ponytail.md)). Never write speculative code, avoid premature abstraction, and prioritize native Flutter/Dart features over third-party bloat.
2. **Async Safety**: Always verify `mounted` before updating state or popping navigation context after `await`.
3. **Service Layer**: Keep backend code isolated in `lib/services/` (`NoteService`, `AuthService`).
4. **Database Schema**: Sync any schema changes with `database_schema.sql` and `media_table.sql`.
5. **Clean Code**: Run `flutter analyze` and ensure zero warnings or errors before finalizing code changes.
