part of '../../oracle_object_storage.dart';

/*
  final RenameObject rename = objectStorage.renameObject(
    sourceObject: RenameSourceObject(
      sourceName: 'users/profilePictures/userId.jpg', 
      newName: 'users/profilePictures/xuxa.jpg',
    ),
  );

  final http.Response response = await http.post(
    Uri.parse(rename.uri),
    body: rename.jsonBytes,
    headers: rename.header,
  );

  print('\noldPublicUrlFile: ${rename.oldPublicUrlFile}\n\n');
  print('newPublicUrlFile: ${rename.newPublicUrlFile}');
  print(response.statusCode); // esperado 200
*/

final class RenameObject implements ObjectAttributes {

  // https://docs.oracle.com/en-us/iaas/api/#/pt/objectstorage/20160918/Object/RenameObject
  const RenameObject._({
    required this.uri, 
    required this.date, 
    required this.authorization, 
    required this.host, 
    required this.xContentSha256,
    required this.contentLegth,
    required this.contentType,
    required this.jsonBytes,
    required this.newPublicUrlFile,
    required this.oldPublicUrlFile,
    required this.jsonData,
    this.addHeaders,
  });

  @override
  final String uri, date, authorization, host;

  final String 
    newPublicUrlFile, 
    oldPublicUrlFile, 
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

  factory RenameObject({
    required OracleObjectStorage objectStorage, 
    required RenameSourceObject sourceObject,
    DateTime? date,
    Map<String, String>? addHeaders,
  }) {

    final String dateString = OracleObjectStorage.getDateRCF1123(date);

    final String jsonData = sourceObject.toJson;

    final Uint8List jsonBytes = convert.utf8.encode(jsonData);

    final String xContentSha256 = jsonBytes.toSha256Base64;
    
    /*
      # Modelo para String de assinatura para o método [post]

      (request-target): <METHOD> <BUCKER_PATH>/actions/renameObject\n
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
      '(request-target): post ${objectStorage.buckerPath}/actions/renameObject\n'
      'date: $dateString\n'
      'host: ${objectStorage.buckerHost}\n'
      'x-content-sha256: $xContentSha256\n'
      'content-type: application/json\n'
      'content-length: ${jsonBytes.length}';
      
    return RenameObject._(
      uri: '${objectStorage.serviceURLOrigin}${objectStorage.buckerPath}/actions/renameObject', 
      date: dateString, 
      host: objectStorage.buckerHost,
      addHeaders: addHeaders,
      xContentSha256: xContentSha256,
      contentType: 'application/json',
      contentLegth: '${jsonBytes.length}',
      jsonBytes: jsonBytes,
      jsonData: jsonData,
      newPublicUrlFile: '${objectStorage.serviceURLOrigin}${objectStorage.buckerPath}/o/${sourceObject.source['newName']}',
      oldPublicUrlFile: '${objectStorage.serviceURLOrigin}${objectStorage.buckerPath}/o/${sourceObject.source['sourceName']}',
      authorization: 'Signature headers="(request-target) date host x-content-sha256 content-type content-length",'
        'keyId="${objectStorage.tenancyOcid}/${objectStorage.userOcid}/${objectStorage.apiPrivateKey.fingerprint}",'
        'algorithm="rsa-sha256",'
        'signature="${objectStorage.apiPrivateKey.sing(signingString)}",'
        'version="1"',
    );

  }
  
}

extension RenameObjectMethod on OracleObjectStorage {
  
  /// Construir dados de autorização para o serviço [RenameObject],
  RenameObject renameObject({
    required RenameSourceObject sourceObject,
    DateTime? date,
    Map<String, String>? addHeaders,
  }) {
    return RenameObject(
      objectStorage: this,
      sourceObject: sourceObject, 
      date: date,
      addHeaders: addHeaders,
    );
  }

}

final class RenameSourceObject {
  
  // https://docs.oracle.com/en-us/iaas/api/#/pt/objectstorage/20160918/datatypes/RenameObjectDetails
  const RenameSourceObject._(this.source);

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
  /// sourceName: users/profilePictures/fileName.jpg
  /// 
  /// newName: users/profilePictures/newfileName.jpg
  ///
  /// [sourceName] o nome de arquivo existente
  /// 
  /// [newName] novo nome para renomear o arquivo
  factory RenameSourceObject({
    required String sourceName, 
    required String newName, 
    String? srcObjIfMatchETag, 
    String? newObjIfMatchETag, 
    String? newObjIfNoneMatchETag,
  }) {

    final Map<String, String> query = {
      'sourceName': sourceName,
      'newName': newName,
    };
      
    if (srcObjIfMatchETag is String && srcObjIfMatchETag.isNotEmpty) {
      query.putIfAbsent('srcObjIfMatchETag', () => srcObjIfMatchETag);
    }
    if (newObjIfMatchETag is String && newObjIfMatchETag.isNotEmpty) {
      query.putIfAbsent('newObjIfMatchETag', () => newObjIfMatchETag);
    }
    if (newObjIfNoneMatchETag is String && newObjIfNoneMatchETag.isNotEmpty) {
      query.putIfAbsent('newObjIfNoneMatchETag', () => newObjIfNoneMatchETag);
    }

    return RenameSourceObject._(Map<String, String>.unmodifiable(query));

  }

}
