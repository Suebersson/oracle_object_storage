// ignore_for_file: constant_identifier_names

part of '../../oracle_object_storage.dart';

/*
  final UpdateObjectStorageTier updateObjectStorageTier = objectStorage.updateObjectStorageTier(
    objectStorageTier: ObjectStorageTier(
      objectName: 'image.jpg', 
      storageTier: StorageTier.InfrequentAccess
    ),
  );

  final http.Response response = await http.post(
    Uri.parse(updateObjectStorageTier.uri),
    body: updateObjectStorageTier.jsonBytes,
    headers: updateObjectStorageTier.headers,
  );

  print(response.statusCode); // esperado 200
*/

final class UpdateObjectStorageTier implements ObjectAttributes {

  // https://docs.oracle.com/en-us/iaas/api/#/pt/objectstorage/20160918/Object/UpdateObjectStorageTier
  const UpdateObjectStorageTier._({
    required this.uri, 
    required this.date, 
    required this.authorization, 
    required this.host, 
    required this.xContentSha256,
    required this.contentLegth,
    required this.contentType,
    required this.jsonBytes,
    required this.jsonData,
    this.addHeaders,
  });

  @override
  final String uri, date, authorization, host;

  final String 
    jsonData,
    xContentSha256, 
    contentLegth, 
    contentType;

  final Uint8List jsonBytes;

  @override
  final Map<String, String>? addHeaders;
  
  @override
  Map<String, String> get headers {
    if (addHeaders is Map<String, String> && (addHeaders?.isNotEmpty ?? false)) {

      addHeaders!
      ..update('authorization', (_) => authorization, ifAbsent: () => authorization,)
      ..update('date', (_) => date, ifAbsent: () => date,)
      ..update('host', (_) => host, ifAbsent: () => host,)
      ..update('x-content-sha256', (_) => xContentSha256, ifAbsent: () => xContentSha256,)
      ..update('content-type', (_) => 'application/json', ifAbsent: () => 'application/json',)
      ..update('content-Length', (_) => contentLegth, ifAbsent: () => contentLegth,);

      return addHeaders!;    

    } else {
      return {
        'authorization': authorization,
        'date': date,
        'host': host,
        'x-content-sha256': xContentSha256,
        'content-type': 'application/json',
        'content-Length': contentLegth,
      };
    }
  }

  factory UpdateObjectStorageTier({
    required OracleObjectStorage objectStorage, 
    required ObjectStorageTier objectStorageTier,
    DateTime? date,
    Map<String, String>? addHeaders,
  }) {

    final String dateString = OracleObjectStorage.getDateRCF1123(date);

    final String jsonData = objectStorageTier.toJson;

    final Uint8List jsonBytes = convert.utf8.encode(jsonData);

    final String xContentSha256 = jsonBytes.toSha256Base64;
    
    /*
      # Modelo para String de assinatura para o método [post]

      (request-target): <METHOD> <BUCKER_PATH>/actions/updateObjectStorageTier\n
      date: <DATE_UTC_FORMAT_RCF1123>\n
      host: <HOST>\n
      x-content-sha256: <FILE_HASH_IN_BASE64>\n'
      content-type: <CONTENT-TYPE>\n
      content-length: <FILE_BYTES>

      # Modelo de autorização/authorization para adicionar nas requisições Rest API
      
      Signature headers="date (request-target) date host x-content-sha256 content-type content-length",
      keyId="<TENANCY_OCID>/<USER_OCID>/<API_KEY_FINGERPRINT>",
      algorithm="rsa-sha256",
      signature="<SIGNATURE>",
      version="1"
    */

    final String signingString = 
      '(request-target): post ${objectStorage.buckerPath}/actions/updateObjectStorageTier\n'
      'date: $dateString\n'
      'host: ${objectStorage.buckerHost}\n'
      'x-content-sha256: $xContentSha256\n'
      'content-type: application/json\n'
      'content-length: ${jsonBytes.length}';
      
    return UpdateObjectStorageTier._(
      uri: '${objectStorage.serviceURLOrigin}${objectStorage.buckerPath}/actions/updateObjectStorageTier', 
      date: dateString, 
      host: objectStorage.buckerHost,
      addHeaders: addHeaders,
      xContentSha256: xContentSha256,
      contentType: 'application/json',
      contentLegth: '${jsonBytes.length}',
      jsonBytes: jsonBytes,
      jsonData: jsonData,
      authorization: 'Signature headers="(request-target) date host x-content-sha256 content-type content-length",'
        'keyId="${objectStorage.tenancyOcid}/${objectStorage.userOcid}/${objectStorage.apiPrivateKey.fingerprint}",'
        'algorithm="rsa-sha256",'
        'signature="${objectStorage.apiPrivateKey.sing(signingString)}",'
        'version="1"',
    );

  }

}

extension UpdateObjectStorageTierMethod on OracleObjectStorage {
  
  /// Construir dados de autorização para o serviço [UpdateObjectStorageTier],
  /// 
  /// Altera a camada de armazenamento do arquivo especificado
  UpdateObjectStorageTier updateObjectStorageTier({
    required ObjectStorageTier objectStorageTier,
    DateTime? date,
    Map<String, String>? addHeaders,
  }) {
    return UpdateObjectStorageTier(
      objectStorage: this,
      objectStorageTier: objectStorageTier, 
      date: date,
      addHeaders: addHeaders,
    );
  }

}


final class ObjectStorageTier {

  // https://docs.oracle.com/en-us/iaas/api/#/pt/objectstorage/20160918/datatypes/UpdateObjectStorageTierDetails
  const ObjectStorageTier._(this.source);

  final Map<String, String> source;

  String get toJson => source.toJson;

  @override
  String toString() => '$runtimeType($source)'.replaceAll(RegExp('{|}'), '');

  /// Para arquivos na raíz/root do bucker, basta apenas informar o nome do arquivo
  /// 
  /// ex: fileName.jpg
  /// 
  /// Para arquivos dentro de diretórios, informar a path do diretório + o nome do arquivo
  /// 
  /// ex: users/profilePictures/fileName.jpg
  ///
  /// [objectName] o nome de arquivo existente
  factory ObjectStorageTier({
    required String objectName, 
    required StorageTier storageTier, 
    String? versionId, 
  }) {

    final Map<String, String> query = {
      'objectName': objectName,
      'storageTier': storageTier.name,
    };
      
    if (versionId is String && versionId.isNotEmpty) {
      query.putIfAbsent('versionId', () => versionId);
    }

    return ObjectStorageTier._(Map<String, String>.unmodifiable(query));

  }

}

enum StorageTier {
  Standard,
  InfrequentAccess,
  Archive;
}