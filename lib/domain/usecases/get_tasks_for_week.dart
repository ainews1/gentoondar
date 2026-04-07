import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../entities/task.dart';
import '../repositories/task_repository.dart';
import '../../core/error/failures.dart';
import '../../core/usecase/usecase.dart';

class GetTasksForWeek implements UseCase<List<Task>, WeekParams> {
  final TaskRepository repository;

  GetTasksForWeek(this.repository);

  @override
  Future<Either<Failure, List<Task>>> call(WeekParams params) async {
    final startOfWeek = _getStartOfWeek(params.weekDate);
    final endOfWeek = startOfWeek.add(const Duration(days: 6, hours: 23, minutes: 59));
    
    return await repository.getTasksInDateRange(startOfWeek, endOfWeek);
  }

  DateTime _getStartOfWeek(DateTime date) {
    // Get Monday as start of week
    final daysFromMonday = date.weekday - 1;
    final startOfWeek = date.subtract(Duration(days: daysFromMonday));
    return DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
  }
}

class WeekParams extends Equatable {
  final DateTime weekDate; // Any date within the week

  const WeekParams({required this.weekDate});

  @override
  List<Object> get props => [weekDate];
}