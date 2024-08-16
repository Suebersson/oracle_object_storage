## [HeadObject](https://pub.dev/packages/oracle_object_storage#HeadObject)

```dart
final HeadObject head = objectStorage.headObject(pathAndFileName: '/users/profilePictures/userId.jpg');

final http.Response response = await http.head(
  Uri.parse(head.uri),
  headers: head.headers,
);

print(response.statusCode); // esperado 200, 404 se o arquivo não existir
print(response.headers);
```