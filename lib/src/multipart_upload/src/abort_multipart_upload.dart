import '../../interfaces/oracle_request_attributes.dart';
import '../../oracle_object_storage.dart';
import '../../oracle_object_storage_exeception.dart';

/*
  final AbortMultipartUpload abort = objectStorage.abortMultipartUpload(
    muiltiPartObjectName: 'muiltPart/object_file.jpg',
    uploadId: '...',
  );

  final http.Response response = await http.delete(
    Uri.parse(abort.uri),
    headers: abort.headers,
  );

  // Status code esperado == 204 == operação multi part cancelada
  print(response.statusCode);
*/

final class AbortMultipartUpload implements OracleRequestAttributes {
  
  // https://docs.oracle.com/en-us/iaas/api/#/pt/objectstorage/20160918/MultipartUpload/AbortMultipartUpload
  const AbortMultipartUpload._({
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

  /// Construir dados de autorização para o serviço [AbortMultipartUpload]
  /// 
  /// [muiltiPartObjectName] Ex: /users/profilePicture/userId.jpg
  factory AbortMultipartUpload({
    required OracleObjectStorage objectStorage, 
    required String muiltiPartObjectName,
    required String uploadId,
    DateTime? date,
    Map<String, String>? addHeaders,
  }) {

    if (muiltiPartObjectName.isEmpty) {
      return throw const OracleObjectStorageExeception('Defina o caminho completo do arquivo');
    }

    final String dateString = OracleObjectStorage.getDateRCF1123(date);

     /*
      
      # Modelo para string de assinatura para o método [delete]

      (request-target): <METHOD> <BUCKER_PATH>/u<DIRECTORY_PATH><FILE_NAME>\n
      date: <DATE_UTC_FORMAT_RCF1123>\n
      host: <HOST>

      # Modelo de autorização/authorization para adicionar nas requisições Rest API
      
      Signature headers="date (request-target) date host",
      keyId="<TENANCY_OCID>/<USER_OCID>/<API_KEY_FINGERPRINT>",
      algorithm="rsa-sha256",
      signature="<SIGNATURE>",
      version="1"

    */

    final String request = '${objectStorage.buckerPath}/u/$muiltiPartObjectName?uploadId=$uploadId';

    final String signingString = 
      '(request-target): delete $request\n'
      'date: $dateString\n'
      'host: ${objectStorage.buckerHost}';

    return AbortMultipartUpload._(
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

extension AbortMultipartUploadMethod on OracleObjectStorage {
  
  /// Construir dados de autorização para o serviço [AbortMultipartUpload]
  /// 
  /// [muiltiPartObjectName] diretório + nome do arquivo 
  /// 
  /// Ex: users/profilePicture/userId.jpg
  /// 
  /// ou
  /// 
  /// Ex: userId.jpg
  AbortMultipartUpload abortMultipartUpload({
    required String muiltiPartObjectName,
    required String uploadId,
    DateTime? date,
    Map<String, String>? addHeaders,
  }) {
    return AbortMultipartUpload(
      objectStorage: this, 
      uploadId: uploadId,
      date: date,
      muiltiPartObjectName: muiltiPartObjectName,
      addHeaders: addHeaders,
    );
  }

}