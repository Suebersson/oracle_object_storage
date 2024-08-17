## [ListPreauthenticatedRequests](https://docs.oracle.com/en-us/iaas/api/#/en/objectstorage/20160918/PreauthenticatedRequest/ListPreauthenticatedRequests)

```dart
final ListPreauthenticatedRequests list = objectStorage.listPreauthenticatedRequests(
    query: const Query({// parâmentro  opcional
        'limit': '1', // no máximo 10 objetos
        'objectNamePrefix': 'events/banners/', // todos os objetos de uma pasta
    }),
);

final http.Response response = await http.get(
    Uri.parse(list.uri),
    headers: list.headers,
);

print(response.statusCode); // esperado 200
print(response.body);// esperado application-json
```