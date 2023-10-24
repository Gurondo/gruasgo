import 'package:gruasgo/src/global/enviroment.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class ConnectionSocket{

  IO.Socket socket = IO.io(Enviroment().serverSocket);

}