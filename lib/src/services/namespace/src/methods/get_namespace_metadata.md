## [GetNamespaceMetadata](https://docs.oracle.com/en-us/iaas/api/#/en/objectstorage/20160918/Namespace/GetNamespaceMetadata)

```dart
final GetNamespaceMetadata metadata = storage.namespace.getNamespaceMetadata();

final http.Response response = await http.get(
  Uri.parse(metadata.uri),
  headers: metadata.headers,
);

print(response.statusCode); // esperado 200 + application-json
print(response.body);
```