import 'package:equatable/equatable.dart';

/// Abstract base class for all failure types in the application.
/// Provides structured error handling across all layers.
abstract class Failure extends Equatable {
  /// Human-readable error message
  final String message;
  
  /// Error code for programmatic handling
  final String code;

  const Failure(this.message, this.code);

  @override
  List<Object> get props => [message, code];
}

/// Failure type for database-related errors.
/// Used when SQLite operations fail or data corruption occurs.
class DatabaseFailure extends Failure {
  const DatabaseFailure(super.message, super.code);
}

/// Failure type for validation errors.
/// Used when input data doesn't meet business rules or constraints.
class ValidationFailure extends Failure {
  const ValidationFailure(super.message, super.code);
}

/// Failure type for resource not found errors.
/// Used when requested entities don't exist in the data store.
class NotFoundFailure extends Failure {
  const NotFoundFailure(super.message, super.code);
}