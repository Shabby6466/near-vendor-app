# Cubit Usage Guide

This guide documents how to properly use Cubits in this Flutter project, based on established patterns and best practices found throughout the codebase.

## Table of Contents
- [Overview](#overview)
- [Cubit Structure](#cubit-structure)
- [State Management Patterns](#state-management-patterns)
- [Creating a Cubit](#creating-a-cubit)
- [Using Cubits in Widgets](#using-cubits-in-widgets)
- [Resource Management](#resource-management)
- [Common Patterns](#common-patterns)
- [What NOT to Do](#what-not-to-do)
- [Best Practices](#best-practices)

## Overview

Cubits are used for state management throughout this project. They provide a simple way to manage state and emit new states in response to user actions or data changes. This project uses the `flutter_bloc` package.

**Key Principles:**
- Cubits extend `Cubit<State>` from `flutter_bloc`
- States should be immutable and use `Equatable` for comparison
- Always clean up resources in the `close()` method
- Use `BlocProvider` to provide cubits to the widget tree
- Use `BlocBuilder`, `BlocConsumer`, or `BlocListener` to react to state changes

## Cubit Structure

### Basic Cubit Template

```dart
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'my_cubit_state.dart';

class MyCubit extends Cubit<MyCubitState> {
  MyCubit() : super(const MyCubitState.initial()) {
    // Optional initialization
    _initialize();
  }

  Future<void> _initialize() async {
    // Initialization logic
  }

  void someAction() {
    emit(state.copyWith(/* updates */));
  }

  @override
  Future<void> close() async {
    // Clean up resources (controllers, subscriptions, timers, etc.)
    await super.close();
  }
}
```

## State Management Patterns

This project uses two main state patterns:

### Pattern 1: Sealed Classes (Union Types)

Used for states with distinct, mutually exclusive states (e.g., loading, success, error).

**Example:** `GeneralPinCubit` and `SettingsCubit`

```dart
part of 'general_pin_cubit.dart';

sealed class GeneralPinState extends Equatable {
  const GeneralPinState();

  @override
  List<Object?> get props => [];
}

final class GeneralPinInitial extends GeneralPinState {}
final class GeneralPinLoading extends GeneralPinState {}
final class GeneralPinSuccess extends GeneralPinState {}
final class GeneralPinFailure extends GeneralPinState {
  final String message;
  const GeneralPinFailure(this.message);
  
  @override
  List<Object?> get props => [message];
}
```

**When to use:**
- Simple flows with distinct states (initial, loading, success, error)
- States are mutually exclusive
- Each state represents a different UI state

**Usage in widgets:**
```dart
BlocBuilder<GeneralPinCubit, GeneralPinState>(
  builder: (context, state) {
    if (state is GeneralPinLoading) {
      return CircularProgressIndicator();
    }
    if (state is GeneralPinFailure) {
      return Text('Error: ${state.message}');
    }
    if (state is GeneralPinSuccess) {
      return Text('Success!');
    }
    return Text('Initial state');
  },
)
```

### Pattern 2: Data Classes with copyWith

Used for complex states that need to hold multiple values and update incrementally.

**Example:** `AppDataCubitState`

```dart
part of 'app_data_cubit.dart';

enum WalletsStatus { initial, loading, ready, error }
enum BalanceStatus { loading, loaded, error }

class AppDataCubitState extends Equatable {
  final WalletsStatus status;
  final Wallet? currentWallet;
  final List<Wallet> wallets;
  final String? error;
  final BalanceStatus balanceStatus;
  final double walletBalance;

  const AppDataCubitState({
    required this.status,
    required this.currentWallet,
    required this.wallets,
    required this.error,
    required this.balanceStatus,
    required this.walletBalance,
  });

  const AppDataCubitState.initial()
    : status = WalletsStatus.initial,
      currentWallet = null,
      wallets = const [],
      error = null,
      balanceStatus = BalanceStatus.loading,
      walletBalance = 0.0;

  AppDataCubitState copyWith({
    WalletsStatus? status,
    Wallet? currentWallet,
    List<Wallet>? wallets,
    String? error,
    BalanceStatus? balanceStatus,
    double? walletBalance,
  }) {
    return AppDataCubitState(
      status: status ?? this.status,
      currentWallet: currentWallet ?? this.currentWallet,
      wallets: wallets ?? this.wallets,
      error: error,
      balanceStatus: balanceStatus ?? this.balanceStatus,
      walletBalance: walletBalance ?? this.walletBalance,
    );
  }

  @override
  List<Object?> get props => [
    status,
    currentWallet,
    wallets.map((w) => w.id).toList(),
    error,
    balanceStatus,
    walletBalance,
  ];
}
```

**When to use:**
- Complex state with multiple related values
- Need to update state incrementally
- State values can coexist (e.g., loading + data)

**Usage in widgets:**
```dart
BlocBuilder<AppDataCubit, AppDataCubitState>(
  builder: (context, state) {
    if (state.status == WalletsStatus.loading) {
      return CircularProgressIndicator();
    }
    return WalletList(wallets: state.wallets);
  },
)
```

## Creating a Cubit

### Step 1: Define the State

Create a state file (e.g., `my_cubit_state.dart`) using one of the patterns above.

### Step 2: Create the Cubit Class

```dart
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'my_cubit_state.dart';

class MyCubit extends Cubit<MyCubitState> {
  MyCubit() : super(const MyCubitState.initial()) {
    _initialize();
  }

  // Private fields for internal state
  final SomeRepository _repository = SomeRepository.instance;
  StreamSubscription? _subscription;
  Timer? _timer;

  Future<void> _initialize() async {
    // Initialization logic
    await loadData();
  }

  Future<void> loadData() async {
    emit(state.copyWith(status: Status.loading));
    try {
      final data = await _repository.fetchData();
      emit(state.copyWith(
        status: Status.loaded,
        data: data,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: Status.error,
        error: e.toString(),
      ));
    }
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    _timer?.cancel();
    await super.close();
  }
}
```

### Step 3: Use in Widgets

See [Using Cubits in Widgets](#using-cubits-in-widgets) section below.

## Using Cubits in Widgets

### Providing a Cubit

Use `BlocProvider` to provide a cubit to the widget tree:

```dart
BlocProvider(
  create: (context) => MyCubit(),
  child: MyWidget(),
)
```

For multiple cubits, use `MultiBlocProvider`:

```dart
MultiBlocProvider(
  providers: [
    BlocProvider(create: (context) => AppDataCubit()),
    BlocProvider(
      create: (context) => WalletConnectCubit(),
      lazy: false, // Create immediately, not lazily
    ),
  ],
  child: MyApp(),
)
```

### Accessing a Cubit

**For reading state (triggers rebuilds):**
```dart
// Using BlocBuilder
BlocBuilder<MyCubit, MyCubitState>(
  builder: (context, state) {
    return Text('Status: ${state.status}');
  },
)

// Using context.watch (in build method)
final state = context.watch<MyCubit>().state;

// Using context.select (rebuilds only when selected value changes)
final wallets = context.select<AppDataCubit, List<Wallet>>(
  (cubit) => cubit.state.wallets,
);
```

**For calling methods (does NOT trigger rebuilds):**
```dart
// Using context.read (preferred for callbacks)
context.read<MyCubit>().loadData();

// In callbacks, event handlers, etc.
onPressed: () => context.read<MyCubit>().someAction(),
```

### Listening to State Changes

**BlocConsumer** - Combines builder and listener:

```dart
BlocConsumer<MyCubit, MyCubitState>(
  listener: (context, state) {
    // Side effects (navigation, showing dialogs, etc.)
    if (state is MySuccessState) {
      Navigator.of(context).pop();
    }
    if (state is MyErrorState) {
      AppAlerts.showErrorSnackBar(state.message);
    }
  },
  builder: (context, state) {
    // UI building
    return MyWidget();
  },
)
```

**BlocListener** - Only for side effects, no UI:

```dart
BlocListener<MyCubit, MyCubitState>(
  listener: (context, state) {
    if (state is MySuccessState) {
      Navigator.of(context).pushReplacement(...);
    }
  },
  child: MyWidget(),
)
```

**BlocBuilder** - Only for UI, no side effects:

```dart
BlocBuilder<MyCubit, MyCubitState>(
  builder: (context, state) {
    if (state is MyLoadingState) {
      return CircularProgressIndicator();
    }
    return MyContent();
  },
)
```

## Resource Management

### Always Clean Up Resources

Cubits must clean up resources in the `close()` method to prevent memory leaks:

```dart
class MyCubit extends Cubit<MyCubitState> {
  StreamSubscription? _subscription;
  Timer? _timer;
  TextEditingController? _controller;
  CancelToken? _cancelToken;

  @override
  Future<void> close() async {
    // Cancel subscriptions
    await _subscription?.cancel();
    
    // Cancel timers
    _timer?.cancel();
    
    // Dispose controllers
    _controller?.dispose();
    
    // Cancel network requests
    _cancelToken?.cancel();
    
    // Always call super.close() last
    await super.close();
  }
}
```

### Examples from the Codebase

**AppDataCubit** - Cleans up stream subscriptions and timers:
```dart
@override
Future<void> close() async {
  await _walletsWatch?.cancel();
  await _currentWalletIdWatch?.cancel();
  _hourlyTimer?.cancel();
  return super.close();
}
```

**GeneralPinCubit** - Disposes text controllers:
```dart
@override
Future<void> close() async {
  codeController.dispose();
  await super.close();
}
```

**ActivityCubit** - Cancels network requests:
```dart
Future<void> refresh({bool silent = false}) async {
  _cancelToken?.cancel(); // Cancel previous request
  _cancelToken = CancelToken();
  // ... make new request
}
```

## Common Patterns

### Pattern 1: Initialization in Constructor

```dart
class MyCubit extends Cubit<MyCubitState> {
  MyCubit() : super(const MyCubitState.initial()) {
    _initialize(); // Call private init method
  }

  Future<void> _initialize() async {
    // Load initial data
    await loadData();
  }
}
```

### Pattern 2: Loading States

Always emit loading state before async operations:

```dart
Future<void> performAction() async {
  emit(state.copyWith(status: Status.loading));
  try {
    final result = await _repository.doSomething();
    emit(state.copyWith(
      status: Status.loaded,
      data: result,
    ));
  } catch (e) {
    emit(state.copyWith(
      status: Status.error,
      error: e.toString(),
    ));
  }
}
```

### Pattern 3: Conditional State Updates

Check current state before emitting to avoid unnecessary rebuilds:

```dart
void switchTab(int index) {
  if (index != state) emit(index); // Only emit if different
}

Future<void> refresh() async {
  if (state.status != WalletsStatus.loading) {
    emit(state.copyWith(status: WalletsStatus.loading));
  }
  // ... rest of logic
}
```

### Pattern 4: Error Handling

Always handle errors and emit error states:

```dart
Future<void> deleteUser() async {
  emit(DeletingAccount());
  try {
    final response = await AuthRepository.instance.deleteUser();
    if (response.status == 200) {
      emit(const AccountDeleted());
    } else {
      emit(FailedState(response.message ?? 'Failed to delete'));
    }
  } catch (e) {
    emit(FailedState('Connection error: $e'));
  }
}
```

### Pattern 5: Private State + Public Getters

Store internal state privately, expose via getters:

```dart
class SendAmountCubit extends Cubit<SendAmountState> {
  Token? _selectedToken;
  double? _amount;
  TokenReceiver? _receiver;

  // Public getters
  Token? get selectedToken => _selectedToken;
  double? get amount => _amount;
  TokenReceiver? get receiver => _receiver;

  void onTokenSelection(Token token) {
    _selectedToken = token;
    _emitLoadedState();
  }
}
```

### Pattern 6: Stream Subscriptions

Listen to external streams and react to changes:

```dart
class AppDataCubit extends Cubit<AppDataCubitState> {
  StreamSubscription? _walletsWatch;

  void _startListening() {
    _walletsWatch = HiveManager.walletsMetadataBox.watch().listen((_) {
      refresh(); // React to changes
    });
  }
}
```

### Pattern 7: Inheriting from Base Cubits

Extend base cubits for shared functionality:

```dart
class ResetPasswordCodeCubit extends GeneralPinCubit {
  final String email;

  ResetPasswordCodeCubit({required this.email}) : super();

  Future<void> verifyResetCode(String code) async {
    try {
      final response = await AuthRepository().verifyOtp(email, code);
      if (response.status == 200) {
        onSuccess(); // Use parent method
      } else {
        onFailure(response.message ?? 'Invalid code');
      }
    } catch (e) {
      onFailure('Network error: $e');
    }
  }
}
```

## What NOT to Do

### ❌ DON'T: Emit States in Build Methods

```dart
// WRONG
@override
Widget build(BuildContext context) {
  context.read<MyCubit>().loadData(); // Don't do this!
  return MyWidget();
}
```

**Why:** Build methods can be called multiple times, causing unnecessary state emissions and potential infinite loops.

**Correct approach:** Initialize in the cubit constructor or use `BlocProvider` with initialization logic.

### ❌ DON'T: Use context.read in Build Methods for Reading State

```dart
// WRONG - This won't trigger rebuilds
@override
Widget build(BuildContext context) {
  final state = context.read<MyCubit>().state; // Don't do this!
  return Text(state.data);
}
```

**Why:** `context.read` doesn't listen to changes, so the widget won't rebuild when state changes.

**Correct approach:**
```dart
// Use BlocBuilder
BlocBuilder<MyCubit, MyCubitState>(
  builder: (context, state) => Text(state.data),
)

// Or use context.watch
final state = context.watch<MyCubit>().state;
```

### ❌ DON'T: Forget to Clean Up Resources

```dart
// WRONG
class MyCubit extends Cubit<MyCubitState> {
  StreamSubscription? _subscription;
  Timer? _timer;
  
  // Missing close() method!
}
```

**Why:** Resources will leak, causing memory issues and unexpected behavior.

**Correct approach:** Always implement `close()` and clean up all resources.

### ❌ DON'T: Emit States Without Checking Current State

```dart
// WRONG - May cause unnecessary rebuilds
void updateStatus() {
  emit(state.copyWith(status: Status.loading)); // Always emits
}
```

**Why:** Can cause unnecessary widget rebuilds even when state hasn't meaningfully changed.

**Correct approach:**
```dart
void updateStatus() {
  if (state.status != Status.loading) {
    emit(state.copyWith(status: Status.loading));
  }
}
```

### ❌ DON'T: Store Mutable State Outside of Cubit State

```dart
// WRONG
class MyCubit extends Cubit<MyCubitState> {
  List<String> items = []; // Mutable state outside of state class
  
  void addItem(String item) {
    items.add(item); // State not in cubit state!
    emit(state); // State hasn't changed
  }
}
```

**Why:** State changes won't be tracked, and widgets won't rebuild properly.

**Correct approach:**
```dart
class MyCubit extends Cubit<MyCubitState> {
  void addItem(String item) {
    emit(state.copyWith(
      items: [...state.items, item],
    ));
  }
}
```

### ❌ DON'T: Use context.read for State in Build Methods

```dart
// WRONG
@override
Widget build(BuildContext context) {
  final cubit = context.read<MyCubit>();
  return Text(cubit.state.data); // Won't rebuild!
}
```

**Why:** `context.read` doesn't create a dependency, so the widget won't rebuild when state changes.

**Correct approach:** Use `BlocBuilder`, `context.watch`, or `context.select`.

### ❌ DON'T: Create Cubits in Build Methods

```dart
// WRONG
@override
Widget build(BuildContext context) {
  final cubit = MyCubit(); // New instance every build!
  return BlocProvider.value(
    value: cubit,
    child: MyWidget(),
  );
}
```

**Why:** Creates a new cubit instance on every rebuild, losing state and causing memory leaks.

**Correct approach:** Use `BlocProvider` with `create` callback, or `BlocProvider.value` with a stable instance.

### ❌ DON'T: Access Cubit Before It's Provided

```dart
// WRONG
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cubit = context.read<MyCubit>(); // May throw error!
    return Text('Data');
  }
}
```

**Why:** If the cubit isn't provided in the widget tree above, this will throw an error.

**Correct approach:** Ensure the cubit is provided via `BlocProvider` higher in the tree, or provide it locally.

### ❌ DON'T: Emit States Synchronously After Async Operations Without Await

```dart
// WRONG
Future<void> loadData() async {
  emit(LoadingState());
  _repository.fetchData().then((data) {
    emit(LoadedState(data)); // May emit after cubit is closed!
  });
}
```

**Why:** If the cubit is closed before the async operation completes, emitting will throw an error.

**Correct approach:**
```dart
Future<void> loadData() async {
  emit(LoadingState());
  try {
    final data = await _repository.fetchData();
    if (!isClosed) { // Check if cubit is still open
      emit(LoadedState(data));
    }
  } catch (e) {
    if (!isClosed) {
      emit(ErrorState(e.toString()));
    }
  }
}
```

### ❌ DON'T: Use Global/Static Cubit Instances

```dart
// WRONG
class MyCubit extends Cubit<MyCubitState> {
  static final MyCubit instance = MyCubit(); // Global instance
}
```

**Why:** Makes testing difficult, can cause state pollution, and doesn't follow Flutter's widget lifecycle.

**Correct approach:** Create cubits through `BlocProvider` and let Flutter manage their lifecycle.

## Best Practices

### ✅ DO: Use Equatable for State Comparison

```dart
class MyState extends Equatable {
  final String data;
  final int count;
  
  const MyState({required this.data, required this.count});
  
  @override
  List<Object?> get props => [data, count];
}
```

**Why:** Prevents unnecessary rebuilds when state hasn't actually changed.

### ✅ DO: Use Sealed Classes for Distinct States

```dart
sealed class MyState extends Equatable {
  const MyState();
}

final class Initial extends MyState {}
final class Loading extends MyState {}
final class Loaded extends MyState {
  final String data;
  const Loaded(this.data);
  @override
  List<Object?> get props => [data];
}
```

**Why:** Type-safe state handling with exhaustive pattern matching.

### ✅ DO: Use copyWith for Data Classes

```dart
MyState copyWith({
  String? data,
  int? count,
}) {
  return MyState(
    data: data ?? this.data,
    count: count ?? this.count,
  );
}
```

**Why:** Immutable updates that are easy to reason about.

### ✅ DO: Handle Errors Properly

```dart
Future<void> performAction() async {
  emit(LoadingState());
  try {
    final result = await _repository.action();
    emit(SuccessState(result));
  } catch (e) {
    emit(ErrorState(e.toString()));
  }
}
```

**Why:** Users need feedback when things go wrong.

### ✅ DO: Use context.select for Performance

```dart
// Only rebuilds when wallets list changes, not on any state change
final wallets = context.select<AppDataCubit, List<Wallet>>(
  (cubit) => cubit.state.wallets,
);
```

**Why:** Prevents unnecessary rebuilds when only specific parts of state change.

### ✅ DO: Use BlocConsumer for Side Effects + UI

```dart
BlocConsumer<MyCubit, MyCubitState>(
  listener: (context, state) {
    // Handle side effects (navigation, alerts, etc.)
    if (state is SuccessState) {
      Navigator.of(context).pop();
    }
  },
  builder: (context, state) {
    // Build UI
    return MyWidget();
  },
)
```

**Why:** Separates concerns and makes code more maintainable.

### ✅ DO: Check isClosed Before Emitting After Async

```dart
Future<void> loadData() async {
  emit(LoadingState());
  final data = await _repository.fetchData();
  if (!isClosed) {
    emit(LoadedState(data));
  }
}
```

**Why:** Prevents errors when cubit is closed before async operation completes.

### ✅ DO: Use Key with BlocProvider for State Reset

```dart
BlocProvider(
  key: ValueKey(walletId), // Reset cubit when walletId changes
  create: (context) => ActivityCubit(currentWallet),
  child: ActivityScreen(),
)
```

**Why:** Ensures fresh state when dependencies change.

### ✅ DO: Initialize in Constructor

```dart
class MyCubit extends Cubit<MyCubitState> {
  MyCubit() : super(const MyCubitState.initial()) {
    _initialize(); // Load initial data
  }
  
  Future<void> _initialize() async {
    await loadData();
  }
}
```

**Why:** Ensures cubit is ready to use immediately after creation.

### ✅ DO: Dispose Controllers in close()

```dart
class MyCubit extends Cubit<MyCubitState> {
  final TextEditingController controller = TextEditingController();
  
  @override
  Future<void> close() async {
    controller.dispose();
    await super.close();
  }
}
```

**Why:** Prevents memory leaks from controllers.

## Examples from the Codebase

### Example 1: Simple Cubit (MainScreenCubit)

```dart
class MainScreenCubit extends Cubit<int> {
  MainScreenCubit(super.initialIndex);

  void switchTab(int index) {
    if (index != state) emit(index); // Only emit if different
  }
}
```

**Key points:**
- Simple state (just an int)
- Conditional emit to avoid unnecessary rebuilds
- No cleanup needed (no resources)

### Example 2: Complex Cubit with Resources (AppDataCubit)

```dart
class AppDataCubit extends Cubit<AppDataCubitState> {
  AppDataCubit() : super(const AppDataCubitState.initial()) {
    _startListening();
    refresh();
    _fetchTokens();
  }

  StreamSubscription? _walletsWatch;
  StreamSubscription? _currentWalletIdWatch;
  Timer? _hourlyTimer;

  void _startListening() {
    _walletsWatch = HiveManager.walletsMetadataBox.watch().listen((_) {
      refresh();
    });
  }

  @override
  Future<void> close() async {
    await _walletsWatch?.cancel();
    await _currentWalletIdWatch?.cancel();
    _hourlyTimer?.cancel();
    return super.close();
  }
}
```

**Key points:**
- Initializes in constructor
- Manages stream subscriptions
- Cleans up all resources in close()
- Uses data class state with copyWith

### Example 3: Cubit with Controllers (GeneralPinCubit)

```dart
class GeneralPinCubit extends Cubit<GeneralPinState> {
  GeneralPinCubit() : super(GeneralPinInitial());

  final codeController = TextEditingController();

  void onCodeChanged(String code) {
    emit(GeneralPinCodeChanged(code));
  }

  @override
  Future<void> close() async {
    codeController.dispose();
    await super.close();
  }
}
```

**Key points:**
- Manages TextEditingController
- Disposes controller in close()
- Uses sealed class states

### Example 4: Inherited Cubit (ResetPasswordCodeCubit)

```dart
class ResetPasswordCodeCubit extends GeneralPinCubit {
  final String email;

  ResetPasswordCodeCubit({required this.email}) : super();

  Future<void> verifyResetCode(String code) async {
    try {
      final response = await AuthRepository().verifyOtp(email, code);
      if (response.status == 200) {
        onSuccess(); // Use parent method
      } else {
        onFailure(response.message ?? 'Invalid code');
      }
    } catch (e) {
      onFailure('Network error: $e');
    }
  }
}
```

**Key points:**
- Extends base cubit for shared functionality
- Uses parent's state management methods
- Handles errors properly

## Summary

**Remember:**
1. ✅ Always extend `Cubit<State>` and use `Equatable` for states
2. ✅ Clean up resources in `close()` method
3. ✅ Use `BlocProvider` to provide cubits
4. ✅ Use `BlocBuilder`/`BlocConsumer`/`BlocListener` appropriately
5. ✅ Use `context.read` for actions, `context.watch`/`BlocBuilder` for state
6. ✅ Handle errors and emit error states
7. ✅ Check `isClosed` before emitting after async operations
8. ✅ Use sealed classes for distinct states, data classes for complex state
9. ❌ Don't emit in build methods
10. ❌ Don't forget to clean up resources
11. ❌ Don't use `context.read` for reading state in build methods
12. ❌ Don't create cubits in build methods

Following these patterns ensures maintainable, performant, and bug-free state management in your Flutter app.
