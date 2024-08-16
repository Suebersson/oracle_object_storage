# [![Oracle](https://raw.githubusercontent.com/Suebersson/oracle_object_storage/main/oracle.svg)](https://www.oracle.com/br/cloud/) Oracle Cloud Object Storage

[![sdk dart](https://img.shields.io/badge/SDK-Dart-blue.svg)](https://dart.dev/get-dart)
[![sdk flutter](https://img.shields.io/badge/SDK-Flutter-blue.svg)](https://docs.flutter.dev/get-started/install)
[![pub package](https://img.shields.io/pub/v/oracle_object_storage.svg?color=blue)](https://pub.dev/packages/oracle_object_storage)
[![popularity](https://img.shields.io/pub/popularity/oracle_object_storage?logo=dart)](https://pub.dev/packages/oracle_object_storage/score)
[![pub points](https://img.shields.io/pub/points/oracle_object_storage?logo=dart)](https://pub.dev/packages/oracle_object_storage/score)
[![License: BSD](https://img.shields.io/badge/license-BSD-blue.svg)](https://pub.dev/packages/oracle_object_storage/license)

Package para construir os headers necessários para [requisições](https://docs.oracle.com/en-us/iaas/Content/API/Concepts/signingrequests.htm#Request_Signatures) REST API através dos métodos de solicitações com base na [documentação](https://docs.oracle.com/en-us/iaas/api/#/pt/objectstorage/20160918/) para usar o serviço da Oracle Object Storage.

Como criar sua [chave de API](https://docs.oracle.com/en/learn/manage-oci-restapi/index.html#task-1-set-up-oracle-cloud-infrastructure-api-keys) para acesso ao bucker

## Formas de instânciar o objeto [OracleObjectStorage](https://docs.oracle.com/pt-br/iaas/Content/Object/Concepts/objectstorageoverview.htm) para requisições [REST API](https://docs.oracle.com/en/learn/manage-oci-restapi/index.html#introduction)

```dart
final OracleObjectStorage objectStorage = OracleObjectStorage(
  buckerNameSpace: '...', 
  buckerName: '...', 
  buckerRegion: '...', 
  tenancyOcid: 'ocid1.tenancy.oc1..aaaaa...', 
  userOcid: 'ocid1.user.oc1..aaaaaa...', 
  apiPrivateKey: ApiPrivateKey.fromValue(
    key: '''
  -----BEGIN PRIVATE KEY-----
    MIIEvAIBAD......JkvgJg4YINu72u7MQ==
  -----END PRIVATE KEY-----
      OCI_API_KEY
    ''', 
    fingerprint: 'od:b5:h6:44:1b:...'
  ),
);
```

```dart
final OracleObjectStorage objectStorage = OracleObjectStorage(
  buckerNameSpace: '...', 
  buckerName: '...', 
  buckerRegion: '...', 
  tenancyOcid: 'ocid1.tenancy.oc1..aaaa...', 
  userOcid: 'ocid1.user.oc1..aaaaaaa...', 
  apiPrivateKey: ApiPrivateKey.fromFile(
    fullPath: '.../.oci/private_key.pem',
    fingerprint: 'od:b5:h6:44:1b:...'
  ),
);
```

```dart
.../.oci/config.json
{
  "buckerNameSpace": "...",
  "buckerName": "...",
  "buckerRegion": "...",
  "userOcid": "ocid1.user.oc1..aaaaaa...",
  "fingerprint": "od:b5:h6:44:1b:...",
  "tenancyOcid": "ocid1.tenancy.oc1..aaaaa..."
}

final OracleObjectStorage objectStorage = OracleObjectStorage.fromConfig(
    configFullPath: '.../.oci/config.json',
    privateKeyFullPath: '.../.oci/private_key.pem'
);
```

## Ordem de como criar um arquivo em múltiplas partes/uploads

Métodos:

  1. [CreateMultipartUpload](https://pub.dev/packages/oracle_object_storage#CreateMultipartUpload)
  2. [UploadPart](https://pub.dev/packages/oracle_object_storage#UploadPart) {enviar o corpo/conteúdo/bytes do arquivo}
  3. [CommitMultipartUpload](https://pub.dev/packages/oracle_object_storage#CommitMultipartUpload) {finalizar/montar as partes enviadas para criar um único arquivo}

## [PutObject](https://docs.oracle.com/en-us/iaas/api/#/pt/objectstorage/20160918/Object/PutObject)

```dart
File file = File(".../fileNAme.jpg");

final Uint8List bytes = await file.readAsBytes();

final PutObject put = objectStorage.putObject(
  pathAndFileName: '/users/profilePictures/fileName.jpg',
  xContentSha256: bytes.toSha256Base64,
  contentLength: bytes.length.toString(),
  contentType: 'image/jpeg',
  addHeaders: <String, String>{
    'opc-meta-*': OpcMeta({
        'fileName': 'fileName.jpg',
        'expiryDate': DateTime.now().toString()
    }).metaFormat,
  }
);

final http.Response response = await http.put(
  Uri.parse(put.uri),
  body: bytes,
  headers: put.headers,
);

print(response.statusCode); // esperado 200
```

## [GetObject](https://docs.oracle.com/en-us/iaas/api/#/pt/objectstorage/20160918/Object/GetObject)

```dart
final GetObject get = objectStorage.getObject(pathAndFileName: '/users/profilePictures/fileName.jpg');

final http.Response response = await http.get(
  Uri.parse(get.uri),
  headers: get.headers,
);

print(response.statusCode); // esperado 200
```

## [HeadObject](https://docs.oracle.com/en-us/iaas/api/#/pt/objectstorage/20160918/Object/HeadObject)

```dart
final HeadObject head = objectStorage.headObject(pathAndFileName: '/users/profilePictures/fileName.jpg');

final http.Response response = await http.head(
  Uri.parse(head.uri),
  headers: head.headers,
);

print(response.statusCode); // esperado 200, 404 se o arquivo não existir
print(response.headers);
```

## [ListObjects](https://docs.oracle.com/en-us/iaas/api/#/pt/objectstorage/20160918/Object/ListObjects)

```dart
final ListObjects list = objectStorage.listObjects(
  query: Query({// parâmentro  opcional
    'limit': '2', // no máximo 2 objetos
  }),
);

final http.Response response = await http.get(
  Uri.parse(list.uri),
  headers: list.headers,
);

print(response.statusCode); // esperado 200
print(response.body);// esperado application-json
```

## [DeleteObject](https://docs.oracle.com/en-us/iaas/api/#/pt/objectstorage/20160918/Object/DeleteObject)

```dart
final DeleteObject delete = objectStorage
  .deleteObject(pathAndFileName: '/users/profilePictures/fileName.jpg');

final http.Response response = await http.delete(
  Uri.parse(delete.uri),
  headers: delete.headers,
);

// Status code esperado == 204 == objeto excluído com sucesso
print(response.statusCode);
```

## [RenameObject](https://docs.oracle.com/en-us/iaas/api/#/pt/objectstorage/20160918/Object/RenameObject)

```dart
final RenameObject rename = objectStorage.renameObject(
  details: RenameSourceObject(
    sourceName: 'users/profilePictures/fileName.jpg', 
    newName: 'users/profilePictures/anyName.jpg',
  ),
);

final http.Response response = await http.post(
  Uri.parse(rename.uri),
  body: rename.jsonBytes,
  headers: rename.headers,
);

print('\noldPublicUrlFile: ${rename.oldPublicUrlFile}\n\n');
print('newPublicUrlFile: ${rename.newPublicUrlFile}');
print(response.statusCode); // esperado 200
```

## [UpdateObjectStorageTier](https://docs.oracle.com/en-us/iaas/api/#/pt/objectstorage/20160918/Object/UpdateObjectStorageTier)

```dart
final UpdateObjectStorageTier updateObjectStorageTier = objectStorage.updateObjectStorageTier(
  details : ObjectStorageTier(
    objectName: 'image.jpg', 
    storageTier: StorageTier.InfrequentAccess
  ),
);

final http.Response response = await http.post(
  Uri.parse(updateObjectStorageTier.uri),
  body: updateObjectStorageTier.jsonBytes,
  headers: updateObjectStorageTier.headers,
);

print(response.statusCode); // esperado 200
```

## [RestoreObjects](https://docs.oracle.com/en-us/iaas/api/#/pt/objectstorage/20160918/Object/RestoreObjects)

```dart
final RestoreObjects restore = objectStorage.restore(
  details: RestoreObjectsSource(
    objectName: 'image.jpg', 
    hours: 120
  )
);

final http.Response response = await http.post(
  Uri.parse(restore.uri),
  body: restore.jsonBytes,
  headers: restore.headers,
);

print(response.statusCode); // esperado 200 ou 202
```

## [CopyObject](https://docs.oracle.com/en-us/iaas/api/#/pt/objectstorage/20160918/Object/CopyObject)

```dart
final CopyObject copy = objectStorage.copyObject(
    details: CopySourceObject(
      sourceObjectName: 'users/profilePictures/image.jpg', // arquivo a ser copiado
      destinationRegion: 'sa-saopaulo-1', // região do bucker para onde o arquivo será copiado
      destinationNamespace: '...', // nameSpace do bucker para onde o arquivo será copiado
      destinationBucket: 'BuckerName', // nome do bucker para onde o arquivo será copiado
      destinationObjectName: 'users/profilePictures/image.jpg', // para onde o arquivo será copiado
    ),
  );

final http.Response response = await http.post(
  Uri.parse(copy.uri),
  body: copy.jsonBytes,
  headers: copy.headers,
);

print('\npublicUrlOfCopiedFile: ${copy.publicUrlOfCopiedFile}\n');
print(response.statusCode); // esperado 202
```

## [CreateMultipartUpload](https://docs.oracle.com/en-us/iaas/api/#/pt/objectstorage/20160918/MultipartUpload/CreateMultipartUpload)

```dart
final CreateMultipartUpload create = objectStorage.createMultipartUpload(
  muiltiPartObjectName: 'users/profilePictures/object_file.jpg',
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

## [ListMultipartUploads](https://docs.oracle.com/en-us/iaas/api/#/pt/objectstorage/20160918/MultipartUpload/ListMultipartUploads)

```dart
final ListMultipartUploads list = objectStorage.listMultipartUploads(
  query: Query({// atributo  Opcional
    'limit': '5', // no máximo 5 objetos
  }),
);

final http.Response response = await http.get(
  Uri.parse(list.uri),
  headers: list.headers,
);

print(response.statusCode); // esperado 200
print(response.body);// esperado application-json
```


## [ListObjectVersions](https://docs.oracle.com/en-us/iaas/api/#/pt/objectstorage/20160918/Object/ListObjectVersions)

```dart
final ListObjectVersions list = objectStorage.listObjectVersions(
  query: Query({// parâmentro  opcional
    'limit': '10', // no máximo 10 objetos
    'prefix': 'events/banners/', // todos os objetos de uma pasta
    'fields': 'name,timeCreated', // apenas os campos especificos
  }),
);

final http.Response response = await http.get(
  Uri.parse(list.uri),
  headers: list.headers,
);

print(response.statusCode); // esperado 200
print(response.body);// esperado application-json
```

## [AbortMultipartUpload](https://docs.oracle.com/en-us/iaas/api/#/pt/objectstorage/20160918/MultipartUpload/AbortMultipartUpload)

```dart
final AbortMultipartUpload abort = objectStorage.abortMultipartUpload(
  muiltiPartObjectName: 'muiltPart/object_file.jpg',
  uploadId: '...',
);

final http.Response response = await http.delete(
  Uri.parse(abort.uri),
  headers: abort.headers,
);

// Status code esperado == 204 == operação multi part cancelada
print(response.statusCode);
```

## [ListMultipartUploadParts](https://docs.oracle.com/en-us/iaas/api/#/pt/objectstorage/20160918/MultipartUpload/ListMultipartUploadParts)

```dart
final ListMultipartUploadParts list = objectStorage.listMultipartUploadParts(
  pathAndFileName: 'object_file.jpg',
  query: Query({
    'uploadId': '892d7aa7b-69df-ea50-3b10-85djfad37095',
  }),
);

final http.Response response = await http.get(
  Uri.parse(list.uri),
  headers: list.headers,
);

print(response.statusCode); // esperado 200
print(response.body);// esperado application-json
```

## [CommitMultipartUpload](https://docs.oracle.com/en-us/iaas/api/#/pt/objectstorage/20160918/MultipartUpload/CommitMultipartUpload)

```dart
final CommitMultipartUpload parts = objectStorage.commitMultipartUpload(
  muiltiPartObjectName: '...',
  uploadId: '...',
  details: CommitMultipartUploadDetails(
    parts: [
      PartsToCommit(
        partNum: 1, 
        etag: '...',
      ),
      PartsToCommit(
        partNum: 2, 
        etag: '...',
      ),
      PartsToCommit(
        partNum: 3, 
        etag: '...',
      ),
    ],
  ),
);

final http.Response response = await http.post(
  Uri.parse(parts.uri),
  body: parts.jsonBytes,
  headers: parts.headers,
);

print(parts.publicUrlFile);
print(response.statusCode); // esperado 200
```

## [UploadPart](https://docs.oracle.com/en-us/iaas/api/#/pt/objectstorage/20160918/MultipartUpload/UploadPart)

```dart
final File file = File(".../fileName.jpg");

final Uint8List bytes = await file.readAsBytes();

final UploadPart uploadPart = objectStorage.uploadPart(
  uploadId: '...',
  uploadPartNum: 1,
  muiltiPartObjectName: '...',
  xContentSha256: bytes.toSha256Base64,
  contentLength: bytes.length.toString(),
  contentType: 'image/jpeg', //application/octet-stream
);

final http.Response response = await http.put(
  Uri.parse(uploadPart.uri),
  body: bytes,
  headers: uploadPart.headers,
);


print(response.statusCode);// esperado 200
print('etag: ${response.headers['etag'] ?? "undefined"}'); // esperado identificação do upload
```

<!-- ## [CreatePreauthenticatedRequest](https://docs.oracle.com/en-us/iaas/api/#/en/objectstorage/20160918/PreauthenticatedRequest/CreatePreauthenticatedRequest)

```dart

``` -->

## PreauthenticatedRequest
  - [CreatePreauthenticatedRequest](https://github.com/Suebersson/oracle_object_storage/blob/main/lib/src/preauthenticated_request/src/create_preauthenticated_request.md)
  - [DeletePreauthenticatedRequest]()
  - [GetPreauthenticatedRequest]()
  - [ListPreauthenticatedRequests]()