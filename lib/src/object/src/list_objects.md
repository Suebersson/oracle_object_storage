## [ListObjects](https://docs.oracle.com/en-us/iaas/api/#/pt/objectstorage/20160918/Object/ListObjects)

```dart
final ListObjects list = objectStorage.listObjects(
  query: const Query({// parâmentro  opcional
    'limit': '2', // no máximo 2 objetos
  }),
);

final http.Response response = await http.get(
  Uri.parse(list.uri),
  headers: list.headers,
);

print(response.statusCode); // esperado 200
print(response.body);// esperado application-json
```