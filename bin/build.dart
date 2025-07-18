import 'dart:io';

import 'package:sharebox/utils/log.dart';

void main(List<String> args) async {
  if (args.isEmpty) {
    logger.d('请提供目标平台参数，例如：dart build.dart windows 或 dart build.dart macos');
    exit(1);
  }

  final targetOS = args[0].toLowerCase();
  logger.d('准备编译 $targetOS 环境');

  // 备份 pubspec.yaml 文件
  final pubspec = File('pubspec.yaml');
  final pubspecBackup = File('pubspec.yaml.tmp');

  // Windows 平台需要包含字体，备份并添加字体部分
  if (targetOS == 'windows') {
    logger.d('$targetOS 环境需要打包字体，准备备份 pubspec.yaml');
    pubspecBackup.writeAsStringSync(pubspec.readAsStringSync());
    logger.d('备份完成');
    logger.d('copy 字体部分');

    final fontsConfig = File('pubspec_fonts.yaml');
    if (fontsConfig.existsSync()) {
      pubspec.writeAsStringSync(
        '\n${fontsConfig.readAsStringSync()}',
        mode: FileMode.append,
      );
      logger.d('完成 copy');
    } else {
      logger.d('缺少 pubspec_fonts.yaml 文件');
      exit(1);
    }
  }

  // 执行 flutter clean
  logger.d('开始清理环境');
  await runCommand('flutter', ['clean']);
  logger.d('完成');

  // 执行 flutter pub get
  logger.d('开始获取依赖');
  await runCommand('flutter', ['pub', 'get', '--no-example']);
  logger.d('完成');

  // 执行 flutter build
  logger.d('开始编译环境');
  await runCommand('flutter', ['build', targetOS, '--release']);
  logger.d('编译完成');

  // 还原 pubspec.yaml 文件
  if (targetOS == 'windows') {
    logger.d('$targetOS 环境恢复备份 pubspec.yaml');
    pubspecBackup.copySync(pubspec.path);
    pubspecBackup.deleteSync();
    logger.d('完成');
  }
}

// Helper function to run commands
Future<void> runCommand(String command, List<String> arguments) async {
  final process = await Process.start(command, arguments, runInShell: true);
  await stdout.addStream(process.stdout);
  await stderr.addStream(process.stderr);
  final exitCode = await process.exitCode;
  if (exitCode != 0) {
    logger.d('命令 $command ${arguments.join(" ")} 失败，退出代码: $exitCode');
    exit(exitCode);
  }
}
