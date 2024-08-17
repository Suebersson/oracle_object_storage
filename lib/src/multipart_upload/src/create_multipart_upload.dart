import 'dart:typed_data' show Uint8List;

import '../../converters.dart';
import '../../interfaces/oracle_request_attributes.dart';
import '../../oracle_object_storage.dart';

/// Criar um objeto com uploads separados
final class CreateMultipartUpload implements OracleRequestAttributes {

  // https://docs.oracle.com/en-us/iaas/api/#/pt/objectstorage/20160918/MultipartUpload/
  // https://docs.oracle.com/en-us/iaas/api/#/pt/objectstorage/20160918/MultipartUpload/CreateMultipartUpload
  // https://docs.oracle.com/en-us/iaas/api/#/pt/objectstorage/20160918/datatypes/CreateMultipartUploadDetails
  const CreateMultipartUpload._({
    required this.uri, 
    required this.date, 
    required this.authorization, 
    required this.host, 
    required this.xContentSha256, 
    required this.contentLegth, 
    required this.contentType, 
    required this.addHeaders,
    required this.muiltiPartObjectName,
    required this.jsonBytes,
  });
  
  @override
  final String uri, date, authorization, host;

  final String 
    muiltiPartObjectName,
    xContentSha256, 
    contentLegth, 
    contentType;

  final Uint8List jsonBytes;

  @override
  final Map<String, String>? addHeaders;
  
  @override
  Map<String, String> get headers {
    if (addHeaders is Map<String, String> && (addHeaders?.isNotEmpty ?? false)) {

      addHeaders!
      ..update('authorization', (_) => authorization, ifAbsent: () => authorization,)
      ..update('date', (_) => date, ifAbsent: () => date,)
      ..update('host', (_) => host, ifAbsent: () => host,)
      ..update('x-content-sha256', (_) => xContentSha256, ifAbsent: () => xContentSha256,)
      ..update('content-type', (_) => 'application/json', ifAbsent: () => 'application/json',)
      ..update('content-Length', (_) => contentLegth, ifAbsent: () => contentLegth,);

      return addHeaders!;    

    } else {
      return {
        'authorization': authorization,
        'date': date,
        'host': host,
        'x-content-sha256': xContentSha256,
        'content-type': 'application/json',
        'content-Length': contentLegth,
      };
    }
  }

  factory CreateMultipartUpload({
    required OracleObjectStorage objectStorage, 
    required String muiltiPartObjectName,
    DateTime? date,
    Map<String, String>? addHeaders,
  }) {

    final String dateString = OracleObjectStorage.getDateRCF1123(date);

    final Uint8List jsonBytes = '{"object":"$muiltiPartObjectName"}'.utf8ToBytes;

    final String xContentSha256 = jsonBytes.toSha256Base64;
    
    /*
      # Modelo para String de assinatura para o método [post]

      (request-target): <METHOD> <BUCKET_PATH>/u\n
      date: <DATE_UTC_FORMAT_RCF1123>\n
      host: <HOST>\n
      x-content-sha256: <FILE_HASH_IN_BASE64>\n'
      content-type: <CONTENT-TYPE>\n
      content-length: <FILE_BYTES>

      # Modelo de autorização/authorization para adicionar nas requisições Rest API

      Signature headers="date (request-target) date host x-content-sha256 content-type content-length",
      keyId="<TENANCY_OCID>/<USER_OCID>/<API_KEY_FINGERPRINT>",
      algorithm="rsa-sha256",
      signature="<SIGNATURE>",
      version="1"
    */

    final String signingString = 
      '(request-target): post ${objectStorage.bucketPath}/u\n'
      'date: $dateString\n'
      'host: ${objectStorage.bucketHost}\n'
      'x-content-sha256: $xContentSha256\n'
      'content-type: application/json\n'
      'content-length: ${jsonBytes.length}';
      
    return CreateMultipartUpload._(
      uri: '${objectStorage.serviceURLOrigin}${objectStorage.bucketPath}/u', 
      date: dateString, 
      host: objectStorage.bucketHost,
      addHeaders: addHeaders,
      xContentSha256: xContentSha256,
      contentType: 'application/json',
      contentLegth: '${jsonBytes.length}',
      muiltiPartObjectName: muiltiPartObjectName,
      jsonBytes: jsonBytes,
      authorization: 'Signature headers="(request-target) date host x-content-sha256 content-type content-length",'
        'keyId="${objectStorage.tenancyOcid}/${objectStorage.userOcid}/${objectStorage.apiPrivateKey.fingerprint}",'
        'algorithm="rsa-sha256",'
        'signature="${objectStorage.apiPrivateKey.sing(signingString)}",'
        'version="1"',
    );

  }

}

extension CreateMultipartUploadMethod on OracleObjectStorage {
  
  /// Construir dados de autorização para o serviço [CreateMultipartUpload]
  /// 
  /// [muiltiPartObjectName] diretório + nome do arquivo 
  /// 
  /// Ex: users/profilePicture/userId.jpg
  /// 
  /// ou
  /// 
  /// Ex: userId.jpg
  CreateMultipartUpload createMultipartUpload({
    required String muiltiPartObjectName,
    DateTime? date,
    Map<String, String>? addHeaders,
  }) {
    return CreateMultipartUpload(
      objectStorage: this,
      muiltiPartObjectName: muiltiPartObjectName, 
      date: date,
      addHeaders: addHeaders,
    );
  }

}