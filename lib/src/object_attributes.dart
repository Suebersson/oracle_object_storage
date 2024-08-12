part of '../oracle_object_storage.dart';

abstract interface class ObjectAttributes {
  String get uri;
  String get date;
  String get authorization;
  String get host;
  Map<String, String> get headers;
  Map<String, String>? get addHeaders;
}