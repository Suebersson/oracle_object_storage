## [CreateBucket](https://docs.oracle.com/en-us/iaas/api/#/en/objectstorage/20160918/Bucket/CreateBucket)

```dart
final CreateBucket create = objectStorage.createBucket(
  details: CreateBucketDetails(
    compartmentId: 'ocid1.tenancy.oc1..aaaa...', 
    name: 'newBucketCreatedFromDart',
    objectEventsEnabled: true, // opicional
    publicAccessType: PublicAccessType.ObjectReadWithoutList, // opicional
  ),
);

final http.Response response = await http.post(
  Uri.parse(create.uri),
  body: create.jsonBytes,
  headers: create.headers,
);

print(response.statusCode);// esperado 200 + application-json
print(response.body);
```