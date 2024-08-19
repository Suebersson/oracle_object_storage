## [UpdateNamespaceMetadata](https://docs.oracle.com/en-us/iaas/api/#/en/objectstorage/20160918/Namespace/UpdateNamespaceMetadata)

```dart
final UpdateNamespaceMetadata update = storage.namespace.updateNamespaceMetadata(
  details : UpdateNamespaceMetadataDetails(
    defaultS3CompartmentId: 'ocid1.tenancy.oc1..aaa...',
    defaultSwiftCompartmentId: 'ocid1.tenancy.oc1..aaa...',
  ),
);

final http.Response response = await http.put(
  Uri.parse(update.uri),
  body: update.jsonBytes,
  headers: update.headers,
);

print(response.statusCode); // esperado 200 + application-json
print(response.body);
```