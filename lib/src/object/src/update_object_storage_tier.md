## [UpdateObjectStorageTier](https://pub.dev/packages/oracle_object_storage#UpdateObjectStorageTier)

```dart
final UpdateObjectStorageTier updateObjectStorageTier = objectStorage.updateObjectStorageTier(
  details : UpdateObjectStorageTierDetails (
    objectName: 'image.jpg', 
    storageTier: ObjectStorageTier.InfrequentAccess
  ),
);

final http.Response response = await http.post(
  Uri.parse(updateObjectStorageTier.uri),
  body: updateObjectStorageTier.jsonBytes,
  headers: updateObjectStorageTier.headers,
);

print(response.statusCode); // esperado 200
```