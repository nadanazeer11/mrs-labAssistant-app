class Userr {
  final String name;
  final String email;
  final String password;
  final List<String> projects;
  final List<String> tasks;
  final bool createP;
  final bool addU;
  final bool inventoryM;
  final String token;

  Userr(
      { required this.name,
        required this.email,
        required this.password,
        required this.projects,
        required this.tasks,
        required this.createP,
        required this.addU,
        required this.inventoryM,
        required this.token
      });

}