import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../base_response/result.dart';
import 'base_state.dart';
import 'latest_request_gate.dart';
import 'safe_emit_mixin.dart';

/// Shared cubit base with Result → BaseState mapping (Al Faris style).
///
/// Firebase apps omit Dio [CancelRequestInterceptor]; requests are awaited
/// directly. Use [emitFromResult] for loading → fold → success/failure.
abstract class BaseCubit<S> extends Cubit<S> with SafeEmitMixin<S> {
  BaseCubit(super.initialState);

  Future<Result<T>> emitFromResult<T>({
    required Future<Result<T>> Function() call,
    required void Function(BaseState<T> next) onUpdate,
    T? Function(T? data)? mapData,
    bool silent = false,
    BaseState<T>? previous,
    FutureOr<void> Function(T? data)? onSuccess,
    void Function(Exception? exception)? onError,
    void Function()? onCancelled,
  }) {
    return emitMappedFromResult<T, T>(
      call: call,
      onUpdate: onUpdate,
      mapData: mapData ?? (data) => data,
      silent: silent,
      previous: previous,
      onSuccess: onSuccess,
      onError: onError,
      onCancelled: onCancelled,
    );
  }

  Future<Result<T>> emitMappedFromResult<T, D>({
    required Future<Result<T>> Function() call,
    required void Function(BaseState<D> next) onUpdate,
    required D? Function(T? data) mapData,
    bool silent = false,
    BaseState<D>? previous,
    FutureOr<void> Function(T? data)? onSuccess,
    void Function(Exception? exception)? onError,
    void Function()? onCancelled,
  }) async {
    if (!silent) {
      onUpdate(BaseState<D>(state: StatusState.loading, data: previous?.data));
    }

    final result = await call();
    if (isClosed) return result;

    result.fold(
      onSuccess: (ok) {
        onUpdate(
          BaseState<D>(state: StatusState.success, data: mapData(ok.data)),
        );
      },
      onError: (err) {
        if (!silent) {
          onUpdate(
            BaseState<D>(
              state: StatusState.failure,
              exception: err.exception,
              data: previous?.data,
            ),
          );
        }
        onError?.call(err.exception);
      },
      onCancelled: (_) => onCancelled?.call(),
    );

    if (result is Success<T>) {
      await onSuccess?.call(result.data);
    }

    return result;
  }

  Future<Result<T>?> emitLatestFromResult<T>({
    required LatestRequestGate gate,
    required int requestId,
    required Future<Result<T>> Function() call,
    required void Function(BaseState<T> next) onUpdate,
    BaseState<T>? previous,
    void Function(Exception? exception)? onError,
    void Function()? onCancelled,
    FutureOr<void> Function(T? data)? onSuccess,
    bool emitLoading = true,
  }) async {
    if (emitLoading) {
      onUpdate(BaseState<T>(state: StatusState.loading, data: previous?.data));
    }

    final result = await call();
    if (!gate.isCurrent(requestId) || isClosed) return null;

    result.fold(
      onSuccess: (ok) {
        onUpdate(BaseState<T>(state: StatusState.success, data: ok.data));
      },
      onError: (err) {
        onUpdate(
          BaseState<T>(
            state: StatusState.failure,
            exception: err.exception,
            data: previous?.data,
          ),
        );
        onError?.call(err.exception);
      },
      onCancelled: (_) => onCancelled?.call(),
    );

    if (result is Success<T>) {
      await onSuccess?.call(result.data);
    }

    return result;
  }
}
