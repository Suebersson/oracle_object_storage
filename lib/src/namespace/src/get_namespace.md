## [GetNamespace](https://docs.oracle.com/en-us/iaas/api/#/en/objectstorage/20160918/Namespace/GetNamespace)

```dart
final GetNamespace namespace = objectStorage.getNamespace();

final http.Response response = await http.get(
  Uri.parse(namespace.uri),
  headers: namespace.headers,
);

print(response.statusCode); // esperado 200 + application-json
print(response.body);
```