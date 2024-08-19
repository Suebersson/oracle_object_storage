import '../../../../interfaces/oracle_request_attributes.dart';
import '../../../../oracle_object_storage.dart';
import '../multipart_upload.dart';

/// https://docs.oracle.com/en-us/iaas/api/#/pt/objectstorage/20160918/MultipartUpload/UploadPart
final class UploadPart implements OracleRequestAttributes {
  const UploadPart._({
    required this.uri,
    required this.date,
    required this.authorization,
    required this.host,
    required this.xContentSha256,
    required this.contentLegth,
    required this.contentType,
    required this.addHeaders,
  });

  @override
  final String uri, date, authorization, host;

  final String xContentSha256, contentLegth, contentType;

  @override
  final Map<String, String>? addHeaders;

  @override
  Map<String, String> get headers {
    if (addHeaders is Map<String, String> &&
        (addHeaders?.isNotEmpty ?? false)) {
      addHeaders!
        ..update(
          'authorization',
          (_) => authorization,
          ifAbsent: () => authorization,
        )
        ..update(
          'date',
          (_) => date,
          ifAbsent: () => date,
        )
        ..update(
          'host',
          (_) => host,
          ifAbsent: () => host,
        )
        ..update(
          'x-content-sha256',
          (_) => xContentSha256,
          ifAbsent: () => xContentSha256,
        )
        ..update(
          'content-type',
          (_) => contentType,
          ifAbsent: () => contentType,
        )
        ..update(
          'content-Length',
          (_) => contentLegth,
          ifAbsent: () => contentLegth,
        );

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

  /// Construir dados de autorização para o serviço [UploadPart]
  factory UploadPart({
    required OracleObjectStorage storage,
    required String objectName,
    required String uploadId,
    required int uploadPartNum,
    required String xContentSha256,
    required String contentType,
    required String contentLength,
    String? namespaceName,
    String? bucketName,
    DateTime? date,
    Map<String, String>? addHeaders,
  }) {
    final String dateString = OracleObjectStorage.getDateRCF1123(date);

    /*
      # Modelo para string de assinatura para o método [put] ou [post]

      (request-target): <METHOD> /n/{namespaceName}/b/{bucketName}/u/{objectName}?uploadId=...&uploadPartNum=...\n
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

    final String request = '/n/$namespaceName/b/$bucketName/u/$objectName'
        '?uploadId=$uploadId&uploadPartNum=$uploadPartNum';

    final String signingString = '(request-target): put $request\n'
        'date: $dateString\n'
        'host: ${storage.host}\n'
        'x-content-sha256: $xContentSha256\n'
        'content-type: $contentType\n'
        'content-length: $contentLength';

    return UploadPart._(
      uri: '${storage.apiUrlOrigin}$request',
      date: dateString,
      host: storage.host,
      xContentSha256: xContentSha256,
      contentType: contentType,
      contentLegth: contentLength,
      addHeaders: addHeaders,
      authorization:
          'Signature headers="(request-target) date host x-content-sha256 content-type content-length",'
          'keyId="${storage.tenancy}/${storage.user}/${storage.apiPrivateKey.fingerprint}",'
          'algorithm="rsa-sha256",'
          'signature="${storage.apiPrivateKey.sing(signingString)}",'
          'version="1"',
    );
  }
}

/// Construir dados de autorização para o serviço [UploadPart]
extension UploadPartMethod on MultipartUpload {
  /// Construir dados de autorização para o serviço [UploadPart]
  ///
  /// [objectName] diretório + nome do arquivo
  ///
  /// Ex: users/profilePicture/userId.jpg
  ///
  /// ou
  ///
  /// Ex: userId.jpg
  UploadPart uploadPart({
    required String objectName,
    required String uploadId,
    required int uploadPartNum,
    required String xContentSha256,
    required String contentType,
    required String contentLength,
    String? namespaceName,
    String? bucketName,
    DateTime? date,
    Map<String, String>? addHeaders,
  }) {
    return UploadPart(
      storage: storage,
      objectName: objectName,
      uploadId: uploadId,
      uploadPartNum: uploadPartNum,
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
