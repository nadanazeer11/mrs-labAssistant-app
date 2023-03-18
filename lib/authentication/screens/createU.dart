import 'package:flutter/material.dart';

import '../../config/colors.dart';
import '../../config/text_styles.dart';

class CreateU extends StatefulWidget {
  const CreateU({Key? key}) : super(key: key);

  @override
  State<CreateU> createState() => _CreateUState();
}

class _CreateUState extends State<CreateU> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:  AppBar(
        backgroundColor:AppColorss.lightmainColor ,
        elevation: 0,
        title:Text("MRS",style:subHeadingStyle) ,
        actions: [
          IconButton(onPressed: (){}, icon:Icon(Icons.filter_list_outlined))
        ],
      ),

    );
  }
}
