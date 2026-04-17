# AGENTS.md

## Purpose
- This repository is a Flutter app named `bilimusic`.
- Stack: Flutter, Riverpod code generation, Dio, Hive CE, Freezed, GoRouter.
- Current app focus: Bilibili QR-code authentication and local session persistence.
- Use this file as the default operating guide for coding agents working in this repo.

## Project Layout
- `lib/main.dart`: app bootstrap and global initialization.
- `lib/myApp.dart`: root widget and app-level theme/router wiring.
- `lib/router/`: navigation setup via GoRouter.
- `lib/core/`: shared infrastructure such as networking, theme, and Hive setup.
- `lib/feature/auth/`: feature-layered auth code split into `data`, `domain`, `logic`, and `ui`.
- `test/`: Flutter tests. At the moment there is only `test/widget_test.dart`.
- `docs/`: reference material, including Bilibili API documentation snapshots.

## Commands

Before running any `flutter` or `dart` command, first ensure the command is executed from the project root directory for this repository.

### Setup
- Install dependencies: `flutter pub get`
- Check Flutter environment: `flutter doctor`

### Run
- Run on default device: `flutter run`
- Run on a specific device: `flutter run -d <device-id>`
- Run web target: `flutter run -d chrome`

### Build
- Android APK: `flutter build apk`
- Android app bundle: `flutter build appbundle`
- iOS: `flutter build ios`
- Web: `flutter build web`
- Linux/macOS/Windows: use the corresponding `flutter build <platform>` command if that platform is enabled.

### Lint and Format
- Static analysis: `flutter analyze`
- Format only Dart files changed for the current task, for example `dart format lib/feature/auth/ui/login_page.dart test/widget_test.dart`.
- Do not format the entire repository unless the user explicitly asks for it.

### Tests
- Run all tests: `flutter test`
- Run one test file: `flutter test test/widget_test.dart`
- Run a single named test: `flutter test --plain-name "Counter increments smoke test" test/widget_test.dart`
- Run tests with machine output: `flutter test --machine`

### Code Generation
- One-off codegen: `dart run build_runner build --delete-conflicting-outputs`
- Watch mode: `dart run build_runner watch --delete-conflicting-outputs`

### Recommended Validation Flow After Changes
- `flutter pub get` if dependencies changed.
- `dart format <changed Dart files only>`.
- `flutter analyze`
- `flutter test`
- `dart run build_runner build --delete-conflicting-outputs` if any `@riverpod`, `@freezed`, Hive adapters, or `part` files changed.

## Single-Test Guidance
- Prefer `flutter test <path>` when validating one test file.
- Prefer `--plain-name` when validating one case inside a file.
- Example for a future auth test: `flutter test --plain-name "starts QR login" test/feature/auth/logic/bili_auth_controller_test.dart`
- There are no `integration_test/` files in the repo right now.

## Source Control Expectations
- Do not edit generated files unless the task explicitly requires it.
- Generated files in this repo include `*.g.dart` and `*.freezed.dart`.
- When source changes affect generated output, update the source file first, then rerun build_runner.
- Keep unrelated workspace changes intact; this repo may already be dirty.

## Existing Agent Rules Check
- No `.cursor/rules/` directory was found.
- No `.cursorrules` file was found.
- No `.github/copilot-instructions.md` file was found.
- As a result, this file is the primary agent instruction source inside the repository.

## Architecture Conventions
- Follow the existing feature-first structure under `lib/feature/<feature-name>/`.
- Within a feature, keep responsibilities split by layer:
- `domain`: enums, immutable models, simple state objects, value types.
- `data`: repository and persistence/network translation logic.
- `logic`: Riverpod providers, notifiers, orchestration, polling, state transitions.
- `ui`: widgets, view composition, widget-only presentation logic.
- Put reusable infrastructure in `lib/core/` rather than inside one feature.
- Keep routing centralized in `lib/router/`.

## Imports
- Use package imports for app code, for example `package:bilimusic/...`.
- Keep Dart SDK imports first, then package imports, then relative imports if absolutely needed.
- Prefer package imports over long relative traversals.
- Keep `part` directives after imports and before declarations.
- Let `dart format` manage wrapping; do not hand-align imports.

## Formatting
- Use `dart format`; do not preserve custom spacing that conflicts with formatter output.
- Prefer trailing commas in multi-line widget trees, argument lists, and constructors.
- Keep lines formatter-friendly instead of fighting wrapping.
- Use blank lines to separate logical sections, not every small statement.
- Avoid decorative comments and commented-out code.

## Types and Null Safety
- The codebase uses sound null safety; preserve it.
- Prefer explicit types when they improve readability or match existing local style.
- Existing code often annotates locals and fields explicitly; that is a safe default.
- Use precise generic types such as `Map<String, dynamic>` and `Box<String>`.
- Avoid `dynamic` unless the external API truly requires it.
- Convert loosely typed API responses at the boundary, then work with typed values.
- Prefer immutable data models and `const` constructors where possible.

## Naming
- Classes, enums, typedefs: `UpperCamelCase`.
- Methods, variables, parameters, providers: `lowerCamelCase`.
- Files: `snake_case.dart`.
- Private members: prefix with `_`.
- Providers should use descriptive names ending in `Provider` after generation.
- Repository classes should be nouns like `BiliAuthRepository`.
- State classes should describe UI/domain state clearly, for example `BiliAuthState`.

## Riverpod Conventions
- This repo uses generator-based Riverpod via `@riverpod` and generated `*.g.dart` files.
- Riverpod providers must use generator annotations (`@riverpod`) and generated `*.g.dart` wiring.
- When adding or refactoring providers, use `@riverpod`/generated notifiers rather than manual provider declarations.
- Prefer keeping provider declaration and implementation in the same source file.
- For notifier-style providers, extend the generated base class such as `_$BiliAuthController`.
- Read dependencies through `ref.read(...)` and subscribe with `ref.watch(...)`.
- Register cleanup with `ref.onDispose(...)` for timers, streams, or controllers.
- Keep state transitions explicit and localized inside the notifier.
- Avoid introducing manual `Provider`, `StateNotifierProvider`, `NotifierProvider`, or hand-written provider wiring when the same result can be expressed with Riverpod generator conventions.

## Model Conventions
- Freezed is already present and used in `lib/core/theme/theme_ui_model.dart`.
- Prefer Freezed for immutable domain models, state objects, DTO-like value types, and any class that would otherwise need manual equality, `copyWith`, unions, or JSON helpers.
- Plain immutable classes should be the exception, not the default; only keep them when the type is truly trivial and Freezed would add no meaningful value.
- Keep `copyWith` semantics predictable and avoid hidden side effects.

## Default Generation Bias
- When choosing between generated and manual patterns, prefer generated patterns first.
- Default to Riverpod generator for providers and controller/notifier definitions.
- Default to Freezed for immutable models and state classes.
- If you intentionally avoid Riverpod generator or Freezed in a new or refactored type, the code should have a concrete reason such as interop constraints, generator limitations, or the type being intentionally minimal.

## UI Conventions
- Prefer small widgets over one giant build method when a section has its own purpose.
- Keep presentation decisions in widgets and network/persistence logic out of UI code.
- Use `Theme.of(context)` and theme text styles instead of hardcoding every text style.
- Reuse spacing patterns with `SizedBox` and consistent radii/padding.
- Preserve the current visual language unless the task asks for a redesign.
- Keep desktop and mobile behavior sensible; current layouts use `ConstrainedBox` and padded cards.

## Networking and Persistence
- Network access goes through `BiliClient` and Dio.
- Keep API base configuration in `lib/core/net/net_config.dart`.
- Validate remote payload structure at the repository boundary.
- Check Bilibili API `code` fields and throw typed exceptions for non-success responses.
- Persist simple user/session values through Hive boxes.
- When loading persisted data, treat missing or empty values defensively.

## Error Handling
- Prefer domain-specific exceptions like `BiliAuthException` over raw strings where possible.
- Catch broad errors at async boundaries with `on Object catch (error)` when surfacing UI state.
- Convert failures into user-visible state in controllers instead of letting them silently disappear.
- Include actionable failure messages, but avoid leaking secrets or raw cookie values.
- Cancel timers and cleanup resources before moving to terminal failure states.

## Async and State Management
- Mark async APIs with `Future<T>` explicitly.
- Guard against re-entrancy when polling or performing repeated requests.
- Cancel periodic work during dispose and before restarting a flow.
- Prefer small helper methods for parsing, cookie extraction, and response validation.
- Keep business logic out of widgets when it affects state transitions or I/O.

## Testing Guidance
- Add tests close to the behavior being changed.
- Prefer widget tests for UI rendering and interaction.
- Prefer unit tests for repository parsing, controller transitions, and helper methods.
- Mock or fake network boundaries instead of hitting live Bilibili APIs in automated tests.
- If fixing the current stale sample test, align it with the actual app entry points and UI.

## Known Repo-Specific Notes
- `test/widget_test.dart` still contains the default counter smoke test and does not match the current app.
- `lib/core/hive/hive_adapters.dart` contains comment noise and should be treated carefully if touched.
- `lib/core/hive/hive_registrar.dart` is currently empty in source view; generated registrar output lives in `hive_registrar.g.dart`.
- Theme persistence uses the Hive `prefs` box.
- Auth persistence stores cookie/session data in the same `prefs` box.

## Agent Checklist Before Finishing
- Did you update generated files only through their source definitions?
- Did you run `dart format` on touched Dart files?
- Did you run `flutter analyze` after code changes?
- Did you run the narrowest useful test command, ideally a single file or single named test first?
- Did you avoid committing secrets, cookies, or local machine artifacts?
