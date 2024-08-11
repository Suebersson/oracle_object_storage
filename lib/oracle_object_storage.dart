import 'dart:io' show File;
import 'dart:convert' as convert;
import 'dart:typed_data' show Uint8List;
import 'dart:developer' show log;
import 'package:intl/intl.dart';
import 'package:pointycastle/digests/sha256.dart' show SHA256Digest;

import './src/request_signing_service.dart';

part './src/private_key.dart';
part './src/objects/delete_object.dart';
part './src/objects/get_object.dart';
part './src/objects/head_object.dart';
part './src/objects/list_objects.dart';
part './src/objects/put_object.dart';
part './src/oracle_object_storage_exeception.dart';
part './src/object_attributes.dart';
part './src/objects/rename_object.dart';
part './src/objects/copy_object.dart';
part './src/objects/update_object_storage_tier.dart';
part './src/objects/restore_objects.dart';
part './src/converters.dart';
part './src/opc_meta.dart';

final class OracleObjectStorage {

  // Referências:
  // https://docs.oracle.com/en-us/iaas/Content/Object/Tasks/managingobjects.htm
  // https://docs.oracle.com/pt-br/iaas/Content/Object/Concepts/objectstorageoverview.htm
  // https://docs.oracle.com/pt-br/iaas/Content/Object/Tasks/usinglifecyclepolicies.htm#namefilters
  // https://docs.oracle.com/pt-br/iaas/Content/Object/Tasks/managingobjects.htm#namerequirements
  // https://docs.oracle.com/pt-br/iaas/Content/Object/Concepts/dedicatedendpoints.htm
  // https://docs.oracle.com/en-us/iaas/Content/API/Concepts/sdkconfig.htm#SDK_and_CLI_Configuration_File
  // https://docs.oracle.com/en/cloud/paas/autonomous-database/dedicated/adbdj/#GUID-26978C37-BFCE-4E0B-8C39-8AF399F2067B
  // https://docs.oracle.com/en/learn/manage-oci-restapi/index.html#task-3-create-and-run-java-code-to-upload-or-put-a-binary-file-from-oci-object-storage-using-rest-apis
  // https://docs.oracle.com/en/cloud/paas/autonomous-database/dedicated/adbdj/#articletitle
  // https://docs.oracle.com/en-us/iaas/api/#/pt/objectstorage/20160918/
  // https://medium.com/@pratapgowda007/signing-oci-object-storage-rest-api-requests-607fb0efa6fb
  // https://docs.oracle.com/pt-br/iaas/Content/API/Concepts/signingrequests.htm#ObjectStoragePut

  const OracleObjectStorage({
    required this.buckerNameSpace,
    required this.buckerName,
    required this.buckerRegion,
    required this.tenancyOcid,
    required this.userOcid,
    required this.apiPrivateKey,
  }): 
    buckerHost = 'objectstorage.$buckerRegion.oraclecloud.com',
    buckerPath = '/n/$buckerNameSpace/b/$buckerName',
    serviceURLOrigin = 'https://objectstorage.$buckerRegion.oraclecloud.com',
    publicFileURLPath = 'https://$buckerNameSpace.objectstorage.$buckerRegion.oci.customer-oci.com/n/$buckerNameSpace/b/$buckerName/o';

  factory OracleObjectStorage.fromConfig({
    required String configFullPath, required String  privateKeyFullPath,}) {

    try {

      if (configFullPath.isEmpty) {
        return throw const OracleObjectStorageExeception('O endereço do arquivo .json no dispositivo '
          'não pode ser vazio [configFullPath]');      
      } else if(!configFullPath.endsWith('.json')) {
        return throw const OracleObjectStorageExeception('informe o endereço do arquivo de '
          'configuração do tipo .json [configFullPath]');      
      }
      
      final File file = File(configFullPath);

      if (file.existsSync()) {

        final String fileBody = file.readAsStringSync();

        final Map<String, dynamic> config = convert.jsonDecode(fileBody.replaceAll('\n', ''));

        return OracleObjectStorage(
          buckerNameSpace: config['buckerNameSpace'] ?? config['nameSpace'] ?? config['namespace'] 
            ?? _generateExeception<String>('O nomeSpace do bucker não foi definido, '
                'insira a chave e valor no arquivo json [buckerNameSpace]'), 
          buckerName: config['buckerName'] ?? config['buckername'] ?? config['name'] 
            ?? _generateExeception<String>('O nome do bucker não foi definido, '
                'insira a chave e valor no arquivo json [buckerName]'), 
          buckerRegion: config['region'] ?? config['buckerRegion'] ?? config['buckerregion'] 
            ?? _generateExeception<String>('A região do bucker não foi definida, '
                'insira a chave e valor no arquivo json [buckerRegion]'), 
          tenancyOcid: config['tenancy'] ?? config['tenancyOcid'] ?? config['tenancyOCID'] 
            ?? _generateExeception<String>('A tenancy não foi definida, '
                'insira a chave e valor no arquivo json [tenancyOcid]'),
          userOcid: config['user'] ?? config['userOcid'] ?? config['userOCID'] 
            ?? _generateExeception<String>('O ID de usuário não foi definido, '
                'insira a chave e valor no arquivo json [userOcid]'),
          apiPrivateKey: ApiPrivateKey.fromFile(
            fullPath: privateKeyFullPath, 
            fingerprint: config['fingerprint'] ?? config['fingerprint'] 
              ?? _generateExeception<String>('A assinatura digital da chave de API não foi definida, '
                'insira a chave e valor no arquivo json [fingerprint]'),
          ),
        );

      } else {
        return throw OracleObjectStorageExeception('Arquivo de configurações não localizado: $configFullPath');      
      }
      
    } on TypeError catch (error, stackTrace) {
      log(
        'Erro ao tentar definir alguma variável com tipos diferentes',
        name: '$OracleObjectStorage > fromConfig',
        stackTrace: stackTrace,
        error: error,
      );
      return throw OracleObjectStorageExeception('Erro ao tentar definir alguma variável com tipos diferentes');
    } on OracleObjectStorageExeception catch (error, stackTrace) {
      log(
        error.message,
        name: '$OracleObjectStorage > fromConfig',
        stackTrace: stackTrace,
        error: error,
      );
      return throw OracleObjectStorageExeception(error.message);
    } catch (error, stackTrace) {
      log(
        'Erro não tratado ao tentar ler o corpo dos parâmetros de configurações no arquivo .json',
        name: '$OracleObjectStorage > fromConfig',
        stackTrace: stackTrace,
        error: error,
      );
      return throw const OracleObjectStorageExeception('Erro não tratado ao tentar ler o '
        'corpo dos parâmetros de configurações no arquivo .json');      
    }

  }

  static T _generateExeception<T>(String message) => throw OracleObjectStorageExeception(message);

  final String 
    buckerNameSpace,
    buckerName,
    buckerHost,
    buckerRegion,
    buckerPath,
    tenancyOcid,
    userOcid,
    serviceURLOrigin,
    publicFileURLPath; 
  
  final ApiPrivateKey apiPrivateKey;

  // https://docs.oracle.com/javase/8/docs/api/java/time/format/DateTimeFormatter.html#RFC_1123_DATE_TIME
  /// Formato de data RCF 1123 ==> 'Tue, 3 Jun 2008 11:05:30 GMT'
  static final DateFormat dateFormatRCF1123 = DateFormat('E, d MMM y H:m:s', 'en_US');

  /// Data na zona UTC
  static String getDateRCF1123(DateTime? date) {
    date ??= DateTime.now().toUtc();
    return '${dateFormatRCF1123.format(date)} GMT';
  }

  // https://docs.oracle.com/pt-br/iaas/Content/Object/Concepts/dedicatedendpoints.htm#dedicated-endpoints__OCIObjectStoragededicatedendpoints-NewURLs
  // https://<BUCKER_NAME_SPACE>.objectstorage.<BUCKER_REGION>.oci.customer-oci.com/n/<BUCKER_NAME_SPACE>/b/<BUCKER_NAME>/o<FULLPATH_FILE_NAME>'; 
  /// URL publica para acesso de arquivo no bucker
  /// [pathAndFileName] Ex: /users/profilePicture/userId.jpg
  String getPublicUrlFile(String pathAndFileName) {
    return '$publicFileURLPath$pathAndFileName';
  }

}
