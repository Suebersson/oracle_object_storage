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
  headers: put.header,
);

print(response.statusCode); // esperado 200
```

## [GetObject](https://docs.oracle.com/en-us/iaas/api/#/pt/objectstorage/20160918/Object/GetObject)

```dart
final GetObject get = objectStorage
  .getObject(pathAndFileName: '/users/profilePictures/fileName.jpg');

final http.Response response = await http.get(
  Uri.parse(get.uri),
  headers: get.header,
);

print(response.statusCode); // esperado 200
```

## [HeadObject](https://docs.oracle.com/en-us/iaas/api/#/pt/objectstorage/20160918/Object/HeadObject)

```dart
final HeadObject head = objectStorage
  .headObject(pathAndFileName: '/users/profilePictures/fileName.jpg');

final http.Response response = await http.head(
  Uri.parse(head.uri),
  headers: head.header,
);

print(response.statusCode); // esperado 200, 404 se o arquivo não existir
print(response.headers);
```

## [ListObjects](https://docs.oracle.com/en-us/iaas/api/#/pt/objectstorage/20160918/Object/ListObjects)

```dart
final ListObjects list = objectStorage.listObjects();

final http.Response response = await http.get(
  Uri.parse(list.uri),
  headers: list.header,
);

print(response.statusCode);// esperado 200
print(response.body);// json
```

## [DeleteObject](https://docs.oracle.com/en-us/iaas/api/#/pt/objectstorage/20160918/Object/DeleteObject)

```dart
final DeleteObject delete = objectStorage
  .deleteObject(pathAndFileName: '/users/profilePictures/fileName.jpg');

final http.Response response = await http.delete(
  Uri.parse(delete.uri),
  headers: delete.header,
);

// Status code esperado == 204 == objeto excluído com sucesso
print(response.statusCode);
```

## [RenameObject](https://docs.oracle.com/en-us/iaas/api/#/pt/objectstorage/20160918/Object/RenameObject)

```dart
final RenameObject rename = objectStorage.renameObject(
  sourceObject: RenameSourceObject(
    sourceName: 'users/profilePictures/fileName.jpg', 
    newName: 'users/profilePictures/anyName.jpg',
  ),
);

final http.Response response = await http.post(
  Uri.parse(rename.uri),
  body: rename.jsonBytes,
  headers: rename.header,
);

print('\noldPublicUrlFile: ${rename.oldPublicUrlFile}\n\n');
print('newPublicUrlFile: ${rename.newPublicUrlFile}');
print(response.statusCode); // esperado 200
```

## [UpdateObjectStorageTier](https://docs.oracle.com/en-us/iaas/api/#/pt/objectstorage/20160918/Object/UpdateObjectStorageTier)

```dart
final UpdateObjectStorageTier updateObjectStorageTier = objectStorage.updateObjectStorageTier(
  objectStorageTier: ObjectStorageTier(
    objectName: 'image.jpg', 
    storageTier: StorageTier.InfrequentAccess
  ),
);

final http.Response response = await http.post(
  Uri.parse(updateObjectStorageTier.uri),
  body: updateObjectStorageTier.jsonBytes,
  headers: updateObjectStorageTier.header,
);

print(response.statusCode); // esperado 200
```

## [RestoreObjects](https://docs.oracle.com/en-us/iaas/api/#/pt/objectstorage/20160918/Object/RestoreObjects)

```dart
final RestoreObjects restore = objectStorage.restore(
  restoreObjectsSource: RestoreObjectsSource(
    objectName: 'image.jpg', 
    hours: 120
  )
);

final http.Response response = await http.post(
  Uri.parse(restore.uri),
  body: restore.jsonBytes,
  headers: restore.header,
);

print(response.statusCode); // esperado 200 ou 202
```

## [CopyObject](https://docs.oracle.com/en-us/iaas/api/#/pt/objectstorage/20160918/Object/CopyObject)

```dart
final CopyObject copy = objectStorage.copyObject(
    sourceObject: CopySourceObject(
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
  headers: copy.header,
);

print('\npublicUrlOfCopiedFile: ${copy.publicUrlOfCopiedFile}\n');
print(response.statusCode); // esperado 202
```