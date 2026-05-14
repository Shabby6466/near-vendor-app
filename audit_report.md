# near_vendor_app — Codebase Audit Report

> Focus: **simplicity, reusability, functionality**
> Generated: May 12, 2026

---

## Summary

| Metric                                           | Count                      |
| ------------------------------------------------ | -------------------------- |
| **Critical issues** (bugs, data loss risk)       | 7                          |
| **Major issues** (performance, maintainability)  | 9                          |
| **Minor issues** (code cleanliness, duplication) | 12                         |
| **Flutter analyze**                              | ✅ 2 info-level lints only |

---

## CRITICAL ISSUES

### C1. `SearchStorage.clearRecentSearches()` writes to wrong Hive box

**File:** `lib/utils/hive/search_storage.dart:54`

```dart
await _userBox.delete(HiveKeys.recentSearchesKey);
```

**Bug:** Should write to `_preferencesBox`, not `_userBox`. Writes to `currentUserBox` will be lost
when `onLogout()` calls `currentUserBox.clear()`, wiping recent search history on every logout.

**Fix:**

```dart
await _preferencesBox.delete(HiveKeys.recentSearchesKey);
```

---

### C2. `HiveManager.onLogout()` clears entire user box instead of selective keys

**File:** `lib/utils/hive/hive_manager.dart:23`

```dart
static void onLogout() {
  currentUserBox.clear();  // wipes EVERYTHING in the box
}
```

`clearUserData()` in `current_user_storage.dart` already does selective deletion. But `onLogout()`
is called **after** `clearUserData()` in `AppData.clear()` (line 97), meaning it redundantly wipes
data that was already deleted. Worse: if any other code writes to `currentUserBox` between
`clearUserData()` and `onLogout()`, that data gets lost too.

**Fix:** Remove `HiveManager.onLogout()` entirely — `CurrentUserStorage.clearUserData()` already
handles selective cleanup.

---

### C3. `AppData` location fields never restored on app restart

**File:** `lib/utils/app_data.dart:31-38`

```dart
double? _latitude;
double? _longitude;
```

`AppData` is a singleton but its `_latitude`/`_longitude`/`_cityName` are only populated at runtime
via `setLocation()`. On cold start, these stay `null`. Any code reading `AppData().latitude`
directly (bypassing `LocationCubit`) gets `null`, even though `CurrentUserStorage` has the last
location saved.

**Impact:** `HomeScreenCubit._fetchShops()` reads `AppData().latitude` (line 52-53), returning null
on cold start, causing a fallback to hardcoded coordinates (24.86, 67.00).

**Fix:** Either:

- Restore from storage in `AppData._()` constructor
- Or make `HomeScreenCubit` read from `LocationCubit` instead

---

### C4. `server.dart` throws raw strings instead of exceptions

**File:** `lib/services/server.dart:126`

```dart
throw AppStrings.checkInternetConnection;  // throws a String, not an Exception
```

This is a `String` being thrown, not an `Exception` or `Error`. Catch blocks like
`catch (e) { ... e.toString() ... }` still work but `catch (e)` with typed catches
(`catch (e is DioException)`) will not catch this. The `checkInternetConnection` string
gets propagated as raw text.

**Impact:** Services that catch `DioException` specifically will miss this error and propagate
the raw string up, potentially reaching users as raw technical text.

**Fix:**

```dart
throw Exception(AppStrings.checkInternetConnection);
```

---

### C5. Self-signed certificate bypass enabled unconditionally

**File:** `lib/services/server.dart:28`

```dart
client.badCertificateCallback = (cert, host, port) => true;
```

The comment says "Allow self-signed certs in dev; remove for production" but the code always
allows untrusted certificates. This is a **security vulnerability** — a MITM attack would go
undetected.

**Fix:** Gate behind `kDebugMode`:

```dart
if (kDebugMode) {
  client.badCertificateCallback = (cert, host, port) => true;
}
```

---

### C6. `main.dart` silently swallows all uncaught errors

**File:** `lib/main.dart:33`

```dart
runZonedGuarded(() async {
  // ...
}, (error, stack) {});  // empty handler — errors are silently dropped
```

Every unhandled exception in the entire app is silently swallowed. No logging, no crash
reporting, no user notification.

**Fix:** At minimum log the error:

```dart
}, (error, stack) {
  debugPrint('Uncaught error: $error\n$stack');
});
```

---

### C7. Doubled server call in `SessionCubit.initialize()`

**File:** `lib/cubits/session/session_cubit.dart:19-60`

`initialize()` first reads user from Hive and emits `authenticated`, then immediately fetches
`/users/me` from the API. If the API call fails, it logs the user out. This means:

1. The UI briefly shows authenticated state with stale user data
2. If the API is down, the user gets logged out even though their stored token is valid
3. Two sequential emits cause unnecessary widget rebuilds

**Fix:** Either await the API first before emitting, or keep local data as fallback and only
emit `authenticated` after confirming with the server.

---

## MAJOR ISSUES

### M1. `app_strings.dart` contains ~200 lines of dead wallet/blockchain strings

**File:** `lib/utils/app_strings.dart`

This is a **vendor app** — there is no wallet, no blockchain, no NFTs, no DeFi. Yet
`app_strings.dart` has sections for:

- Wallet Connect Errors (3 strings)
- Wallet Errors (5 strings)
- Transaction Messages (7 strings)
- Wallet tabs (Swap, NFTs, DeFi Yield)
- dApp categories (Lending, DEX, Staking, Yield, NFT)
- Lock Screen & Security (50+ strings for passcode/biometric screens not in this app)
- Address Book, QR Scanner, Wallet Management, Security Settings

~200 strings are completely unused, bloating the binary and confusing developers.

**Fix:** Remove all wallet/blockchain/crypto sections.

---

### M2. `helper_functions.dart` contains 6 unused wallet/blockchain functions

**File:** `lib/utils/helper_functions.dart`

Unused functions in a vendor app:

- `isValidAddress()` — ETH/Solana address validation
- `shortenAddress()` — "0xabc...def" truncation
- `formatAddressInLines()` — address formatting
- `shortAddress()` — another truncation variant
- `hashPassword()` — SHA-256 hashing (not used by any auth flow)
- `verifyPassword()` — hash comparison

`showAmountWithCurrency()` and `trimTrailingZeros()` are also likely unused.

**Fix:** Audit and remove dead code.

---

### M3. `MapCubit` re-created on every location state change

**File:** `lib/views/screens/home/view/main_screen.dart:43-56`

```dart
BlocBuilder<LocationCubit, LocationState>(
  builder: (context, location) {
    return BlocProvider(
      create: (context) => MapCubit(
        lat: location.latitude ?? 33.68,
        lon: location.longitude ?? 73.04,
      ),
      child: MapScreen(...),
    );
  },
),
```

Every time `LocationCubit` emits a new state (even minor updates like temp coordinates during
picker drag), a brand new `MapCubit` is created, destroying the old one. This causes `MapScreen`
to completely rebuild.

**Fix:** Create `MapCubit` once in a parent provider and update its coordinates via method call.

---

### M4. `isInternetAvailable()` (DNS lookup) blocks every API request

**File:** `lib/services/server.dart:125` calling `helper_functions.dart:53`

```dart
if (!await isInternetAvailable()) { // DNS lookup to google.com every time
  throw ...;
}
```

Every single API call performs a DNS lookup to `www.google.com`. This adds ~200-500ms latency
to each request. Also unreliable in regions where Google DNS is blocked.

**Fix:** Remove this check and let Dio handle connectivity errors natively via timeout/DioException.
Or use `connectivity_plus` which is already a dependency.

---

### M5. `_showPremiumConfirmation` uses fragile `showGeneralDialog` pattern

**File:** `lib/views/screens/wishlist/widgets/my_wishes_view.dart:728-730`

```dart
pageBuilder: (context, anim1, anim2) {
  return const SizedBox.shrink();  // Empty widget!
},
```

`return const SizedBox.shrink()` as the page builder is a known pattern but can cause layout
issues on some platforms. The transition builder does the actual rendering. This is fragile.

**Fix:** Use `showDialog` with a custom `TransitionBuilder`, or use `AlertDialog` directly.

---

### M6. `Upgrader` configured with `minAppVersion: '0.0.0'`

**File:** `lib/main.dart:90`

```dart
Upgrader(
  minAppVersion: '0.0.0',  // never triggers
  durationUntilAlertAgain: const Duration(hours: 1),  // alerts every hour
),
```

`minAppVersion: '0.0.0'` means the minimum required version is always satisfied, so the upgrade
prompt never actually appears. Combined with `durationUntilAlertAgain: 1 hour`, if it did appear,
it would annoy users every hour.

**Fix:** Either configure properly with the actual minimum version, or remove `Upgrader` if not
connected to an app store review.

---

### M7. `AppBottomSheet` hardcodes `ColorName.primary` as background

**File:** `lib/views/widgets/app_bottom_sheet.dart:36`

```dart
color: ColorName.primary.withValues(alpha: 0.7),
```

All bottom sheets use a primary-colored translucent background with a white border. This doesn't
adapt to dark/light theme and looks inconsistent on dark mode.

**Fix:** Use `Theme.of(context).colorScheme.surface.withValues(alpha: 0.95)` or similar.

---

### M8. No loading state for `completeWishlist` / `deleteWishlist`

**File:** `lib/views/screens/wishlist/cubit/user_wishlist_cubit.dart`

The `completeWishlist()` and `deleteWishlist()` methods don't emit a loading state. The UI
calls these methods but has no visual feedback (no spinner, no disabled button) while the
operation is in progress. If the API call is slow, the UI appears unresponsive.

**Fix:** Emit a `UserWishlistLoading` state (or add a dedicated loading flag) before async
operations.

---

### M9. `HomeScreenCubit._initialize()` called in constructor — no error handling

**File:** `lib/views/screens/home/cubit/home_screen_cubit.dart:16-18`

```dart
HomeScreenCubit() : super(HomeScreenInitial()) {
  _initialize();  // async fire-and-forget in constructor
}
```

`_initialize()` runs API calls but is called from the constructor without `await`. If it fails,
the cubit stays in `HomeScreenInitial` forever. No error is emitted.

**Fix:** Call `loadShops()` explicitly from the widget layer or catch errors and emit
`HomeScreenFailure`.

---

## MINOR ISSUES

### m1. `GenericApiResponse` is a pointless wrapper

**File:** `lib/utils/generic_api_response.dart`

```dart
class GenericApiResponse extends BaseApiResponse {
  GenericApiResponse({super.message, super.status});
  GenericApiResponse.fromJson(Map<String, dynamic> json) : super.fromJson(json);
}
```

This adds zero value over `BaseApiResponse`. Every usage could just use `BaseApiResponse` directly.

---

### m2. `WishlistActionResponse` duplicates `GenericApiResponse`

Both `WishlistActionResponse` and `GenericApiResponse` are identical wrappers over
`BaseApiResponse`. Use one or the other.

---

### m3. `AppScaffold` is a thin wrapper adding no value

**File:** `lib/views/widgets/app_scaffold.dart`

This just passes all props through to `Scaffold` with minor defaults. It's an extra layer of
indirection that makes code harder to follow. `extendBody: true` default could cause layout
issues on screens that don't expect it.

---

### m4. `runZonedGuarded` imports unused in `main.dart`

`dart:async` imported for `runZonedGuarded` but this is a `dart:async` built-in — the import
isn't needed by modern Dart SDKs.

---

### m5. Two identical home screen `coming_soon_screen.dart` files

- `lib/views/screens/home/view/coming_soon_screen.dart`
- `lib/views/screens/chat/views/coming_soon_screen.dart`

If they're different, names should clarify. If identical, share one.

---

### m6. `home_screen_cubit.dart.backup` left in source tree

**File:** `lib/views/screens/home/cubit/home_screen_cubit.dart.backup`

This should have been deleted after refactoring. Commit it to `.gitignore` or remove.

---

### m7. `cubits/search/` directory is empty

**Directory:** `lib/cubits/search/`

No files. Should be removed.

---

### m8. `AppElevatedButton` doesn't use theme's button style

**File:** `lib/views/widgets/app_elevated_button.dart:27`

```dart
style: theme.elevatedButtonTheme.style,
```

This reads `elevatedButtonTheme.style` which may be null if not configured. Should fall back to
default button style.

---

### m9. `AuthConfig` — no centralized auth gate

Multiple screens repeat the same pattern:

```dart
final isAuthenticated = AppData().isLoggedIn;
if (!isAuthenticated) { ... show login prompt ... }
```

This pattern is duplicated in `WishlistMainScreen`, `SearchScreen`, `ProfileScreen`, etc.
A reusable widget or mixin would reduce duplication.

---

### m10. `ConnectivityCubit` declared but `search_cubit.dart` has typo

**File:** `lib/views/screens/search/cubit/search_cubit.dart`

```dart
class HomeScreenCubit extends Cubit<HomeScreenState>  // typo in search_cubit.dart
```

A class declaration comment references `HomeScreenCubit` inside `search_cubit.dart`. Debug text.

---

### m11. `FlutterMap` tile URL hardcoded

**File:** `lib/views/screens/search/view/search_results_screen.dart:57`

```dart
urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
```

Hardcoded OSM tile URL. If the tile server changes or requires an API key, this needs updating
in multiple places. Should be configurable.

---

### m12. No API error logging infrastructure

All service files have identical catch blocks:

```dart
} catch (e) {
  return XxxResponse(message: e.toString());
}
```

Error details are swallowed into response objects. There's no centralized error logging,
analytics integration, or structured error reporting.

---

## SUMMARY TABLE

| ID  | Severity | File                            | Issue                                                 |
| --- | -------- | ------------------------------- | ----------------------------------------------------- |
| C1  | CRITICAL | `search_storage.dart:54`        | Wrong Hive box for `clearRecentSearches`              |
| C2  | CRITICAL | `hive_manager.dart:23`          | `onLogout()` unnecessarily clears entire box          |
| C3  | CRITICAL | `app_data.dart:31-38`           | Location fields never restored on restart             |
| C4  | CRITICAL | `server.dart:126`               | Throws raw string instead of Exception                |
| C5  | CRITICAL | `server.dart:28`                | Self-signed certs always allowed                      |
| C6  | CRITICAL | `main.dart:33`                  | All uncaught errors silently swallowed                |
| C7  | CRITICAL | `session_cubit.dart:19-60`      | Double emit causes flicker + premature logout         |
| M1  | MAJOR    | `app_strings.dart`              | ~200 dead wallet/blockchain strings                   |
| M2  | MAJOR    | `helper_functions.dart`         | 6 unused wallet functions                             |
| M3  | MAJOR    | `main_screen.dart:43-56`        | MapCubit destroyed/recreated on every location change |
| M4  | MAJOR    | `server.dart:125`               | DNS lookup before every API call adds latency         |
| M5  | MAJOR    | `my_wishes_view.dart:728-730`   | Fragile `showGeneralDialog` pattern                   |
| M6  | MAJOR    | `main.dart:90`                  | Upgrader configured with no-op settings               |
| M7  | MAJOR    | `app_bottom_sheet.dart:36`      | Hardcoded primary color — no theme adaptation         |
| M8  | MAJOR    | `user_wishlist_cubit.dart`      | No loading state for delete/complete operations       |
| M9  | MAJOR    | `home_screen_cubit.dart:16-18`  | Async init in constructor with no error handling      |
| m1  | MINOR    | `generic_api_response.dart`     | Pointless wrapper class                               |
| m2  | MINOR    | `wishlist_response.dart`        | Duplicate of `GenericApiResponse`                     |
| m3  | MINOR    | `app_scaffold.dart`             | Thin wrapper adding no value                          |
| m4  | MINOR    | `main.dart`                     | Unused import                                         |
| m5  | MINOR    | `home/view/` + `chat/views/`    | Duplicate `coming_soon_screen.dart`                   |
| m6  | MINOR    | `home_screen_cubit.dart.backup` | Backup file in source tree                            |
| m7  | MINOR    | `cubits/search/`                | Empty directory                                       |
| m8  | MINOR    | `app_elevated_button.dart:27`   | Null-unsafe theme read                                |
| m9  | MINOR    | Multiple files                  | Duplicated auth gate patterns                         |
| m10 | MINOR    | `search_cubit.dart`             | Stray `HomeScreenCubit` class declaration             |
| m11 | MINOR    | `search_results_screen.dart`    | Hardcoded map tile URL                                |
| m12 | MINOR    | All services                    | No structured error logging                           |

---

## RECOMMENDATIONS (Priority Order)

1. **Fix C1** — Wrong Hive box in `SearchStorage.clearRecentSearches()` (1-line fix)
2. **Fix C4** — Wrap string with `Exception()` in `server.dart:126` (1-line fix)
3. **Fix C5** — Gate certificate bypass behind `kDebugMode` (1-line fix)
4. **Fix C3** — Restore location from storage in `AppData` constructor (5 lines)
5. **Fix C2** — Remove redundant `HiveManager.onLogout()` (3 lines + remove call site)
6. **Fix C6** — Add error logging to `runZonedGuarded` (1-line fix)
7. **Fix M1/M2** — Strip dead wallet/blockchain code (reduces binary size, improves clarity)
8. **Fix M4** — Remove DNS check, use `connectivity_plus` or Dio timeouts
9. **Fix M3** — Hoist `MapCubit` creation to parent widget
10. **Fix M7** — Use theme colors in `AppBottomSheet`
11. **Fix C7** — Restructure `SessionCubit.initialize()` to avoid double emit
12. **Fix M6** — Configure Upgrader properly or remove it
13. **Fix M9** — Add error handling to `HomeScreenCubit._initialize()`
14. **Cleanup** — Remove dead code: `generic_api_response.dart`, `home_screen_cubit.dart.backup`, empty `cubits/search/`, duplicate strings, unused functions
