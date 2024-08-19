## [GetBucket](https://docs.oracle.com/en-us/iaas/api/#/en/objectstorage/20160918/Bucket/GetBucket)

```dart
final GetBucket get = storage.bucket.getBucket(
    bucketName: '...name',
    namespaceName: '...name',
);

final http.Response response = await http.get(
    Uri.parse(get.uri),
    headers: get.headers,
);

print(response.statusCode); // esperado 200
print(response.body); // esperado application/json
```