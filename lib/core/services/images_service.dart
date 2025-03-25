import 'package:http/http.dart' as http;

class ImagesService {

  static Future<bool> doesImageLinkExist(String url) async {
    try {
      final response = await http.head(Uri.parse(url));
      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }
}