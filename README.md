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

## Object
- [CopyObject](https://github.com/Suebersson/oracle_object_storage/blob/main/lib/src/object/src/copy_object.md)
- [DeleteObject](https://github.com/Suebersson/oracle_object_storage/blob/main/lib/src/object/src/delete_object.md)
- [GetObject](https://github.com/Suebersson/oracle_object_storage/blob/main/lib/src/object/src/get_object.md)
- [HeadObject](https://github.com/Suebersson/oracle_object_storage/blob/main/lib/src/object/src/head_object.md)
- [ListObjectVersions](https://github.com/Suebersson/oracle_object_storage/blob/main/lib/src/object/src/list_object_versions.md)
- [ListObjects](https://github.com/Suebersson/oracle_object_storage/blob/main/lib/src/object/src/list_objects.md)
- [PutObject](https://github.com/Suebersson/oracle_object_storage/blob/main/lib/src/object/src/put_object.md)
- [RenameObject](https://github.com/Suebersson/oracle_object_storage/blob/main/lib/src/object/src/rename_object.md)
- [RestoreObjects](https://github.com/Suebersson/oracle_object_storage/blob/main/lib/src/object/src/restore_objects.md)
- [UpdateObjectStorageTier](https://github.com/Suebersson/oracle_object_storage/blob/main/lib/src/object/src/update_object_storage_tier.md)


## MultipartUpload
- [CreateMultipartUpload](https://github.com/Suebersson/oracle_object_storage/blob/main/lib/src/multipart_upload/src/create_multipart_upload.md)
- [AbortMultipartUpload](https://github.com/Suebersson/oracle_object_storage/blob/main/lib/src/multipart_upload/src/abort_multipart_upload.md)
- [CommitMultipartUpload](https://github.com/Suebersson/oracle_object_storage/blob/main/lib/src/multipart_upload/src/commit_multipart_upload.md)
- [ListMultipartUploadParts](https://github.com/Suebersson/oracle_object_storage/blob/main/lib/src/multipart_upload/src/list_multipart_upload_parts.md)
- [ListMultipartUploads](https://github.com/Suebersson/oracle_object_storage/blob/main/lib/src/multipart_upload/src/list_multipart_uploads.md)
- [UploadPart](https://github.com/Suebersson/oracle_object_storage/blob/main/lib/src/multipart_upload/src/upload_part.md)

Ordem de como criar um arquivo em múltiplas partes/uploads:

  1. [CreateMultipartUpload](https://pub.dev/packages/oracle_object_storage#CreateMultipartUpload)
  2. [UploadPart](https://pub.dev/packages/oracle_object_storage#UploadPart) {enviar o corpo/conteúdo/bytes do arquivo}
  3. [CommitMultipartUpload](https://pub.dev/packages/oracle_object_storage#CommitMultipartUpload) {finalizar/montar as partes enviadas para criar um único arquivo}


## PreauthenticatedRequest
  - [CreatePreauthenticatedRequest](https://github.com/Suebersson/oracle_object_storage/blob/main/lib/src/preauthenticated_request/src/create_preauthenticated_request.md)
  - [DeletePreauthenticatedRequest](https://github.com/Suebersson/oracle_object_storage/blob/main/lib/src/preauthenticated_request/src/delete_preauthenticated_request.md)
  - [GetPreauthenticatedRequest](https://github.com/Suebersson/oracle_object_storage/blob/main/lib/src/preauthenticated_request/src/get_preauthenticated_request.md)
  - [ListPreauthenticatedRequests](https://github.com/Suebersson/oracle_object_storage/blob/main/lib/src/preauthenticated_request/src/list_preauthenticated_requests.md)