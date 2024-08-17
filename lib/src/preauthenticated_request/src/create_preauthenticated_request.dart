// ignore_for_file: constant_identifier_names

import 'dart:typed_data';

import '../../../oracle_object_storage.dart';
import '../../interfaces/details.dart';
import '../../interfaces/oracle_request_attributes.dart';

final class CreatePreauthenticatedRequest implements OracleRequestAttributes {

  // https://docs.oracle.com/en-us/iaas/api/#/en/objectstorage/20160918/PreauthenticatedRequest/CreatePreauthenticatedRequest
  const CreatePreauthenticatedRequest._({
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

  /// Construir dados de autorização para o serviço [CreatePreauthenticatedRequest]
  /// 
  /// [date] na zona UTC
  factory CreatePreauthenticatedRequest({
    required OracleObjectStorage objectStorage, 
    required CreatePreauthenticatedRequestDetails details,
    String? namespaceName,
    String? bucketName,
    DateTime? date,
    Map<String, String>? addHeaders,
  }) {

    final String dateString = OracleObjectStorage.getDateRCF1123(date);

    /*

      # Modelo para string de assinatura para o método [put] ou [post]

      (request-target): <METHOD> /n/{namespaceName}/b/{bucketName}/p/\n
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

    namespaceName ??= objectStorage.bucketNameSpace;
    bucketName ??= objectStorage.bucketName;

    final String request = '/n/$namespaceName/b/$bucketName/p/';

    final String signingString = 
      '(request-target): post $request\n'
      'date: $dateString\n'
      'host: ${objectStorage.bucketHost}\n'
      'x-content-sha256: ${details.xContentSha256}\n'
      'content-type: ${details.contentType}\n'
      'content-length: ${details.bytesLength}';

    return CreatePreauthenticatedRequest._(
      uri: '${objectStorage.serviceURLOrigin}$request',
      date: dateString, 
      host: objectStorage.bucketHost,
      jsonBytes: details.bytes,
      xContentSha256: details.xContentSha256,
      contentType: details.contentType,
      contentLegth: '${details.bytesLength}',
      addHeaders: addHeaders,
      authorization: 'Signature headers="(request-target) date host x-content-sha256 content-type content-length",'
        'keyId="${objectStorage.tenancyOcid}/${objectStorage.userOcid}/${objectStorage.apiPrivateKey.fingerprint}",'
        'algorithm="rsa-sha256",'
        'signature="${objectStorage.apiPrivateKey.sing(signingString)}",'
        'version="1"',
    );

  }

}

extension CreatePreauthenticatedRequestMethod on OracleObjectStorage {
  
  /// Construir dados de autorização para o serviço [CreatePreauthenticatedRequest]
  CreatePreauthenticatedRequest createPreauthenticatedRequest({
    required CreatePreauthenticatedRequestDetails details,
    String? namespaceName,
    String? bucketName,
    DateTime? date,
    Map<String, String>? addHeaders,
  }) {
    return CreatePreauthenticatedRequest(
      objectStorage: this, 
      details: details,
      namespaceName: namespaceName,
      bucketName: bucketName,
      date: date,
      addHeaders: addHeaders,
    );
    
  }

}

final class CreatePreauthenticatedRequestDetails implements Details<Map<String, String>> {

  // https://docs.oracle.com/en-us/iaas/api/#/en/objectstorage/20160918/datatypes/CreatePreauthenticatedRequestDetails
  const CreatePreauthenticatedRequestDetails._({
    required this.details,
    required this.json,
    required this.bytes,
    required this.xContentSha256,
  }) : 
    contentType = 'application/json', 
    bytesLength = bytes.length;

  @override
  final Map<String, String> details;

  @override
  final Uint8List bytes;

  @override
  final int bytesLength;
  
  @override
  final String contentType, json, xContentSha256;

  /// [timeExpires] no formato RFC 3339
  /// 
  /// [objectName] o nome de arquivo específico ou um prefixo
  /// 
  /// arquivo: events/banners/fileName.jpg  
  /// 
  /// prefixo: events/banners/
  factory CreatePreauthenticatedRequestDetails({
    required AccessType accessType,
    required String name,
    required String timeExpires,
    BucketListingAction? bucketListingAction,
    String? objectName,
  }) {

    if (name.isEmpty) {
      return throw const OracleObjectStorageExeception('Defina o nome do acesso pré-autenticado');
    }

    final Map<String, String> source = {
      'accessType': accessType.name,
      'name': name,
      'timeExpires': timeExpires,
    };

    if (bucketListingAction is BucketListingAction) {
      source.addAll({'bucketListingAction': bucketListingAction.name});
    }
    if (objectName is String && objectName.isNotEmpty) {
      source.addAll({'objectName': objectName});
    }

    final String json = source.toJson;

    final Uint8List bytes = json.utf8ToBytes;

    return CreatePreauthenticatedRequestDetails._(
      details: source, 
      json: json, 
      bytes: bytes, 
      xContentSha256: bytes.toSha256Base64,
    );

  }

  @override
  String toString() => '$runtimeType($details)'.replaceAll(RegExp('{|}'), '');

}

enum AccessType {
  ObjectRead,
  ObjectWrite,
  ObjectReadWrite,
  AnyObjectWrite,
  AnyObjectRead,
  AnyObjectReadWrite;
}

enum BucketListingAction {
  Deny,
  ListObjects;
}