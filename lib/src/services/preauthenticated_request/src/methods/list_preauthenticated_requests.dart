import '../../../../interfaces/oracle_request_attributes.dart';
import '../../../../oracle_object_storage.dart';
import '../../../../oci_request_helpers/query.dart';
import '../preauthenticated_request.dart';

/// https://docs.oracle.com/en-us/iaas/api/#/en/objectstorage/20160918/PreauthenticatedRequest/ListPreauthenticatedRequests
final class ListPreauthenticatedRequests implements OracleRequestAttributes {
  const ListPreauthenticatedRequests._({
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

  /// Construir dados de autorização para o serviço [ListPreauthenticatedRequests]
  factory ListPreauthenticatedRequests({
    required OracleObjectStorage storage,
    String? namespaceName,
    String? bucketName,
    Query? query,
    DateTime? date,
    Map<String, String>? addHeaders,
  }) {
    final String dateString = OracleObjectStorage.getDateRCF1123(date);

    /*
      # Modelo para String de assinatura para o método

      (request-target): get /n/{namespaceName}/b/{bucketName}/p/\n
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
        ? '/n/$namespaceName/b/$bucketName/p/${query.toURLParams}'
        : '/n/$namespaceName/b/$bucketName/p/';

    final String signingString = '(request-target): get $request\n'
        'date: $dateString\n'
        'host: ${storage.host}';

    return ListPreauthenticatedRequests._(
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

/// Construir dados de autorização para o serviço [ListPreauthenticatedRequests]
extension ListPreauthenticatedRequestsMethod on PreauthenticatedRequest {
  /// Construir dados de autorização para o serviço [ListPreauthenticatedRequests]
  ListPreauthenticatedRequests listPreauthenticatedRequests({
    String? namespaceName,
    String? bucketName,
    Query? query,
    DateTime? date,
    Map<String, String>? addHeaders,
  }) {
    return ListPreauthenticatedRequests(
      storage: storage,
      namespaceName: namespaceName,
      bucketName: bucketName,
      query: query,
      date: date,
      addHeaders: addHeaders,
    );
  }
}
