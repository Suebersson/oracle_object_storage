## [GetObject](https://pub.dev/packages/oracle_object_storage#GetObject)

```dart
final GetObject get = objectStorage.getObject(pathAndFileName: '/users/profilePictures/userId.jpg');

final http.Response response = await http.get(
  Uri.parse(get.uri),
  headers: get.headers,
);

print(response.statusCode); // esperado 200
```