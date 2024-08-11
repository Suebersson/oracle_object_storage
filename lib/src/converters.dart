part of '../oracle_object_storage.dart';

extension ConverterForBytes on Uint8List {

  String get toSha256Base64 => convert.base64.encode(SHA256Digest().process(this));

  String get toBase64 => convert.base64.encode(this);

}

extension ConverterForDate on DateTime {

  String get toFormatRCF1123 => '${OracleObjectStorage.dateFormatRCF1123.format(this)} GMT';

}

extension ConverterForString on String {

  Uint8List get base64ToBytes => convert.base64.decode(this);

  Uint8List get utf8ToBytes => convert.utf8.encode(this);

}

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