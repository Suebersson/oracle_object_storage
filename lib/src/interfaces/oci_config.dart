import '../private_key.dart';

/// Interface de atributos para parâmetros de configurações OCI
abstract interface class OCIConfig {
  String get tenancy;
  String get user;
  String get region;
  ApiPrivateKey get apiPrivateKey;
}
