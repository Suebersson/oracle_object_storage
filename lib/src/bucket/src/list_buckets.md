## [ListBuckets](https://docs.oracle.com/en-us/iaas/api/#/en/objectstorage/20160918/Bucket/ListBuckets)

```dart
final ListBuckets list = objectStorage.listBuckets(
  query: const Query({
    // 'compartmentId': 'ocid1.tenancy.oc1..aaa...', // obrigatório, mas pode ser omitido
    'limit': '2', // opcional, no máximo 2 buckets
  }),
);

final http.Response response = await http.get(
  Uri.parse(list.uri),
  headers: list.headers,
);

print(response.statusCode); // esperado 200
print(response.body);// esperado application-json
```