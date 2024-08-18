import '../private_key.dart';

abstract interface class OCIConfig {
  String get tenancy;
  String get user;
  String get region;
  String get serviceApiUrlOrigin;
  ApiPrivateKey get apiPrivateKey;
}