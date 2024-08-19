## [CopyObject](https://docs.oracle.com/en-us/iaas/api/#/pt/objectstorage/20160918/Object/CopyObject)

```dart
final CopyObject copy = storage.object.copyObject(
  details: CopyObjectDetails(
    sourceObjectName: 'users/profilePictures/image.jpg', // arquivo a ser copiado
    destinationRegion: 'sa-saopaulo-1', // região do bucker para onde o arquivo será copiado
    destinationNamespace: '...', // nameSpace do bucker para onde o arquivo será copiado
    destinationBucket: 'BuckerName', // nome do bucker para onde o arquivo será copiado
    destinationObjectName: 'users/profilePictures/image.jpg', // para onde o arquivo será copiado
  ),
);

final http.Response response = await http.post(
  Uri.parse(copy.uri),
  body: copy.jsonBytes,
  headers: copy.headers,
);

print('\npublicUrlOfCopiedFile: ${copy.publicUrlOfCopiedFile}\n');
print(response.statusCode); // esperado 202
```