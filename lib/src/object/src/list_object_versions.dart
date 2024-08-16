import '../../../oracle_object_storage.dart';
import '../../interfaces/oracle_request_attributes.dart';

/*
  final ListObjectVersions list = objectStorage.listObjectVersions(
    query: Query({// parâmentro  opcional
      'limit': '10', // no máximo 10 objetos
      'prefix': 'events/banners/', // todos os objetos de uma pasta
      'fields': 'name,timeCreated', // apenas os campos especificos
    }),
  );

  final http.Response response = await http.get(
    Uri.parse(list.uri),
    headers: list.headers,
  );

  print(response.statusCode); // esperado 200
  print(response.body);// esperado application-json
*/

final class ListObjectVersions implements OracleRequestAttributes {

  // https://docs.oracle.com/en-us/iaas/api/#/pt/objectstorage/20160918/Object/ListObjectVersions
  const ListObjectVersions._({
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

  /// Construir dados de autorização para o serviço [ListObjectVersions]
  factory ListObjectVersions({
    required OracleObjectStorage objectStorage, 
    Query? query,
    DateTime? date,
    Map<String, String>? addHeaders,
  }) {

    final String dateString = OracleObjectStorage.getDateRCF1123(date);

    /*
      
      # Modelo para String de assinatura para o método

      (request-target): get <BUCKER_PATH>/objectversions\n
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
      ? '${objectStorage.buckerPath}/objectversions${query.toURLParams}'
      : '${objectStorage.buckerPath}/objectversions';

    final String signingString = 
      '(request-target): get $request\n'
      'date: $dateString\n'
      'host: ${objectStorage.buckerHost}';

    return ListObjectVersions._(
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

extension ListObjectVersionsMethod on OracleObjectStorage {
  
  /// Construir dados de autorização para o serviço [ListObjectVersions],
  ListObjectVersions listObjectVersions({
    Query? query,
    DateTime? date,
    Map<String, String>? addHeaders,
  }) {
    return ListObjectVersions(
      objectStorage: this, 
      query: query,
      date: date,
      addHeaders: addHeaders,
    );
  }

}