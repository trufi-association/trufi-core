import 'dart:async';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:synchronized/synchronized.dart';

class ReadException implements Exception {
  ReadException(this._innerException);

  final Exception _innerException;

  @override
  String toString() {
    return "Read exception caused by: ${_innerException.toString()}";
  }
}

class FileStorage {
  FileStorage(this._fileName);

  final String _fileName;
  final Lock _fileLock = Lock();

  File _file;

  static Future<String> get localPath async {
    return (await getApplicationDocumentsDirectory()).path;
  }

  static Future<File> localFile(String fileName) async {
    return File('${await localPath}/$fileName');
  }

  Future<FileSystemEntity> delete() async {
    final File f = await file;
    return _fileLock.synchronized(() => f.delete());
  }

  Future<File> write(String data) async {
    final File f = await file;
    return _fileLock.synchronized(() => f.writeAsString(data));
  }

  Future<String> read() async {
    try {
      final File f = await file;
      return _fileLock.synchronized(() => f.readAsString());
    } on Exception catch (e) {
      throw ReadException(e);
    }
  }

  Future<File> get file async => _file ??= await localFile(_fileName);
}
