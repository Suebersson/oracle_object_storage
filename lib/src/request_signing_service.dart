import 'dart:typed_data' show Uint8List;
import 'package:asn1lib/asn1lib.dart';
import 'package:pointycastle/export.dart';

import '../oracle_object_storage.dart' show ConverterForBytes;

// https://pub.dev/packages/asn1lib
// https://pub.dev/packages/pointycastle

final class RequestSigningService {

  final SHA256Digest digest;
  final AsymmetricBlockCipher cipher;
  final String digestIdentifierHex;
  final Uint8List digestBytes, digestIdentifierHexLength;
  final RSAPrivateKey rsaPrivateKey;
  // final RSAPublicKey rsaPublicKey;
  final CipherParameters cipherParameters;

  RequestSigningService._({
    required this.rsaPrivateKey,
    // required this.rsaPublicKey,
    required this.digest, 
    required this.cipher, 
    required this.digestIdentifierHex, 
  }) : 
    cipherParameters = PrivateKeyParameter<RSAPrivateKey>(rsaPrivateKey),
    digestIdentifierHexLength = decodeHexString(digestIdentifierHex),
    digestBytes = Uint8List(digest.digestSize);

  factory RequestSigningService(Uint8List privateKeyBytes) {
    return RequestSigningService._(
      rsaPrivateKey: parserPrivateKey(parsePrivateSequence(parseSequence(privateKeyBytes))),
      // rsaPublicKey: parserPublicKey(parserPublicSequence(parseSequence(publicKeyBytes))),
      digest: SHA256Digest(), 
      cipher: PKCS1Encoding(RSAEngine()), 
      digestIdentifierHex: '0609608648016503040201', 
    );
  }

  // https://github.com/bcgit/pc-dart/blob/master/tutorials/rsa.md#signing-and-verifying
  String sign(Uint8List dataToSign) {

    digest
      ..reset()
      ..update(dataToSign, 0, dataToSign.length)
      ..doFinal(digestBytes, 0);

    cipher
      ..reset()
      ..init(true, cipherParameters);

    return cipher.process(_encode(digestBytes)).toBase64;

  }

  Uint8List _encode(Uint8List digestBytes) {

    final Uint8List out = Uint8List(2 + 2 + digestIdentifierHexLength.length + 2 + 2 + digestBytes.length);

    int i = 0;

    // header
    out[i++] = 48;
    out[i++] = out.length - 2;

    // algorithmIdentifier.header
    out[i++] = 48;
    out[i++] = digestIdentifierHexLength.length + 2;

    // algorithmIdentifier.bytes
    out.setAll(i, digestIdentifierHexLength);
    i += digestIdentifierHexLength.length;

    // algorithmIdentifier.null
    out[i++] = 5;
    out[i++] = 0;

    // digestBytes.header
    out[i++] = 4;
    out[i++] = digestBytes.length;

    // digestBytes.bytes
    out.setAll(i, digestBytes);

    return out;

  }

  static Uint8List decodeHexString(String input) {

    assert(input.length % 2 == 0, 'Insira um comprimento de caracteres em pares'); // ex: 22

    return Uint8List.fromList(
      List.generate(
        input.length ~/ 2,
        (i) => int.parse(input.substring(i * 2, (i * 2) + 2), radix: 16),
      ).toList(),
    );

  }

  /// Para chaves RSA que começam com [-----BEGIN RSA PRIVATE/PUBLIC KEY-----]
  static ASN1Sequence parseSequence(Uint8List keyBytes) {
    return ASN1Parser(keyBytes).nextObject() as ASN1Sequence;
  }

  /// Para chaves que començam com [-----BEGIN PRIVATE KEY-----]
  static ASN1Sequence parsePrivateSequence(ASN1Sequence sequence) {
    final ASN1Object bitString = sequence.elements[2];
    final Uint8List bytes = bitString.valueBytes();
    final ASN1Parser parser = ASN1Parser(bytes);
    return parser.nextObject() as ASN1Sequence;
  }

  /// Para chaves que començam com [-----BEGIN PUBLIC KEY-----]
  static ASN1Sequence parserPublicSequence(ASN1Sequence sequence) {
    final ASN1Object bitString = sequence.elements[1];
    final Uint8List bytes = bitString.valueBytes().sublist(1);
    final ASN1Parser parser = ASN1Parser(Uint8List.fromList(bytes));
    return parser.nextObject() as ASN1Sequence;
  }

  static RSAPrivateKey parserPrivateKey(ASN1Sequence sequence) {
    final BigInt modulus = (sequence.elements[1] as ASN1Integer).valueAsBigInteger;
    final BigInt exponent = (sequence.elements[3] as ASN1Integer).valueAsBigInteger;
    final BigInt p = (sequence.elements[4] as ASN1Integer).valueAsBigInteger;
    final BigInt q = (sequence.elements[5] as ASN1Integer).valueAsBigInteger;
    return RSAPrivateKey(modulus, exponent, p, q);
  }

  static RSAPublicKey parserPublicKey(ASN1Sequence sequence) {
    final BigInt modulus = (sequence.elements[0] as ASN1Integer).valueAsBigInteger;
    final BigInt exponent = (sequence.elements[1] as ASN1Integer).valueAsBigInteger;
    return RSAPublicKey(modulus, exponent);
  }
  
}