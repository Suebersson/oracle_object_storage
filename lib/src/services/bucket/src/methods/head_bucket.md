## [HeadBucket](https://docs.oracle.com/en-us/iaas/api/#/en/objectstorage/20160918/Bucket/HeadBucket)

```dart
final HeadBucket head = storage.bucket.headBucket();

final http.Response response = await http.head(
    Uri.parse(head.uri),
    headers: head.headers,
);

print(response.statusCode);// esperado 200, 404 se o arquivo não existir
print(response.headers);
```