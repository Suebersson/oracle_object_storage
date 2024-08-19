import 'dart:convert' as convert;
import 'dart:typed_data' show Uint8List;
import 'package:pointycastle/digests/sha256.dart' show SHA256Digest;

import './oracle_object_storage.dart';

/// Auxiliar para converter objetos [Uint8List]
extension ConverterForBytes on Uint8List {

  String get toSha256Base64 => convert.base64.encode(SHA256Digest().process(this));

  String get toBase64 => convert.base64.encode(this);

}

/// Auxiliar para converter objetos [DateTime]
extension ConverterForDate on DateTime {

  String get toFormatRCF1123 => '${OracleObjectStorage.dateFormatRCF1123.format(this)} GMT';

  String get toFormatRCF3339 => toIso8601String();

}

/// Auxiliar para converter objetos [String]
extension ConverterForString on String {

  Uint8List get base64ToBytes => convert.base64.decode(this);

  Uint8List get utf8ToBytes => convert.utf8.encode(this);

  dynamic get decodeJson => convert.json.decode(
    this,
    reviver: (key, value) {
      try {
        if (value is String && RegExp(r'^(\d{4}-\d{2}-\d{2})|(-\d{4}-\d{2}-\d{2})').hasMatch(value)) {
          return DateTime.tryParse(value) ?? value;
        } else if(value is String && (value.toLowerCase() == 'true' || value.toLowerCase() == 'false')) {
          return bool.tryParse(value) ?? value;
        } else if(value is String && RegExp('^[0-9]{1,}\$').hasMatch(value)) {
          return int.tryParse(value) ?? value;
        } else if(value is String && RegExp('^[0-9]{1,}\\.[0-9]{1,}\$').hasMatch(value)) {
          return double.tryParse(value) ?? value;
        } else {
          return value;
        }
      } on FormatException {
        return value;
      } catch (_) {
        return value;
      }
    },
  );

}

/// Auxiliar para converter objetos [Map]
extension ConverterForMap on Map<String, dynamic> {

  String get toJson => convert.json.encode(
    this, 
    toEncodable: (dynamic object) {
      if (object is DateTime || object is Enum) {
        return object.toString();
      } else {
        // Exeception que será emitida se o objeto for icompatível para o formato 
        // JSON [JsonUnsupportedObjectError] caso essa função seja defina
        return throw UnsupportedError(
          'Tipos objetos compatíveis para o formato json Key:[String], Key:[int], Key:[double], Key:[bool], '
          'Key:[Null], Key:[List], Key:[Map]\n\n'
          'Tipo de objeto não tratado para converter para o formato '  
          'json, faça uma implementação condicional para processar e tratar este tipo de '
          'objeto[${object.runtimeType}] ou converta para algum tipo compatível');
      }
    },
  );

}