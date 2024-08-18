
import '../../interfaces/oracle_request_attributes.dart';
import '../../oracle_object_storage.dart';
import '../../query.dart';

final class ListBuckets implements OracleRequestAttributes {
  
  // https://docs.oracle.com/en-us/iaas/api/#/en/objectstorage/20160918/Bucket/ListBuckets
  const ListBuckets._({
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

  /// Construir dados de autorização para o serviço [ListBuckets]
  /// 
  /// A chave [compartmentId] dentro da query é == tenancy
  factory ListBuckets({
    required OracleObjectStorage objectStorage, 
    Query? query,
    String? namespaceName,
    DateTime? date,
    Map<String, String>? addHeaders,
  }) {

    final String dateString = OracleObjectStorage.getDateRCF1123(date);

    /*
      
      # Modelo para String de assinatura para o método

      (request-target): get /n/{namespaceName}/b/?compartmentId=...\n
      date: <DATE_UTC_FORMAT_RCF1123>\n
      host: <HOST>

      # Modelo de autorização/authorization para adicionar nas requisições Rest API
      
      Signature headers="date (request-target) date host",
      keyId="<TENANCY_OCID>/<USER_OCID>/<API_KEY_FINGERPRINT>",
      algorithm="rsa-sha256",
      signature="<SIGNATURE>",
      version="1"

    */

    if (query is! Query) {
      query ??= Query({'compartmentId': objectStorage.tenancyOcid});
    } else if (!query.querys.containsKey('compartmentId')) {
      query = Query({
        'compartmentId': objectStorage.tenancyOcid,
        ...query.querys,
      });
    }

    namespaceName ??= objectStorage.bucketNameSpace;

    final String request = '/n/$namespaceName/b/${query.toURLParams}';

    final String signingString = 
      '(request-target): get $request\n'
      'date: $dateString\n'
      'host: ${objectStorage.bucketHost}';

    return ListBuckets._(
      uri: '${objectStorage.serviceAPIOrigin}$request', 
      date: dateString, 
      host: objectStorage.bucketHost,
      addHeaders: addHeaders,
      authorization: 'Signature headers="(request-target) date host",'
        'keyId="${objectStorage.tenancyOcid}/${objectStorage.userOcid}/${objectStorage.apiPrivateKey.fingerprint}",'
        'algorithm="rsa-sha256",'
        'signature="${objectStorage.apiPrivateKey.sing(signingString)}",'
        'version="1"',
    );

  }

}

extension ListBucketsMethod on OracleObjectStorage {
  
  /// Construir dados de autorização para o serviço [ListBuckets],
  /// 
  /// A chave [compartmentId] dentro da query é == tenancy
  ListBuckets listBuckets({
    Query? query,
    String? namespaceName,
    DateTime? date,
    Map<String, String>? addHeaders,
  }) {
    return ListBuckets(
      objectStorage: this,
      namespaceName: namespaceName,
      query: query,
      date: date,
      addHeaders: addHeaders,
    );
  }

}