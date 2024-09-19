import '../../../../interfaces/oracle_request_attributes.dart';
import '../../../../oracle_object_storage.dart';
import '../../../../oracle_object_storage_exeception.dart';
import '../multipart_upload.dart';

/// Construir dados de autorização para o serviço [AbortMultipartUpload]
///
/// https://docs.oracle.com/en-us/iaas/api/#/pt/objectstorage/20160918/MultipartUpload/AbortMultipartUpload
final class AbortMultipartUpload implements OracleRequestAttributes {
  const AbortMultipartUpload._({
    required this.uri,
    required this.date,
    required this.authorization,
    required this.host,
    this.addHeaders,
  });

  @override
  final String uri, date, authorization, host;

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
        );

      return addHeaders!;
    } else {
      return {
        'authorization': authorization,
        'date': date,
        'host': host,
      };
    }
  }

  /// Construir dados de autorização para o serviço [AbortMultipartUpload]
  ///
  /// [objectName] Ex: users/profilePicture/userId.jpg
  factory AbortMultipartUpload({
    required OracleObjectStorage storage,
    required String objectName,
    required String uploadId,
    String? namespaceName,
    String? bucketName,
    DateTime? date,
    Map<String, String>? addHeaders,
  }) {
    if (objectName.isEmpty) {
      throw const OracleObjectStorageExeception(
        'Defina o caminho completo do arquivo',
      );
    }

    final String dateString = OracleObjectStorage.getDateRCF1123(date);

    /*
      # Modelo para string de assinatura para o método [delete]

      (request-target): <METHOD> /n/{namespaceName}/b/{bucketName}/u/{objectName}\n
      date: <DATE_UTC_FORMAT_RCF1123>\n
      host: <HOST>

      # Modelo de autorização/authorization para adicionar nas requisições Rest API
      
      Signature headers="date (request-target) date host",
      keyId="<TENANCY_OCID>/<USER_OCID>/<API_KEY_FINGERPRINT>",
      algorithm="rsa-sha256",
      signature="<SIGNATURE>",
      version="1"
    */

    namespaceName ??= storage.nameSpace;
    bucketName ??= storage.bucketName;

    final String request =
        '/n/$namespaceName/b/$bucketName/u/$objectName?uploadId=$uploadId';

    final String signingString = '(request-target): delete $request\n'
        'date: $dateString\n'
        'host: ${storage.host}';

    return AbortMultipartUpload._(
      uri: '${storage.apiUrlOrigin}$request',
      date: dateString,
      host: storage.host,
      addHeaders: addHeaders,
      authorization: 'Signature headers="(request-target) date host",'
          'keyId="${storage.tenancy}/${storage.user}/${storage.apiPrivateKey.fingerprint}",'
          'algorithm="rsa-sha256",'
          'signature="${storage.apiPrivateKey.sing(signingString)}",'
          'version="1"',
    );
  }
}

/// Construir dados de autorização para o serviço [AbortMultipartUpload]
extension AbortMultipartUploadMethod on MultipartUpload {
  /// Construir dados de autorização para o serviço [AbortMultipartUpload]
  ///
  /// [objectName] diretório + nome do arquivo
  ///
  /// Ex: users/profilePicture/userId.jpg
  ///
  /// ou
  ///
  /// Ex: userId.jpg
  AbortMultipartUpload abortMultipartUpload({
    required String objectName,
    required String uploadId,
    String? namespaceName,
    String? bucketName,
    DateTime? date,
    Map<String, String>? addHeaders,
  }) {
    return AbortMultipartUpload(
      storage: storage,
      objectName: objectName,
      uploadId: uploadId,
      namespaceName: namespaceName,
      bucketName: bucketName,
      date: date,
      addHeaders: addHeaders,
    );
  }
}
