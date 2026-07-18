sealed class Result<T> {
  const Result();

  /// The value, or the failure thrown, for state holders that use AsyncValue.
  T unwrap() => switch (this) {
    Success<T>(:final value) => value,
    FailureResult<T>(:final failure) => throw failure,
  };
}

final class Success<T> extends Result<T> {
  const Success(this.value);

  final T value;
}

final class FailureResult<T> extends Result<T> {
  const FailureResult(this.failure);

  final AppFailure failure;
}

/// A typed failure. UI turns [code] into text; [message] is for logs only.
final class AppFailure implements Exception {
  const AppFailure(this.message, {this.code, this.cause});

  final String message;
  final String? code;
  final Object? cause;

  @override
  String toString() => message;
}
