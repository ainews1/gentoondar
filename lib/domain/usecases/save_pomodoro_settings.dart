import 'package:dartz/dartz.dart' hide Task;
import 'package:task_calendar_app/core/error/failures.dart';
import 'package:task_calendar_app/core/usecase/usecase.dart';
import 'package:task_calendar_app/data/datasources/local/pomodoro_settings_datasource.dart';
import 'package:task_calendar_app/domain/entities/pomodoro_settings.dart';

/// Use case for saving Pomodoro settings.
/// Goes through SharedPreferences datasource directly (not repository)
/// since settings are simple key-value data, not relational.
class SavePomodoroSettings
    implements UseCase<void, SavePomodoroSettingsParams> {
  final PomodoroSettingsDatasource datasource;

  SavePomodoroSettings(this.datasource);

  @override
  Future<Either<Failure, void>> call(
      SavePomodoroSettingsParams params) async {
    try {
      await datasource.saveSettings(params.settings);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(
        'Failed to save pomodoro settings: ${e.toString()}',
        'SAVE_SETTINGS_ERROR',
      ));
    }
  }
}

/// Parameters for SavePomodoroSettings use case.
class SavePomodoroSettingsParams {
  final PomodoroSettings settings;

  const SavePomodoroSettingsParams({required this.settings});
}
