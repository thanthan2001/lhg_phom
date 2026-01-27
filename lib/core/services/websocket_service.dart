import 'package:socket_io_client/socket_io_client.dart' as IO;

class WebSocketService {
  final String url;
  late IO.Socket socket;

  WebSocketService(this.url);

  void connect(
    Function(String) onMessage, {
    Function? onError,
    Function? onDone,
  }) {
    socket = IO.io(
      url,
      IO.OptionBuilder()
          .setTransports(['websocket']) 
          .disableAutoConnect() 
          .build(),
    );

    socket.connect();

    socket.onConnect((_) {});

    socket.on('updatePosts', (data) {
      onMessage(data);
    });

    socket.on('updateComments', (data) {
      onMessage(data);
    });

    socket.on('updateFavorites', (data) {
      onMessage(data);
    });

    socket.on('updateMessage', (data) {
      onMessage(data);
    });

    socket.onError((error) {
      if (onError != null) {
        onError(error);
      }
    });

    socket.onDisconnect((_) {
      if (onDone != null) {
        onDone();
      }
    });
  }

  void sendMessage(String event, dynamic message) {
    socket.emit(event, message);
  }

  void disconnect() {
    socket.disconnect();
  }
}
