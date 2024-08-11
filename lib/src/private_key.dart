part of '../oracle_object_storage.dart';

/*
  int count = 0;
  Timer.periodic(const Duration(seconds: 5), (timer) async{
    
    if(count <= 8){

      final ListObjects list = objectStorage.listObjects();

      final http.Response response = await http.get(
        Uri.parse(list.uri),
        headers: list.header,
      );

      print('\n\nStatus da requisição: ${response.statusCode}');
      print(response.body);// json

      count++;
    
    } else {
      print('\n------ fim do teste ------\n');
      timer.cancel();
    }

  });
*/

final class ApiPrivateKey {

  ApiPrivateKey._({
    required this.key, 
    required this.keyBytes,
    required this.fingerprint,
  }) : signingService = RequestSigningService(keyBytes);

  final String key, fingerprint;
  final Uint8List keyBytes;
  final RequestSigningService signingService;

  static RegExp get regExpForClearKey => RegExp('(\\n|\\s|-----.*-----|OCI_API_KEY)');

  /// [key] ==> valor da chave
  factory ApiPrivateKey.fromValue({required String key, required String fingerprint}) {
    key = key.replaceAll(regExpForClearKey, '');
    return ApiPrivateKey._(
      key: key,
      keyBytes: key.base64ToBytes, 
      fingerprint: fingerprint,
    );
  }

  /// [fullPath] ==> caminho de diretório + nome do arquivo
  factory ApiPrivateKey.fromFile({required String fullPath, required String fingerprint}) {

    try {
      
      if (fullPath.isEmpty) {
        return throw const OracleObjectStorageExeception('O endereço do arquivo no dispositivo '
          'não pode ser vazio');      
      }
      
      final File file = File(fullPath);

      if (file.existsSync()) {

        String fileBody = file.readAsStringSync();
      
        fileBody = fileBody.replaceAll(regExpForClearKey, '');

        return ApiPrivateKey._(
          key: fileBody,
          keyBytes: fileBody.base64ToBytes, 
          fingerprint: fingerprint,
        );

      } else {
        return throw OracleObjectStorageExeception('Arquivo de chave privada não localizado: $fullPath');      
      }
    } on OracleObjectStorageExeception catch (error, stackTrace) {
      log(
        error.message,
        name: '$ApiPrivateKey',
        stackTrace: stackTrace,
        error: error,
      );
      return throw OracleObjectStorageExeception(error.message);      
    } catch (error, stackTrace) {
      log(
        'Erro não tratado ao tentar ler o corpo da chave de API',
        name: '$ApiPrivateKey',
        stackTrace: stackTrace,
        error: error,
      );
      return throw const OracleObjectStorageExeception('Erro não tratado ao tentar ler o corpo da chave de API através do arquivo');      
    }

  }

  /// Assinar requisição
  String sing(String dataToSign) {
    return signingService.sign(dataToSign.utf8ToBytes);
  }

}