import '../../../../interfaces/oracle_request_attributes.dart';
import '../../../../oracle_object_storage.dart';
import '../../../../oracle_object_storage_exeception.dart';
import '../../../../oci_request_helpers/query.dart';
import '../multipart_upload.dart';

/// https://docs.oracle.com/en-us/iaas/api/#/pt/objectstorage/20160918/Object/ListMultipartUploadParts
final class ListMultipartUploadParts implements OracleRequestAttributes {
  const ListMultipartUploadParts._({
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

  /// Construir dados de autorização para o serviço [ListMultipartUploadParts]
  ///
  /// [objectName] Ex: users/profilePicture/userId.jpg
  factory ListMultipartUploadParts({
    required OracleObjectStorage storage,
    required String objectName,
    required Query query,
    String? namespaceName,
    String? bucketName,
    DateTime? date,
    Map<String, String>? addHeaders,
  }) {
    if (objectName.isEmpty) {
      return throw const OracleObjectStorageExeception(
        'Defina o nome do arquivo',
      );
    }
    if (!query.querys.containsKey('uploadId')) {
      return throw const OracleObjectStorageExeception(
        'O parâmetros [uploadId] é obrigatório dentro da query',
      );
    }

    final String dateString = OracleObjectStorage.getDateRCF1123(date);

    /*
      # Modelo para String de assinatura para o método [get]

      (request-target): <METHOD> /n/{namespaceName}/b/{bucketName}/u/{objectName}?uploadId=...\n
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
        '/n/$namespaceName/b/$bucketName/u/$objectName${query.toURLParams}';

    final String signingString = '(request-target): get $request\n'
        'date: $dateString\n'
        'host: ${storage.host}';

    return ListMultipartUploadParts._(
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

/// Construir dados de autorização para o serviço [ListMultipartUploadParts]
extension ListMultipartUploadPartsMethod on MultipartUpload {
  /// Construir dados de autorização para o serviço [ListMultipartUploadParts]
  ///
  /// [objectName] diretório + nome do arquivo
  ///
  /// Ex: users/profilePicture/userId.jpg
  ///
  /// ou
  ///
  /// Ex: userId.jpg
  ListMultipartUploadParts listMultipartUploadParts({
    required String objectName,
    required Query query,
    String? namespaceName,
    String? bucketName,
    DateTime? date,
    Map<String, String>? addHeaders,
  }) {
    return ListMultipartUploadParts(
      storage: storage,
      objectName: objectName,
      query: query,
      date: date,
      addHeaders: addHeaders,
    );
  }
}
