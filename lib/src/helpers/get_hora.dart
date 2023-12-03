String getHoraHelpers(){
  DateTime now = DateTime.now();
  String formattedDateTime = "${now.hour}:${now.minute}";
  return formattedDateTime;
}