## [ListObjectVersions](https://pub.dev/packages/oracle_object_storage#ListObjectVersions)

```dart
final ListObjectVersions list = objectStorage.listObjectVersions(
  query: Query({// parâmentro  opcional
    'limit': '10', // no máximo 10 objetos
    'prefix': 'events/banners/', // todos os objetos de uma pasta
    'fields': 'name,timeCreated', // apenas os campos especificos
  }),
);

final http.Response response = await http.get(
  Uri.parse(list.uri),
  headers: list.headers,
);

print(response.statusCode); // esperado 200
print(response.body);// esperado application-json
```