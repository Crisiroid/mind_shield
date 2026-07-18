import '../../../../core/database/syncable_local_data_source.dart';
import '../../../../core/sync/offline_first_repository.dart';
import '../../../../core/sync/write_result.dart';
import '../datasources/cognitive_game_local_datasource.dart';
import '../datasources/cognitive_game_remote_datasource.dart';
import '../models/cognitive_game_model.dart';

/// Cognitive game repository — offline-first bridge between the data sources
/// and the domain layer.
class CognitiveGameRepository
    extends OfflineFirstRepository<CognitiveGameModel> {
  final CognitiveGameRemoteDataSource _remoteDataSource;
  final CognitiveGameLocalDataSource _localDataSource;

  CognitiveGameRepository(this._remoteDataSource, this._localDataSource);

  @override
  String get featureKey => 'cognitive_game';

  @override
  SyncableLocalDataSource<CognitiveGameModel> get local => _localDataSource;

  @override
  Future<List<CognitiveGameModel>> fetchRemoteList() =>
      _remoteDataSource.listCognitiveGames(page: 1, pageSize: 200);

  @override
  Future<CognitiveGameModel> pushCreate(CognitiveGameModel item) async =>
      (await _remoteDataSource.createCognitiveGame(game: item)).data;

  /// Create a new cognitive game result (offline-first).
  Result<WriteResult<CognitiveGameModel>> createCognitiveGame({
    required CognitiveGameModel game,
  }) {
    return writeCreate(
      game,
      (i) => _remoteDataSource.createCognitiveGame(game: i),
    );
  }

  /// List cognitive game results (offline-first).
  Result<List<CognitiveGameModel>> listCognitiveGames({
    int page = 1,
    int pageSize = 20,
  }) {
    return readList(
      () =>
          _remoteDataSource.listCognitiveGames(page: page, pageSize: pageSize),
    );
  }
}
