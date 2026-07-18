import '../../../../core/database/syncable_local_data_source.dart';
import '../../../../core/sync/offline_first_repository.dart';
import '../datasources/emotion_triangle_local_datasource.dart';
import '../datasources/emotion_triangle_remote_datasource.dart';
import '../models/emotion_interaction_model.dart';

/// Emotion triangle repository — offline-first bridge between the data
/// sources and the domain layer.
///
/// Extends [OfflineFirstRepository] so reads fall back to the local mirror
/// when offline and writes are persisted optimistically then synced. Depends
/// on abstractions (remote/local datasources), not on Dio directly
/// (Dependency Inversion). Public method signatures are unchanged so the
/// view model keeps working without edits.
class EmotionTriangleRepository
    extends OfflineFirstRepository<EmotionInteractionModel> {
  final EmotionTriangleRemoteDataSource _remoteDataSource;
  final EmotionTriangleLocalDataSource _localDataSource;

  EmotionTriangleRepository(this._remoteDataSource, this._localDataSource);

  @override
  String get featureKey => 'emotion';

  @override
  SyncableLocalDataSource<EmotionInteractionModel> get local =>
      _localDataSource;

  @override
  Future<List<EmotionInteractionModel>> fetchRemoteList() =>
      _remoteDataSource.listInteractions(page: 1, pageSize: 200);

  @override
  Future<EmotionInteractionModel> pushCreate(EmotionInteractionModel item) =>
      _remoteDataSource.createInteraction(interaction: item);

  /// Create a new emotion triangle interaction (offline-first).
  Result<EmotionInteractionModel> createInteraction({
    required EmotionInteractionModel interaction,
  }) {
    return writeCreate(
      interaction,
      (i) => _remoteDataSource.createInteraction(interaction: i),
    );
  }

  /// List emotion triangle interactions (offline-first).
  Result<List<EmotionInteractionModel>> listInteractions({
    int page = 1,
    int pageSize = 20,
  }) {
    return readList(
      () => _remoteDataSource.listInteractions(page: page, pageSize: pageSize),
    );
  }
}
