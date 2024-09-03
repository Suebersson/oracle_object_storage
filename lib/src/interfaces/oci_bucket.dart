/// Interface de atributos para parâmetros de um bucket
abstract interface class OCIBucket {
  String get bucketName;
  String get bucketPath;
  String get bucketPublicURL;
}