String getHoraHelpers(){
  DateTime now = DateTime.now();
  String formattedDateTime = "${now.hour}:${now.minute}:${now.second}";
  return formattedDateTime;
}