import '../../../oracle_object_storage.dart';

// https://docs.oracle.com/en-us/iaas/api/#/en/objectstorage/20160918/ObjectLifecyclePolicy/
final class ObjectLifecyclePolicy {
  const ObjectLifecyclePolicy(this.storage);
  final OracleObjectStorage storage;
}
