## [RestoreObjects](https://docs.oracle.com/en-us/iaas/api/#/pt/objectstorage/20160918/Object/RestoreObjects)

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