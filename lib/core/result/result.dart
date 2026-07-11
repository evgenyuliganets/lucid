sealed class Result<T> {
  const Result();
}

final class Success<T> extends Result<T> {
  const Success(this.value);

  final T value;
}

final class FailureResult<T> extends Result<T> {
  const FailureResult(this.failure);

  final AppFailure failure;
}

final class AppFailure implements Exception {
  const AppFailure(this.message, {this.cause});

  final String message;
  final Object? cause;

  @override
  String toString() => message;
}
