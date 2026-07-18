/// Contract implemented by every feature repository that participates in
/// offline-first sync.
///
/// Follows the Interface Segregation Principle: the [SyncManager] depends only
/// on these three members, never on a concrete repository. Adding a new
/// offline feature means implementing this contract and registering the
/// repository — no edits to the manager (Open/Closed Principle).
abstract class SyncableRepository {
  /// Stable key used for progress reporting and logging (e.g. `emotion`).
  String get featureKey;

  /// Fetch the authoritative list from the server and replace the local
  /// mirror (server is the source of truth). Pending local rows are preserved.
  Future<void> pullFromServer();

  /// Replay locally-queued (pending) writes to the server, then let the
  /// caller reconcile via [pullFromServer].
  Future<void> pushPending();
}
