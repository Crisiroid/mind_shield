import '../../../../core/database/syncable_local_data_source.dart';
import '../../../../core/sync/offline_first_repository.dart';
import '../../../../core/sync/write_result.dart';
import '../datasources/conflict_exercise_local_datasource.dart';
import '../datasources/conflict_exercise_remote_datasource.dart';
import '../models/conflict_exercise_model.dart';

/// Conflict exercise repository — offline-first bridge between the data
/// sources and the domain layer.
class ConflictExerciseRepository
    extends OfflineFirstRepository<ConflictExerciseModel> {
  final ConflictExerciseRemoteDataSource _remoteDataSource;
  final ConflictExerciseLocalDataSource _localDataSource;

  ConflictExerciseRepository(this._remoteDataSource, this._localDataSource);

  @override
  String get featureKey => 'conflict_exercise';

  @override
  SyncableLocalDataSource<ConflictExerciseModel> get local => _localDataSource;

  @override
  Future<List<ConflictExerciseModel>> fetchRemoteList() =>
      _remoteDataSource.listConflictExercises(page: 1, pageSize: 200);

  @override
  Future<ConflictExerciseModel> pushCreate(ConflictExerciseModel item) async =>
      (await _remoteDataSource.createConflictExercise(exercise: item)).data;

  /// Create a new conflict exercise attempt (offline-first).
  Result<WriteResult<ConflictExerciseModel>> createConflictExercise({
    required ConflictExerciseModel exercise,
  }) {
    return writeCreate(
      exercise,
      (i) => _remoteDataSource.createConflictExercise(exercise: i),
    );
  }

  /// List conflict exercise attempts (offline-first).
  Result<List<ConflictExerciseModel>> listConflictExercises({
    int page = 1,
    int pageSize = 20,
  }) {
    return readList(
      () => _remoteDataSource.listConflictExercises(
        page: page,
        pageSize: pageSize,
      ),
    );
  }
}
