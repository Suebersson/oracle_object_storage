import '../services/bucket/src/bucket.dart';
import '../services/multipart_upload/src/multipart_upload.dart';
import '../services/namespace/src/namespace.dart';
import '../services/object/src/object.dart';
import '../services/preauthenticated_request/src/preauthenticated_request.dart';

/// Categorias de serviços disponiveis para a Oracle Object Storage
abstract interface class OCIServices {
  ObjectStorage get object;
  Namespace get namespace;
  Bucket get bucket;
  MultipartUpload get multipartUpload;
  PreauthenticatedRequest get preauthenticatedRequest;
}