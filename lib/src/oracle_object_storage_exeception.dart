/// Exeception geral do package
final class OracleObjectStorageExeception implements Exception {
  final String message;
  const OracleObjectStorageExeception(this.message);
  @override
  String toString() => message;
}
