## [ListObjects](https://pub.dev/packages/oracle_object_storage#ListObjects)

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