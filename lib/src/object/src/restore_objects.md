## [RestoreObjects](https://pub.dev/packages/oracle_object_storage#RestoreObjects)

```dart
final RestoreObjects restoreObjects = objectStorage.restoreObjects(
  details: RestoreObjectsDetails(
    objectName: 'image.jpg', 
    hours: 120
  )
);

final http.Response response = await http.post(
  Uri.parse(restoreObjects.uri),
  body: restoreObjects.jsonBytes,
  headers: restoreObjects.headers,
);

print(response.statusCode); // esperado 200 ou 202
```