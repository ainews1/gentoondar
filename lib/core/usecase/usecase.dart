import 'package:dartz/dartz.dart';
import 'package:task_calendar_app/core/error/failures.dart';

/// Abstract base class for all use cases in the application.
/// Defines the standard interface for business operations.
/// 
/// [Type] - The return type of the use case
/// [Params] - The parameters required for the use case
abstract class UseCase<Type, Params> {
  /// Execute the use case with the given parameters.
  /// Returns Either<Failure, Type> for functional error handling.
  Future<Either<Failure, Type>> call(Params params);
}

/// Placeholder class for use cases that don't require parameters.
class NoParams {
  const NoParams();
}