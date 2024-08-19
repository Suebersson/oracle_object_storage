import '../../../../interfaces/oracle_request_attributes.dart';
import '../../../../oracle_object_storage.dart';
import '../../../../oracle_object_storage_exeception.dart';
import '../../../../oci_request_helpers/query.dart';
import '../object.dart';

/// Construir dados de autorização para o serviço [DeleteObject]
///
/// [pathAndFileName] diretório + nome do arquivo Ex: /users/profilePicture/userId.jpg
///
/// https://docs.oracle.com/en-us/iaas/api/#/pt/objectstorage/20160918/Object/DeleteObject
final class DeleteObject implements OracleRequestAttributes {
  const DeleteObject._({
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

  /// Construir dados de autorização para o serviço [DeleteObject]
  ///
  /// [pathAndFileName] Ex: /users/profilePicture/userId.jpg
  factory DeleteObject({
    required OracleObjectStorage storage,
    required String pathAndFileName,
    String? namespaceName,
    String? bucketName,
    Query? query,
    DateTime? date,
    Map<String, String>? addHeaders,
  }) {
    if (pathAndFileName.isEmpty) {
      return throw const OracleObjectStorageExeception(
        'Defina o caminho completo do arquivo',
      );
    }

    final String dateString = OracleObjectStorage.getDateRCF1123(date);

    /*
      # Modelo para string de assinatura para o método [delete]

      (request-target): <METHOD> /n/{namespaceName}/b/{bucketName}/o/{objectName}\n
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

    final String request = query is Query
        ? '/n/$namespaceName/b/$bucketName/o$pathAndFileName${query.toURLParams}'
        : '/n/$namespaceName/b/$bucketName/o$pathAndFileName';

    final String signingString = '(request-target): delete $request\n'
        'date: $dateString\n'
        'host: ${storage.host}';

    return DeleteObject._(
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

/// Construir dados de autorização para o serviço [DeleteObject]
///
/// [pathAndFileName] diretório + nome do arquivo Ex: /users/profilePicture/userId.jpg
extension DeleteObjectMethod on ObjectStorage {
  /// Construir dados de autorização para o serviço [DeleteObject]
  ///
  /// [pathAndFileName] diretório + nome do arquivo Ex: /users/profilePicture/userId.jpg
  DeleteObject deleteObject({
    required String pathAndFileName,
    String? namespaceName,
    String? bucketName,
    Query? query,
    DateTime? date,
    Map<String, String>? addHeaders,
  }) {
    return DeleteObject(
      storage: storage,
      namespaceName: namespaceName,
      bucketName: bucketName,
      query: query,
      date: date,
      pathAndFileName: pathAndFileName,
      addHeaders: addHeaders,
    );
  }
}
