// TODO: Agrege el idUsuario para que en todo el momento se sepa que usuario esta haciendo cada solicitud, y no
// TODO: hacer consulta cada vez que se requiera
class UserModel {
  String idUsuario;
  String email;
  String nombreusuario;
  String TipoUsuario;

  UserModel({required this.email, required this.nombreusuario, required this.TipoUsuario, required this.idUsuario});
}