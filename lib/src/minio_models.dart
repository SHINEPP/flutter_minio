// ignore_for_file: deprecated_member_use

import 'package:flutter_minio/src/minio_errors.dart';
import 'package:flutter_minio/src/minio_models_generated.dart';
import 'package:flutter_minio/src/utils.dart';
import 'package:xml/xml.dart';

class ListObjectsResult {
  ListObjectsResult({
    required this.objects,
    required this.prefixes,
  });

  /// Metadata about each object returned.
  final List<Object> objects;

  /// Like directorys in a file system, prefixes are delimited by slashes.
  final List<String> prefixes;

  @override
  String toString() {
    return '$runtimeType{objects: $objects, prefixes: $prefixes}';
  }
}

class ListObjectsOutput {
  bool? isTruncated;
  String? nextMarker;
  List<Object>? contents;
  late List<CommonPrefix> commonPrefixes;
}

class ListObjectsV2Output {
  bool? isTruncated;
  String? nextContinuationToken;
  List<Object>? contents;
  late List<CommonPrefix> commonPrefixes;
}

class CompleteMultipartUpload {
  CompleteMultipartUpload(
    this.parts,
  );

  XmlNode toXml() {
    final builder = XmlBuilder();
    builder.element(
      'CompleteMultipartUpload',
      nest: parts.map((p) => p.toXml()),
    );
    return builder.buildDocument();
  }

  /// Array of CompletedPart data types.
  List<CompletedPart> parts;
}

class ListMultipartUploadsOutput {
  ListMultipartUploadsOutput.fromXml(XmlElement xml) {
    isTruncated = getProp(xml, 'IsLatest')?.text.toUpperCase() == 'TRUE';
    nextKeyMarker = getProp(xml, 'NextKeyMarker')?.text;
    nextUploadIdMarker = getProp(xml, 'NextUploadIdMarker')?.text;
    uploads = xml
        .findElements('Upload')
        .map((e) => MultipartUpload.fromXml(e))
        .toList();
  }

  bool? isTruncated;
  String? nextKeyMarker;
  String? nextUploadIdMarker;
  late List<MultipartUpload> uploads;
}

class ListPartsOutput {
  ListPartsOutput.fromXml(XmlElement xml) {
    isTruncated = getProp(xml, 'IsLatest')?.text.toUpperCase() == 'TRUE';
    nextPartNumberMarker =
        int.parse(getProp(xml, 'NextPartNumberMarker')!.text);
    parts = xml.findElements('Upload').map((e) => Part.fromXml(e)).toList();
  }

  late bool isTruncated;
  late int nextPartNumberMarker;
  late List<Part> parts;
}

class IncompleteUpload {
  IncompleteUpload({
    this.upload,
    this.size,
  });

  final MultipartUpload? upload;
  final int? size;
}

class CopyConditions {
  String? modified;
  String? unmodified;
  String? matchETag;
  String? matchETagExcept;

  void setModified(DateTime date) {
    modified = toRfc7231Time(date.toUtc());
  }

  void setUnmodified(DateTime date) {
    unmodified = toRfc7231Time(date.toUtc());
  }

  void setMatchETag(String etag) {
    matchETag = etag;
  }

  void setMatchETagExcept(String etag) {
    matchETagExcept = etag;
  }
}

class StatObjectResult {
  StatObjectResult({
    this.size,
    this.etag,
    this.lastModified,
    this.metaData,
    this.acl,
  });

  final int? size;
  final String? etag;
  final DateTime? lastModified;
  final Map<String, String?>? metaData;
  final AccessControlPolicy? acl;
}

/// Build PostPolicy object that can be signed by presignedPostPolicy
class PostPolicy {
  final policy = <String, dynamic>{
    'conditions': [],
  };

  final formData = <String, String>{};

  /// set expiration date
  void setExpires(DateTime date) {
    policy['expiration'] = date.toIso8601String();
  }

  /// set object name
  void setKey(String object) {
    MinioInvalidObjectNameError.check(object);
    policy['conditions'].add(['eq', r'$key', object]);
    formData['key'] = object;
  }

  /// set object name prefix, i.e policy allows any keys with this prefix
  void setKeyStartsWith(String prefix) {
    MinioInvalidPrefixError.check(prefix);
    policy['conditions'].add(['starts-with', r'$key', prefix]);
    formData['key'] = prefix;
  }

  /// set bucket name
  void setBucket(bucket) {
    MinioInvalidBucketNameError.check(bucket);
    policy['conditions'].add(['eq', r'$bucket', bucket]);
    formData['bucket'] = bucket;
  }

  /// set Content-Type
  void setContentType(String type) {
    policy['conditions'].add(['eq', r'$Content-Type', type]);
    formData['Content-Type'] = type;
  }

  /// set minimum/maximum length of what Content-Length can be.
  void setContentLengthRange(int min, int max) {
    if (min > max) {
      throw MinioError('min cannot be more than max');
    }
    if (min < 0) {
      throw MinioError('min should be > 0');
    }
    if (max < 0) {
      throw MinioError('max should be > 0');
    }
    policy['conditions'].add(['content-length-range', min, max]);
  }
}

class PostPolicyResult {
  PostPolicyResult({this.postURL, this.formData});

  final String? postURL;
  final Map<String, String>? formData;
}
