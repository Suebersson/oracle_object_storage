## [GetObject](https://docs.oracle.com/en-us/iaas/api/#/pt/objectstorage/20160918/Object/GetObject)

```dart
final GetObject get = objectStorage.getObject(pathAndFileName: '/users/profilePictures/userId.jpg');

final http.Response response = await http.get(
  Uri.parse(get.uri),
  headers: get.headers,
);

print(response.statusCode); // esperado 200
```