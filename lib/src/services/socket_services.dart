import 'package:gruasgo/src/global/enviroment.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

enum ServerStatus {
  online,
  offline,
  connecting
}

class SocketService{
  

  static IO.Socket? _socket;

  static IO.Socket get socket => _socket!;
  static Function get emit => _socket!.emit;
  static Function get on => _socket!.on;
  static Function get off => _socket!.off;

  SocketService._();

  
  static connection(){
    _socket = IO.io(Enviroment().serverSocket, {
      'transports': ['websocket'],
      'autoConnect' : false,
    });
    _socket!.on('connect', (_) {});

    _socket!.on('disconnect', (_) {});

  }

  static open() => _socket!.open();

  static close() => _socket!.close();

}