---
name: taste
description: >-
  Use this skill to elevate UI/UX aesthetics, eliminate generic "AI slop", and ensure
  world-class visual polish, cohesive design systems, modern typography, and refined micro-interactions.
---

# Taste: Anti "AI-Slop" & Aesthetic Polish Skill

> *"Good design is opinionated, cohesive, and intentional. Great software feels crafted, not generated."*

This skill prevents cookie-cutter, outdated UI designs by enforcing modern product design standards in Flutter.

---

## 1. The Core Design Pillars

### 🎨 1. Nuanced Color Palette (No Raw Primaries)
- **Never** use raw default colors like `Colors.red`, `Colors.blue`, `Colors.yellow` directly in primary UI components.
- Use tailored tones with depth (e.g., Deep Slate `Color(0xFF0F172A)`, Indigo Accent `Color(0xFF6366F1)`, Emerald Success `Color(0xFF10B981)`, Rose Crimson `Color(0xFFF43F5E)`).
- Use subtle background tints with semi-transparent alphas for chips, badges, and cards (e.g., `primaryColor.withOpacity(0.08)` background with `primaryColor` text/icon).

### 📐 2. Spatial Rhythm & The 8pt System
- Standardize all margins, paddings, and gaps to multiples of 4 / 8:
  - `4px`: Micro spacing (between icon and text inside a badge)
  - `8px`: Tight spacing (between list items, chip gaps)
  - `16px`: Standard padding (card padding, screen gutters)
  - `24px`: Section spacing (between distinct screen sections)
  - `32px`: Hero / header spacing

### 🪟 3. Visual Depth & Surface Craft
- **Borders**: Prefer ultra-subtle borders (`Border.all(color: Colors.white.withOpacity(0.08))` in dark mode, or `Colors.black.withOpacity(0.06)` in light mode) over harsh solid outlines.
- **Elevation**: Avoid heavy, muddy black shadows. Use multi-layer soft shadows with low opacity and high blur radius:
  ```dart
  boxShadow: [
    BoxShadow(
      color: Colors.black.withOpacity(0.04),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
    BoxShadow(
      color: Colors.black.withOpacity(0.02),
      blurRadius: 4,
      offset: const Offset(0, 1),
    ),
  ]
  ```
- **Glassmorphism**: Use `BackdropFilter` with `ImageFilter.blur(sigmaX: 10, sigmaY: 10)` and translucent surfaces for floating bars, bottom sheets, and app bars.

### ✍️ 4. Typography Hierarchy
- Differentiate hierarchy through **weight, opacity, and size**, not just font size.
- Example hierarchy:
  - **Screen Title**: `TextStyle(fontSize: 24, fontWeight: FontWeight.w700, letterSpacing: -0.5)`
  - **Card Title**: `TextStyle(fontSize: 16, fontWeight: FontWeight.w600)`
  - **Body Text**: `TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: theme.textTheme.bodyMedium?.color?.withOpacity(0.85), height: 1.45)`
  - **Caption / Meta**: `TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: theme.textTheme.bodySmall?.color?.withOpacity(0.6))`

### ✨ 5. Micro-Interactions & Transitions
- Add tactile feedback: subtle scale transitions on tap (`Transform.scale`), smooth color transitions on hover/focus, and Hero animations between master and detail views.
- Use natural curves like `Curves.easeOutCubic` or `Curves.fastOutSlowIn` instead of linear animations.

---

## 2. Taste Checklist for UI Reviews

Before finalizing any UI widget or screen:
- [ ] Does it look like a customized, modern app or a generic template?
- [ ] Are the border radii consistent throughout the view (e.g., 12px or 16px)?
- [ ] Are empty states and loading states as carefully designed as the populated view?
- [ ] Is contrast accessible and readable across both light and dark themes?
- [ ] Are interactive buttons and cards giving clear tap/hover visual feedback?
