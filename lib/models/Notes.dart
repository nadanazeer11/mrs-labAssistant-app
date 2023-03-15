class Notes{
  String user;
  String note;

  Notes({required this.user,required this.note});
  Map<String, dynamic> toMap() {
    return {
      'user': user,
      'note':note,
    };
  }
}