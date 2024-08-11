#!/bin/bash

# https://docs.oracle.com/en/learn/manage-oci-restapi/index.html#task-2-create-and-run-shell-script-to-upload-or-put-a-binary-file-from-oci-object-storage-using-rest-apis

# Comando para dar permissão de execução para este arquivo bash
# 
# sudo chmod +x ./put_object_storage_exemple.sh

# Comando para executar este arquivo/código bash
# 
# bash ./put_object_storage_exemple.sh

########################## Fill these in with your values ##########################
#OCID of the tenancy calls are being made in to
tenancy_ocid="ocid1.tenancy.oc1..aaaaaaaa..."

# namespace of the tenancy
namespace="BUCKER_NAME_SPACE"

# OCID of the user making the rest call
user_ocid="ocid1.user.oc1..aaaa..."

# path to the private PEM format key for this user
privateKeyPath=".../private_key.pem"

# fingerprint of the private key for this user
fingerprint="5d:b5:d6:44:..."

#bucket name for uplaod/ put
bucket="BUCKER_NAME"

#file name for upload/ put
object="users/profilePictures/userId.jpg"

# The REST api you want to call, with any required paramters.
rest_api="/n/$namespace/b/$bucket/o/$object"

buckerRegion="sa-saopaulo-1"

# The host you want to make the call against
host="objectstorage.$buckerRegion.oraclecloud.com"

# the file containing the data you want to POST to the rest endpoint
# caminho completo do arquivo
body="/mnt/.../anyImage.jpg" 
####################################################################################

# extra headers required for a POST/PUT request
method="put"
content_type="image/jpeg"
body_arg=(--data-binary @${body})
content_sha256="$(openssl dgst -binary -sha256 < $body | openssl enc -e -base64)";
content_sha256_header="x-content-sha256: $content_sha256"
content_length="$(wc -c < $body | xargs)";
content_length_header="content-length: $content_length"
headers="(request-target) date host"
# add on the extra fields required for a POST/PUT
headers=$headers" x-content-sha256 content-type content-length"
content_type_header="content-type: $content_type";

date=`date -u "+%a, %d %h %Y %H:%M:%S GMT"`
date_header="date: $date"
host_header="host: $host"
request_target="(request-target): $method $rest_api"

# note the order of items. The order in the signing_string matches the order in the headers, including the extra POST fields
signing_string="$request_target\n$date_header\n$host_header"
# add on the extra fields required for a POST/PUT
signing_string="$signing_string\n$content_sha256_header\n$content_type_header\n$content_length_header"

signature=`printf '%b' "$signing_string" | openssl dgst -sha256 -sign $privateKeyPath | openssl enc -e -base64 | tr -d '\n'`

set -x
curl -v -X $(echo $method | tr [:lower:] [:upper:]) --data-binary "@$body" -sS https://$host$rest_api -H "date: $date" -H "x-content-sha256: $content_sha256" -H "content-type: $content_type" -H "content-length: $content_length" -H "Authorization: Signature version=\"1\",keyId=\"$tenancy_ocid/$user_ocid/$fingerprint\",algorithm=\"rsa-sha256\",headers=\"$headers\",signature=\"$signature\""
