import 'dart:typed_data' show Uint8List;

/// Interface de atributos para criar dados json para uma requisição
abstract interface class Details<T> {
  T get details;
  String get json;
  String get contentType;
  Uint8List get bytes;
  int get bytesLength;
  String get xContentSha256;
}