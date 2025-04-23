import 'dart:convert';
import 'dart:io';

import 'package:flutter_minio/minio.dart';

void main() async {
  final file = File('keystore/access_minio2.json');
  final text = await file.readAsString();
  final json = jsonDecode(text);
  print('json = $json');

  final minio = Minio(
    endPoint: '127.0.0.1',
    region: 'us-east-1',
    port: 9000,
    useSSL: false,
    accessKey: json['accessKey'],
    secretKey: json['secretKey'],
    pathStyle: true,
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
    'video',
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
