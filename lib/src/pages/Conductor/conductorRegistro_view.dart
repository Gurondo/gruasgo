import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:gruasgo/src/utils/colors.dart' as utils;
import 'package:gruasgo/src/widgets/button_app.dart';
import 'package:image_picker/image_picker.dart';
import 'package:gruasgo/src/pages/Conductor/conductorRegistro_controller.dart';
import 'dart:io';
import 'package:gruasgo/src/utils/snackbar.dart' as utils;
import 'package:permission_handler/permission_handler.dart';


class conductorReg extends StatefulWidget {
  const conductorReg({super.key});

  @override
  State<conductorReg> createState() => _conductorRegState();

}

class _conductorRegState extends State<conductorReg> {

  final conductorController _con = conductorController();
  GlobalKey<ScaffoldState> key = GlobalKey<ScaffoldState>();

  bool showWidgets = false;
  DateTime selectedDate = DateTime.now();
  File? _image;
  File? _imagePlaca;
  bool _obscureText = true;
  String? _selectedCategory = 'Selecciona una categoria'; // Categoría seleccionada
  String? _selectedItem = 'Selecciona una subcategoria';     // Ítem seleccionado dentro de la categoría

  Map<String,
  List<String>> _options = {
    'Selecciona una categoria': ['Selecciona una subcategoria'],
    'GRUAS': ['Grua Palanca', 'Grua Pluma', 'Grua Crane'],
    'MONTA CARGA': ['Pequeña', 'Mediana', 'Grande'],
    'VOLQUETAS': ['Volqueta 5cb', 'Volqueta de 10cb', 'Volqueta de 15cb'],
  };

  Future<void> _getImageFromGallery() async {
    final imagePicker = ImagePicker();
    final pickedFile = await imagePicker.pickImage(source: ImageSource.camera);

      if (pickedFile != null) {
        // Solicitar permisos de escritura
        final status = await Permission.storage.request();
        if (status.isGranted) {
        // Obtener el directorio de almacenamiento de la aplicación
        final rootDir = Directory('/storage/emulated/0/'); // Ruta a la raíz del almacenamiento interno
        // Crear un nuevo archivo en la raíz con un nombre único
        final imageFileName = 'image_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final imagePath = '${rootDir.path}/$imageFileName';

        // Copiar la imagen desde la ubicación temporal a la ubicación permanente
        File(pickedFile.path).copySync(imagePath);
        setState(() {
          _image = File(imagePath);
          //print('La foto capturada se encuentra en: $imagePath');
        });
        } else {
          utils.Snackbar.showSnackbar(context, key, 'Permiso de escritura denegado, debe permir el permiso de excritura');
        }

      } else {
        utils.Snackbar.showSnackbar(context, key, 'No se seleccionó ninguna imagen.');
      }
  }

  Future<void> _getImageFromGalleryPlaca() async {
    final imagePicker = ImagePicker();
    final pickedFile = await imagePicker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      // Solicitar permisos de escritura
      final status = await Permission.storage.request();
      if (status.isGranted) {
        // Obtener el directorio de almacenamiento de la aplicación
        final rootDir = Directory('/storage/emulated/0/'); // Ruta a la raíz del almacenamiento interno
        // Crear un nuevo archivo en la raíz con un nombre único
        final imageFileName = 'image_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final imagePath = '${rootDir.path}/$imageFileName';

        // Copiar la imagen desde la ubicación temporal a la ubicación permanente
        File(pickedFile.path).copySync(imagePath);
        setState(() {
          _imagePlaca = File(imagePath);
          //print('La foto capturada se encuentra en: $imagePath');
        });
      } else {
        utils.Snackbar.showSnackbar(context, key, 'Permiso de escritura denegado, debe permir el permiso de excritura');
      }

    } else {
      utils.Snackbar.showSnackbar(context, key, 'No se seleccionó ninguna imagen.');
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        _con.fechaVencimientoController.text = "${selectedDate.toLocal()}".split(' ')[0];
      });
    }
  }


  @override
  void initState() {
    // TODO: implement initState
    //print('INIT STATE');
    _con.fechaVencimientoController.text = "${selectedDate.toLocal()}".split(' ')[0];
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      _con.init(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: utils.Colors.logoColor,
        ),
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 10),
              _textRegistrarseConduc(),
              _txtNombreAp(),
              _txtNroLicencia(),
              _txtFechaVenLic(),
              _txtEmail(),
              Row(
                children: <Widget>[
                  _imagenes(),
                  // SizedBox(width: 20), // Espacio entre los dos widgets
                  _txtCelular(),
                ],
              ),
              _txtPassword(),
              _txtDireccion(),
              _textRegistrarVehiculo(),
              Row(
                children: <Widget>[
                  _txtPlaca(),
                  _txtCRPVA(),
                ],
              ),
              _cboCategoria(),
              _cboSubCategoria(),
              Row(
                children: <Widget>[
                  _txtCapTon(),
                  _txtCapCub(),
                ],
              ),
              Row(
                children: <Widget>[
                  _txtMarca(),
                  _txtModelo(),
                ],
              ),
              _textFotoVehiculo(),
              _fotoVehiculo(),
              _textFotoPlaca(),
              _fotoPlaca(),
              _datosEmpresa(),
              _btnCreaCuenta(),

            ],
          ),
        )
    );
  }

    Widget _textRegistrarseConduc(){
    return Container(
      alignment: Alignment.centerLeft,
      margin: const EdgeInsets.symmetric(horizontal: 15,vertical: 10), // MARGENES DEL TEXTO LOGIN
      child: const Text(
        'Registro de Conductor',
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 25,
        ),
      ),
    );
  }

  Widget _txtNombreAp(){
    return Container(
      margin: const EdgeInsets.only(top: 5, left: 15, right: 15, bottom: 10),
      height: 70, // ALTO DEL TEXT
      child: TextField(
        controller: _con.nombreapeController,
        maxLength: 30,
        style: const TextStyle(fontSize: 17),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z ]')),
        ],
        decoration: InputDecoration(
          labelText: 'Nombre',
          filled: true, // Habilita el llenado de color de fondo
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ) ,
      ),
    );
  }

  Widget _txtNroLicencia(){
    return Container(
      margin: const EdgeInsets.only(top: 5, left: 15, right: 15, bottom: 10),
      height: 70, // ALTO DEL TEXT
      child: TextField(
        controller: _con.numLicenciaController,
        maxLength: 10,
        style: const TextStyle(fontSize: 17),
        keyboardType: TextInputType.number,
        inputFormatters: <TextInputFormatter> [
          FilteringTextInputFormatter.digitsOnly,
        ],
        decoration: InputDecoration(
          // hintText: 'Correo Electronico',
          labelText: 'Nro de Licencia',
          filled: true, // Habilita el llenado de color de fondo
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ) ,
      ),
    );
  }

  Widget _txtFechaVenLic(){
    return Container(
      margin: const EdgeInsets.only(top: 5, left: 15, right: 15, bottom: 10),
      height: 70, // ALTO DEL TEXT
      child: TextField(
        controller: _con.fechaVencimientoController,
        decoration: InputDecoration(
          // hintText: 'Correo Electronico',
          labelText: 'Fecha Vencimiento Licencia',
          filled: true, // Habilita el llenado de color de fondo
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          suffixIcon: IconButton(
            onPressed: () {
              _selectDate(context);
            },
            icon: const Icon(Icons.calendar_today),
          ),
        ),
        readOnly: true,
        onTap: () {
          _selectDate(context);
        },
      ),
    );
  }

  Widget _txtEmail(){
    return Container(
      margin: const EdgeInsets.only(top: 5, left: 15, right: 15, bottom: 10),
      height: 70,
      child: TextField(
        controller: _con.emailController,
        maxLength: 35,
        decoration: InputDecoration(
          // hintText: 'Correo Electronico',
          labelText: 'Correo Electrónico',
          filled: true, // Habilita el llenado de color de fondo
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ) ,
      ),
    );
  }

  Widget _imagenes(){
    return Container(
/*      width: 100, // Ancho del primer widget
      height: 100, // Alto del primer widget*/
      //margin: const EdgeInsets.symmetric(horizontal: 15,vertical: 3),
      margin: const EdgeInsets.only(top: 0, left: 15, right: 15, bottom: 10),
      //color: Colors.white,
      child:
      Image.asset(
        'assets/img/591.png',  // Ruta de la imagen en la carpeta de assets
        width: 80,              // Ancho de la imagen
        height: 80,             // Alto de la imagen
      ),
      /*CircleAvatar(
        backgroundImage: AssetImage('assets/img/my_location.png'),
      ),*/
    );
  }

  Widget _txtCelular(){
    return Container(
      width: 233, // Ancho del segundo widget
      height: 70, // Alto del segundo widget
      margin: const EdgeInsets.only(top: 0, left: 0, right: 0, bottom: 10),
      child: TextField(
        controller: _con.celularController,
        maxLength: 8,
        style: const TextStyle(fontSize: 17),
        keyboardType: TextInputType.number,
        inputFormatters: <TextInputFormatter> [
          FilteringTextInputFormatter.digitsOnly,
        ],
        decoration: InputDecoration(
          // hintText: 'Correo Electronico',
          labelText: 'Telefono',
          filled: true, // Habilita el llenado de color de fondo
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ) ,
      ),
    );
  }

  Widget _txtPassword(){
    return Container(
      margin: const EdgeInsets.only(top: 5, left: 15, right: 15, bottom: 10),
      height: 70,
      child: TextField(
        controller: _con.passwordController,
        maxLength: 50,
        obscureText: _obscureText,
        style: const TextStyle(fontSize: 17),
        decoration: InputDecoration(
          // hintText: 'Correo Electronico',
          labelText: 'Contraseña',
          filled: true, // Habilita el llenado de color de fondo
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          suffixIcon: IconButton(
            icon: Icon(
              _obscureText ? Icons.visibility : Icons.visibility_off,
            ),
            onPressed: () {
              setState(() {
                _obscureText = !_obscureText; // Cambia entre mostrar y ocultar la contraseña
              });
            },
          ),
        ) ,
      ),
    );
  }

  Widget _txtDireccion(){
    return Container(
      margin: const EdgeInsets.only(top: 5, left: 15, right: 15, bottom: 10),
      height: 90,
      child: TextField(
        controller: _con.domicilioController,
        maxLength: 100,
        decoration: InputDecoration(
          // hintText: 'Correo Electronico',
          labelText: 'Domicilio del conductor',
          filled: true, // Habilita el llenado de color de fondo
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ) ,
      ),
    );
  }

  Widget _textRegistrarVehiculo(){
    return Container(
      alignment: Alignment.centerLeft,
      margin: const EdgeInsets.symmetric(horizontal: 15,vertical: 10), // MARGENES DEL TEXTO LOGIN
      child: const Text(
        'Datos del Vehiculo',
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 25,
        ),
      ),
    );
  }

  Widget _txtPlaca(){
    return Container(
      width: 130, // Ancho del segundo widget
      height: 70, // Alto del segundo widget
      margin: const EdgeInsets.only(top: 0, left: 15, right: 15, bottom: 10),
      child: TextField(
        controller: _con.placaVehiculoController,
        maxLength: 9,
        style: const TextStyle(fontSize: 17),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'[A-Z0-9 ]')),
        ],
        decoration: InputDecoration(
          // hintText: 'Correo Electronico',
          labelText: 'PLACA',
          filled: true, // Habilita el llenado de color de fondo
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ) ,
      ),
    );
  }

  Widget _txtCRPVA(){
    return Container(
      width: 185, // Ancho del segundo widget
      height: 70, // Alto del segundo widget
      margin: const EdgeInsets.only(top: 0, left: 0, right: 0, bottom: 10),
      child: TextField(
        controller: _con.ruatVehiculoController,
        style: const TextStyle(fontSize: 17),
        maxLength: 12,
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'[A-Z0-9]')),
        ],
        decoration: InputDecoration(
          // hintText: 'Correo Electronico',
          labelText: 'CRPVA - RUAT',
          filled: true, // Habilita el llenado de color de fondo
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ) ,
      ),
    );
  }

  Widget _cboCategoria(){
    return Container(
      //margin: const EdgeInsets.only(top: 5, left: 0, right: 0, bottom: 10),
      margin: const EdgeInsets.symmetric(horizontal: 1,vertical: 10), // MARGENES DEL TEXTO LOGIN
      width: 330,
      height: 70,// Ancho del DropdownButton
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: 'Seleccione una Categoria',
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(width: 1,color: Colors.black, style: BorderStyle.solid),
          ),
        ),
        value: _selectedCategory,
        items: _options.keys.map((String category) {
          return DropdownMenuItem<String>(
            value: category,
            child: Text(category),
          );
        }).toList(),
        onChanged: (String? newValue) {
          setState(() {
            _selectedCategory = newValue!;
            //_selectedItem = 'Categoría 1';
            _con.categoriaController.text = _selectedCategory!;
            _selectedItem = _options[_selectedCategory]?.first ?? '';// Restablecer el ítem seleccionado cuando cambie la categoría
          });
        },
      ),
    );
  }

  Widget _cboSubCategoria(){
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 1,vertical: 10), // MARGENES DEL TEXTO LOGIN
      width: 330,
      height: 70,
      child:DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: 'Seleccione la Sub Categoria',
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(width: 1,color: Colors.black, style: BorderStyle.solid),
          ),
        ),
        value: _selectedItem,
        items: _options[_selectedCategory]?.map((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(item),
          );
        }).toList() ?? [],
        onChanged: (String? newValue) {
          setState(() {
            _selectedItem = newValue!;
            _con.subcategoriaController.text = _selectedItem!;
          });
        },
      ),
    );
  }

  Widget _txtCapTon(){
    return Container(
      width: 156, // Ancho del segundo widget
      height: 70, // Alto del segundo widget
      margin: const EdgeInsets.only(top: 10, left: 15, right: 0, bottom: 10),
      child: TextField(
        controller: _con.toneladasController,
        style: const TextStyle(fontSize: 17),
        maxLength: 5,
        keyboardType: TextInputType.number,
        inputFormatters: <TextInputFormatter> [
          FilteringTextInputFormatter.digitsOnly,
        ],
        textAlign: TextAlign.center,
        decoration: InputDecoration(
          // hintText: 'Correo Electronico',
          labelText: 'Toneladas',
          filled: true, // Habilita el llenado de color de fondo
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ) ,
      ),
    );
  }

  Widget _txtCapCub(){
    return Container(
      width: 156, // Ancho del segundo widget
      height: 70, // Alto del segundo widget
      margin: const EdgeInsets.only(top: 10, left: 15, right: 0, bottom: 10),
      child: TextField(
        controller: _con.cubosController,
        style: const TextStyle(fontSize: 17),
        maxLength: 5,
        keyboardType: TextInputType.number,
        inputFormatters: <TextInputFormatter> [
          FilteringTextInputFormatter.digitsOnly,
        ],
        textAlign: TextAlign.center,
        decoration: InputDecoration(
          // hintText: 'Correo Electronico',
          labelText: 'Cap Cubos',
          filled: true, // Habilita el llenado de color de fondo
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ) ,
      ),
    );
  }

  Widget _txtMarca(){
    return Container(
      width: 156, // Ancho del segundo widget
      height: 70, // Alto del segundo widget
      margin: const EdgeInsets.only(top: 10, left: 15, right: 0, bottom: 10),
      child: TextField(
        controller: _con.marcaController,
        style: const TextStyle(fontSize: 17),
        maxLength: 25,
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z ]')),
        ],
        textAlign: TextAlign.center,
        decoration: InputDecoration(
          // hintText: 'Correo Electronico',
          labelText: 'Marca',
          filled: true, // Habilita el llenado de color de fondo
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ) ,
      ),
    );
  }

  Widget _txtModelo(){
    return Container(
      width: 156, // Ancho del segundo widget
      height: 70, // Alto del segundo widget
      margin: const EdgeInsets.only(top: 10, left: 15, right: 0, bottom: 10),
      child: TextField(
        controller: _con.modeloController,
        style: const TextStyle(fontSize: 17),
        maxLength: 25,
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'[A-Z0-9 ]')),
        ],
        textAlign: TextAlign.center,
        decoration: InputDecoration(
          // hintText: 'Correo Electronico',
          labelText: 'Modelo',
          filled: true, // Habilita el llenado de color de fondo
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ) ,
      ),
    );
  }

  Widget _textFotoVehiculo(){
    return Container(
      alignment: Alignment.centerLeft,
      margin: const EdgeInsets.symmetric(horizontal: 15,vertical: 10), // MARGENES DEL TEXTO LOGIN
      child: const Text(
        'Foto del Vehiculo',
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _fotoVehiculo(){
    return Container(
      width: 280, // Ancho del primer widget
      height: 280, // Alto del primer widget
      //margin: const EdgeInsets.symmetric(horizontal: 15,vertical: 3),
      margin: const EdgeInsets.only(top: 0, left: 15, right: 15, bottom: 10),
      //color: Colors.white,
      child:
      GestureDetector(
        onTap: _getImageFromGallery,
        child:
            _image == null
              ? Image.asset('assets/img/sin_imagen.jpg')  //Text('no selecciono')
              : Image.file(_image!),
      ),
    );
  }

  Widget _textFotoPlaca(){
    return Container(
      alignment: Alignment.centerLeft,
      margin: const EdgeInsets.symmetric(horizontal: 15,vertical: 2), // MARGENES DEL TEXTO LOGIN
      child: const Text(
        'Foto de Placa',
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _fotoPlaca(){
    return Container(
      width: 280, // Ancho del primer widget
      height: 280, // Alto del primer widget
      //margin: const EdgeInsets.symmetric(horizontal: 15,vertical: 3),
      margin: const EdgeInsets.only(top: 0, left: 15, right: 15, bottom: 10),
      //color: Colors.white,
      child:
      GestureDetector(
        onTap: _getImageFromGalleryPlaca,
        child:
        _imagePlaca == null
            ? Image.asset('assets/img/sin_imagen.jpg')  //Text('no selecciono')
            : Image.file(_imagePlaca!),
      ),
    );
  }

  Widget _datosEmpresa(){
    return Container(
      alignment: Alignment.centerLeft,
      margin: const EdgeInsets.symmetric(horizontal: 10,vertical: 10),
      child: Column(
        children: <Widget>[
          ExpansionPanelList.radio(
            elevation: 1,
            expandedHeaderPadding: const EdgeInsets.all(8.0),
            dividerColor: Colors.grey,
            animationDuration: const Duration(milliseconds: 500),
            children: [
              ExpansionPanelRadio(
                headerBuilder: (BuildContext context, bool isExpanded) {
                  return const ListTile(
                    title: Text('Datos de la Empresa',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  );
                },
                body: Container(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    // crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      //Text('Contenido de la sección expandible'),
                      Container(
                        margin: const EdgeInsets.only(top: 0, left: 0, right: 0, bottom: 10),
                        height: 70, // ALTO DEL TEXT
                        child: TextField(
                          maxLength: 40,
                          style: const TextStyle(fontSize: 17),
                          inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z ]')),
                          ],
                          controller: _con.razonSocialController,

                          decoration: InputDecoration(
                            // hintText: 'Correo Electronico',
                            labelText: 'Razon Social',
                            filled: true, // Habilita el llenado de color de fondo
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ) ,
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 5, left: 0, right: 0, bottom: 10),
                        height: 70, // ALTO DEL TEXT
                        child: TextField(
                          style: const TextStyle(fontSize: 17),
                          maxLength: 15,
                          keyboardType: TextInputType.number,
                          inputFormatters: <TextInputFormatter> [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          controller: _con.nitEmpController,
                          decoration: InputDecoration(
                            labelText: 'NIT',
                            filled: true, // Habilita el llenado de color de fondo
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ) ,
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 5, left: 0, right: 0, bottom: 10),
                        height: 100, // ALTO DEL TEXT
                        child: TextField(
                          controller: _con.direccionEmpController,
                          style: const TextStyle(fontSize: 17),
                          maxLength: 60,
                          decoration: InputDecoration(
                            labelText: 'Direccion Empresa',
                            filled: true, // Habilita el llenado de color de fondo
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ) ,
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 5, left: 0, right: 0, bottom: 10),
                        height: 70, // ALTO DEL TEXT
                        child: TextField(
                          controller: _con.celularEmpController,
                          style: const TextStyle(fontSize: 17),
                          maxLength: 8,
                          keyboardType: TextInputType.number,
                          inputFormatters: <TextInputFormatter> [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          decoration: InputDecoration(
                            labelText: 'Celular',
                            filled: true, // Habilita el llenado de color de fondo
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ) ,
                        ),
                      ),

                      Container(
                        margin: const EdgeInsets.only(top: 5, left: 0, right: 0, bottom: 10),
                        height: 70, // ALTO DEL TEXT
                        child: TextField(
                          controller: _con.referenciasEmpController,
                          style: const TextStyle(fontSize: 17),
                          maxLength: 60,
                          decoration: InputDecoration(
                            // hintText: 'Correo Electronico',
                            labelText: 'Referencias',
                            filled: true, // Habilita el llenado de color de fondo
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ) ,
                        ),
                      ),
                    ],
                  ),
                ),
                value: 1, // Valor que debe coincidir con el grupo de radio
                canTapOnHeader: true,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _btnCreaCuenta(){
    return Container(
        margin: const EdgeInsets.symmetric(horizontal: 15,vertical: 25),

        child: ButtonApp(
          text: 'Registrar',
          color: Colors.amber,
          textColor: Colors.black,
          onPressed: _con.registerConductor,
        )
    );
  }
}
