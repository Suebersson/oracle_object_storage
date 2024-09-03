## [GetObjectLifecyclePolicy](https://docs.oracle.com/en-us/iaas/api/#/en/objectstorage/20160918/ObjectLifecyclePolicy/GetObjectLifecyclePolicy)

```dart
final GetObjectLifecyclePolicy lifecycle = storage.objectLifecyclePolicy.getObjectLifecyclePolicy();

final http.Response response = await http.get(
  Uri.parse(lifecycle.uri),
  headers: lifecycle.headers,
);

print(response.statusCode); // esperado 200 + application-json
print(response.body);
```