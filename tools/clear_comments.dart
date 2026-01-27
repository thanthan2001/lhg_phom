import 'dart:io';

/// Regex nhận diện tất cả comment (dòng đơn, doc, và block)
final allComments = RegExp(
  r'(//.*$)|(///.*$)|(/\*[\s\S]*?\*/)',
  multiLine: true,
);

void main(List<String> args) {
  // Thư mục mặc định là lib/
  final targetDir = args.isNotEmpty ? args.first : 'lib';
  final dir = Directory(targetDir);

  if (!dir.existsSync()) {
    print('❌ Không tìm thấy thư mục: ${dir.path}');
    return;
  }

  print('🚀 Đang xoá toàn bộ comment trong: ${dir.path}');
  clearAllComments(dir);
  print('✅ Hoàn tất xoá comment!');
}

void clearAllComments(Directory dir) {
  for (final entity in dir.listSync(recursive: true)) {
    if (entity is File && entity.path.endsWith('.dart')) {
      var content = entity.readAsStringSync();

      // Xóa mọi comment
      content = content.replaceAll(allComments, '');

      // Xóa nhiều dòng trống liên tiếp
      content = content.replaceAll(RegExp(r'\n\s*\n+'), '\n\n');

      entity.writeAsStringSync(content.trim() + '\n');
      print('🧹 Đã xoá comment trong: ${entity.path}');
    }
  }
}
