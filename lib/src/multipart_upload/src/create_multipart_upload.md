## [CreateMultipartUpload](https://docs.oracle.com/en-us/iaas/api/#/pt/objectstorage/20160918/MultipartUpload/CreateMultipartUpload)

```dart
final CreateMultipartUpload create = objectStorage.createMultipartUpload(
  details: CreateMultipartUploadDetails(
    objectName: 'users/object_file.jpg',
    contentType: 'image/jpeg',
  ),
);

final http.Response response = await http.post(
  Uri.parse(create.uri),
  body: create.jsonBytes,
  headers: create.headers,
);

print(response.statusCode); // esperado 200 + application-json

final Map<String, dynamic> json = {};

if (response.statusCode == 200) {
  
  json.addAll(jsonDecode(response.body));

  print('uploadId: ${json['uploadId'] ?? "undefined"}');

}
```