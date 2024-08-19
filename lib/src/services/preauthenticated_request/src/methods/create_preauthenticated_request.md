## [CreatePreauthenticatedRequest](https://docs.oracle.com/en-us/iaas/api/#/en/objectstorage/20160918/PreauthenticatedRequest/CreatePreauthenticatedRequest)

```dart
final CreatePreauthenticatedRequest create = storage.preauthenticatedRequest
  .createPreauthenticatedRequest(
    details: CreatePreauthenticatedRequestDetails(
      accessType: AccessType.AnyObjectRead,
      bucketListingAction: BucketListingAction.ListObjects,
      name: 'preauthenticatedNameFromDART', 
      timeExpires: DateTime.now().add(const Duration(days: 10)).toUtc().toIso8601String(),
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

  print('accessUri: ${json['accessUri'] ?? "undefined"}');
  print('id: ${json['id'] ?? "undefined"}');
  print('fullPath: ${json['fullPath'] ?? "undefined"}');

}
```