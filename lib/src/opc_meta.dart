part of '../oracle_object_storage.dart';

// https://docs.oracle.com/en-us/iaas/Content/Object/Tasks/managingobjects.htm#HeadersAndMetadata
// https://docs.oracle.com/en-us/iaas/Content/Object/Tasks/usingpreauthenticatedrequests_topic-Working_with_PreAuthenticated_Requests.htm#To_put_an_object_with_metadata

final class OpcMeta {
  
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

}