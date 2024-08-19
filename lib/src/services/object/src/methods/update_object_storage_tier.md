## [UpdateObjectStorageTier](https://docs.oracle.com/en-us/iaas/api/#/pt/objectstorage/20160918/Object/UpdateObjectStorageTier)

```dart
final UpdateObjectStorageTier updateObjectStorageTier = storage.object
  .updateObjectStorageTier(
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