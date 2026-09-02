# Rule: Ponytail - Pragmatic Minimalism & YAGNI

All AI agents working on this codebase must strictly adhere to the **Ponytail** rule set:

---

## 1. Core Mandate: YAGNI (You Aren't Gonna Need It)
- *"The best code is the code you never wrote."*
- Always prefer the simplest working solution. Never write code for hypothetical future requirements ("just in case").

---

## 2. The Decision Ladder (Mandatory Before Writing Code)
1. **Platform / Native First**: Use built-in Flutter/Dart widgets, standard libraries, and methods before introducing any third-party packages or custom complex logic.
2. **Reuse Existing**: Always check existing services (`NoteService`, `AuthService`), models, and widgets (`NoteCard`, `EmptyStateWidget`) to avoid code duplication.
3. **Simplify & Flatten**: Avoid deep class hierarchies, premature abstraction layers, unnecessary wrapper widgets, or speculative interfaces.

---

## 3. Strict Prohibitions
- ❌ Do NOT add third-party packages for trivial utilities that can be written in 5-10 lines of native Dart.
- ❌ Do NOT write multi-tier boilerplate (factories, repositories, complex state machines) when a simple direct service or `setState` / `ValueNotifier` is sufficient.
- ❌ Do NOT leave dead code, unused imports, or speculative code blocks in the codebase.
- ❌ Do NOT over-engineer error handlers for impossible edge cases; validate inputs cleanly and fail early.
