import 'package:flutter/material.dart';
import 'package:mrs/colors.dart';
class HomeP extends StatefulWidget {
  const HomeP({Key? key}) : super(key: key);

  @override
  State<HomeP> createState() => _HomePState();
}

class _HomePState extends State<HomeP> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8.0,15,8,0),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text("Your Projects",style: TextStyle(fontSize: 23,fontWeight:FontWeight.w500),),
                      IconButton(onPressed: (){}, icon: Icon(Icons.arrow_right))
                    ],
                  ),
                  ListView.builder(
                    //physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: 4,
                    itemBuilder: (context, index) => projects(context, index),
                  ),
                  SizedBox(height: 4,),
                  Divider(
                    height: 4,
                    color: AppColorss.darkmainColor.withOpacity(0.5),
                  ),
                  SizedBox(height: 4,),
                  // Row(
                  //   children: [
                  //     Text("Your Projects",style: TextStyle(fontSize: 23,fontWeight:FontWeight.w500),),
                  //     IconButton(onPressed: (){}, icon: Icon(Icons.arrow_right))
                  //   ],
                  // ),
                  // ListView.builder(
                  //   //physics: NeverScrollableScrollPhysics(),
                  //   shrinkWrap: true,
                  //   itemCount: 4,
                  //   itemBuilder: (context, index) => projects(context, index),
                  // ),
                  // SizedBox(height: 4,),
                  // Divider(
                  //   height: 4,
                  //   color: AppColorss.darkmainColor.withOpacity(0.5),
                  // )

                ]),
          ),
        ),

    );
  }
  projects(BuildContext context,index){
    DateTime  Start=DateTime.now();
    return GestureDetector(
      onTap: (){},
      child: Column(
        children: [
          Row(children: [
            Text('${index+1}',style: TextStyle(fontWeight: FontWeight.w400,color: Colors.grey,fontSize: 27),),
            SizedBox(width: 9,),
            Expanded(child: Text("Introduction to robotics and lab",style: TextStyle(color: Colors.black.withOpacity(0.7),fontSize: 22),)),
          ]),
          Padding(
            padding: const EdgeInsets.fromLTRB(35,5,5,5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(Icons.alarm,color: Colors.black,),
                Text('${Start.day}/${Start.month}/${Start.year}'),
              ],
            ),
          )
        ],
      ),
    );
  }
}
