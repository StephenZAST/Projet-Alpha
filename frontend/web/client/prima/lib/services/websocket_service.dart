import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:convert';

class WebSocketService {
  WebSocketChannel? _channel;
  final String _baseUrl = 'ws://localhost:3001/ws';
  final String _token;

  WebSocketService(this._token);

  void connect() {
    _channel = WebSocketChannel.connect(
      Uri.parse('$_baseUrl?token=$_token'),
    );
  }

  Stream<dynamic> get orderUpdates {
    if (_channel == null) connect();
    return _channel!.stream.map((message) => jsonDecode(message));
  }

  void dispose() {
    _channel?.sink.close();
  }
}
