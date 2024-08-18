## [DeleteObject](https://docs.oracle.com/en-us/iaas/api/#/pt/objectstorage/20160918/Object/DeleteObject)

```dart
final DeleteObject delete = objectStorage
  .deleteObject(pathAndFileName: '/users/profilePictures/userId.jpg');

final http.Response response = await http.delete(
  Uri.parse(delete.uri),
  headers: delete.headers,
);

// Status code esperado == 204 == objeto excluído com sucesso
print(response.statusCode);
```