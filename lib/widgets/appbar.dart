import '../colors.dart';
import '../consts/consts.dart';

  Widget AppB(){
     return AppBar( backgroundColor: Colors.transparent,
      elevation: 0.0,
      toolbarHeight: 50,
      leading:
      CircleAvatar(
        backgroundImage: AssetImage("assets/mrsrb.png"),
        backgroundColor: Colors.white,
        radius: 2,

      ),

      title: Text("MRS"),

      //centerTitle: true,
      flexibleSpace: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.only(bottomLeft: Radius.circular(10),bottomRight: Radius.circular(10)),
            color: AppColorss.darkmainColor
        ),
      ));
  }

