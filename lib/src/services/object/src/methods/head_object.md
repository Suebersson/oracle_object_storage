## [HeadObject](https://docs.oracle.com/en-us/iaas/api/#/pt/objectstorage/20160918/Object/HeadObject)

```dart
final HeadObject head = storage.object
  .headObject(pathAndFileName: '/users/profilePictures/userId.jpg');

final http.Response response = await http.head(
  Uri.parse(head.uri),
  headers: head.headers,
);

print(response.statusCode); // esperado 200, 404 se o arquivo não existir
print(response.headers);
```