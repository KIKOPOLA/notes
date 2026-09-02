# CLAUDE.md - AI Agent & Assistant Guide for Notes App

This document provides essential instructions, architecture guidelines, and operational commands for Claude (Claude Code / Anthropic AI agents) working on this Flutter repository.

---

## 1. Project Overview

- **App Name**: Notes Flutter Application
- **Frontend**: Flutter (Dart SDK `^3.10.0`, Material Design 3)
- **Backend**: Supabase (Authentication, PostgreSQL Database, Storage buckets for media attachments)
- **Key Features**:
  - Rich Text Note Editor with `flutter_quill`
  - Media support (Images, Videos, Audio memos)
  - Note archiving, search, and categorization
  - Realtime cloud sync with Supabase

---

## 2. Essential CLI Commands

```bash
# Install / update dependencies
flutter pub get

# Run application locally
flutter run

# Run static analysis and lint checks
flutter analyze

# Run test suite
flutter test

# Build release targets
flutter build apk --release
flutter build windows --release
```

---

## 3. Project Architecture & Directory Layout

```text
notes/
├── .agents/
│   ├── rules/
│   │   ├── flutter_rules.md            # Workspace coding rules
│   │   └── ponytail.md                 # Pragmatic minimalism & YAGNI rules
│   └── skills/
│       ├── ponytail/                   # Minimalist coding & Decision Ladder
│       ├── taste/                      # High aesthetic standards & UI design
│       ├── flutter-supabase-expert/    # Supabase backend integration workflows
│       ├── flutter-ui-animation/       # Modern UI design system & animations
│       ├── code-qa-testing/            # Linter, static analysis & testing runbook
│       └── git-workflow/               # Conventional commits & git guide
├── database_schema.sql                 # Primary database schema & RLS policies
├── media_table.sql                     # Media attachments table schema
├── alur_kode_notes.md                  # Application architecture summary
├── lib/
│   ├── main.dart                       # App entrypoint & Supabase initialization
│   ├── config/                         # Supabase & app configuration
│   ├── models/                         # Data models (NoteModel, UserModel)
│   ├── pages/                          # UI Screens (Home, Login, NoteEditor, etc.)
│   ├── services/                       # API & Backend services (AuthService, NoteService)
│   └── widgets/                        # Reusable UI components & custom cards
└── pubspec.yaml                        # Dependencies and Flutter assets config
```

---

## 4. Coding Standards & Conventions

### a. Ponytail: Minimalism & YAGNI (Mandatory)
- *"The best code is the code you never wrote."*
- Never write speculative or "just in case" code.
- Always check the Decision Ladder: (1) Use SDK/Flutter native first, (2) Reuse existing helpers/services, (3) Simplify & flatten abstractions.
- No third-party packages for simple tasks that can be done in a few lines of Dart.

### b. Dart & Flutter Conventions
- **Sound Null Safety**: Avoid unnecessary `!` force unwrapping. Use null-aware operators (`?.`, `??`).
- **Async Gap Safety**: Always check `if (!mounted) return;` after `await` in `StatefulWidget` callbacks before interacting with `BuildContext` or calling `setState()`.
- **Const Constructors**: Prefer `const` widgets whenever possible to minimize widget tree rebuilds.

### c. Supabase Service Pattern
- Encapsulate all database queries and auth operations inside `lib/services/`.
- Never execute raw database queries directly inside widget `build()` methods.
- Handle `PostgrestException` and `AuthException` with clear, user-facing feedback.

### d. Git Commit Convention
- Use Conventional Commits (`feat:`, `fix:`, `refactor:`, `style:`, `test:`, `docs:`, `chore:`).

---

## 5. Available Agent Skills in Workspace

Refer to the skills defined in `.agents/skills/` for detailed runbooks:
- [ponytail](.agents/skills/ponytail/SKILL.md): Pragmatic minimalism, YAGNI, anti-overengineering, and code reduction.
- [taste](.agents/skills/taste/SKILL.md): Anti-slop UI design, refined aesthetics, modern typography, and spatial rhythm.
- [flutter-supabase-expert](.agents/skills/flutter-supabase-expert/SKILL.md): Backend, RLS, storage uploads, and database operations.
- [flutter-ui-animation](.agents/skills/flutter-ui-animation/SKILL.md): Theme design, hero transitions, glassmorphism, and micro-interactions.
- [code-qa-testing](.agents/skills/code-qa-testing/SKILL.md): Static analysis, `flutter analyze`, and unit/widget testing.
- [git-workflow](.agents/skills/git-workflow/SKILL.md): Git branch strategies, diff review, and commit standards.
