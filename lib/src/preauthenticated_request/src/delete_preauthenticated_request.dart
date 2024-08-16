import '../../interfaces/oracle_request_attributes.dart';
import '../../oracle_object_storage.dart';

final class DeletePreauthenticatedRequest implements OracleRequestAttributes {
  
  // https://docs.oracle.com/en-us/iaas/api/#/pt/objectstorage/20160918/PreauthenticatedRequest/DeletePreauthenticatedRequest
  const DeletePreauthenticatedRequest._({
    required this.uri, 
    required this.date, 
    required this.authorization, 
    required this.host, 
    this.addHeaders,
  });
  
  @override
  final String uri, date, authorization, host;

  @override
  final Map<String, String>? addHeaders;

  @override
  Map<String, String> get headers {
    if (addHeaders is Map<String, String> && (addHeaders?.isNotEmpty ?? false)) {

      addHeaders!
      ..update('authorization', (_) => authorization, ifAbsent: () => authorization,)
      ..update('date', (_) => date, ifAbsent: () => date,)
      ..update('host', (_) => host, ifAbsent: () => host,);

      return addHeaders!;    

    } else {
      return {
        'authorization': authorization,
        'date': date,
        'host': host,
      };
    }
  }

  /// Construir dados de autorização para o serviço [DeletePreauthenticatedRequest]
  factory DeletePreauthenticatedRequest({
    required OracleObjectStorage objectStorage, 
    required String parId, 
    DateTime? date,
    Map<String, String>? addHeaders,
  }) {

    final String dateString = OracleObjectStorage.getDateRCF1123(date);

     /*
      
      # Modelo para string de assinatura para o método [delete]

      (request-target): <METHOD> <BUCKER_PATH>/p/<parId>\n
      date: <DATE_UTC_FORMAT_RCF1123>\n
      host: <HOST>

      # Modelo de autorização/authorization para adicionar nas requisições Rest API
      
      Signature headers="date (request-target) date host",
      keyId="<TENANCY_OCID>/<USER_OCID>/<API_KEY_FINGERPRINT>",
      algorithm="rsa-sha256",
      signature="<SIGNATURE>",
      version="1"

    */

    final String request = '${objectStorage.buckerPath}/p/$parId';

    final String signingString = 
      '(request-target): delete $request\n'
      'date: $dateString\n'
      'host: ${objectStorage.buckerHost}';

    return DeletePreauthenticatedRequest._(
      uri: '${objectStorage.serviceURLOrigin}$request', 
      date: dateString, 
      host: objectStorage.buckerHost,
      addHeaders: addHeaders,
      authorization: 'Signature headers="(request-target) date host",'
        'keyId="${objectStorage.tenancyOcid}/${objectStorage.userOcid}/${objectStorage.apiPrivateKey.fingerprint}",'
        'algorithm="rsa-sha256",'
        'signature="${objectStorage.apiPrivateKey.sing(signingString)}",'
        'version="1"',
    );

  }

}

extension DeletePreauthenticatedRequestMethod on OracleObjectStorage {
  
  /// Construir dados de autorização para o serviço [DeletePreauthenticatedRequest]
  DeletePreauthenticatedRequest deletePreauthenticatedRequest({
    required String parId,
    DateTime? date,
    Map<String, String>? addHeaders,
  }) {
    return DeletePreauthenticatedRequest(
      objectStorage: this, 
      parId: parId,
      date: date,
      addHeaders: addHeaders,
    );
  }

}