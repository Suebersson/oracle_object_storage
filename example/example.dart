import 'dart:io' show File;
import 'dart:typed_data' show Uint8List;
import 'dart:developer' show log;
import 'package:http/http.dart' as http;
import 'package:oracle_object_storage/oracle_object_storage.dart';

void main() async{

  final OracleObjectStorage storage = OracleObjectStorage(
    nameSpace: '...', 
    bucketName: '...', 
    region: 'sa-saopaulo-1', 
    tenancy: 'ocid1.tenancy.oc1..aaa...', 
    user: 'ocid1.user.oc1..aaaaa...', 
    apiPrivateKey: ApiPrivateKey.fromFile(
      fullPath: '.../private_key.pem',
      fingerprint: '8d:b5:d6:50:1b:2...',
    ),
  );

  final File file = File('.../fileName.jpg');

  final Uint8List bytes = await file.readAsBytes();

  final PutObject put = storage.object.putObject(
    pathAndFileName: '/users/profilePictures/fileName.jpg',
    xContentSha256: bytes.toSha256Base64,
    contentLength: bytes.length.toString(),
    contentType: 'image/jpeg',
    addHeaders: <String, String>{
      'opc-meta-*': OpcMeta({
          'fileName': 'fileName.jpg',
          'expiryDate': DateTime.now().toString(),
      }).metaFormat,
    },
  );

  final http.Response response = await http.put(
    Uri.parse(put.uri),
    body: bytes,
    headers: put.headers,
  );

  log(
    '${response.statusCode}',
    name: 'main > $PutObject',
  );

}