import '../../interfaces/oracle_request_attributes.dart';
import '../../oracle_object_storage.dart';
import '../../query.dart';

/*
  final ListPreauthenticatedRequests list = objectStorage.listPreauthenticatedRequests(
    query: Query({// parâmentro  opcional
      'limit': '1', // no máximo 10 objetos
      'objectNamePrefix': 'events/banners/', // todos os objetos de uma pasta
    }),
  );

  final http.Response response = await http.get(
    Uri.parse(list.uri),
    headers: list.headers,
  );

  print(response.statusCode); // esperado 200
  print(response.body);// esperado application-json
*/

final class ListPreauthenticatedRequests implements OracleRequestAttributes {
  
  // https://docs.oracle.com/en-us/iaas/api/#/en/objectstorage/20160918/PreauthenticatedRequest/ListPreauthenticatedRequests
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
    if (addHeaders is Map<String, String> && (addHeaders?.isNotEmpty ?? false)) {

      addHeaders!
      ..update('authorization', (_) => authorization, ifAbsent: () => authorization,)
      ..update('date', (_) => date, ifAbsent: () => date,)
      ..update('host', (_) => host, ifAbsent: () => host,);

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
    required OracleObjectStorage objectStorage, 
    Query? query,
    DateTime? date,
    Map<String, String>? addHeaders,
  }) {

    final String dateString = OracleObjectStorage.getDateRCF1123(date);

    /*
      
      # Modelo para String de assinatura para o método

      (request-target): get <BUCKER_PATH>/p/\n
      date: <DATE_UTC_FORMAT_RCF1123>\n
      host: <HOST>

      # Modelo de autorização/authorization para adicionar nas requisições Rest API
      
      Signature headers="date (request-target) date host",
      keyId="<TENANCY_OCID>/<USER_OCID>/<API_KEY_FINGERPRINT>",
      algorithm="rsa-sha256",
      signature="<SIGNATURE>",
      version="1"

    */

    final String request = query is Query
      ? '${objectStorage.buckerPath}/p/${query.toURLParams}'
      : '${objectStorage.buckerPath}/p/';

    final String signingString = 
      '(request-target): get $request\n'
      'date: $dateString\n'
      'host: ${objectStorage.buckerHost}';

    return ListPreauthenticatedRequests._(
      uri: '${objectStorage.serviceURLOrigin}$request', 
      date: dateString, 
      host: objectStorage.buckerHost,
      addHeaders: addHeaders,
      authorization: 'Signature headers="(request-target) date host",'
        'keyId="${objectStorage.tenancyOcid}/${objectStorage.userOcid}/${objectStorage.apiPrivateKey.fingerprint}",'
        'algorithm="rsa-sha256",'
        'signature="${objectStorage.apiPrivateKey.sing(signingString)}",'
        'version="1"',
    );

  }

}

extension ListPreauthenticatedRequestsMethod on OracleObjectStorage {
  
  /// Construir dados de autorização para o serviço [ListPreauthenticatedRequests],
  ListPreauthenticatedRequests listPreauthenticatedRequests({
    Query? query,
    DateTime? date,
    Map<String, String>? addHeaders,
  }) {
    return ListPreauthenticatedRequests(
      objectStorage: this,
      query: query,
      date: date,
      addHeaders: addHeaders,
    );
  }

}