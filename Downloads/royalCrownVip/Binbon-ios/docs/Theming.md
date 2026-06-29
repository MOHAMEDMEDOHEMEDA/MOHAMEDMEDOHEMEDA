# Binbon — Theming Guide (iOS)

How colors work in the app and how to use them when you build a new feature.
**TL;DR: never hard‑code a color. Always use a token from `AppColor` or `Color.appText`.**

---

## 1. The four themes

The app has one theme switch with four modes (`AppThemeMode`):

| Mode      | Background        | Brand surfaces (buttons, tab bar, list rows) | Gold accent |
|-----------|-------------------|----------------------------------------------|-------------|
| `light`   | white → light     | flat charcoal `#2B2B2B`                       | neutral ink |
| `dark`    | pure black        | flat charcoal `#2B2B2B`                       | neutral ink |
| `colored` | purple → maroon   | brand gradients (coral/purple/orange)         | real gold   |
| `system`  | follows the device → resolves to `light` or `dark` | — | — |

Design rules that fall out of this:

- **Light and Dark are "flat".** No purple/coral gradients, no gold. Brand surfaces are `#2B2B2B`; accents are neutral ink (`appText`).
- **Colored is the only "vivid" theme** — it keeps gradients and real gold.
- The bottom tab bar's **active item** is the one intentional exception that always uses gold→orange.

---

## 2. The pieces

```
ThemeManager (singleton, ObservableObject)
   └─ holds the current `mode` + live `systemScheme`
ThemePalette (struct)
   └─ the raw per‑theme color values (colored / light / dark instances)
AppColor (enum) + Color.appText / .appGold / .themed(...)
   └─ the tokens you actually call from views
```

- **`ThemeManager.shared`** — current mode, persisted; publishes on change.
- **`ThemePalette`** — three concrete instances (`.colored`, `.light`, `.dark`) holding raw values. You rarely touch this directly.
- **`AppColor`** — the public token API. **This is what you use in views.**

---

## 3. Using colors in a new feature

### ✅ Do
```swift
Text("Title").foregroundStyle(.appText)                 // adaptive ink
.background(AppColor.cardBackground)                     // themed surface
.fill(AppColor.buttonGradient)                           // themed button
RoundedRectangle().stroke(AppColor.goldAccentGradient)   // themed accent ring
```

### ❌ Don't
```swift
.foregroundStyle(.black)                 // breaks in dark mode
.background(Color(hex: "2B2B2B"))        // hard‑coded; won't follow the theme
.fill(LinearGradient(colors: [.purple])) // purple leaks into light/dark
```

### Token reference

| You want…                            | Use                              | Resolves to |
|--------------------------------------|----------------------------------|-------------|
| Primary text / icon                  | `Color.appText` (`.appText`)     | white on dark/colored, near‑black on light |
| Text/icon **on a dark brand fill**   | `AppColor.textPrimary` (`.white`)| always white (use on buttons, dark headers) |
| App background                       | `AppColor.backgroundGradient` (or `.appBackground()` modifier) | per‑theme gradient |
| Card / panel surface                 | `AppColor.cardBackground`        | charcoal / faint / translucent |
| Expand‑section / notification card   | `AppColor.sectionSurface`        | `#2B2B2B` dark, light‑gray light |
| Primary button fill                  | `AppColor.buttonGradient`        | `#2B2B2B` flat, brand gradient on colored |
| List‑row / secondary button fill     | `AppColor.authListFollowingRowGradient` | same idea |
| Gold accent (single color)           | `Color.appGold`                  | gold on colored, neutral ink on light/dark |
| Gold accent **gradient** (rings, selected tabs) | `AppColor.goldAccentGradient` | gold→orange on colored, ink on light/dark |
| Tab bar / FAB fill                   | `AppColor.tabBarFill`            | `#2B2B2B`, brand gradient on colored |
| Profile header fill                  | `AppColor.profileHeaderFill`     | black / light / purple per theme |

> Need a quick translucent variant? Use opacity on `appText`: `.appText.opacity(0.7)`.
> It stays semantically "ink at X%" in every theme.

### The golden contrast rule
Pick text color by **what surface it sits on**, not by the theme:
- On the **app background** or an **adaptive card** → `.appText` (it flips to stay readable).
- On a **fixed dark brand fill** (button, tab bar, expand header, social row) → `AppColor.textPrimary` / `.white` (the surface is dark in every theme, so the text must always be light).

---

## 4. Reactivity — making colors update live

There are two ways a color updates when the theme changes. You usually get the first for free; you opt into the second only when needed.

### a) System appearance flips (light ↔ dark) — automatic
All `AppColor` tokens and `Color.appText` are **dynamic colors**. They re‑resolve themselves when the device appearance changes, so the screen repaints live with **no extra code**. Just use the tokens.

### b) In‑app theme switch involving `colored` — observe the manager
Switching **colored ↔ dark** produces **no device‑trait change** (both use a dark trait), so a dynamic color can't auto‑refresh. A view repaints only if it **re‑renders**. Most screens are fine because they're rebuilt when you navigate to them, but a view that stays on screen across the switch (e.g. the tab bar) must observe the manager:

```swift
struct MyPersistentChrome: View {
    @ObservedObject private var theme = ThemeManager.shared   // ← forces re‑render on any theme change
    var body: some View { … AppColor.tabBarFill … }
}
```

**Rule of thumb:** add `@ObservedObject private var theme = ThemeManager.shared` to any view that
(1) is visible while the user changes the theme **and** (2) draws theme colors. Otherwise you don't need it.

---

## 5. Common recipes

**A themed screen** (gets the background + adaptive ink automatically):
```swift
var body: some View {
    content
        .appBackground()                 // themed gradient background
        .foregroundStyle(.appText)       // default ink for children
}
```

**A primary button:**
```swift
Text("Login")
    .foregroundStyle(.white)             // on a dark brand fill
    .frame(maxWidth: .infinity).padding(.vertical, 16)
    .background(AppColor.buttonGradient, in: RoundedRectangle(cornerRadius: 12))
```
(or just use the shared `AppButton`, which is already themed.)

**A card / section:**
```swift
content.padding(12)
    .background(AppColor.sectionSurface, in: RoundedRectangle(cornerRadius: 10))
```

**A remote icon tinted to the theme** (monochrome icons only):
```swift
ImageView(user.zodiacImageUrl, tint: .appText)   // recolors the loaded image per theme
```

---

## 6. Adding a new themed color

1. Add the raw value to **all three** `ThemePalette` instances in
   `Utilities/Theme/ThemePalette.swift` (`.colored`, `.light`, `.dark`).
2. Expose a token in `AppColor` (`Extensions/AppColor.swift`):
   - If it **differs between light and dark**, make it dynamic so it updates live:
     ```swift
     static var myColor: Color {
         .themed(colored: coloredPalette.myColor,
                 light:   lightPalette.myColor,
                 dark:    darkPalette.myColor)
     }
     ```
   - If it's a **gradient** or **identical across light/dark**, a plain
     `palette.myColor` accessor is fine (it only needs a re‑render, see §4b).
3. Use `AppColor.myColor` in views. Never reference `ThemePalette` from a view.

> `Color.themed(colored:light:dark:)` builds a dynamic `UIColor` that also reads
> `ThemeManager.mode`, so it handles **both** system appearance flips and the
> `colored` mode correctly. Prefer it for any single‑color token that varies by theme.

---

## 7. Gotchas

- **No raw hex / system colors in views.** `Color(hex:)`, `.black`, `.white` (except as "on dark fill"), `.purple`, `.pink` are red flags in review.
- **Gold only in colored + the tab bar's active item.** Anywhere else, gold must come from `Color.appGold` / `AppColor.goldAccentGradient` so it neutralizes in light/dark.
- **`tint:` on `ImageView` is for monochrome icons.** A full‑color photo will flatten to a silhouette.
- **Don't `.id(...)` a whole screen on theme change** to force a refresh — it resets navigation/scroll state. Observe the manager instead (§4b).
- **Test every screen in all four modes**, and toggle the device appearance from Control Center while the screen is open to confirm it repaints live.
