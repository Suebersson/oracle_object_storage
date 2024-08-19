import 'dart:typed_data' show Uint8List;

import '../../../../converters.dart';
import '../../../../interfaces/details.dart';
import '../../../../interfaces/oracle_request_attributes.dart';
import '../../../../oracle_object_storage.dart';
import '../object.dart';

/// https://docs.oracle.com/en-us/iaas/api/#/pt/objectstorage/20160918/Object/CopyObject
/// https://docs.oracle.com/en-us/iaas/Content/Object/Tasks/copyingobjects.htm
final class CopyObject implements OracleRequestAttributes{
  
  const CopyObject._({
    required this.uri, 
    required this.date, 
    required this.authorization, 
    required this.host, 
    required this.xContentSha256,
    required this.contentLegth,
    required this.contentType,
    required this.jsonBytes,
    required this.jsonData,
    required this.publicUrlOfCopiedFile,
    this.addHeaders,
  });

  @override
  final String uri, date, authorization, host;

  final String 
    publicUrlOfCopiedFile,
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
      ..update('content-type', (_) => contentType, ifAbsent: () => contentType,)
      ..update('content-Length', (_) => contentLegth, ifAbsent: () => contentLegth,);

      return addHeaders!;

    } else {
      return {
        'authorization': authorization,
        'date': date,
        'host': host,
        'x-content-sha256': xContentSha256,
        'content-type': contentType,
        'content-Length': contentLegth,
      };
    }
  }

  /// Cria uma solicitação para copiar um arquivo dentro de uma 
  /// região ou para outra região [CopyObject]
  /// 
  /// https://docs.oracle.com/en-us/iaas/api/#/pt/objectstorage/20160918/Object/CopyObject
  /// https://docs.oracle.com/en-us/iaas/Content/Object/Tasks/copyingobjects.htm
  factory CopyObject({
    required OracleObjectStorage storage, 
    required CopyObjectDetails details,
    String? namespaceName,
    String? bucketName,
    DateTime? date,
    Map<String, String>? addHeaders,
  }) {

    final String dateString = OracleObjectStorage.getDateRCF1123(date);

    /*
      # Modelo para String de assinatura para o método [post]

      (request-target): <METHOD> /n/{namespaceName}/b/{bucketName}/actions/copyObject\n
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

    namespaceName ??= storage.nameSpace;
    bucketName ??= storage.bucketName;

    final String request = '/n/$namespaceName/b/$bucketName/actions/copyObject';

    final String signingString = 
      '(request-target): post $request\n'
      'date: $dateString\n'
      'host: ${storage.host}\n'
      'x-content-sha256: ${details.xContentSha256}\n'
      'content-type: ${details.contentType}\n'
      'content-length: ${details.bytesLength}';
      
    return CopyObject._(
      uri: '${storage.apiUrlOrigin}$request', 
      date: dateString, 
      host: storage.host,
      addHeaders: addHeaders,
      xContentSha256: details.xContentSha256,
      contentType: details.contentType,
      contentLegth: '${details.bytesLength}',
      jsonBytes: details.bytes,
      jsonData: details.json,
      publicUrlOfCopiedFile: 
        'https://objectstorage.${details.details['destinationRegion']}.oraclecloud.com'
        '/n/${details.details['destinationNamespace']}'
        '/b/${details.details['destinationBucket']}'
        '/o/${details.details['destinationObjectName']}',
      authorization: 'Signature headers="(request-target) date host x-content-sha256 content-type content-length",'
        'keyId="${storage.tenancy}/${storage.user}/${storage.apiPrivateKey.fingerprint}",'
        'algorithm="rsa-sha256",'
        'signature="${storage.apiPrivateKey.sing(signingString)}",'
        'version="1"',
    );

  }

}

/// Cria uma solicitação para copiar um arquivo dentro de uma 
/// região ou para outra região [CopyObject]
extension CopyObjectMethod on ObjectStorage {

  /// Cria uma solicitação para copiar um arquivo dentro de uma 
  /// região ou para outra região [CopyObject]
  CopyObject copyObject({
    required CopyObjectDetails details,
    String? namespaceName,
    String? bucketName,
    DateTime? date,
    Map<String, String>? addHeaders,
  }) {
    return CopyObject(
      storage: storage,
      details: details,
      namespaceName: namespaceName,
      bucketName: bucketName,
      date: date,
      addHeaders: addHeaders,
    );
  }

}

/// https://docs.oracle.com/en-us/iaas/api/#/pt/objectstorage/20160918/datatypes/CopyObjectDetails
final class CopyObjectDetails implements Details<Map<String, dynamic>> {

  const CopyObjectDetails._({
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

  /// https://docs.oracle.com/en-us/iaas/api/#/pt/objectstorage/20160918/datatypes/CopyObjectDetails
  factory CopyObjectDetails({
    required String sourceObjectName, 
    required String destinationRegion, 
    required String destinationNamespace,
    required String destinationBucket,
    required String destinationObjectName,
    Map<String, String>? destinationObjectMetadata,
    String? sourceObjectIfMatchETag,
    String? destinationObjectIfMatchETag,
    String? destinationObjectIfNoneMatchETag,
    String? destinationObjectStorageTier,
    String? sourceVersionId,
  }) {

    final Map<String, dynamic> source = {
      'sourceObjectName': sourceObjectName,
      'destinationRegion': destinationRegion,
      'destinationNamespace': destinationNamespace,
      'destinationBucket': destinationBucket,
      'destinationObjectName': destinationObjectName,
    };
      
    if (destinationObjectMetadata is Map<String, String> && destinationObjectMetadata.isNotEmpty) {
      source.putIfAbsent('destinationObjectMetadata', () => destinationObjectMetadata);
    }
    if (sourceObjectIfMatchETag is String && sourceObjectIfMatchETag.isNotEmpty) {
      source.putIfAbsent('sourceObjectIfMatchETag', () => sourceObjectIfMatchETag);
    }
    if (destinationObjectIfMatchETag is String && destinationObjectIfMatchETag.isNotEmpty) {
      source.putIfAbsent('destinationObjectIfMatchETag', () => destinationObjectIfMatchETag);
    }
    if (destinationObjectIfNoneMatchETag is String && destinationObjectIfNoneMatchETag.isNotEmpty) {
      source.putIfAbsent('destinationObjectIfNoneMatchETag', () => destinationObjectIfNoneMatchETag);
    }
    if (destinationObjectStorageTier is String && destinationObjectStorageTier.isNotEmpty) {
      source.putIfAbsent('destinationObjectStorageTier', () => destinationObjectStorageTier);
    }
    if (sourceVersionId is String && sourceVersionId.isNotEmpty) {
      source.putIfAbsent('sourceVersionId', () => sourceVersionId);
    }

    final String json = source.toJson;

    final Uint8List bytes = json.utf8ToBytes;

    return CopyObjectDetails._(
      details: source, 
      json: json, 
      bytes: bytes, 
      xContentSha256: bytes.toSha256Base64,
    );

  }

  @override
  String toString() => '$runtimeType($details)'.replaceAll(RegExp('{|}'), '');

}
