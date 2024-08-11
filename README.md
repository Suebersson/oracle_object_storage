## Métodos disponíveis

- PutObject
- GetObject
- HeadObject
- ListObjects
- DeleteObject
- RenameObject
- UpdateObjectStorageTier
- RestoreObjects
- CopyObject

## Formar de instânciar o objeto [OracleObjectStorage]

```
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

```
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

```
Referência:
https://docs.oracle.com/en-us/iaas/Content/API/Concepts/sdkconfig.htm#SDK_and_CLI_Configuration_File

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