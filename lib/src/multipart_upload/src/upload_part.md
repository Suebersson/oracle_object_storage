## [UploadPart](https://docs.oracle.com/en-us/iaas/api/#/pt/objectstorage/20160918/MultipartUpload/UploadPart)

```dart
final File file = File(".../fileName.jpg");

final Uint8List bytes = await file.readAsBytes();

final UploadPart uploadPart = objectStorage.uploadPart(
  uploadId: '...',
  uploadPartNum: 1,
  muiltiPartObjectName: '...',
  xContentSha256: bytes.toSha256Base64,
  contentLength: bytes.length.toString(),
  contentType: 'image/jpeg', //application/octet-stream
);

final http.Response response = await http.put(
  Uri.parse(uploadPart.uri),
  body: bytes,
  headers: uploadPart.headers,
);

print(response.statusCode);// esperado 200
print('etag: ${response.headers['etag'] ?? "undefined"}'); // esperado identificação do upload
```