class WriteResult<T> {
  final T data;

  final String message;

  final bool fromServer;

  const WriteResult(this.data, this.message, {this.fromServer = true});
}
