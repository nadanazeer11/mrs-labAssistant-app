// import '../consts/consts.dart';
//
// class MainPage extends StatefulWidget {
//   final String title;
//
//   const MainPage({
//     @required this.title,
//   });
//
//   @override
//   _MainPageState createState() => _MainPageState();
// }
//
// class _MainPageState extends State<MainPage> {
//   final formKey = GlobalKey<FormState>();
//   String username = '';
//   String email = '';
//   String password = '';
//
//   @override
//   Widget build(BuildContext context) => Scaffold(
//     appBar: AppBar(
//       title: Text(widget.title),
//     ),
//     body: Form(
//       key: formKey,
//       //autovalidateMode: AutovalidateMode.onUserInteraction,
//       child: ListView(
//         padding: EdgeInsets.all(16),
//         children: [
//           buildUsername(),
//           const SizedBox(height: 16),
//           buildEmail(),
//           const SizedBox(height: 32),
//           buildPassword(),
//           const SizedBox(height: 32),
//           buildSubmit(),
//         ],
//       ),
//     ),
//   );
//
//   Widget buildUsername() => TextFormField(
//     decoration: InputDecoration(
//       labelText: 'Username',
//       border: OutlineInputBorder(),
//       // errorBorder:
//       //     OutlineInputBorder(borderSide: BorderSide(color: Colors.purple)),
//       // focusedErrorBorder:
//       //     OutlineInputBorder(borderSide: BorderSide(color: Colors.purple)),
//       // errorStyle: TextStyle(color: Colors.purple),
//     ),
//     validator: (value) {
//       if (value?.length < 4) {
//         return 'Enter at least 4 characters';
//       } else {
//         return null;
//       }
//     },
//     maxLength: 30,
//     onSaved: (value) => setState(() => username = value),
//   );
//
//   Widget buildEmail() => TextFormField(
//     decoration: InputDecoration(
//       labelText: 'Email',
//       border: OutlineInputBorder(),
//     ),
//     validator: (value) {
//       final pattern = r'(^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$)';
//       final regExp = RegExp(pattern);
//       if(value==null){
//         return 'Enter an email';
//       }
//       if (value.isEmpty) {
//         return 'Enter an email';
//       } else if (!regExp.hasMatch(value!)) {
//         return 'Enter a valid email';
//       } else {
//         return null;
//       }
//     },
//     keyboardType: TextInputType.emailAddress,
//
//   );
//
//   Widget buildPassword() => TextFormField(
//     decoration: InputDecoration(
//       labelText: 'Password',
//       border: OutlineInputBorder(),
//     ),
//     validator: (value) {
//       if(value==null){
//         return 'Password must be at least 7 characters long';
//       }
//       if (value.length < 7) {
//         return 'Password must be at least 7 characters long';
//       } else {
//         return null;
//       }
//     },
//
//     keyboardType: TextInputType.visiblePassword,
//     obscureText: true,
//   );
//
//   Widget buildSubmit() => Builder(
//     builder: (context) => ButtonWidget(
//       text: 'Submit',
//       onClicked: () {
//         final isValid = formKey.currentState.validate();
//         // FocusScope.of(context).unfocus();
//
//         if (isValid) {
//           formKey.currentState.save();
//
//           final message =
//               'Username: $username\nPassword: $password\nEmail: $email';
//           final snackBar = SnackBar(
//             content: Text(
//               message,
//               style: TextStyle(fontSize: 20),
//             ),
//             backgroundColor: Colors.green,
//           );
//           ScaffoldMessenger.of(context).showSnackBar(snackBar);
//         }
//       },
//     ),
//   );
// }
