part of '../../oracle_object_storage.dart';

/*
  final DeleteObject delete = objectStorage
    .deleteObject(pathAndFileName: '/users/profilePictures/userId.jpg');

  final http.Response response = await http.delete(
    Uri.parse(delete.uri),
    headers: delete.headers,
  );

  // Status code esperado == 204 == objeto excluído com sucesso
  print(response.statusCode);
*/

final class DeleteObject implements ObjectAttributes {

  // https://docs.oracle.com/en-us/iaas/api/#/pt/objectstorage/20160918/Object/DeleteObject
  const DeleteObject._({
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

  /// Construir dados de autorização para o serviço [DeleteObject]
  /// 
  /// [pathAndFileName] Ex: /users/profilePicture/userId.jpg
  factory DeleteObject({
    required OracleObjectStorage objectStorage, 
    required String pathAndFileName, 
    DateTime? date,
    Map<String, String>? addHeaders,
  }) {

    if (pathAndFileName.isEmpty) {
      return throw const OracleObjectStorageExeception('Defina o caminho completo do arquivo');
    }

    final String dateString = OracleObjectStorage.getDateRCF1123(date);

     /*
      
      # Modelo para string de assinatura para o método [delete]

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

    final String signingString = 
      '(request-target): delete ${objectStorage.buckerPath}/o$pathAndFileName\n'
      'date: $dateString\n'
      'host: ${objectStorage.buckerHost}';

    return DeleteObject._(
      uri: '${objectStorage.serviceURLOrigin}${objectStorage.buckerPath}/o$pathAndFileName', 
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

extension DeleteObjectMethod on OracleObjectStorage {
  
  /// Construir dados de autorização para o serviço [DeleteObject],
  /// [pathAndFileName] diretório + nome do arquivo Ex: /users/profilePicture/userId.jpg
  DeleteObject deleteObject({
    required String pathAndFileName,
    DateTime? date,
    Map<String, String>? addHeaders,
  }) {
    return DeleteObject(
      objectStorage: this, 
      date: date,
      pathAndFileName: pathAndFileName,
      addHeaders: addHeaders,
    );
  }

}