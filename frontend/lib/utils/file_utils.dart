import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart';

MultipartFile getBytesMultipartFile(
  PlatformFile file, {
  String field = 'files',
}) {
  return MultipartFile.fromBytes(
    field,
    file.bytes ?? [],
    filename: file.name,
  );
}

MultipartFile getStreamMultipartFile(
  PlatformFile file, {
  String field = 'files',
}) {
  final stream = ByteStream(file.readStream!);
  return MultipartFile(
    field,
    stream,
    file.size,
    filename: file.name,
  );
}