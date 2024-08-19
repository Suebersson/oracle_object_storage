import 'dart:typed_data' show Uint8List;

import '../../../../converters.dart';
import '../../../../interfaces/details.dart';
import '../../../../interfaces/oracle_request_attributes.dart';
import '../../../../oracle_object_storage.dart';
import '../object.dart';

/// https://docs.oracle.com/en-us/iaas/api/#/pt/objectstorage/20160918/Object/RenameObject
final class RenameObject implements OracleRequestAttributes {
  const RenameObject._({
    required this.uri,
    required this.date,
    required this.authorization,
    required this.host,
    required this.xContentSha256,
    required this.contentLegth,
    required this.contentType,
    required this.jsonBytes,
    required this.newPublicUrlFile,
    required this.oldPublicUrlFile,
    required this.jsonData,
    this.addHeaders,
  });

  @override
  final String uri, date, authorization, host;

  final String newPublicUrlFile,
      oldPublicUrlFile,
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

  /// https://docs.oracle.com/en-us/iaas/api/#/pt/objectstorage/20160918/Object/RenameObject
  factory RenameObject({
    required OracleObjectStorage storage,
    required RenameObjectDetails details,
    String? namespaceName,
    String? bucketName,
    DateTime? date,
    Map<String, String>? addHeaders,
  }) {
    final String dateString = OracleObjectStorage.getDateRCF1123(date);

    /*
      # Modelo para String de assinatura para o método [post]

      (request-target): <METHOD> /n/{namespaceName}/b/{bucketName}/actions/renameObject\n
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
        '/n/$namespaceName/b/$bucketName/actions/renameObject';

    final String signingString = '(request-target): post $request\n'
        'date: $dateString\n'
        'host: ${storage.host}\n'
        'x-content-sha256: ${details.xContentSha256}\n'
        'content-type: ${details.contentType}\n'
        'content-length: ${details.bytesLength}';

    return RenameObject._(
      uri: '${storage.apiUrlOrigin}$request',
      date: dateString,
      host: storage.host,
      addHeaders: addHeaders,
      xContentSha256: details.xContentSha256,
      contentType: details.contentType,
      contentLegth: '${details.bytesLength}',
      jsonBytes: details.bytes,
      jsonData: details.json,
      newPublicUrlFile:
          '${storage.apiUrlOrigin}${storage.bucketPath}/o/${details.details['newName']}',
      oldPublicUrlFile:
          '${storage.apiUrlOrigin}${storage.bucketPath}/o/${details.details['sourceName']}',
      authorization:
          'Signature headers="(request-target) date host x-content-sha256 content-type content-length",'
          'keyId="${storage.tenancy}/${storage.user}/${storage.apiPrivateKey.fingerprint}",'
          'algorithm="rsa-sha256",'
          'signature="${storage.apiPrivateKey.sing(signingString)}",'
          'version="1"',
    );
  }
}

/// Construir dados de autorização para o serviço [RenameObject]
extension RenameObjectMethod on ObjectStorage {
  /// Construir dados de autorização para o serviço [RenameObject]
  RenameObject renameObject({
    required RenameObjectDetails details,
    String? namespaceName,
    String? bucketName,
    DateTime? date,
    Map<String, String>? addHeaders,
  }) {
    return RenameObject(
      storage: storage,
      details: details,
      namespaceName: namespaceName,
      bucketName: bucketName,
      date: date,
      addHeaders: addHeaders,
    );
  }
}

/// https://docs.oracle.com/en-us/iaas/api/#/pt/objectstorage/20160918/datatypes/RenameObjectDetails
final class RenameObjectDetails implements Details<Map<String, String>> {
  const RenameObjectDetails._({
    required this.details,
    required this.json,
    required this.bytes,
    required this.xContentSha256,
  })  : contentType = 'application/json',
        bytesLength = bytes.length;

  @override
  final Map<String, String> details;

  @override
  final Uint8List bytes;

  @override
  final int bytesLength;

  @override
  final String contentType, json, xContentSha256;

  /// Para arquivos na raíz/root do bucker, basta apenas informar o nome do arquivo
  ///
  /// ex: fileName.jpg
  ///
  /// Para arquivos dentro de diretórios, informar a path do diretório + o nome do arquivo
  ///
  /// ex: users/profilePictures/fileName.jpg
  ///
  /// sourceName: users/profilePictures/fileName.jpg
  ///
  /// newName: users/profilePictures/newfileName.jpg
  ///
  /// [sourceName] o nome de arquivo existente
  ///
  /// [newName] novo nome para renomear o arquivo
  factory RenameObjectDetails({
    required String sourceName,
    required String newName,
    String? srcObjIfMatchETag,
    String? newObjIfMatchETag,
    String? newObjIfNoneMatchETag,
  }) {
    final Map<String, String> source = {
      'sourceName': sourceName,
      'newName': newName,
    };

    if (srcObjIfMatchETag is String && srcObjIfMatchETag.isNotEmpty) {
      source.putIfAbsent('srcObjIfMatchETag', () => srcObjIfMatchETag);
    }
    if (newObjIfMatchETag is String && newObjIfMatchETag.isNotEmpty) {
      source.putIfAbsent('newObjIfMatchETag', () => newObjIfMatchETag);
    }
    if (newObjIfNoneMatchETag is String && newObjIfNoneMatchETag.isNotEmpty) {
      source.putIfAbsent('newObjIfNoneMatchETag', () => newObjIfNoneMatchETag);
    }

    final String json = source.toJson;

    final Uint8List bytes = json.utf8ToBytes;

    return RenameObjectDetails._(
      details: source,
      json: json,
      bytes: bytes,
      xContentSha256: bytes.toSha256Base64,
    );
  }

  @override
  String toString() => '$runtimeType($details)'.replaceAll(RegExp('{|}'), '');
}
