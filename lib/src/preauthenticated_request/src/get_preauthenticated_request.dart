import '../../interfaces/oracle_request_attributes.dart';
import '../../oracle_object_storage.dart';

/*
  final GetPreauthenticatedRequest get = objectStorage.getPreauthenticatedRequest(
    parId: 'KjZkD2/MaoSecI+zDMX7ivFSzA6Wh+vv2fUjya1NfyMSTyU1DpRHjQPfk1Jce3Fb',
  );

  final http.Response response = await http.get(
    Uri.parse(get.uri),
    headers: get.headers,
  );

  print(response.statusCode); // esperado 200
  print(response.body);
*/

final class GetPreauthenticatedRequest implements OracleRequestAttributes {
  
  const GetPreauthenticatedRequest._({
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

  /// Construir dados de autorização para o serviço [GetPreauthenticatedRequest]
  factory GetPreauthenticatedRequest({
    required OracleObjectStorage objectStorage, 
    required String parId, 
    DateTime? date,
    Map<String, String>? addHeaders,
  }) {

    final String dateString = OracleObjectStorage.getDateRCF1123(date);

    /*
      
      # Modelo para String de assinatura para o método [get]

      (request-target): <METHOD> <BUCKER_PATH>/p/<parId>\n
      date: <DATE_UTC_FORMAT_RCF1123>\n
      host: <HOST>

      # Modelo de autorização/authorization para adicionar nas requisições Rest API
      
      Signature headers="date (request-target) date host",
      keyId="<TENANCY_OCID>/<USER_OCID>/<API_KEY_FINGERPRINT>",
      algorithm="rsa-sha256",
      signature="<SIGNATURE>",
      version="1"

    */

    final String request = '${objectStorage.buckerPath}/p/$parId';

    final String signingString = 
      '(request-target): get $request\n'
      'date: $dateString\n'
      'host: ${objectStorage.buckerHost}';

    return GetPreauthenticatedRequest._(
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

extension GetPreauthenticatedRequestMethod on OracleObjectStorage {
  
  /// Construir dados de autorização para o serviço [GetPreauthenticatedRequest],
  GetPreauthenticatedRequest getPreauthenticatedRequest({
    required String parId,
    DateTime? date,
    Map<String, String>? addHeaders,
  }) {
    return GetPreauthenticatedRequest(
      objectStorage: this, 
      parId: parId,
      date: date,
      addHeaders: addHeaders,
    );
  }

}