import '../../interfaces/oracle_request_attributes.dart';
import '../../oracle_object_storage.dart';
import '../../oracle_object_storage_exeception.dart';
import '../../query.dart';

final class HeadObject implements OracleRequestAttributes {

  // https://docs.oracle.com/en-us/iaas/api/#/pt/objectstorage/20160918/Object/HeadObject
  const HeadObject._({
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

  /// Construir dados de autorização para o serviço [HeadObject]
  /// 
  /// [pathAndFileName] Ex: /users/profilePicture/userId.jpg
  factory HeadObject({
    required OracleObjectStorage objectStorage, 
    required String pathAndFileName,
    Query? query,
    DateTime? date,
    Map<String, String>? addHeaders,
  }) {

    if (pathAndFileName.isEmpty) {
      return throw const OracleObjectStorageExeception('Defina o caminho completo do arquivo');
    }

    final String dateString = OracleObjectStorage.getDateRCF1123(date);

    /*
      
      # Modelo para String de assinatura para o método [head]

      (request-target): <METHOD> <BUCKER_PATH><DIRECTORY_PATH><FILE_NAME>\n
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
      ? '${objectStorage.buckerPath}/o$pathAndFileName${query.toURLParams}'
      : '${objectStorage.buckerPath}/o$pathAndFileName';

    final String signingString = 
      '(request-target): head $request\n'
      'date: $dateString\n'
      'host: ${objectStorage.buckerHost}';

    return HeadObject._(
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

extension HeadObjectMethod on OracleObjectStorage {
  
  /// Construir dados de autorização para o serviço [HeadObject],
  /// [pathAndFileName] diretório + nome do arquivo Ex: /users/profilePicture/userId.jpg
  HeadObject headObject({
    required String pathAndFileName,
    Query? query,
    DateTime? date,
    Map<String, String>? addHeaders,
  }) {
    return HeadObject(
      objectStorage: this,
      query: query, 
      date: date,
      pathAndFileName: pathAndFileName,
      addHeaders: addHeaders,
    );
  }

}