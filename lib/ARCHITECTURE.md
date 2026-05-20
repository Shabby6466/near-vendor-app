# Near Vendor App — Directory Structure

Aligned with `vendor_app` conventions: layered `lib/`, feature modules under `views/screens/`, and co-located `cubit/` + `view/` per feature.

## `lib/` layout

```
lib/
├── main.dart
├── ARCHITECTURE.md
├── cubits/                         # App-wide state only (not per-screen)
│   ├── analytics_mixin.dart
│   ├── connectivity/
│   └── session/
├── enums/
├── gen/                            # Generated — do not edit
├── models/
│   ├── api_request_models/         # DTOs sent to the API
│   ├── api_responses/              # DTOs from the API
│   ├── data_models/                # Domain / entity models
│   └── ui_models/                  # UI-only display models
├── services/                       # API & domain services
├── utils/
│   ├── constants/
│   ├── hive/                       # Local persistence
│   ├── navigation/                 # Routing, deep links, location picker
│   ├── theme/                      # AppThemeData, spacing
│   └── ui/                         # Alerts, strings
└── views/
    ├── screens/
    │   ├── auth/       → cubit/, view/, widgets/
    │   ├── common/     → shared screens + cubit/ (splash, pin, …)
    │   ├── home/       → cubit/, view/, widgets/
    │   ├── onboarding/ → view/, widgets/
    │   ├── profile/    → cubit/, view/, widgets/
    │   ├── search/     → cubit/, view/, widgets/, utils/
    │   └── wishlist/   → cubit/, view/, widgets/
    └── widgets/                      # Shared UI components only
```

## Feature module convention

Every feature under `views/screens/<feature>/` uses:

| Folder     | Contents                                      |
|------------|-----------------------------------------------|
| `view/`    | Full screens (`*_screen.dart`) — **singular** |
| `widgets/` | Feature-specific widgets — **plural**         |
| `cubit/`   | `*_cubit.dart` + `*_state.dart` (flat, no nested subfolders) |

Optional: `utils/` for feature-only helpers (e.g. `search/utils/`).

### Cubit layout (flat)

Place cubit files directly in `cubit/`, not in nested folders:

```
auth/cubit/
├── login_cubit.dart
├── login_state.dart
├── signup_cubit.dart
├── signup_state.dart
├── verification_cubit.dart
└── verification_state.dart
```

Use `part` / `part of` when state lives in a separate file (same directory).

## State & data

| Concern              | Location                                      |
|----------------------|-----------------------------------------------|
| Last-known location  | `AppData.locationNotifier` (single source)    |
| GPS / save location  | `AppLocationService`                          |
| Open location picker | `LocationPickerLauncher` (`utils/navigation/`) |
| Screen state         | Feature `cubit/` or `lib/cubits/` if app-wide  |
| API calls            | `lib/services/`                               |

## Naming rules

- Files: `snake_case.dart`
- Screens: `*_screen.dart` inside `view/` (or `common/` for shared)
- Cubits: `*_cubit.dart`, states `*_state.dart`
- Imports: `package:nearvendorapp/...`
- Do **not** use `views/` (plural) for screen folders — use `view/`
- Do **not** nest cubits in subfolders (`cubit/foo_cubit/foo_cubit.dart`)
- Do **not** put full screens under `views/widgets/` — use `screens/common/` or a feature `view/`

## Utils map

| Path | Purpose |
|------|---------|
| `utils/app_data.dart` | Singleton app cache, location, user |
| `utils/globals.dart` | Navigator key, shared globals |
| `utils/navigation/` | `AppNavigator`, deep links, location picker |
| `utils/theme/` | `AppThemeData`, `AppSpacing` |
| `utils/ui/` | `AppAlerts`, `AppStrings` |
| `utils/hive/` | Hive boxes and storage helpers |
| `utils/constants/` | API keys, Hive keys, defaults |

## Comparison with `vendor_app`

| Area              | `vendor_app`              | `near_vendor_app`        |
|-------------------|---------------------------|--------------------------|
| Request models    | `api_request_models/`     | `api_request_models/`    |
| Feature UI        | `views/screens/<feature>/`| Same                     |
| Screen folder     | `view/`                   | `view/`                  |
| Cubit files       | Flat in `cubit/`          | Flat in `cubit/`         |
| App-wide cubit    | `utils/connectivity_cubit`| `cubits/connectivity/`   |
