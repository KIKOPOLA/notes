---
name: code-qa-testing
description: >-
  Use this skill when auditing code quality, running static analysis (flutter analyze),
  fixing lint warnings, writing unit & widget tests, and verifying application stability.
---

# Flutter Code Quality & Testing QA Skill

This skill enforces strict quality gates, static code analysis, and testing standards for Flutter applications.

---

## 1. Static Analysis & Lint Enforcement

- Always run `flutter analyze` after making significant code edits.
- Adhere to `analysis_options.yaml` rules (including `flutter_lints`).
- Resolve all warnings:
  - Add `const` constructors where possible to reduce unnecessary widget rebuilds.
  - Avoid unused imports or dead code.
  - Avoid raw `print()` statements in production code; use `debugPrint()` or structured logging.
  - Check `mounted` before calling `setState()` or `Navigator.pop(context)` across async gaps:
    ```dart
    final result = await someAsyncOperation();
    if (!mounted) return;
    setState(() { ... });
    ```

---

## 2. Testing Strategies

### a. Unit Testing (`test/unit/`)
- Test data models (`fromJson`, `toJson`, `copyWith`).
- Test business logic and helper utilities without UI dependencies.

```dart
test('NoteModel fromJson parses valid json correctly', () {
  final json = {
    'id': '123',
    'title': 'Test Note',
    'content': 'Hello world',
    'created_at': '2026-09-02T00:00:00Z',
    'is_archived': false,
  };
  final note = NoteModel.fromJson(json);
  expect(note.id, '123');
  expect(note.title, 'Test Note');
  expect(note.isArchived, false);
});
```

### b. Widget Testing (`test/widget/`)
- Verify widget rendering and state changes using `WidgetTester`:
```dart
testWidgets('NoteCard displays title and content correctly', (tester) async {
  final note = NoteModel(id: '1', title: 'Belajar Flutter', content: 'Catatan');
  await tester.pumpWidget(MaterialApp(home: Scaffold(body: NoteCard(note: note))));
  expect(find.text('Belajar Flutter'), findsOneWidget);
});
```

---

## 3. QA Checklist Before Shipping Changes

1. `flutter analyze` passes with **0 issues**.
2. `flutter test` executes and all test suites pass.
3. No breaking changes introduced to database models or service contracts.
4. Clean widget dispose lifecycle for controllers, streams, and animations.
