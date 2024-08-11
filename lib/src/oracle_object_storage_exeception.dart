part of '../oracle_object_storage.dart';

final class OracleObjectStorageExeception implements Exception {
  final String message;
  const OracleObjectStorageExeception(this.message);
  @override
  String toString() => message;
}