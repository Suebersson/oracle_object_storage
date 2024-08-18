import '../../interfaces/oracle_request_attributes.dart';
import '../../oracle_object_storage.dart';
import '../../query.dart';

final class GetBucket implements OracleRequestAttributes {
  
  // https://docs.oracle.com/en-us/iaas/api/#/en/objectstorage/20160918/Bucket/GetBucket
  const GetBucket._({
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

  /// Construir dados de autorização para o serviço [GetBucket]
  factory GetBucket({
    required OracleObjectStorage objectStorage, 
    String? namespaceName,
    String? bucketName,
    Query? query,
    DateTime? date,
    Map<String, String>? addHeaders,
  }) {

    final String dateString = OracleObjectStorage.getDateRCF1123(date);

    /*
      # Modelo para String de assinatura para o método [get]

      (request-target): <METHOD> <BUCKET_PATH>/\n
      date: <DATE_UTC_FORMAT_RCF1123>\n
      host: <HOST>

      # Modelo de autorização/authorization para adicionar nas requisições Rest API
      
      Signature headers="date (request-target) date host",
      keyId="<TENANCY_OCID>/<USER_OCID>/<API_KEY_FINGERPRINT>",
      algorithm="rsa-sha256",
      signature="<SIGNATURE>",
      version="1"
    */


    namespaceName ??= objectStorage.bucketNameSpace;
    bucketName ??= objectStorage.bucketName;

    final String request = query is Query
      ? '/n/$namespaceName/b/$bucketName/${query.toURLParams}'
      : '/n/$namespaceName/b/$bucketName/';

    final String signingString = 
      '(request-target): get $request\n'
      'date: $dateString\n'
      'host: ${objectStorage.bucketHost}';

    return GetBucket._(
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

extension GetBucketMethod on OracleObjectStorage {
  
  /// Construir dados de autorização para o serviço [GetBucket]
  GetBucket getBucket({
    String? namespaceName,
    String? bucketName,
    Query? query,
    DateTime? date,
    Map<String, String>? addHeaders,
  }) {
    return GetBucket(
      objectStorage: this,
      namespaceName: namespaceName,
      bucketName: bucketName,
      query: query,
      date: date,
      addHeaders: addHeaders,
    );
  }

}