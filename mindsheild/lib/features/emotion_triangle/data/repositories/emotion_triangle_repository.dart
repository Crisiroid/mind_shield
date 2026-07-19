import '../../../../core/database/syncable_local_data_source.dart';
import '../../../../core/sync/offline_first_repository.dart';
import '../../../../core/sync/write_result.dart';
import '../datasources/emotion_triangle_local_datasource.dart';
import '../datasources/emotion_triangle_remote_datasource.dart';
import '../models/emotion_interaction_model.dart';

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
  Future<EmotionInteractionModel> pushCreate(
    EmotionInteractionModel item,
  ) async =>
      (await _remoteDataSource.createInteraction(interaction: item)).data;

  Result<WriteResult<EmotionInteractionModel>> createInteraction({
    required EmotionInteractionModel interaction,
  }) {
    return writeCreate(
      interaction,
      (i) => _remoteDataSource.createInteraction(interaction: i),
    );
  }

  Result<List<EmotionInteractionModel>> listInteractions({
    int page = 1,
    int pageSize = 20,
  }) {
    return readList(
      () => _remoteDataSource.listInteractions(page: page, pageSize: pageSize),
    );
  }
}
