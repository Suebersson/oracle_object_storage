part of '../../oracle_object_storage.dart';

/*
final CopyObject copy = objectStorage.copyObject(
    sourceObject: CopySourceObject(
      sourceObjectName: 'users/profilePictures/image.jpg', // arquivo a ser copiado
      destinationRegion: 'sa-saopaulo-1', // região do bucker para onde o arquivo será copiado
      destinationNamespace: '...', // nameSpace do bucker para onde o arquivo será copiado
      destinationBucket: 'BuckerName', // nome do bucker para onde o arquivo será copiado
      destinationObjectName: 'users/profilePictures/image.jpg', // para onde o arquivo será copiado
    ),
  );

  final http.Response response = await http.post(
    Uri.parse(copy.uri),
    body: copy.jsonBytes,
    headers: copy.header,
  );

  print('\npublicUrlOfCopiedFile: ${copy.publicUrlOfCopiedFile}\n');
  print(response.statusCode); // esperado 202
*/

final class CopyObject implements ObjectAttributes{
  
  // https://docs.oracle.com/en-us/iaas/api/#/pt/objectstorage/20160918/Object/CopyObject
  // https://docs.oracle.com/en-us/iaas/Content/Object/Tasks/copyingobjects.htm
  const CopyObject._({
    required this.uri, 
    required this.date, 
    required this.authorization, 
    required this.host, 
    required this.xContentSha256,
    required this.contentLegth,
    required this.contentType,
    required this.jsonBytes,
    required this.jsonData,
    required this.publicUrlOfCopiedFile,
    this.addHeaders,
  });

  @override
  final String uri, date, authorization, host;

  final String 
    publicUrlOfCopiedFile,
    jsonData,
    xContentSha256, 
    contentLegth, 
    contentType;

  final Uint8List jsonBytes;

  @override
  final Map<String, String>? addHeaders;
  
  @override
  Map<String, String> get header {
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

  /// Cria uma solicitação para copiar um arquivo dentro de uma 
  /// região ou para outra região [CopyObject]
  factory CopyObject({
    required OracleObjectStorage objectStorage, 
    required CopySourceObject sourceObject,
    DateTime? date,
    Map<String, String>? addHeaders,
  }) {

    final String dateString = OracleObjectStorage.getDateRCF1123(date);

    final String jsonData = sourceObject.toJson;

    final Uint8List jsonBytes = convert.utf8.encode(jsonData);

    final String xContentSha256 = jsonBytes.toSha256Base64;
    
    /*
      # Modelo para String de assinatura para o método [post]

      (request-target): <METHOD> <BUCKER_PATH>/actions/copyObject\n
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
      '(request-target): post ${objectStorage.buckerPath}/actions/copyObject\n'
      'date: $dateString\n'
      'host: ${objectStorage.buckerHost}\n'
      'x-content-sha256: $xContentSha256\n'
      'content-type: application/json\n'
      'content-length: ${jsonBytes.length}';
      
    return CopyObject._(
      uri: '${objectStorage.serviceURLOrigin}${objectStorage.buckerPath}/actions/copyObject', 
      date: dateString, 
      host: objectStorage.buckerHost,
      addHeaders: addHeaders,
      xContentSha256: xContentSha256,
      contentType: 'application/json',
      contentLegth: '${jsonBytes.length}',
      jsonBytes: jsonBytes,
      jsonData: jsonData,
      publicUrlOfCopiedFile: 
        'https://objectstorage.${sourceObject.source['destinationRegion']}.oraclecloud.com'
        '/n/${sourceObject.source['destinationNamespace']}'
        '/b/${sourceObject.source['destinationBucket']}'
        '/o/${sourceObject.source['destinationObjectName']}',
      authorization: 'Signature headers="(request-target) date host x-content-sha256 content-type content-length",'
        'keyId="${objectStorage.tenancyOcid}/${objectStorage.userOcid}/${objectStorage.apiPrivateKey.fingerprint}",'
        'algorithm="rsa-sha256",'
        'signature="${objectStorage.apiPrivateKey.sing(signingString)}",'
        'version="1"',
    );

  }

}

extension CopyObjectMethod on OracleObjectStorage {

  /// Cria uma solicitação para copiar um arquivo dentro de uma 
  /// região ou para outra região [CopyObject]
  CopyObject copyObject({
    required CopySourceObject sourceObject,
    DateTime? date,
    Map<String, String>? addHeaders,
  }) {
    return CopyObject(
      objectStorage: this,
      sourceObject: sourceObject, 
      date: date,
      addHeaders: addHeaders,
    );
  }

}

final class CopySourceObject {

  // https://docs.oracle.com/en-us/iaas/api/#/pt/objectstorage/20160918/datatypes/CopyObjectDetails
  const CopySourceObject._(this.source);

  final Map<String, String> source;

  String get toJson => source.toJson;

  factory CopySourceObject({
    required String sourceObjectName, 
    required String destinationRegion, 
    required String destinationNamespace,
    required String destinationBucket,
    required String destinationObjectName,
    String? destinationObjectMetadata,
    String? sourceObjectIfMatchETag,
    String? destinationObjectIfMatchETag,
    String? destinationObjectIfNoneMatchETag,
    String? destinationObjectStorageTier,
    String? sourceVersionId,
  }) {

    final Map<String, String> query = {
      'sourceObjectName': sourceObjectName,
      'destinationRegion': destinationRegion,
      'destinationNamespace': destinationNamespace,
      'destinationBucket': destinationBucket,
      'destinationObjectName': destinationObjectName,
    };
      
    if (destinationObjectMetadata is String && destinationObjectMetadata.isNotEmpty) {
      query.putIfAbsent('destinationObjectMetadata', () => destinationObjectMetadata);
    }
    if (sourceObjectIfMatchETag is String && sourceObjectIfMatchETag.isNotEmpty) {
      query.putIfAbsent('sourceObjectIfMatchETag', () => sourceObjectIfMatchETag);
    }
    if (destinationObjectIfMatchETag is String && destinationObjectIfMatchETag.isNotEmpty) {
      query.putIfAbsent('destinationObjectIfMatchETag', () => destinationObjectIfMatchETag);
    }
    if (destinationObjectIfNoneMatchETag is String && destinationObjectIfNoneMatchETag.isNotEmpty) {
      query.putIfAbsent('destinationObjectIfNoneMatchETag', () => destinationObjectIfNoneMatchETag);
    }
    if (destinationObjectStorageTier is String && destinationObjectStorageTier.isNotEmpty) {
      query.putIfAbsent('destinationObjectStorageTier', () => destinationObjectStorageTier);
    }
    if (sourceVersionId is String && sourceVersionId.isNotEmpty) {
      query.putIfAbsent('sourceVersionId', () => sourceVersionId);
    }

    return CopySourceObject._(Map<String, String>.unmodifiable(query));

  }

}
