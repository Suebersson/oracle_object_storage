library multipart_upload;

// https://docs.oracle.com/en-us/iaas/Content/Object/Tasks/usingmultipartuploads.htm

export 'src/create_multipart_pload.dart';
export 'src/upload_part.dart';
export 'src/list_multipart_uploads.dart';
export 'src/abort_multipart_upload.dart';
export 'src/list_multipart_upload_parts.dart';
export 'src/commit_multipart_upload.dart';

/*

  OREDEM PARA CRIAR UM ARQUIVO EM MULTIPLAS PART/UPLOAD

  Métodos:

    1. CreateMultipartUpload
    2. UploadPart (enviar o corpo/conteúdo/bytes do arquivo)
    3. CommitMultipartUpload (finalizar/montar as partes enviadas para criar um único arquivo)

*/