  ## [DeletePreauthenticatedRequest](https://docs.oracle.com/en-us/iaas/api/#/pt/objectstorage/20160918/PreauthenticatedRequest/DeletePreauthenticatedRequest)

  ```dart
  final DeletePreauthenticatedRequest delete = storage.preauthenticatedRequest
    .deletePreauthenticatedRequest(
      parId: 'EiMeeRZs6FaPWBu8bDS3jXVf/NvZlfE4trI89kvUOygVUA/Hko+t8V2vKUy0k5I1',
    );

  final http.Response response = await http.delete(
    Uri.parse(delete.uri),
    headers: delete.headers,
  );

  // Status code esperado == 200 ou 204 == autenticação excluída com sucesso
  print(response.statusCode);
  ```