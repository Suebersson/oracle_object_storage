## [DeleteBucket](https://docs.oracle.com/en-us/iaas/api/#/en/objectstorage/20160918/Bucket/DeleteBucket)

```dart
final DeleteBucket delete = objectStorage.deleteBucket(
  bucketName: 'deletedFromDart',
);

final http.Response response = await http.delete(
  Uri.parse(delete.uri),
  headers: delete.headers,
);

// Status code esperado == 204 == bucket excluído com sucesso
print(response.statusCode);
```