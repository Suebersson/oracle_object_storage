## [ListMultipartUploads](https://docs.oracle.com/en-us/iaas/api/#/pt/objectstorage/20160918/MultipartUpload/ListMultipartUploads)

```dart
final ListMultipartUploads list = objectStorage.listMultipartUploads(
  query: const Query({// atributo  Opcional
    'limit': '5', // no máximo 5 objetos
  }),
);

final http.Response response = await http.get(
  Uri.parse(list.uri),
  headers: list.headers,
);

print(response.statusCode); // esperado 200
print(response.body);// esperado application-json
```