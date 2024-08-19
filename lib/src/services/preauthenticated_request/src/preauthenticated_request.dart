import '../../../oracle_object_storage.dart';

final class PreauthenticatedRequest {
  const PreauthenticatedRequest(this.storage);
  final OracleObjectStorage storage;
}