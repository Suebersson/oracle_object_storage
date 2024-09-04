## [PutObjectLifecyclePolicy](https://docs.oracle.com/en-us/iaas/api/#/en/objectstorage/20160918/ObjectLifecyclePolicy/PutObjectLifecyclePolicy)

```dart
final PutObjectLifecyclePolicy put = storage.objectLifecyclePolicy.putObjectLifecyclePolicy(
    details: PutObjectLifecyclePolicyDetails([
      
      ObjectLifecycleRule(
        action: ObjectLifecycleRuleAction.DELETE, 
        isEnabled: true, 
        name: 'newLifecyclePolicyFromDart_DELETE', 
        timeUnit: ObjectLifecycleRuleTimeUnit.DAYS, 
        timeAmount: 25,
        target: ObjectLifecycleRuleTarget.objects,
        filter: ObjectNameFilter(
          exclusionPatterns: [
            'events/banners/*.png',
            'events/banners/*.jpeg',
            'events/banners/*.jpg',
          ],
        ),
      ),

      ObjectLifecycleRule(
        action: ObjectLifecycleRuleAction.ARCHIVE, 
        isEnabled: true, 
        name: 'newLifecyclePolicyFromDart_ARCHIVE', 
        timeUnit: ObjectLifecycleRuleTimeUnit.DAYS, 
        timeAmount: 30,
        target: ObjectLifecycleRuleTarget.objects,
        filter: ObjectNameFilter(
          inclusionPatterns: [
            'events/banners/*.png',
            'events/banners/*.jpeg',
            'events/banners/*.jpg',
          ],
        ),
      ),

      ObjectLifecycleRule.deleteMultipartUploadsWithoutCommit(
        name: 'newLifecyclePolicyFromDart_multipartUploads_ABORT', 
        days: 7,
      ),

    ]),
);

final http.Response response = await http.put(
  Uri.parse(put.uri),
  headers: put.headers,
  body: put.jsonBytes,
);

print(response.statusCode); // Status code esperado 200
print(response.body); // application-json
```