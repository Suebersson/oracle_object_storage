import '../../../../interfaces/oracle_request_attributes.dart';
import '../../../../oracle_object_storage.dart';
import '../../../../oracle_object_storage_exeception.dart';
import '../object.dart';

/// https://docs.oracle.com/en-us/iaas/api/#/pt/objectstorage/20160918/
/// 
/// https://docs.oracle.com/en-us/iaas/api/#/pt/objectstorage/20160918/Object/PutObject
/// 
/// https://docs.oracle.com/pt-br/iaas/Content/API/Concepts/signingrequests.htm#ObjectStoragePut
final class PutObject implements OracleRequestAttributes {
  
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
    required OracleObjectStorage storage, 
    required String pathAndFileName, 
    required String xContentSha256,
    required String contentType, 
    required String contentLength,
    String? namespaceName,
    String? bucketName,
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

      (request-target): <METHOD> /n/{namespaceName}/b/{bucketName}/o/{objectName}\n
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

    namespaceName ??= storage.nameSpace;
    bucketName ??= storage.bucketName;

    final String request = '/n/$namespaceName/b/$bucketName/o$pathAndFileName';

    final String signingString = 
      '(request-target): put $request\n'
      'date: $dateString\n'
      'host: ${storage.host}\n'
      'x-content-sha256: $xContentSha256\n'
      'content-type: $contentType\n'
      'content-length: $contentLength';

    return PutObject._(
      publicUrlFile: storage.getPublicUrlFile(pathAndFileName),
      uri: '${storage.apiUrlOrigin}$request',
      date: dateString, 
      host: storage.host,
      xContentSha256: xContentSha256,
      contentType: contentType,
      contentLegth: contentLength,
      addHeaders: addHeaders,
      authorization: 'Signature headers="(request-target) date host x-content-sha256 content-type content-length",'
        'keyId="${storage.tenancy}/${storage.user}/${storage.apiPrivateKey.fingerprint}",'
        'algorithm="rsa-sha256",'
        'signature="${storage.apiPrivateKey.sing(signingString)}",'
        'version="1"',
    );

  }

}

/// Construir dados de autorização para o serviço [PutObject]
extension PutObjectMethod on ObjectStorage {

  
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
  /// 
  /// https://docs.oracle.com/en-us/iaas/Content/Object/Tasks/managingobjects.htm#nameprefix
  PutObject putObject({
    required String pathAndFileName,
    required String xContentSha256,
    required String contentType, 
    required String contentLength,
    String? namespaceName,
    String? bucketName, 
    DateTime? date,
    Map<String, String>? addHeaders,
  }) {
    return PutObject(
      storage: storage, 
      pathAndFileName: pathAndFileName,
      xContentSha256: xContentSha256,
      contentType: contentType,
      contentLength: contentLength,
      namespaceName: namespaceName,
      bucketName: bucketName, 
      date: date,
      addHeaders: addHeaders,
    );
  }

}