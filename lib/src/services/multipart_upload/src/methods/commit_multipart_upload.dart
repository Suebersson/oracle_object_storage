import 'dart:typed_data' show Uint8List;

import '../../../../converters.dart';
import '../../../../interfaces/details.dart';
import '../../../../interfaces/oracle_request_attributes.dart';
import '../../../../oracle_object_storage.dart';
import '../../../../oracle_object_storage_exeception.dart';
import '../multipart_upload.dart';

/// Construir dados de autorização para o serviço [CommitMultipartUpload]
///
/// https://docs.oracle.com/en-us/iaas/api/#/pt/objectstorage/20160918/MultipartUpload/CommitMultipartUpload
final class CommitMultipartUpload implements OracleRequestAttributes {
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

  final String publicUrlFile,
      jsonData,
      xContentSha256,
      contentLegth,
      contentType;

  final Uint8List jsonBytes;

  @override
  final Map<String, String>? addHeaders;

  @override
  Map<String, String> get headers {
    if (addHeaders is Map<String, String> &&
        (addHeaders?.isNotEmpty ?? false)) {
      addHeaders!
        ..update(
          'authorization',
          (_) => authorization,
          ifAbsent: () => authorization,
        )
        ..update(
          'date',
          (_) => date,
          ifAbsent: () => date,
        )
        ..update(
          'host',
          (_) => host,
          ifAbsent: () => host,
        )
        ..update(
          'x-content-sha256',
          (_) => xContentSha256,
          ifAbsent: () => xContentSha256,
        )
        ..update(
          'content-type',
          (_) => 'application/json',
          ifAbsent: () => 'application/json',
        )
        ..update(
          'content-Length',
          (_) => contentLegth,
          ifAbsent: () => contentLegth,
        );

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

  /// Construir dados de autorização para o serviço [CommitMultipartUpload]
  factory CommitMultipartUpload({
    required OracleObjectStorage storage,
    required CommitMultipartUploadDetails details,
    required String uploadId,
    required String objectName,
    String? namespaceName,
    String? bucketName,
    DateTime? date,
    Map<String, String>? addHeaders,
  }) {
    final String dateString = OracleObjectStorage.getDateRCF1123(date);

    /*
      # Modelo para String de assinatura para o método [post]

      (request-target): <METHOD> /n/{namespaceName}/b/{bucketName}/u/{objectName}?uploadId=...\n
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

    final String request =
        '/n/$namespaceName/b/$bucketName/u/$objectName?uploadId=$uploadId';

    final String signingString = '(request-target): post $request\n'
        'date: $dateString\n'
        'host: ${storage.host}\n'
        'x-content-sha256: ${details.xContentSha256}\n'
        'content-type: ${details.contentType}\n'
        'content-length: ${details.bytesLength}';

    return CommitMultipartUpload._(
      publicUrlFile: storage.getPublicUrlFile('/$objectName'),
      uri: '${storage.apiUrlOrigin}$request',
      date: dateString,
      host: storage.host,
      addHeaders: addHeaders,
      xContentSha256: details.xContentSha256,
      contentType: details.contentType,
      contentLegth: '${details.bytesLength}',
      jsonBytes: details.bytes,
      jsonData: details.json,
      authorization:
          'Signature headers="(request-target) date host x-content-sha256 content-type content-length",'
          'keyId="${storage.tenancy}/${storage.user}/${storage.apiPrivateKey.fingerprint}",'
          'algorithm="rsa-sha256",'
          'signature="${storage.apiPrivateKey.sing(signingString)}",'
          'version="1"',
    );
  }
}

/// Construir dados de autorização para o serviço [CommitMultipartUpload]
extension CommitMultipartUploadMethod on MultipartUpload {
  /// Construir dados de autorização para o serviço [CommitMultipartUpload]
  ///
  /// [objectName] diretório + nome do arquivo
  ///
  /// Ex: users/profilePicture/userId.jpg
  ///
  /// ou
  ///
  /// Ex: userId.jpg
  CommitMultipartUpload commitMultipartUpload({
    required CommitMultipartUploadDetails details,
    required String objectName,
    required String uploadId,
    String? namespaceName,
    String? bucketName,
    DateTime? date,
    Map<String, String>? addHeaders,
  }) {
    return CommitMultipartUpload(
      storage: storage,
      objectName: objectName,
      uploadId: uploadId,
      details: details,
      namespaceName: namespaceName,
      bucketName: bucketName,
      date: date,
      addHeaders: addHeaders,
    );
  }
}

/// https://docs.oracle.com/en-us/iaas/api/#/pt/objectstorage/20160918/datatypes/CommitMultipartUploadDetails
final class CommitMultipartUploadDetails
    implements Details<Map<String, dynamic>> {
  const CommitMultipartUploadDetails._({
    required this.details,
    required this.json,
    required this.bytes,
    required this.xContentSha256,
  })  : contentType = 'application/json',
        bytesLength = bytes.length;

  @override
  final Map<String, dynamic> details;

  @override
  final Uint8List bytes;

  @override
  final int bytesLength;

  @override
  final String contentType, json, xContentSha256;

  /// Construir o objeto [CommitMultipartUploadDetails]
  factory CommitMultipartUploadDetails({
    required List<PartsToCommit> parts,
    List<int>? partsToExclude,
  }) {
    if (parts.isEmpty) {
      throw const OracleObjectStorageExeception(
        'O parâmetro [parts] é obrigatório',
      );
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

/// Parâmentros para o objeto [CommitMultipartUploadDetails]
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
