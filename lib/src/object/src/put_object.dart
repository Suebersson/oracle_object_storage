import '../../interfaces/oracle_request_attributes.dart';
import '../../oracle_object_storage.dart';
import '../../oracle_object_storage_exeception.dart';

final class PutObject implements OracleRequestAttributes {
  
  // https://docs.oracle.com/en-us/iaas/api/#/pt/objectstorage/20160918/
  // https://docs.oracle.com/en-us/iaas/api/#/pt/objectstorage/20160918/Object/PutObject
  // https://docs.oracle.com/pt-br/iaas/Content/API/Concepts/signingrequests.htm#ObjectStoragePut
  const PutObject._({
    required this.uri, 
    required this.date, 
    required this.authorization, 
    required this.host,
    required this.xContentSha256,
    required this.contentLegth,
    required this.contentType,
    required this.publicUrlFile,
    this.addHeaders,
  });

  @override
  final String uri, date, authorization, host;

  final String xContentSha256, contentLegth, contentType, publicUrlFile;

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
      ..update('content-type', (_) => contentType, ifAbsent: () => contentType,)
      ..update('content-Length', (_) => contentLegth, ifAbsent: () => contentLegth,);

      return addHeaders!;    

    } else {
      return {
        'authorization': authorization,
        'date': date,
        'host': host,
        'x-content-sha256': xContentSha256,
        'content-type': contentType,
        'content-Length': contentLegth,
      };
    }
  }

  /// Construir dados de autorização para o serviço [PutObject]
  /// 
  /// [date] na zona UTC
  /// 
  /// [contentLength] tamanho do arquivo em bytes
  /// 
  /// [contentType] tipo de arquivo
  /// 
  /// [pathAndFileName] diretório + nome do arquivo 
  /// 
  /// Ex: /users/profilePicture/userId.jpg
  /// 
  /// ou
  /// 
  /// Ex: userId.jpg
  factory PutObject({
    required OracleObjectStorage objectStorage, 
    required String pathAndFileName, 
    required String xContentSha256,
    required String contentType, 
    required String contentLength, 
    DateTime? date,
    Map<String, String>? addHeaders,
  }) {

    if (pathAndFileName.isEmpty) {
      return throw const OracleObjectStorageExeception('Defina o caminho completo para criar o arquivo');
    }

    final String dateString = OracleObjectStorage.getDateRCF1123(date);

    /*

      // https://docs.oracle.com/pt-br/iaas/Content/API/Concepts/signingrequests.htm#ObjectStoragePut
      // https://docs.oracle.com/en/learn/manage-oci-restapi/index.html#task-1-set-up-oracle-cloud-infrastructure-api-keys
      
      # Modelo para string de assinatura para o método [put] ou [post]

      (request-target): <METHOD> <BUCKER_PATH><DIRECTORY_PATH><FILE_NAME>\n
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

    final String request = '${objectStorage.buckerPath}/o$pathAndFileName';

    final String signingString = 
      '(request-target): put $request\n'
      'date: $dateString\n'
      'host: ${objectStorage.buckerHost}\n'
      'x-content-sha256: $xContentSha256\n'
      'content-type: $contentType\n'
      'content-length: $contentLength';

    return PutObject._(
      publicUrlFile: objectStorage.getPublicUrlFile(pathAndFileName),
      uri: '${objectStorage.serviceURLOrigin}$request',
      date: dateString, 
      host: objectStorage.buckerHost,
      xContentSha256: xContentSha256,
      contentType: contentType,
      contentLegth: contentLength,
      addHeaders: addHeaders,
      authorization: 'Signature headers="(request-target) date host x-content-sha256 content-type content-length",'
        'keyId="${objectStorage.tenancyOcid}/${objectStorage.userOcid}/${objectStorage.apiPrivateKey.fingerprint}",'
        'algorithm="rsa-sha256",'
        'signature="${objectStorage.apiPrivateKey.sing(signingString)}",'
        'version="1"',
    );

  }

}

extension PutObjectMethod on OracleObjectStorage {

  // https://docs.oracle.com/en-us/iaas/Content/Object/Tasks/managingobjects.htm#nameprefix
  
  /// Construir dados de autorização para o serviço [PutObject]
  /// 
  /// [date] na zona UTC
  /// 
  /// [contentLength] tamanho do arquivo em bytes
  /// 
  /// [contentType] tipo de arquivo
  /// 
  /// [pathAndFileName] diretório + nome do arquivo 
  /// 
  /// Ex: /users/profilePicture/userId.jpg
  /// 
  /// ou
  /// 
  /// Ex: userId.jpg
  PutObject putObject({
    required String pathAndFileName,
    required String xContentSha256,
    required String contentType, 
    required String contentLength, 
    DateTime? date,
    Map<String, String>? addHeaders,
  }) {
    return PutObject(
      objectStorage: this, 
      pathAndFileName: pathAndFileName,
      xContentSha256: xContentSha256,
      contentType: contentType,
      contentLength: contentLength, 
      date: date,
      addHeaders: addHeaders,
    );
  }

}