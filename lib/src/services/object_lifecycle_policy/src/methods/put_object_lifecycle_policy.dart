// ignore_for_file: constant_identifier_names
import 'dart:typed_data' show Uint8List;

import '../../../../converters.dart';
import '../../../../interfaces/details.dart';
import '../../../../interfaces/oracle_request_attributes.dart';
import '../../../../oracle_object_storage.dart';
import '../../../../oracle_object_storage_exeception.dart';
import '../object_lifecycle_policy.dart';

/// https://docs.oracle.com/en-us/iaas/api/#/en/objectstorage/20160918/ObjectLifecyclePolicy/PutObjectLifecyclePolicy
///
/// Este método irá adicionar as novas políticas senão existir nenhuma
/// 
/// Caso exista alguma política, irá reescrever/substituir pelas novas políticas enviadas 
final class PutObjectLifecyclePolicy implements OracleRequestAttributes {
  
  const PutObjectLifecyclePolicy._({
    required this.uri,
    required this.date,
    required this.authorization,
    required this.host,
    required this.xContentSha256,
    required this.contentLegth,
    required this.contentType,
    required this.jsonBytes,
    required this.jsonData,
    this.addHeaders,
  });

  @override
  final String uri, date, authorization, host;

  final String jsonData, xContentSha256, contentLegth, contentType;

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

  /// https://docs.oracle.com/en-us/iaas/api/#/en/objectstorage/20160918/ObjectLifecyclePolicy/PutObjectLifecyclePolicy
  ///
  /// Este método irá adicionar as novas políticas senão existir nenhuma
  /// 
  /// Caso exista alguma política, irá reescrever/substituir pelas novas políticas enviadas
  factory PutObjectLifecyclePolicy({
    required OracleObjectStorage storage,
    required PutObjectLifecyclePolicyDetails details,
    String? namespaceName,
    String? bucketName,
    DateTime? date,
    Map<String, String>? addHeaders,
  }) {

    final String dateString = OracleObjectStorage.getDateRCF1123(date);

    /*
      # Modelo para string de assinatura para o método [put] ou [post]

      (request-target): <METHOD> /n/{namespaceName}/b/{bucketName}/l\n
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

    final String request = '/n/$namespaceName/b/$bucketName/l';

    final String signingString = '(request-target): put $request\n'
      'date: $dateString\n'
      'host: ${storage.host}\n'
      'x-content-sha256: ${details.xContentSha256}\n'
      'content-type: ${details.contentType}\n'
      'content-length: ${details.bytesLength}';

    return PutObjectLifecyclePolicy._(
      uri: '${storage.apiUrlOrigin}$request',
      date: dateString,
      host: storage.host,
      xContentSha256: details.xContentSha256,
      contentType: details.contentType,
      contentLegth: '${details.bytesLength}',
      addHeaders: addHeaders,
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

/// Construir dados de autorização para o serviço [PutObjectLifecyclePolicy]
///
/// Este método irá adicionar as novas políticas senão existir nenhuma
/// 
/// Caso exista alguma política, irá reescrever/substituir pelas novas políticas enviadas  
extension PutObjectLifecyclePolicyMethod on ObjectLifecyclePolicy {
  /// Construir dados de autorização para o serviço [PutObjectLifecyclePolicy]
  /// Este método irá adicionar as novas políticas senão existir nenhuma
  /// 
  /// Caso exista alguma política, irá reescrever/substituir pelas novas políticas enviadas 
  PutObjectLifecyclePolicy putObjectLifecyclePolicy({
    required PutObjectLifecyclePolicyDetails details,
    String? namespaceName,
    String? bucketName,
    DateTime? date,
    Map<String, String>? addHeaders,
  }) {
    return PutObjectLifecyclePolicy(
      storage: storage,
      details: details,
      namespaceName: namespaceName,
      bucketName: bucketName,
      date: date,
      addHeaders: addHeaders,
    );
  }
}

/// https://docs.oracle.com/en-us/iaas/api/#/en/objectstorage/20160918/datatypes/PutObjectLifecyclePolicyDetails
final class PutObjectLifecyclePolicyDetails implements Details<Map<String, dynamic>> {

  const PutObjectLifecyclePolicyDetails._({
    required this.details,
    required this.json,
    required this.bytes,
    required this.xContentSha256,
  }) : contentType = 'application/json', bytesLength = bytes.length;

  @override
  final Map<String, dynamic> details;

  @override
  final Uint8List bytes;

  @override
  final int bytesLength;

  @override
  final String contentType, json, xContentSha256;

  factory PutObjectLifecyclePolicyDetails(List<ObjectLifecycleRule> rules) {

    final Map<String, dynamic> source = {'items': rules};

    final String json = source.toJson;

    final Uint8List bytes = json.utf8ToBytes;

    return PutObjectLifecyclePolicyDetails._(
      details: source,
      json: json,
      bytes: bytes,
      xContentSha256: bytes.toSha256Base64,
    );

  }

  @override
  String toString() => '$runtimeType($details)'.replaceAll(RegExp('{|}'), '');

}

/// https://docs.oracle.com/en-us/iaas/api/#/en/objectstorage/20160918/datatypes/ObjectLifecycleRule
final class ObjectLifecycleRule {

  final ObjectLifecycleRuleAction action;
  final bool isEnabled;
  final String name;
  final ObjectLifecycleRuleTimeUnit timeUnit;
  final int timeAmount;
  final ObjectNameFilter? filter;
  final ObjectLifecycleRuleTarget? target;

  const ObjectLifecycleRule({
    required this.action, 
    required this.isEnabled, 
    required this.name, 
    required this.timeUnit, 
    required this.timeAmount, 
    this.filter, 
    this.target,
  });

  factory ObjectLifecycleRule.deleteMultipartUploadsWithoutCommit({
    bool isEnabled = true, 
    required String name, 
    required int days, 
  }) {
    return ObjectLifecycleRule(
      action: ObjectLifecycleRuleAction.ABORT, 
      timeUnit: ObjectLifecycleRuleTimeUnit.DAYS, 
      target: ObjectLifecycleRuleTarget.multipartUploads,
      isEnabled: isEnabled, 
      name: name, 
      timeAmount: days,
    );
  }

  Map<String, dynamic> get encodeableToJson {

    final Map<String, dynamic> rule = {
      'action': action.toString(),
      'isEnabled': isEnabled,
      'name': name,
      'timeAmount': timeAmount,
      'timeUnit': timeUnit.toString(), 
    };

    if (filter is ObjectNameFilter) {
      rule.addAll({'objectNameFilter': filter});
    }

    if (target is ObjectLifecycleRuleTarget) {
      rule.addAll({'target': target?.target ?? ObjectLifecycleRuleTarget.objects.target});
    }

    return rule;

  }

  String get toJson => encodeableToJson.toJson;

  @override
  String toString() => '$runtimeType($encodeableToJson)'.replaceAll(RegExp('{|}'), '');

}

/// https://docs.oracle.com/en-us/iaas/api/#/en/objectstorage/20160918/datatypes/ObjectNameFilter
final class ObjectNameFilter {

  const ObjectNameFilter._({
    this.exclusionPatterns, 
    this.inclusionPatterns, 
    this.inclusionPrefixes,
  });
  
  final List<String>? 
    exclusionPatterns,
    inclusionPatterns,
    inclusionPrefixes;

  factory ObjectNameFilter({
    List<String>? exclusionPatterns, 
    List<String>? inclusionPatterns, 
    List<String>? inclusionPrefixes,
  }) {

    if (exclusionPatterns is List<String> && exclusionPatterns.length > 1000) {
      throw const OracleObjectStorageExeception(
        'Limite máximo para o padrão de filtro[exclusionPatterns]: 1000',
      );
    }

    if (inclusionPatterns is List<String> && inclusionPatterns.length > 1000) {
      throw const OracleObjectStorageExeception(
        'Limite máximo para o padrão de filtro[inclusionPatterns]: 1000',
      );
    }

    return ObjectNameFilter._(
      exclusionPatterns: exclusionPatterns, 
      inclusionPatterns: inclusionPatterns, 
      inclusionPrefixes: inclusionPrefixes,
    );

  }

  Map<String, List<String>> get encodeableToJson {

    final Map<String, List<String>> filters = {};

    if (exclusionPatterns is List<String>) {
      filters.addAll({'exclusionPatterns': exclusionPatterns ?? []});
    }
    if (inclusionPatterns is List<String>) {
      filters.addAll({'inclusionPatterns': inclusionPatterns ?? []});
    }
    if (inclusionPrefixes is List<String>) {
      filters.addAll({'inclusionPrefixes': inclusionPrefixes ?? []});
    }

    return filters;

  }

  String get toJson => encodeableToJson.toJson;

  @override
  String toString() => '$runtimeType($encodeableToJson})'.replaceAll(RegExp('{|}'), '');

}

/// https://docs.oracle.com/en-us/iaas/api/#/en/objectstorage/20160918/datatypes/ObjectLifecycleRule
enum ObjectLifecycleRuleAction {
  ARCHIVE,
  DELETE,
  ABORT,
  INFREQUENT_ACCESS;

  @override
  String toString() => name;

}

/// https://docs.oracle.com/en-us/iaas/api/#/en/objectstorage/20160918/datatypes/ObjectLifecycleRule
enum ObjectLifecycleRuleTimeUnit {
  DAYS,
  YEARS;

  @override
  String toString() => name;

}

/// https://docs.oracle.com/en-us/iaas/api/#/en/objectstorage/20160918/datatypes/ObjectLifecycleRule
enum ObjectLifecycleRuleTarget {
  objects('objects'),
  multipartUploads('multipart-uploads'),
  previousObjectVersions('previous-object-versions');

  const ObjectLifecycleRuleTarget(this.target);
  final String target;

  @override
  String toString() => target;

}