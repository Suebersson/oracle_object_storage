// ignore_for_file: avoid_print

class ApiPrivateKey{}

final class Namespace {
  const Namespace(this.storage);
  final OracleObjectStorage storage;
}

final class Object {
  const Object(this.storage);
  final OracleObjectStorage storage;
}

final class PreauthenticatedRequest {
  const PreauthenticatedRequest(this.storage);
  final OracleObjectStorage storage;
}

final class MultipartUpload {
  const MultipartUpload(this.storage);
  final OracleObjectStorage storage;
}

final class Bucket {
  const Bucket(this.storage);
  final OracleObjectStorage storage;
}

extension GetNamespaceMethod on Namespace {

  void getNamespace() {

    print('getNamespace');
    print(hashCode);
    print(storage.user);

  }

}

extension GetNamespaceMetadataMethod on Namespace {

  void getNamespaceMetadata() {

    print('getNamespaceMetadata');
    print(hashCode);
    print(storage.user);

  }

}

abstract interface class OCIConfig {
  String get tenancy;
  String get user;
  String get region;
  ApiPrivateKey get apiPrivateKey;
}

abstract interface class OCIAPIService {
  String get nameSpace;
  String get host;
  String get apiUrlOrigin;
}

abstract interface class OCIServices {
  Object get object;
  Namespace get namespace;
  Bucket get bucket;
  MultipartUpload get multipartUpload;
  PreauthenticatedRequest get preauthenticatedRequest;
}

abstract interface class OCIBucket {
  String get bucketName;
  String get bucketPath;
  String get bucketPublicURL;
}


class OracleObjectStorage implements OCIConfig, OCIAPIService, OCIBucket, OCIServices {

  OracleObjectStorage({
    required this.apiPrivateKey,
    required this.user,
    required this.tenancy,
    required this.region,
    required this.nameSpace,
    required this.bucketName,
  }) :
    host = 'objectstorage.$region.oraclecloud.com',
    bucketPath = '/n/$nameSpace/b/$bucketName',
    apiUrlOrigin = 'https://objectstorage.$region.oraclecloud.com',
    bucketPublicURL = 'https://$nameSpace.objectstorage.$region.oci.customer-oci.com/n/$nameSpace/b/$bucketName/o';

  @override
  final ApiPrivateKey apiPrivateKey;
  
  @override
  final String 
    user,
    tenancy,
    region,
    apiUrlOrigin,
    host,
    bucketName,
    nameSpace,
    bucketPath,
    bucketPublicURL;

  @override
  late final Namespace namespace = Namespace(this);
  
  @override
  late final Bucket bucket = Bucket(this);
  
  @override
  late final MultipartUpload multipartUpload = MultipartUpload(this);
  
  @override
  late final Object object = Object(this);
  
  @override
  late final PreauthenticatedRequest preauthenticatedRequest = PreauthenticatedRequest(this);

}


void main() async{


  final OracleObjectStorage storage = OracleObjectStorage(
    apiPrivateKey: ApiPrivateKey(), 
    user: 'user', 
    tenancy: 'tenancy', 
    region: 'region',
    bucketName: '',
    nameSpace: '', 
  );

  storage.namespace.getNamespace();
  storage.namespace.getNamespaceMetadata();

}