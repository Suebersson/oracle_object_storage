## [UpdateBucket](https://docs.oracle.com/en-us/iaas/api/#/en/objectstorage/20160918/Bucket/UpdateBucket)

```dart
final UpdateBucket update = storage.bucket.updateBucket(
  bucketName: 'newBucketCreatedFromDart',
  details: UpdateBucketDetails(
    compartmentId: 'ocid1.tenancy.oc1..aaaa...', // opicional
    objectEventsEnabled: false, // opicional
    publicAccessType: PublicAccessType.NoPublicAccess, // opicional
  ),
);

final http.Response response = await http.post(
  Uri.parse(update.uri),
  body: update.jsonBytes,
  headers: update.headers,
);

print(response.statusCode);// esperado 200 + application-json
print(response.body);
```