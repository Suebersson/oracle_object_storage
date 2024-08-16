## [ListMultipartUploadParts](https://docs.oracle.com/en-us/iaas/api/#/pt/objectstorage/20160918/Object/ListMultipartUploadParts)

```dart
final ListMultipartUploadParts list = objectStorage.listMultipartUploadParts(
  muiltiPartObjectName: 'object_file.jpg',
  query: Query({
    'uploadId': '892d7aa7b-69df-ea50-3b10-85djfad37095',
  }),
);

final http.Response response = await http.get(
  Uri.parse(list.uri),
  headers: list.headers,
);

print(response.statusCode); // esperado 200
print(response.body);// esperado application-json
```