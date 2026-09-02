---
name: git-workflow
description: >-
  Use this skill when preparing git commits, staging changes, generating changelogs,
  managing branches, or enforcing Conventional Commits formatting.
---

# Git Workflow & Conventional Commits Skill

This skill defines version control standards and commit conventions for the repository.

---

## 1. Conventional Commits Format

Format all commit messages according to the Conventional Commits specification:

```text
<type>(<optional scope>): <short summary in imperative mood>

[optional body explaining 'why' and 'what']

[optional footer for breaking changes or issue references]
```

### Commit Types:
- `feat`: A new feature (e.g., `feat(notes): add audio playback and voice memo support`)
- `fix`: A bug fix (e.g., `fix(auth): handle expired supabase refresh token gracefully`)
- `refactor`: Code restructuring without changing external behavior (e.g., `refactor(services): split note storage into dedicated service`)
- `style`: UI styling, theme updates, or formatting changes without logic changes
- `perf`: Performance improvements (e.g., `perf(images): compress attachments prior to upload`)
- `test`: Adding or updating test cases
- `docs`: Documentation updates (e.g., `docs: update alur_kode_notes.md with RLS details`)
- `chore`: Build config, dependencies, or tool updates (e.g., `chore: upgrade flutter_quill dependencies`)

---

## 2. Commit Best Practices

1. **Atomic Commits**: Group related changes together; do not mix refactors and new features into a single commit.
2. **Review Diffs**: Always check `git status` and `git diff` prior to staging and committing.
3. **No Sensitive Keys**: Never commit raw Supabase secret keys, personal credentials, or `.env` secrets.
