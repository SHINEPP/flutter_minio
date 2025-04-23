import 'dart:convert';
import 'dart:io';

import 'package:flutter_minio/minio.dart';

void main() async {
  final file = File('keystore/access_s3.json');
  final text = await file.readAsString();
  final json = jsonDecode(text);
  print('json = $json');

  final minio = Minio(
    endPoint: 's3.amazonaws.com',
    port: 443,
    useSSL: true,
    accessKey: json['accessKey'],
    secretKey: json['secretKey'],
    pathStyle: false,
  );

  final buckets = await minio.listBuckets();
  for (var bucket in buckets) {
    try {
      print('bucket = $bucket');
      final region = await minio.getBucketRegion(bucket.name);
      print('region = $region');
    } catch (e) {
      print('e = $e');
    }
  }

  final objectStream = minio.listObjects(
    'aliyun-oa-query-results-1280606198194346-oss-cn-beijing',
  );
  await for (final result in objectStream) {
    for (final name in result.prefixes) {
      print('name = $name');
    }
    for (final object in result.objects) {
      print('object = $object');
    }
  }
}
