import 'package:socket_io_client/socket_io_client.dart' as IO;

class WebSocketService {
  final String url;
  late IO.Socket socket;

  WebSocketService(this.url);

  // Kết nối với Socket.IO
  void connect(Function(String) onMessage,
      {Function? onError, Function? onDone}) {
    // Kết nối đến server Socket.IO
    socket = IO.io(
      url,
      IO.OptionBuilder()
          .setTransports(['websocket']) // Sử dụng WebSocket làm transport
          .disableAutoConnect() // Tắt auto connect
          .build(),
    );

    // Kết nối tới server
    socket.connect();

    // Xử lý sự kiện khi kết nối thành công
    socket.onConnect((_) {
      print('Connected to WebSocket');
    });

    // Lắng nghe sự kiện tin nhắn từ server
    socket.on('updatePosts', (data) {
      onMessage(data);
    });

    // Lắng nghe sự kiện bình luận mới
    socket.on('updateComments', (data) {
      onMessage(data);
    });

    // Lắng nghe sự kiện yêu thích
    socket.on('updateFavorites', (data) {
      onMessage(data);
    });

    // Lắng nghe sự kiện tin nhắn mới
    socket.on('updateMessage', (data) {
      onMessage(data);
    });

    // Xử lý sự kiện lỗi
    socket.onError((error) {
      if (onError != null) {
        onError(error);
      }
    });

    // Xử lý khi kết nối đóng
    socket.onDisconnect((_) {
      if (onDone != null) {
        onDone();
      }
    });
  }

  // Gửi tin nhắn tới server
  void sendMessage(String event, dynamic message) {
    socket.emit(event, message);
  }

  // Đóng kết nối
  void disconnect() {
    socket.disconnect();
  }
}