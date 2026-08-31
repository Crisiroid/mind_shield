abstract class SyncableRepository {
  String get featureKey;

  Future<void> pullFromServer();

  Future<void> pushPending();
}
