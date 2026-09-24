---
name: flutter-thin-page
description: >-
  Enforces Al Faris Flutter presentation architecture: thin RoutePages,
  public body widgets, AutoRouteWrapper + InjectedBlocProvider DI, SOLID/SRP
  UI splits, view utils, and cubit part/extension splits for fat cubits. Use
  when creating or refactoring feature pages/widgets/cubits, auditing
  presentation structure, extracting god pages, cubit extensions, or when the
  user mentions thin page, SOLID UI, OOP widgets, presentation DI, or cubit
  part files.
---

# Flutter Thin Page (Al Faris)

## Gold pattern

```
feature/
  api/ data/ domain/          # clean architecture (existing)
  presentation/
    view_model/cubit/         # @injectable cubits + states
    view/
      pages/                  # thin RoutePage only
      widgets/                # public *Body and UI pieces
      utils/                  # share helpers, loaders, camera sessions (no widgets)
```

### Page (thin)

```dart
@RoutePage()
class ExamplePage extends StatelessWidget implements AutoRouteWrapper {
  const ExamplePage({super.key});

  @override
  Widget wrappedRoute(BuildContext context) {
    return InjectedBlocProvider<ExampleCubit>(
      onCreate: (cubit) => cubit.load(),
      child: this,
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(top: false, child: ExampleBody()),
    );
  }
}
```

Rules:
- **No** private `_XxxView` / `_XxxShimmer` / `CustomPainter` classes in `pages/`
- **No** `InjectedBlocProvider` inside `build()` — use `wrappedRoute`
- Prefer `StatelessWidget` + `AutoRouteWrapper`; keep `StatefulWidget` only when the **page shell** must own lifecycle (rare — prefer body)
- Page may own: route args, app bar title wiring, `PopScope`, status-bar `AnnotatedRegion`
- Reference: `login_page.dart`, `receive_points_page.dart`, `notification_page.dart`

### Body / widgets

- Put UI in `presentation/view/widgets/` as **public** classes (`ExampleBody`, `ExampleShimmer`)
- One job per widget file when it grows (list, panel, dialog, painter)
- Multi-step flows → `*FlowBody` (e.g. `ForgetPasswordFlowBody`, `RegisterFlowBody`)

### Utils (SRP)

- Non-widget logic (share QR, camera session, filter loaders) → `view/utils/`
- Do not bury file I/O / permission / share inside page `State`

### DI

- Cubits: `@injectable` (or factory with params) via GetIt / injectable codegen
- Provide only through `InjectedBlocProvider` / `InjectedBlocProvider.factory`
- Never `BlocProvider(create: () => SomeCubit(...))` bypassing GetIt

### Cubit extensions (`part` split)

When a cubit grows past one clear responsibility, keep a **façade** class and
split methods into `part` files as **extensions on the cubit** (same library →
private fields stay accessible).

```dart
// example_cubit.dart
part 'example_cubit_load.dart';
part 'example_cubit_actions.dart';

@injectable
class ExampleCubit extends Cubit<ExampleState> {
  ExampleCubit(this._useCase) : super(const ExampleState());
  final ExampleUseCase _useCase;
  // ctor, dispose, shared private helpers only
}

// example_cubit_load.dart
part of 'example_cubit.dart';

extension ExampleCubitLoad on ExampleCubit {
  Future<void> load() async { /* emit + use cases */ }
}
```

Rules:
- Use `part` / `part of` — **not** separate libraries (extensions need private members)
- One concern per file: load, pricing, coupon, checkout, location, etc.
- Main file: deps, ctor, state wiring, dispose, short façade comment listing parts
- Still **one** `@injectable` class registered in GetIt
- Reference: `cart_cubit.dart` (+ items/pricing/coupon/checkout), `delivery_cubit.dart` (+ slider/location/pricing)
- Do **not** split small cubits (under ~150–200 lines) just for symmetry

### Params (SRP)

- `PaginationParams` = **page + limit only**
- Feature filters (`type`, `status`, `isUsed`, …) go on dedicated params that **embed** `PaginationParams` (see `StoresParams`, `AvailableRewardsParams`, `MyGiftsParams`)
- Never overload `PaginationParams` with domain filters
- Don’t mix list-query and create/update bodies in one params type (e.g. `GetRatingsParams` vs `UpsertRatingParams`)
- Don’t mix list-query and get-by-id path params (e.g. `StoresParams` vs `GetStoreByIdParams`, `GetOrderParams` vs `GetOrderByIdParams`, `StoreProductParams` vs `GetProductByIdParams`)

## Refactor checklist

When a page is fat or has private widgets:

1. Extract public `*Body` (and shimmers/painters) under `widgets/`
2. Move duplicated fetch/share/camera logic to `view/utils/`
3. Convert page to `AutoRouteWrapper` + thin `build`
4. `dart analyze` the feature `presentation/view` path
5. Target page size roughly **≤ 60 lines** (shells like hub/profile can be slightly higher)

## Anti-patterns

| Bad | Good |
|-----|------|
| God page 150–300+ lines | Thin page + body |
| `_PrivateView` in pages | Public widget file |
| Provider in `build()` | `wrappedRoute` |
| Share/camera I/O in page State | `view/utils/` helper |
| Duplicate fetch switch in page + body | Single loader util |
| 400+ line god cubit | Façade + `part` extensions by concern |
| Separate dart files that can’t see `_private` | `part of` same cubit library |

## Audit command hints

```bash
# Fat pages
wc -l lib/features/*/presentation/view/pages/*.dart | sort -n

# Private classes still in pages
rg '^class _' lib/features/*/presentation/view/pages -g '*.dart'

# DI in build instead of wrapper
rg -L 'wrappedRoute' $(rg -l 'InjectedBlocProvider' lib/features/*/presentation/view/pages -g '*.dart')

# Cubit extension splits already in use
rg -n 'extension \w+ on \w+Cubit' lib/features -g '*.dart'
rg -n "^part '" lib/features/*/presentation/view_model/cubit -g '*_cubit.dart'
```
