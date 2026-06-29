# OpenWolf

@.wolf/OPENWOLF.md

This project uses OpenWolf for context management. Read and follow .wolf/OPENWOLF.md every session. Check .wolf/cerebrum.md before generating code. Check .wolf/anatomy.md before reading files.


# AGENTS.md

This file provides guidance to Codex (Codex.ai/code) when working with code in this repository.

## Project

Binbon is a native iOS social app (SwiftUI, iOS 17.6+, Swift 5). No external package manager — there is no SPM `Package.swift`, CocoaPods, or Carthage; everything is first-party code in a single Xcode project. Bundle id `com.tailors.Binbon3`, scheme `Binbon`.

## Build, test, run

```bash
# Build (simulator)
xcodebuild -project Binbon.xcodeproj -scheme Binbon \
  -destination 'platform=iOS Simulator,name=iPhone 16' build

# Run all tests (target: BinbonTests, XCTest)
xcodebuild -project Binbon.xcodeproj -scheme Binbon \
  -destination 'platform=iOS Simulator,name=iPhone 16' test

# Run a single test class or method
xcodebuild ... test -only-testing:BinbonTests/NotificationSettingViewModelTests
xcodebuild ... test -only-testing:BinbonTests/NotificationModelTests/testDecoding
```

Day-to-day this is normally built and run from Xcode (⌘B / ⌘U). Tests use plain XCTest and mock the network layer at the repo-protocol boundary (see `BinbonTests/MockNotificationRepo.swift`) — view models are tested against a mock repo, never the live network.

## Architecture

### MVVM + feature folders
Each screen under `Binbon/Screens/<Feature>/` is split into `Model/`, `View/`, `ViewModel/`. View models are `@MainActor final class … ObservableObject`, own a `Repo` instance, expose `@Published` state (including `isLoading: Bool` and `error: APIError?`), and run network work in `Task { }`. Match this structure when adding a screen.

### Navigation — central enum router
All navigation flows through `Binbon/App/AppRouter.swift`. Adding a screen to the nav graph means **three coordinated edits** in that file:
1. add a `case` to the `Route` enum,
2. add the matching `case` to the `@ViewBuilder var view` switch (this maps route → View),
3. navigate with `router.navigate(.yourRoute)` (push) or `router.root(.yourRoute)` (reset stack).

`AppRouter.shared` is a singleton injected via `@Environment(\.router)`. `AppRoot` (in the same file) hosts the `NavigationStack`, shows the splash, and listens to `Network.shared.unauthorize` to present a session-expired alert that logs out and resets to auth.

### Networking — Service / Repo / Network
Three layers, all under `Binbon/Network/`:

- **Service** (`enum …Service: ServiceProtocol`) — one enum per domain (Auth, Profile, Setting, Notification, …). Each case is an endpoint; the enum supplies `url`, `path`, `method`, `parameters`, `headers`, `body`. Endpoint path strings are centralized in `Network/Core/API.swift` (`API.baseUrl`, `API.notifications`, etc.). **Base URL / environment is hardcoded** via `let API = Api(config: .development)` in `API.swift` — switch `.development`/`.production` there.
- **Repo** (`class …Repo: Repo, …RepoProtocol`) — calls `network.call(Service.case)`, wraps the result as `Result<BaseResponse<T>, APIError>` (does the `do/catch` → `.success`/`.failure(network.mapError(error))` dance). Always define a `…RepoProtocol` so view models can be unit-tested against a mock. A repo may call another domain's Service to reuse endpoints (e.g. `NotificationRepo` calls `ProfileService.followUser`).
- **Network** (`Network.shared`, `Network/Core/Network.swift`) — the single async `call<T: Decodable>` entry point. Decodes 2xx, maps 4xx/5xx to `APIError`, and on a `401` (for non-auth services) fires `unauthorize` to trigger global logout. All envelopes use `BaseResponse<T>` (`status`/`message`/`data`); use `EmptyResponse` for dataless responses (`Generic.swift`).

### Persistence
`Storage.shared` (`Binbon/App/AppStorage.swift`) wraps `UserDefaults` via a `@UserDefault` property wrapper and a `Storage.Key` enum (`token`, `user`, `language`, `didLaunch`, `version`). `Storage.shared.logout()` clears user + token. There is no Core Data / database.

### Localization — JSON, not String Catalogs
Localization is **custom JSON-based**, not `.strings`/`.xcstrings`. Tables live at `Binbon/Utilities/Localization/en.json` and `ar.json` (must keep identical key sets). Look up with `"some_key".localized` (SwiftUI/UIKit) or `"key".localizedFormat(args)` for `%@`/`%d` placeholders. Resolution: current language (from `Storage`) → English fallback → raw key. Adding user-facing text means adding the key to **both** `en.json` and `ar.json`. (Note: a legacy `.localize` / `Localizer` path also exists for NSLocalizedString — prefer `.localized`.) See `localization_audit.md` for the key inventory.

### Shared UI
Reusable components live in `Binbon/Widgets/` (e.g. `AppButton`, `AppTextField`, `AppNavbar`, `DynamicSelector`, `ErrorAlertModifier`, `LoadingModifier`). App-wide modifiers `.theme()`, `.toaster()`, `.connectivity()`, `.localizer()` are applied once in `AppView.swift` and back features like the global toast and offline banner. Reuse these widgets instead of rebuilding equivalent components — check what already exists first.

### Theming — design tokens, not literals
Colors and spacing come from the app's theme (the `.theme()` system), never from hardcoded values. Use the existing theme tokens for every color and spacing value; do not introduce raw hex strings or magic spacing numbers in views. When implementing a screen from a Figma design, map its color and spacing variables onto the existing theme tokens rather than copying literal values out of Figma.

## Conventions & gotchas

- New user-facing strings → add the key to **both** JSON tables.
- New endpoint → add the path to `API.swift`, a case to the domain `Service`, and a method to the `Repo` (+ its protocol).
- New screen → feature folder with Model/View/ViewModel **and** the three `AppRouter` edits.
- Colors & spacing → use theme tokens, never hardcode hex or raw spacing; map Figma variables onto existing tokens.
- Implement only what's explicitly requested for the screen at hand — no anticipatory additions, no invented API contracts or structures.

### Comments & Documentation

When generating code, write comments and documentation in a natural, human-written style. Avoid verbose, AI-like explanations or comments that simply restate what the code already does.

Prefer concise documentation that explains the purpose of a class, method, or non-obvious implementation when it adds value. Do not document every line of code. Focus on intent, important business logic, edge cases, assumptions, and design decisions that would help another developer understand or maintain the code.

## Figma MCP → SwiftUI

When implementing from a Figma link:

- **Tokens first.** Call `get_variable_defs` before writing any code. Map every color/spacing/typography value to the app theme — colors are resolved through `AppColors`, never inline `Color`/hex literals in views. If a value has no matching token, flag it instead of inventing one.
- **Strings.** Every user-facing string becomes a key in `AppStrings` and is added to **both** `en.json` and `ar.json`. Views reference the key via `.localized` — never hardcode literal text in a view.
- **Framework.** Set the Figma framework to SwiftUI (`clientFrameworks: SwiftUI`) so generation reuses Code Connect mappings and existing `Widgets/` components instead of generic shapes.
- **Assets & icons.** Use the design's own icons/assets. First check `Assets.xcassets` for an already-present matching asset and reuse it. If an asset is not in the project and cannot be exported from the Figma node, do NOT substitute an SF Symbol, system icon, or any other asset — insert a clearly-named placeholder and record the missing item in a `// TODO: missing asset — <name>` note so it can be added manually.
- **Scope.** For a full screen, scaffold the shell first, then build it section by section rather than generating the whole frame at once.

## Current phase (temporary)

Back new screens with mock/placeholder data — no live networking yet. Still scaffold the `Repo` + `…RepoProtocol` per the networking architecture above so the screen stays wired and unit-testable; just have the ViewModel pull from mock data instead of calling the live API. **Remove this section once API integration begins.**
