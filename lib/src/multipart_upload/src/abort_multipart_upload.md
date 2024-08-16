## [AbortMultipartUpload](https://docs.oracle.com/en-us/iaas/api/#/pt/objectstorage/20160918/MultipartUpload/AbortMultipartUpload)

```dart
  final AbortMultipartUpload abort = objectStorage.abortMultipartUpload(
    muiltiPartObjectName: 'muiltPart/object_file.jpg',
    uploadId: '...',
  );

  final http.Response response = await http.delete(
    Uri.parse(abort.uri),
    headers: abort.headers,
  );

  // Status code esperado == 204 == operação multi part cancelada
  print(response.statusCode);
```