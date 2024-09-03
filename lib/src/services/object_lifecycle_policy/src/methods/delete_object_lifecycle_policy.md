## [DeleteObjectLifecyclePolicy](https://docs.oracle.com/en-us/iaas/api/#/en/objectstorage/20160918/ObjectLifecyclePolicy/DeleteObjectLifecyclePolicy)

```dart
final DeleteObjectLifecyclePolicy delete = storage.objectLifecyclePolicy.deleteObjectLifecyclePolicy();

final http.Response response = await http.delete(
  Uri.parse(delete.uri),
  headers: delete.headers,
);

// Status code esperado == 204 == política de ciclo de vida excluída com sucesso
print(response.statusCode);
```