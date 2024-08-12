part of '../../oracle_object_storage.dart';

/*
  final ListObjects list = objectStorage.listObjects();

  final http.Response response = await http.get(
    Uri.parse(list.uri),
    headers: list.headers,
  );

  print(response.statusCode);// esperado 200
  print(response.body);// json
*/

final class ListObjects implements ObjectAttributes {

  // https://docs.oracle.com/en-us/iaas/api/#/pt/objectstorage/20160918/Object/ListObject
  const ListObjects._({
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

  /// Construir dados de autorização para o serviço [ListObject]
  factory ListObjects({
    required OracleObjectStorage objectStorage, 
    DateTime? date,
    Map<String, String>? addHeaders,
  }) {

    final String dateString = OracleObjectStorage.getDateRCF1123(date);

    /*
      
      # Modelo para String de assinatura para o método

      (request-target): get <BUCKER_PATH>/o\n
      date: <DATE_UTC_FORMAT_RCF1123>\n
      host: <HOST>

      # Modelo de autorização/authorization para adicionar nas requisições Rest API
      
      Signature headers="date (request-target) date host",
      keyId="<TENANCY_OCID>/<USER_OCID>/<API_KEY_FINGERPRINT>",
      algorithm="rsa-sha256",
      signature="<SIGNATURE>",
      version="1"

    */

    final String signingString = 
      '(request-target): get ${objectStorage.buckerPath}/o\n'
      'date: $dateString\n'
      'host: ${objectStorage.buckerHost}';

    return ListObjects._(
      uri: '${objectStorage.serviceURLOrigin}${objectStorage.buckerPath}/o', 
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

extension ListObjectsMethod on OracleObjectStorage {
  
  /// Construir dados de autorização para o serviço [ListObjects],
  ListObjects listObjects({
    DateTime? date,
    Map<String, String>? addHeaders,
  }) {
    return ListObjects(
      objectStorage: this, 
      date: date,
      addHeaders: addHeaders,
    );
  }

}