import 'dart:typed_data';

import '../../converters.dart';
import '../../interfaces/details.dart';
import '../../interfaces/oracle_request_attributes.dart';
import '../../oracle_object_storage.dart';
import '../../oracle_object_storage_exeception.dart';

final class CommitMultipartUpload implements OracleRequestAttributes {
  
  // https://docs.oracle.com/en-us/iaas/api/#/pt/objectstorage/20160918/MultipartUpload/CommitMultipartUpload
  const CommitMultipartUpload._({
    required this.uri, 
    required this.date, 
    required this.authorization, 
    required this.host, 
    required this.xContentSha256,
    required this.contentLegth,
    required this.contentType,
    required this.jsonBytes,
    required this.jsonData,
    required this.publicUrlFile,
    this.addHeaders,
  });

  @override
  final String uri, date, authorization, host;

  final String 
    publicUrlFile,
    jsonData,
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
  
  factory CommitMultipartUpload({
    required OracleObjectStorage objectStorage, 
    required CommitMultipartUploadDetails details,
    required String uploadId,
    required String muiltiPartObjectName,
    DateTime? date,
    Map<String, String>? addHeaders,
  }) {

    final String dateString = OracleObjectStorage.getDateRCF1123(date);
    
    /*
      # Modelo para String de assinatura para o método [post]

      (request-target): <METHOD> <BUCKER_PATH>/u<DIRECTORY_PATH><FILE_NAME><?uploadId=...>\n
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

    final String request = '${objectStorage.buckerPath}/u/$muiltiPartObjectName?uploadId=$uploadId';

    final String signingString = 
      '(request-target): post $request\n'
      'date: $dateString\n'
      'host: ${objectStorage.buckerHost}\n'
      'x-content-sha256: ${details.xContentSha256}\n'
      'content-type: ${details.contentType}\n'
      'content-length: ${details.bytesLength}';
      
    return CommitMultipartUpload._(
      publicUrlFile: objectStorage.getPublicUrlFile('/$muiltiPartObjectName'),
      uri: '${objectStorage.serviceURLOrigin}$request', 
      date: dateString, 
      host: objectStorage.buckerHost,
      addHeaders: addHeaders,
      xContentSha256: details.xContentSha256,
      contentType: details.contentType,
      contentLegth: '${details.bytesLength}',
      jsonBytes: details.bytes,
      jsonData: details.json,
      authorization: 'Signature headers="(request-target) date host x-content-sha256 content-type content-length",'
        'keyId="${objectStorage.tenancyOcid}/${objectStorage.userOcid}/${objectStorage.apiPrivateKey.fingerprint}",'
        'algorithm="rsa-sha256",'
        'signature="${objectStorage.apiPrivateKey.sing(signingString)}",'
        'version="1"',
    );

  }

}

extension CommitMultipartUploadMethod on OracleObjectStorage {
  
  /// Construir dados de autorização para o serviço [CommitMultipartUpload]
  /// 
  /// [muiltiPartObjectName] diretório + nome do arquivo 
  /// 
  /// Ex: users/profilePicture/userId.jpg
  /// 
  /// ou
  /// 
  /// Ex: userId.jpg
  CommitMultipartUpload commitMultipartUpload({
    required CommitMultipartUploadDetails details,
    required String muiltiPartObjectName,
    required String uploadId,
    DateTime? date,
    Map<String, String>? addHeaders,
  }) {
  
    return CommitMultipartUpload(
      objectStorage: this, 
      muiltiPartObjectName: muiltiPartObjectName,
      uploadId: uploadId,
      details: details,
      date: date,
      addHeaders: addHeaders,
    );
  
  }

}

final class CommitMultipartUploadDetails implements Details<Map<String, dynamic>> {
  
  // https://docs.oracle.com/en-us/iaas/api/#/pt/objectstorage/20160918/datatypes/CommitMultipartUploadDetails
  const CommitMultipartUploadDetails._({
    required this.details,
    required this.json,
    required this.bytes,
    required this.xContentSha256,
  }) : 
    contentType = 'application/json', 
    bytesLength = bytes.length;

  @override
  final Map<String, dynamic> details;

  @override
  final Uint8List bytes;

  @override
  final int bytesLength;
  
  @override
  final String contentType, json, xContentSha256;

  factory CommitMultipartUploadDetails({
    required List<PartsToCommit> parts, 
    List<int>? partsToExclude, 
  }) {

    if (parts.isEmpty) {
      throw const OracleObjectStorageExeception('O parâmetro [parts] é obrigatório');
    }

    final Map<String, dynamic> source = {};

    // List<Map<String, dynamic>>
    source.addAll({'partsToCommit': parts.map((e) => e.toMap).toList()});

    if (partsToExclude is List<int>) {
      source.addAll({'partsToExclude': partsToExclude});
    }

    final String json = source.toJson;

    final Uint8List bytes = json.utf8ToBytes;

    return CommitMultipartUploadDetails._(
      details: source, 
      json: json, 
      bytes: bytes,
      xContentSha256: bytes.toSha256Base64,
    );

  }
  
  @override
  String toString() => '$runtimeType($details)'.replaceAll(RegExp('{|}'), '');

}

final class PartsToCommit {
 
  const PartsToCommit({required this.partNum, required this.etag});
 
  final int partNum;
  final String etag;

  Map<String, dynamic> get toMap => {
    'partNum': partNum,
    'etag': etag,
  };

  String get toJson => toMap.toJson;

}