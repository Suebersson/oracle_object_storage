import 'dart:typed_data' show Uint8List;

import '../../../../converters.dart';
import '../../../../interfaces/details.dart';
import '../../../../interfaces/oracle_request_attributes.dart';
import '../../../../oracle_object_storage.dart';
import '../../../../oracle_object_storage_exeception.dart';
import '../bucket.dart';
import 'create_bucket.dart';

final class UpdateBucket implements OracleRequestAttributes {
  
  // https://docs.oracle.com/en-us/iaas/api/#/en/objectstorage/20160918/Bucket/UpdateBucket
  const UpdateBucket._({
    required this.uri, 
    required this.date, 
    required this.authorization, 
    required this.host,
    required this.jsonBytes,
    required this.xContentSha256,
    required this.contentLegth,
    required this.contentType,
    this.addHeaders,
  });

  @override
  final String uri, date, authorization, host;

  final String xContentSha256, contentLegth, contentType;

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

  /// Construir dados de autorização para o serviço [UpdateBucket]
  /// 
  /// [date] na zona UTC
  factory UpdateBucket({
    required OracleObjectStorage storage, 
    required UpdateBucketDetails details,
    String? namespaceName,
    String? bucketName,
    DateTime? date,
    Map<String, String>? addHeaders,
  }) {

    final String dateString = OracleObjectStorage.getDateRCF1123(date);

    /*
      # Modelo para string de assinatura para o método [put] ou [post]

      (request-target): <METHOD> /n/{namespaceName}/b/{bucketName}/\n
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

    final String request = '/n/$namespaceName/b/$bucketName/';

    final String signingString = 
      '(request-target): post $request\n'
      'date: $dateString\n'
      'host: ${storage.host}\n'
      'x-content-sha256: ${details.xContentSha256}\n'
      'content-type: ${details.contentType}\n'
      'content-length: ${details.bytesLength}';

    return UpdateBucket._(
      uri: '${storage.apiUrlOrigin}$request',
      date: dateString, 
      host: storage.host,
      jsonBytes: details.bytes,
      xContentSha256: details.xContentSha256,
      contentType: details.contentType,
      contentLegth: '${details.bytesLength}',
      addHeaders: addHeaders,
      authorization: 'Signature headers="(request-target) date host x-content-sha256 content-type content-length",'
        'keyId="${storage.tenancy}/${storage.user}/${storage.apiPrivateKey.fingerprint}",'
        'algorithm="rsa-sha256",'
        'signature="${storage.apiPrivateKey.sing(signingString)}",'
        'version="1"',
    );

  }
  
}

/// Construir dados de autorização para o serviço [UpdateBucket]
extension UpdateBucketMethod on Bucket {
  
  /// Construir dados de autorização para o serviço [UpdateBucket]
  UpdateBucket updateBucket({
    required UpdateBucketDetails details,
    String? namespaceName,
    String? bucketName,
    DateTime? date,
    Map<String, String>? addHeaders,
  }) {

    return UpdateBucket(
      storage: storage,
      details: details,
      namespaceName: namespaceName,
      bucketName: bucketName,
      date: date,
      addHeaders: addHeaders,
    );
    
  }

}

/// https://docs.oracle.com/en-us/iaas/api/#/en/objectstorage/20160918/datatypes/UpdateBucketDetails
final class UpdateBucketDetails implements Details<Map<String, dynamic>> {

  const UpdateBucketDetails._({
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

    /// [compartmentId] == tenancy
  factory UpdateBucketDetails({
    String? compartmentId,
    String? name,
    String? namespace,
    String? kmsKeyId,
    bool? objectEventsEnabled,
    AutoTiering? autoTiering,
    Versioning? versioning,
    PublicAccessType? publicAccessType,
    Map<String, String>? definedTags,
    Map<String, String>? freeformTags,
    Map<String, String>? metadata,
  }) {

    final Map<String, dynamic> source = {};

    if (name is String) {
      final int nameLength = name.length;
      if (nameLength < 1 || nameLength > 256) {
        return throw const OracleObjectStorageExeception('O nome do bucket deve ter entre 1 e 256 caracteres');
      } else {
        source.addAll({'name': name});
      }
    }

    if (compartmentId is String) {
      source.addAll({'compartmentId': compartmentId});
    }
    if (namespace is String) {
      source.addAll({'namespace': namespace});
    }
    if (kmsKeyId is String) {
      source.addAll({'kmsKeyId': kmsKeyId});
    }
    if (objectEventsEnabled is bool) {
      source.addAll({'objectEventsEnabled': objectEventsEnabled});
    }
    if (autoTiering is AutoTiering) {
      source.addAll({'autoTiering': autoTiering.name});
    }
    if (versioning is Versioning) {
      source.addAll({'versioning': versioning.name});
    }
    if (publicAccessType is PublicAccessType) {
      source.addAll({'publicAccessType': publicAccessType.name});
    }
    if (definedTags is Map<String, String> && definedTags.isNotEmpty) {
      source.addAll({'definedTags': definedTags});
    }
    if (freeformTags is Map<String, String> && freeformTags.isNotEmpty) {
      source.addAll({'freeformTags': freeformTags});
    }
    if (metadata is Map<String, String> && metadata.isNotEmpty) {
      source.addAll({'metadata': metadata});
    }

    final String json = source.toJson;

    final Uint8List bytes = json.utf8ToBytes;

    return UpdateBucketDetails._(
      details: source, 
      json: json, 
      bytes: bytes, 
      xContentSha256: bytes.toSha256Base64,
    );

  }
  
  @override
  String toString() => '$runtimeType($details)'.replaceAll(RegExp('{|}'), '');

}