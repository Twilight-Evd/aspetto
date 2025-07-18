import 'dart:io';

import 'package:process_run/utils/process_result_extension.dart';
import 'package:sharebox/utils/file.dart';
import 'package:sharebox/utils/log.dart';

void main(List<String> arguments) async {
  // 检查是否传入了文件路径参数
  if (arguments.isEmpty) {
    logger.d('请提供文件路径作为参数');
    return;
  }
  String name = arguments[0];
  String filePath =
      "lib/repositories/parsers/src/platform/${name.toLowerCase()}.dart";
  if (await FileHelper.fileExist(filePath)) {
    logger.d('文件已经存在');
    exit(0);
  }
  logger.d('开始生成 ${name}Parser 文件');
  String content = await FileHelper.readFromFile(
      "lib/repositories/parsers/src/platform/kuaishou.dart");
  String updatedContent = content.replaceAll('KuaishouParser', '${name}Parser');
  FileHelper.writeToFile(filePath, updatedContent);

  logger.d('已生成 ${name}Parser 文件');

  logger.d('开始生成 $name test 文件');

  String testcontent =
      await FileHelper.readFromFile("test/repositories/parsers/ks_test.dart");
  String testupdatedContent = testcontent
      .replaceAll('KuaishouParser', '${name}Parser')
      .replaceAll("kuaishou.dart", "${name.toLowerCase()}.dart");
  FileHelper.writeToFile(
      "test/repositories/parsers/${name.toLowerCase()}_test.dart",
      testupdatedContent);

  logger.d('已生成 $name test 文件');

  // 执行 `dart run build_runner build`
  final result = await Process.run(
      'dart', ['run', 'build_runner', 'build', '--delete-conflicting-outputs'],
      runInShell: true);

  // 输出 build_runner 命令的执行结果
  if (result.exitCode == 0) {
    logger.d('build_runner 构建成功');
  } else {
    logger.d('build_runner 构建失败');
    logger.d(result.stderr);
    logger.d(result.errText);
  }
}
