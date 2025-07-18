// import 'dart:io';
// import 'package:dio/dio.dart';
// import 'package:path_provider/path_provider.dart';

// Future<void> downloadImage(String url) async {
//   final dio = Dio();
  
//   // 下载图片
//   final response = await dio.get(
//     url,
//     options: Options(
//       responseType: ResponseType.bytes,
//     ),
//   );

//   // 获取 Content-Type 并确定文件扩展名
//   String? contentType = response.headers.value(Headers.contentTypeHeader);
//   String fileExtension = _getFileExtensionFromContentType(contentType);

//   // 获取文件存储目录
//   final directory = await getApplicationDocumentsDirectory();
//   final filePath = '${directory.path}/downloaded_image$fileExtension';

//   // 保存图片到本地
//   final file = File(filePath);
//   await file.writeAsBytes(response.data);

//   print('Image downloaded to $filePath');
// }

// // 根据 Content-Type 返回文件后缀
// String _getFileExtensionFromContentType(String? contentType) {
//   switch (contentType) {
//     case 'image/jpeg':
//       return '.jpg';
//     case 'image/png':
//       return '.png';
//     case 'image/gif':
//       return '.gif';
//     case 'image/webp':
//       return '.webp';
//     default:
//       return ''; // 没有匹配时，可以选择不加后缀，或者使用通用的 '.img' 等
//   }
// }
