import '../oracle_object_storage.dart';

/// Interface de atributos para o objeto [OracleObjectStorage]
abstract interface class OracleRequestAttributes {
  String get uri;
  String get date;
  String get authorization;
  String get host;
  Map<String, String> get headers;
  Map<String, String>? get addHeaders;
}