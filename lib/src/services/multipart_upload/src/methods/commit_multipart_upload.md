## [CommitMultipartUpload](https://docs.oracle.com/en-us/iaas/api/#/pt/objectstorage/20160918/MultipartUpload/CommitMultipartUpload)

```dart
final CommitMultipartUpload parts = storage.multipartUpload.commitMultipartUpload(
  objectName: '...',
  uploadId: '...',
  details: CommitMultipartUploadDetails(
    parts: [
      PartsToCommit(
        partNum: 1, 
        etag: '...',
      ),
      PartsToCommit(
        partNum: 2, 
        etag: '...',
      ),
      PartsToCommit(
        partNum: 3, 
        etag: '...',
      ),
    ],
  ),
);

final http.Response response = await http.post(
  Uri.parse(parts.uri),
  body: parts.jsonBytes,
  headers: parts.headers,
);

print(parts.publicUrlFile);
print(response.statusCode); // esperado 200
```