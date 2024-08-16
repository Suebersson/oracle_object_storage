## [GetPreauthenticatedRequest](https://docs.oracle.com/en-us/iaas/api/#/en/objectstorage/20160918/PreauthenticatedRequest/GetPreauthenticatedRequest)

```dart
final GetPreauthenticatedRequest get = objectStorage.getPreauthenticatedRequest(
    parId: 'KjZkD2/MaoSecI+zDMX7ivFSzA6Wh+vv2fUjya1NfyMSTyU1DpRHjQPfk1Jce3Fb',
);

final http.Response response = await http.get(
    Uri.parse(get.uri),
    headers: get.headers,
);

print(response.statusCode); // esperado 200
print(response.body);
```