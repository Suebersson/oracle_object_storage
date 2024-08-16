## [PutObject](https://pub.dev/packages/oracle_object_storage#PutObject)

```dart
File file = File(".../fileNAme.jpg");

final Uint8List bytes = await file.readAsBytes();

final PutObject put = objectStorage.putObject(
  pathAndFileName: '/users/profilePictures/userId.jpg',
  xContentSha256: bytes.toSha256Base64,
  contentLength: bytes.length.toString(),
  contentType: 'image/jpeg',
  addHeaders: <String, String>{
    'opc-meta-*': OpcMeta({ // opcional
        'fileName': 'fileName.jpg',
        'expiryDate': DateTime.now().toString()
    }).metaFormat,
  }
);

final http.Response response = await http.put(
  Uri.parse(put.uri),
  body: bytes,
  headers: put.headers,
);

print(response.statusCode); // esperado 200
print(response.headers.toString());
```