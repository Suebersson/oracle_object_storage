import 'dart:io' show File;
import 'dart:developer' show log;
import 'package:intl/intl.dart' show DateFormat;

import './oracle_object_storage_exeception.dart';
import './private_key.dart';
import './converters.dart';
import './interfaces/oci_api_service.dart';
import './interfaces/oci_bucket.dart';
import './interfaces/oci_config.dart';
import './interfaces/oci_services.dart';
import './services/bucket/src/bucket.dart';
import './services/multipart_upload/src/multipart_upload.dart';
import './services/namespace/src/namespace.dart';
import './services/object/src/object.dart';
import './services/preauthenticated_request/src/preauthenticated_request.dart';

/// Criar instância para requisições Oracle Objet Storage
final class OracleObjectStorage
    implements OCIConfig, OCIAPIService, OCIBucket, OCIServices {
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

  /// Criar instância para requisições Oracle Objet Storage
  OracleObjectStorage({
    required this.nameSpace,
    required this.bucketName,
    required this.region,
    required this.tenancy,
    required this.user,
    required this.apiPrivateKey,
  })  : host = 'objectstorage.$region.oraclecloud.com',
        bucketPath = '/n/$nameSpace/b/$bucketName',
        apiUrlOrigin = 'https://objectstorage.$region.oraclecloud.com',
        bucketPublicURL =
            'https://$nameSpace.objectstorage.$region.oci.customer-oci.com/n/$nameSpace/b/$bucketName/o';

  /// Criar instância para requisições Oracle Objet Storage
  factory OracleObjectStorage.fromConfig({
    required String configFullPath,
    required String privateKeyFullPath,
  }) {
    try {
      if (configFullPath.isEmpty) {
        return throw const OracleObjectStorageExeception(
            'O endereço do arquivo .json no dispositivo '
            'não pode ser vazio [configFullPath]');
      } else if (!configFullPath.endsWith('.json')) {
        return throw const OracleObjectStorageExeception(
            'informe o endereço do arquivo de '
            'configuração do tipo .json [configFullPath]');
      }

      final File file = File(configFullPath);

      if (file.existsSync()) {
        final String fileBody = file.readAsStringSync();

        final Map<String, dynamic> config =
            fileBody.replaceAll('\n', '').decodeJson;

        return OracleObjectStorage(
          nameSpace: config['nameSpace'] ??
              config['bucketNameSpace'] ??
              config['namespace'] ??
              _generateExeception<String>(
                  'O nomeSpace do bucket não foi definido, '
                  'insira a chave e valor no arquivo json [bucketNameSpace]'),
          bucketName: config['bucketName'] ??
              config['buckername'] ??
              config['name'] ??
              _generateExeception<String>('O nome do bucket não foi definido, '
                  'insira a chave e valor no arquivo json [bucketName]'),
          region: config['region'] ??
              config['bucketRegion'] ??
              config['buckerregion'] ??
              _generateExeception<String>(
                  'A região do bucket não foi definida, '
                  'insira a chave e valor no arquivo json [bucketRegion]'),
          tenancy: config['tenancy'] ??
              config['tenancyOcid'] ??
              config['tenancyOCID'] ??
              _generateExeception<String>('A tenancy não foi definida, '
                  'insira a chave e valor no arquivo json [tenancyOcid]'),
          user: config['user'] ??
              config['userOcid'] ??
              config['userOCID'] ??
              _generateExeception<String>('O ID de usuário não foi definido, '
                  'insira a chave e valor no arquivo json [userOcid]'),
          apiPrivateKey: ApiPrivateKey.fromFile(
            fullPath: privateKeyFullPath,
            fingerprint: config['fingerprint'] ??
                config['Fingerprint'] ??
                config['fingerPrint'] ??
                _generateExeception<String>(
                    'A assinatura digital da chave de API não foi definida, '
                    'insira a chave e valor no arquivo json [fingerprint]'),
          ),
        );
      } else {
        return throw OracleObjectStorageExeception(
          'Arquivo de configurações não localizado: $configFullPath',
        );
      }
    } on TypeError catch (error, stackTrace) {
      log(
        'Erro ao tentar definir alguma variável com tipos diferentes',
        name: '$OracleObjectStorage > fromConfig',
        stackTrace: stackTrace,
        error: error,
      );
      return throw const OracleObjectStorageExeception(
        'Erro ao tentar definir alguma variável com tipos diferentes',
      );
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
      return throw const OracleObjectStorageExeception(
          'Erro não tratado ao tentar ler o '
          'corpo dos parâmetros de configurações no arquivo .json');
    }
  }

  static T _generateExeception<T>(String message) =>
      throw OracleObjectStorageExeception(message);

  @override
  final String region,
      tenancy,
      user,
      nameSpace,
      apiUrlOrigin,
      host,
      bucketName,
      bucketPublicURL,
      bucketPath;

  @override
  final ApiPrivateKey apiPrivateKey;

  // https://docs.oracle.com/javase/8/docs/api/java/time/format/DateTimeFormatter.html#RFC_1123_DATE_TIME
  /// Formato de data RCF 1123 ==> 'Tue, 3 Jun 2008 11:05:30 GMT'
  static final DateFormat dateFormatRCF1123 =
      DateFormat('E, d MMM y H:m:s', 'en_US');

  /// Data na zona UTC
  static String getDateRCF1123(DateTime? date) {
    date ??= DateTime.now().toUtc();
    return '${dateFormatRCF1123.format(date)} GMT';
  }

  // https://docs.oracle.com/pt-br/iaas/Content/Object/Concepts/dedicatedendpoints.htm#dedicated-endpoints__OCIObjectStoragededicatedendpoints-NewURLs
  // https://<NAME_SPACE>.objectstorage.<REGION>.oci.customer-oci.com/n/<NAME_SPACE>/b/<BUCKER_NAME>/o<FULLPATH_FILE_NAME>';
  /// URL publica para acesso de arquivo no bucket
  ///
  /// [pathAndFileName] Ex: /users/profilePicture/userId.jpg
  String getPublicUrlFile(String pathAndFileName) {
    return '$bucketPublicURL$pathAndFileName';
  }

  @override
  late final ObjectStorage object = ObjectStorage(this);

  @override
  late final Namespace namespace = Namespace(this);

  @override
  late final Bucket bucket = Bucket(this);

  @override
  late final MultipartUpload multipartUpload = MultipartUpload(this);

  @override
  late final PreauthenticatedRequest preauthenticatedRequest =
      PreauthenticatedRequest(this);
}
