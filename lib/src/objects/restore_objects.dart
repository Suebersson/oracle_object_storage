part of '../../oracle_object_storage.dart';

/*
  final RestoreObjects restoreObjects = objectStorage.restoreObjects(
    restoreObjectsSource: RestoreObjectsSource(
      objectName: 'image.jpg', 
      hours: 120
    )
  );

  final http.Response response = await http.post(
    Uri.parse(restoreObjects.uri),
    body: restoreObjects.jsonBytes,
    headers: restoreObjects.headers,
  );

  print(response.statusCode); // esperado 200 ou 202
*/

final class RestoreObjects implements ObjectAttributes {

  // https://docs.oracle.com/en-us/iaas/api/#/pt/objectstorage/20160918/Object/RestoreObjects
  const RestoreObjects._({
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

  factory RestoreObjects({
    required OracleObjectStorage objectStorage, 
    required RestoreObjectsSource restoreObjectsSource,
    DateTime? date,
    Map<String, String>? addHeaders,
  }) {

    final String dateString = OracleObjectStorage.getDateRCF1123(date);

    final String jsonData = restoreObjectsSource.toJson;

    final Uint8List jsonBytes = convert.utf8.encode(jsonData);

    final String xContentSha256 = jsonBytes.toSha256Base64;
    
    /*
      # Modelo para String de assinatura para o método [post]

      (request-target): <METHOD> <BUCKER_PATH>/actions/restoreObjects\n
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
      '(request-target): post ${objectStorage.buckerPath}/actions/restoreObjects\n'
      'date: $dateString\n'
      'host: ${objectStorage.buckerHost}\n'
      'x-content-sha256: $xContentSha256\n'
      'content-type: application/json\n'
      'content-length: ${jsonBytes.length}';
      
    return RestoreObjects._(
      uri: '${objectStorage.serviceURLOrigin}${objectStorage.buckerPath}/actions/restoreObjects', 
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

extension RestoreObjectsMethod on OracleObjectStorage {
  
  /// Construir dados de autorização para o serviço [RestoreObjects],
  RestoreObjects restoreObjects({
    required RestoreObjectsSource restoreObjectsSource,
    DateTime? date,
    Map<String, String>? addHeaders,
  }) {
    return RestoreObjects(
      objectStorage: this,
      restoreObjectsSource: restoreObjectsSource, 
      date: date,
      addHeaders: addHeaders,
    );
  }

}

final class RestoreObjectsSource {

  // https://docs.oracle.com/en-us/iaas/api/#/pt/objectstorage/20160918/datatypes/RestoreObjectsDetails
  const RestoreObjectsSource._(this.source);

  final Map<String, dynamic> source;

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
  factory RestoreObjectsSource({
    required String objectName, 
    required int hours, 
    String? versionId, 
  }) {

    if (hours < 1 || hours > 240) {
      throw const OracleObjectStorageExeception('Defina a duração em horas para restaurar o '
        'arquivo entre 1 e 240 horas.');
    }

    final Map<String, dynamic> query = {
      'objectName': objectName,
      'hours': hours,
    };
      
    if (versionId is String && versionId.isNotEmpty) {
      query.putIfAbsent('versionId', () => versionId);
    }

    return RestoreObjectsSource._(Map<String, dynamic>.unmodifiable(query));

  }

}