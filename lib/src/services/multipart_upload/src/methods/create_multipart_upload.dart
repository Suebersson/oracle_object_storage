// ignore_for_file: constant_identifier_names

import 'dart:typed_data' show Uint8List;

import '../../../../converters.dart';
import '../../../../interfaces/details.dart';
import '../../../../interfaces/oracle_request_attributes.dart';
import '../../../../oci_request_helpers/opc_meta.dart';
import '../../../../oracle_object_storage.dart';
import '../../../../oracle_object_storage_exeception.dart';
import '../multipart_upload.dart';

/// Criar um objeto com uploads separados
///
/// Construir dados de autorização para o serviço [CreateMultipartUpload]
///
/// https://docs.oracle.com/en-us/iaas/api/#/pt/objectstorage/20160918/MultipartUpload/
/// https://docs.oracle.com/en-us/iaas/api/#/pt/objectstorage/20160918/MultipartUpload/CreateMultipartUpload
final class CreateMultipartUpload implements OracleRequestAttributes {
  const CreateMultipartUpload._({
    required this.uri,
    required this.date,
    required this.authorization,
    required this.host,
    required this.xContentSha256,
    required this.contentLegth,
    required this.contentType,
    required this.addHeaders,
    required this.jsonBytes,
  });

  @override
  final String uri, date, authorization, host;

  final String xContentSha256, contentLegth, contentType;

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
          (_) => contentType,
          ifAbsent: () => contentType,
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
        'content-type': contentType,
        'content-Length': contentLegth,
      };
    }
  }

  /// Construir dados de autorização para o serviço [CreateMultipartUpload]
  factory CreateMultipartUpload({
    required OracleObjectStorage storage,
    required CreateMultipartUploadDetails details,
    String? namespaceName,
    String? bucketName,
    DateTime? date,
    Map<String, String>? addHeaders,
  }) {
    final String dateString = OracleObjectStorage.getDateRCF1123(date);

    /*
      # Modelo para String de assinatura para o método [post]

      (request-target): <METHOD> /n/{namespaceName}/b/{bucketName}/u\n
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

    final String request = '/n/$namespaceName/b/$bucketName/u';

    final String signingString = '(request-target): post $request\n'
        'date: $dateString\n'
        'host: ${storage.host}\n'
        'x-content-sha256: ${details.xContentSha256}\n'
        'content-type: ${details.contentType}\n'
        'content-length: ${details.bytesLength}';

    return CreateMultipartUpload._(
      uri: '${storage.apiUrlOrigin}$request',
      date: dateString,
      host: storage.host,
      addHeaders: addHeaders,
      xContentSha256: details.xContentSha256,
      contentType: details.contentType,
      contentLegth: '${details.bytesLength}',
      jsonBytes: details.bytes,
      authorization:
          'Signature headers="(request-target) date host x-content-sha256 content-type content-length",'
          'keyId="${storage.tenancy}/${storage.user}/${storage.apiPrivateKey.fingerprint}",'
          'algorithm="rsa-sha256",'
          'signature="${storage.apiPrivateKey.sing(signingString)}",'
          'version="1"',
    );
  }
}

/// Construir dados de autorização para o serviço [CreateMultipartUpload]
extension CreateMultipartUploadMethod on MultipartUpload {
  /// Construir dados de autorização para o serviço [CreateMultipartUpload]
  CreateMultipartUpload createMultipartUpload({
    required CreateMultipartUploadDetails details,
    String? namespaceName,
    String? bucketName,
    DateTime? date,
    Map<String, String>? addHeaders,
  }) {
    return CreateMultipartUpload(
      storage: storage,
      details: details,
      namespaceName: namespaceName,
      bucketName: bucketName,
      date: date,
      addHeaders: addHeaders,
    );
  }
}

/// https://docs.oracle.com/en-us/iaas/api/#/en/objectstorage/20160918/datatypes/CreateMultipartUploadDetails
final class CreateMultipartUploadDetails
    implements Details<Map<String, dynamic>> {
  const CreateMultipartUploadDetails._({
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

  /// [objectName] o nome de arquivo específico
  ///
  /// arquivo: events/banners/fileName.jpg
  ///
  /// prefixo: events/banners/
  factory CreateMultipartUploadDetails({
    required String objectName,
    String? cacheControl,
    String? contentDisposition,
    String? contentEncoding,
    String? contentLanguage,
    String? contentType,
    OpcMeta? metadata,
    MultiPartStorageTier? storageTier,
  }) {
    if (objectName.isEmpty) {
      return throw const OracleObjectStorageExeception(
        'Defina o nome do [object]',
      );
    }

    final Map<String, dynamic> source = {
      'object': objectName,
    };

    if (cacheControl is String) {
      source.addAll({'cacheControl': cacheControl});
    }
    if (contentDisposition is String) {
      source.addAll({'contentDisposition': contentDisposition});
    }
    if (contentEncoding is String) {
      source.addAll({'contentEncoding': contentEncoding});
    }
    if (contentLanguage is String) {
      source.addAll({'contentLanguage': contentLanguage});
    }
    if (contentType is String) {
      source.addAll({'contentType': contentType});
    }
    if (metadata is OpcMeta) {
      source.addAll({'metadata': metadata.metaFormat});
    }
    if (storageTier is MultiPartStorageTier) {
      source.addAll({'storageTier': storageTier.name});
    }

    final String json = source.toJson;

    final Uint8List bytes = json.utf8ToBytes;

    return CreateMultipartUploadDetails._(
      details: source,
      json: json,
      bytes: bytes,
      xContentSha256: bytes.toSha256Base64,
    );
  }

  @override
  String toString() => '$runtimeType($details)'.replaceAll(RegExp('{|}'), '');
}

/// Parâmentro para objeto [CreateMultipartUploadDetails]
///
/// https://docs.oracle.com/en-us/iaas/Content/Object/Concepts/understandingstoragetiers.htm
enum MultiPartStorageTier {
  Standard,
  Archive,
  InfrequentAccess;

  @override
  String toString() => name;

}
