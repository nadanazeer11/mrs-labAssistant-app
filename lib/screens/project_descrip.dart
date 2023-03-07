import 'package:mrs/controllers/project_controller.dart';
import 'package:mrs/widgets/big_text.dart';
import 'package:mrs/widgets/small_text.dart';
import 'package:flutter/material.dart';
import '../widgets/appbar.dart';
import './../colors.dart';
//import './fillHome.dart';
import 'package:fluentui_icons/fluentui_icons.dart';
import 'dart:ui';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mrs/colors.dart';
import 'package:mrs/consts/consts.dart';
import 'package:mrs/dimensions.dart';
class ProjDescrip extends StatefulWidget {
  const ProjDescrip({Key? key}) : super(key: key);

  @override
  State<ProjDescrip> createState() => _ProjDescripState();
}

class _ProjDescripState extends State<ProjDescrip> {
  DateTime Start= DateTime.now();
  @override
  Widget build(BuildContext context) {
    double w=MediaQuery.of(context).size.width;
    double h=MediaQuery.of(context).size.height;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar( backgroundColor: Colors.transparent,
            elevation: 0.0,
            toolbarHeight: 50,
            leading:
            CircleAvatar(
              backgroundImage: AssetImage("assets/mrsrb.png"),
              backgroundColor: Colors.white,
              radius: 2,

            ),

            title: Text("MRS",style: TextStyle(color: AppColorss.darkmainColor),),

            //centerTitle: true,
            flexibleSpace: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(bottomLeft: Radius.circular(10),bottomRight: Radius.circular(10)),
                  color: AppColorss.lightGrey
              ),
            )),
        body:Stack(
          children: [
            SingleChildScrollView(
              child: SizedBox(
                width: double.infinity,
                child:Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      Text("Multi robotic system",style:TextStyle(fontSize: 29,fontWeight: FontWeight.w500,color: Colors.black87,fontStyle: FontStyle.normal)),
                      SizedBox(height: 9,),
                      Text.rich(
                    TextSpan(
                      text: 'Created By: ',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                      children: <TextSpan>[
                        TextSpan(
                          text: 'Ahmed Mohamed',
                          style: TextStyle(fontWeight: FontWeight.w400, color: AppColorss.darkmainColor),
                        ),

                      ],
                    ),
                  ),
                      SizedBox(height: 12,),
                      Row(
                        children: [
                          Icon(Icons.add_alert_sharp,color: Colors.red,),
                          Text('${Start.day}/${Start.month}/${Start.year}',style: TextStyle(fontSize:20),),

                            ],
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 15),
                        child: Divider(
                          height: 4,
                          color: Colors.blue,
                        ),
                      ),
                      Text(
                        "Description",
                        style: TextStyle(fontWeight: FontWeight.w300,fontSize: 22,color: Color(0xFF36454F)),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      Text(
                        'Your recipe has been uploaded, you can see it on your profile. Your recipe has been uploaded, you can see it on your.Your recipe has been uploaded, you can see it on your.Your recipe has been uploaded, you can see it on your.Your recipe has been uploaded, you can see it on your.Your recipe has been uploaded, you can see it on yourYour recipe has been uploaded, you can see it on your',
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium!
                            .copyWith(color:Color(0xFF9FA5C0)),
                      ),

                  ],
                  ),
                )
              ),
            ),

           // buttonArrow(context),
            scroll(context),


          ],
        )
      ),
    );
  }
  buttonArrow(BuildContext context){
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: InkWell(
        onTap: (){
          Navigator.pop(context);
        },
        child: Container(
          clipBehavior: Clip.hardEdge,
          height: 55,
          width: 55,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),

          ),
          child: BackdropFilter(filter: ImageFilter.blur(
            sigmaX: 10,sigmaY: 10
          ),child: Container(
              height: 55,
              width: 55,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
              ),
            child: Icon(
              Icons.arrow_back_ios,
              size: 20,
                color: Colors.white,
            ),
          ),

          ),
        ),
      ),
    );
  }
  scroll(BuildContext context){
    double w=MediaQuery.of(context).size.width;

    final h = MediaQuery.of(context).size.height;
    final initialChildSize = 0.6;
    return Container(
      height: h,
      child: DraggableScrollableSheet(
        initialChildSize: initialChildSize,
        maxChildSize: 0.7,
        minChildSize: 0,
          builder: (context, scrollController){
          return Container(
            clipBehavior: Clip.hardEdge,
              decoration:  BoxDecoration(
              color: AppColorss.darkmainColor,
              borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20)),
              ),
            child: SingleChildScrollView(
              controller: scrollController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Text("Notes:",style: TextStyle(fontSize: 21,fontWeight: FontWeight.w500,color: Colors.white),),
                        IconButton(onPressed: (){}, icon: Icon(Icons.add))
                      ],
                    ),
                  ),
                  ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: 10,
                    itemBuilder: (context, index) => steps(context, index),
                  ),
                ],
              ),
            ),
          );
          }
      ),
    );
  }
  steps(BuildContext context, int index) {

    return Padding(
      padding: const EdgeInsets.fromLTRB(4,0,3,27),
      child:
      Container(
        margin:EdgeInsets.fromLTRB(4, 0, 3, 0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              CircleAvatar(
                radius: 30,
                // add avatar image or tex
              ),
              SizedBox(width: 15),
              Expanded(
                child: SizedBox(
                  child: Text(
                      "Your recipe has been uploaded, you can see it on your profile. Your recipe has been uploaded, you can see it on your",
                    style: TextStyle(fontSize: 16,color: Colors.black54),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

    );
  }
}

