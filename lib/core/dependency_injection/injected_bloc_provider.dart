import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'injectable_config.dart';

/// Provides a Cubit/Bloc resolved from GetIt so feature pages never call
/// [getIt] directly.
class InjectedBlocProvider<T extends StateStreamableSource<Object?>>
    extends StatelessWidget {
  final Widget child;
  final void Function(T cubit)? onCreate;
  final T Function()? create;

  /// Resolve [T] from GetIt (default).
  const InjectedBlocProvider({
    super.key,
    required this.child,
    this.onCreate,
  }) : create = null;

  /// Custom factory (e.g. cubits with `@factoryParam`).
  const InjectedBlocProvider.factory({
    super.key,
    required T Function() this.create,
    required this.child,
    this.onCreate,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider<T>(
      create: (_) {
        final cubit = create?.call() ?? getIt<T>();
        onCreate?.call(cubit);
        return cubit;
      },
      child: child,
    );
  }
}

/// Thin facade so call sites do not import GetIt by name.
abstract final class Injected {
  static T get<T extends Object>({dynamic param1, dynamic param2}) {
    return getIt<T>(param1: param1, param2: param2);
  }
}
