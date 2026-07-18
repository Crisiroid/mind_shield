import 'dart:math';

/// Generates client-side unique identifiers for offline-created records.
///
/// Records created while offline need a stable local id before the server
/// assigns one. This produces RFC-4122 version-4 style UUID strings so local
/// ids never collide with server-generated ids.
///
/// Follows the Single Responsibility Principle — only concerned with id
/// generation, nothing else.
class UuidGenerator {
  UuidGenerator._();

  static final Random _random = Random.secure();

  /// Generate a random version-4 UUID string (e.g. `f47ac10b-58cc-4372-...`).
  static String generate() {
    final bytes = List<int>.generate(16, (_) => _random.nextInt(256));

    // Set version (4) and variant (10xx) bits per RFC 4122.
    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    bytes[8] = (bytes[8] & 0x3f) | 0x80;

    final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).toList();

    return '${hex[0]}${hex[1]}${hex[2]}${hex[3]}-'
        '${hex[4]}${hex[5]}-'
        '${hex[6]}${hex[7]}-'
        '${hex[8]}${hex[9]}-'
        '${hex[10]}${hex[11]}${hex[12]}${hex[13]}${hex[14]}${hex[15]}';
  }

  /// Whether [id] looks like a locally-generated id that has not yet been
  /// confirmed by the server. Local ids are plain UUIDs; this is a best-effort
  /// helper for callers that need to distinguish optimistic rows.
  static bool isLocal(String id) => id.contains('-') && id.length == 36;
}
