import 'package:dartz/dartz.dart' hide Task;
import 'package:equatable/equatable.dart';
import '../entities/task.dart';
import '../repositories/task_repository.dart';
import '../../core/error/failures.dart';
import '../../core/usecase/usecase.dart';

class GetTasksInDateRange implements UseCase<List<Task>, DateRangeParams> {
  final TaskRepository repository;

  GetTasksInDateRange(this.repository);

  @override
  Future<Either<Failure, List<Task>>> call(DateRangeParams params) async {
    return await repository.getTasksInDateRange(params.startDate, params.endDate);
  }
}

class DateRangeParams extends Equatable {
  final DateTime startDate;
  final DateTime endDate;

  const DateRangeParams({
    required this.startDate,
    required this.endDate,
  });

  @override
  List<Object> get props => [startDate, endDate];
}