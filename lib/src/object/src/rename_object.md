## [RenameObject](https://pub.dev/packages/oracle_object_storage#RenameObject)

```dart
final RenameObject rename = objectStorage.renameObject(
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