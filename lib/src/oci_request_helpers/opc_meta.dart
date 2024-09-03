import '../converters.dart';

/// Criar metadados no formato OCI
///
/// https://docs.oracle.com/en-us/iaas/Content/Object/Tasks/managingobjects.htm#HeadersAndMetadata
///
/// https://docs.oracle.com/en-us/iaas/Content/Object/Tasks/usingpreauthenticatedrequests_topic-Working_with_PreAuthenticated_Requests.htm#To_put_an_object_with_metadata
final class OpcMeta {
  /// Criar metadados no formato OCI
  const OpcMeta(this.metadata);

  final Map<String, String> metadata;

  String get jsonFormat => metadata.toJson;

  String get metaFormat {
    return metadata.entries.fold('', (previousValue, entry) {
      if (previousValue.isNotEmpty) {
        return '$previousValue, opc-meta-${entry.key}:${entry.value}';
      } else {
        return 'opc-meta-${entry.key}:${entry.value}';
      }
    });
  }

  String get join {
    return metadata.entries.fold('', (previousValue, entry) {
      if (previousValue.isNotEmpty) {
        return '$previousValue, ${entry.key}:${entry.value}';
      } else {
        return '${entry.key}:${entry.value}';
      }
    });
  }
  
}
