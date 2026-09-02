---
name: flutter-ui-animation
description: >-
  Use this skill when designing, building, or refining Flutter user interfaces, widgets,
  animations, themes, Hero transitions, glassmorphism effects, and micro-interactions.
---

# Flutter UI & Animation Design System Skill

This skill provides guidelines for crafting modern, visually stunning, and highly responsive UI components in Flutter.

---

## 1. UI Principles & Aesthetics

- **Color Harmony**: Use curated color palettes (deep slates, vibrant accents, dark mode gradients). Avoid raw primary colors (`Colors.red`, `Colors.blue`).
- **Visual Depth**: Utilize subtle borders, layered shadows (`BoxShadow`), and blur effects (`BackdropFilter` for glassmorphism).
- **Typography**: Maintain clear hierarchy (Headline > Title > Body > Caption) with consistent font weights and line heights.
- **Micro-Interactions**: Add subtle feedback for taps, hovers, card expand/collapse, and state changes.

---

## 2. Animation Guidelines

### a. Smooth Transitions & Hero Animations
- Wrap note cards or thumbnail images with `Hero(tag: 'note_${note.id}', child: ...)` to create seamless transitions between `HomePage` and `NoteEditorPage`.
- Use `AnimatedSwitcher` or `AnimatedCrossFade` for smooth view state changes (e.g., empty state vs. list, loading spinner vs. content).

### b. Implicit vs Explicit Animations
- Prefer implicit animation widgets (`AnimatedContainer`, `AnimatedOpacity`, `AnimatedScale`) for simple state transitions.
- Use explicit `AnimationController` with `SingleTickerProviderStateMixin` when custom timing curves, loops, or staggered animations are needed.
- Always dispose `AnimationController` in `dispose()` to prevent memory leaks.

```dart
class _PulsingBadgeState extends State<PulsingBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(scale: _scaleAnimation, child: widget.child);
  }
}
```

---

## 3. Responsive & Adaptive Design

- Use `LayoutBuilder` and `MediaQuery.of(context).size` for responsive grid/column adaptations (e.g., 1 column on phones, 2-3 columns on tablets/desktop).
- Implement pull-to-refresh (`RefreshIndicator`) and smooth slivers (`CustomScrollView`, `SliverAppBar`) for high-polish lists.
