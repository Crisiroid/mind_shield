/// Outcome of an offline-first write (create/update).
///
/// Carries the confirmed model together with the message that accompanied it
/// so the presentation layer can surface the server's own response. When a
/// write is persisted optimistically while offline, [fromServer] is `false`
/// and [message] holds a local fallback string.
class WriteResult<T> {
  /// The confirmed model — the server copy on success, or the optimistic
  /// local copy when the write was kept pending offline.
  final T data;

  /// The message to display to the user (the server's `message` field, or a
  /// local fallback when [fromServer] is `false`).
  final String message;

  /// Whether [data]/[message] originated from a server response (`true`) or
  /// from an optimistic offline write (`false`).
  final bool fromServer;

  const WriteResult(this.data, this.message, {this.fromServer = true});
}
