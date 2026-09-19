import 'package:flutter_bloc/flutter_bloc.dart';

/// Guards every [emit] with an [isClosed] check (Al Faris).
mixin SafeEmitMixin<S> on Cubit<S> {
  @override
  void emit(S state) {
    if (!isClosed) super.emit(state);
  }
}
