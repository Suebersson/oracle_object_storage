import '../../interfaces/oracle_request_attributes.dart';
import '../../oracle_object_storage.dart';
import '../../oracle_object_storage_exeception.dart';
import '../../query.dart';

final class ListMultipartUploadParts implements OracleRequestAttributes{
  
  // https://docs.oracle.com/en-us/iaas/api/#/pt/objectstorage/20160918/Object/ListMultipartUploadParts
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

  /// Construir dados de autorização para o serviço [ListMultipartUploadParts]
  /// 
  /// [objectName] Ex: users/profilePicture/userId.jpg
  factory ListMultipartUploadParts({
    required OracleObjectStorage objectStorage, 
    required String objectName, 
    required Query query,
    DateTime? date,
    Map<String, String>? addHeaders,
  }) {

    if (objectName.isEmpty) {
      return throw const OracleObjectStorageExeception('Defina o nome do arquivo');
    }
    if (!query.querys.containsKey('uploadId')) {
      return throw const OracleObjectStorageExeception('O parâmetros [uploadId] é obrigatório dentro da query');
    }

    final String dateString = OracleObjectStorage.getDateRCF1123(date);

    /*
      
      # Modelo para String de assinatura para o método [get]

      (request-target): <METHOD> <BUCKET_PATH>/u<DIRECTORY_PATH><FILE_NAME><?uploadId=...>\n
      date: <DATE_UTC_FORMAT_RCF1123>\n
      host: <HOST>

      # Modelo de autorização/authorization para adicionar nas requisições Rest API
      
      Signature headers="date (request-target) date host",
      keyId="<TENANCY_OCID>/<USER_OCID>/<API_KEY_FINGERPRINT>",
      algorithm="rsa-sha256",
      signature="<SIGNATURE>",
      version="1"

    */

    final String request = '${objectStorage.bucketPath}/u/$objectName${query.toURLParams}';

    final String signingString = 
      '(request-target): get $request\n'
      'date: $dateString\n'
      'host: ${objectStorage.bucketHost}';

    return ListMultipartUploadParts._(
      uri: '${objectStorage.serviceURLOrigin}$request', 
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

extension ListMultipartUploadPartsMethod on OracleObjectStorage {
  
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
    DateTime? date,
    Map<String, String>? addHeaders,
  }) {
    return ListMultipartUploadParts(
      objectStorage: this,
      query: query,
      date: date,
      objectName: objectName,
      addHeaders: addHeaders,
    );
  }

}