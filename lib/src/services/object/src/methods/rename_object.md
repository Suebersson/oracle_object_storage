## [RenameObject](https://docs.oracle.com/en-us/iaas/api/#/pt/objectstorage/20160918/Object/RenameObject)

```dart
final RenameObject rename = storage.object.renameObject(
  details: RenameObjectDetails(
    sourceName: 'users/profilePictures/userId.jpg', 
    newName: 'users/profilePictures/fileName.jpg',
  ),
);

final http.Response response = await http.post(
  Uri.parse(rename.uri),
  body: rename.jsonBytes,
  headers: rename.headers,
);

print('\noldPublicUrlFile: ${rename.oldPublicUrlFile}\n\n');
print('newPublicUrlFile: ${rename.newPublicUrlFile}');
print(response.statusCode); // esperado 200
```