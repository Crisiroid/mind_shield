import 'package:dartz/dartz.dart';
import '../../../../core/database/syncable_local_data_source.dart';
import '../../../../core/sync/offline_first_repository.dart';
import '../../../../core/sync/write_result.dart';
import '../datasources/week1_remote_datasource.dart';
import '../datasources/week1_local_datasource.dart';
import '../models/weekly_exercise_model.dart';
import '../models/day_progress_model.dart';

class Week1ExerciseRepository
    extends OfflineFirstRepository<WeeklyExerciseModel> {
  final Week1RemoteDataSource _remoteDataSource;
  final WeeklyExerciseLocalDataSource _localDataSource;

  Week1ExerciseRepository(this._remoteDataSource, this._localDataSource);

  @override
  String get featureKey => 'weekly_exercises';

  @override
  SyncableLocalDataSource<WeeklyExerciseModel> get local => _localDataSource;

  @override
  Future<List<WeeklyExerciseModel>> fetchRemoteList() =>
      _remoteDataSource.listExerciseResponses();

  @override
  Future<WeeklyExerciseModel> pushCreate(WeeklyExerciseModel item) async =>
      (await _remoteDataSource.createExerciseResponse(entry: item)).data;

  @override
  Future<WeeklyExerciseModel> pushUpdate(WeeklyExerciseModel item) async =>
      (await _remoteDataSource.updateExerciseResponse(
        id: item.id,
        data: item.toUpdateJson(),
      )).data;

  Result<WriteResult<WeeklyExerciseModel>> createExerciseResponse({
    required WeeklyExerciseModel entry,
  }) {
    return writeCreate(
      entry,
      (i) => _remoteDataSource.createExerciseResponse(entry: i),
    );
  }

  Result<List<WeeklyExerciseModel>> getExercisesByWeek({
    required int weekNumber,
  }) {
    return readList(
      () => _remoteDataSource.getExercisesByWeek(weekNumber: weekNumber),
    );
  }
}

class DayProgressRepository extends OfflineFirstRepository<DayProgressModel> {
  final Week1RemoteDataSource _remoteDataSource;
  final DayProgressLocalDataSource _localDataSource;

  DayProgressRepository(this._remoteDataSource, this._localDataSource);

  @override
  String get featureKey => 'day_progress';

  @override
  SyncableLocalDataSource<DayProgressModel> get local => _localDataSource;

  @override
  Future<List<DayProgressModel>> fetchRemoteList() =>
      _remoteDataSource.getDayProgressByWeek(weekNumber: 1);

  @override
  Future<DayProgressModel> pushCreate(DayProgressModel item) async =>
      (await _remoteDataSource.createDayProgress(entry: item)).data;

  @override
  Future<DayProgressModel> pushUpdate(DayProgressModel item) async =>
      (await _remoteDataSource.createDayProgress(entry: item)).data;

  Result<DayProgressModel> markDayCompleted({
    required int weekNumber,
    required int dayNumber,
  }) async {
    try {
      final result = await _remoteDataSource.markDayCompleted(
        weekNumber: weekNumber,
        dayNumber: dayNumber,
      );
      await _localDataSource.saveSynced(result);
      return Right(result);
    } catch (e) {
      // Fallback: create locally
      final local = DayProgressModel(
        id: DateTime.now().toIso8601String(),
        userId: '',
        weekNumber: weekNumber,
        dayNumber: dayNumber,
        isCompleted: true,
        completedAt: DateTime.now(),
      );
      await _localDataSource.saveSynced(local);
      return Right(local);
    }
  }

  Result<List<DayProgressModel>> getDayProgressSummary({
    required int weekNumber,
  }) {
    return readList(
      () => _remoteDataSource.getDayProgressSummary(weekNumber: weekNumber),
    );
  }
}
