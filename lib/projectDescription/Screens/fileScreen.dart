import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dialogs/flutter_dialogs.dart';
import 'package:mrs/config/colors.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import '../../config/text_styles.dart';
import '../../models/FileObj.dart';
import '../backend/projectDescripController.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:external_path/external_path.dart';
import 'package:percent_indicator/percent_indicator.dart';

class fileScreen extends StatefulWidget {
  const fileScreen({Key? key}) : super(key: key);

  @override
  State<fileScreen> createState() => _fileScreenState();
}

class _fileScreenState extends State<fileScreen> {
  bool loading=false;
  double perc=0;

  @override
  Widget build(BuildContext context) {
    ProjectDContr pdc=new ProjectDContr();
    final args=ModalRoute.of(context)!.settings.arguments as FileObj;
    String link=args.url ?? "https://firebasestorage.googleapis.com/v0/b/mrslab-1c119.appspot.com/o/images.png?alt=media&token=87f0491f-aa66-4f2b-8437-20404a819e1c";
    if(args.url==null || args.baseName==null){
      return Center(child:Text("nothing to see",style: TextStyle(fontSize: 16,color: AppColorss.darkmainColor),));
    }
    else{
      debugPrint("url gay sa7 $link");
      return SafeArea(
          child:Scaffold(
            appBar:AppBar(
              backgroundColor:AppColorss.lightmainColor ,
              elevation: 0,
              title:Text("MRS",style:subHeadingStyle) ,
              actions: [
                IconButton(onPressed: (){}, icon:Icon(Icons.filter_list_outlined))
              ],
              leading: IconButton(onPressed: (){
                Navigator.pop(context);
              },icon: Icon(Icons.arrow_back_ios),),
            ),
            body: SingleChildScrollView(
              child: Column(children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                    Expanded(child: Text("${args.baseName}",style: TextStyle(fontSize: 20,fontWeight: FontWeight.w400,overflow: TextOverflow.ellipsis),)),
                    //   Tooltip(message: args.baseName, child: Text("... ${args.baseName?.substring(0, 10)}" ) ),
                    loading==true ? CircularPercentIndicator(
                      radius: 20.0,
                      lineWidth: 5.0,
                      percent: perc,
                      progressColor: AppColorss.darkmainColor,
                    ):IconButton(onPressed: ()async {
                      setState(() {
                        loading=true;
                      });
                      String path=await ExternalPath.getExternalStoragePublicDirectory(
                          ExternalPath.DIRECTORY_DOWNLOADS);
                      // debugPrint("path ahoe $path");
                      String fullPath = "$path/${args.baseName}";
                      debugPrint("full path $fullPath");
                      Dio dio = Dio();
                      download2(dio,args.url,fullPath, context);
                    }, icon:Icon(Icons.download))
                  ],),
                ),
            Image.network(
                link,
                fit: BoxFit.fill,
                loadingBuilder: (BuildContext context, Widget child,
                    ImageChunkEvent? loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  );
                },
                errorBuilder: (context, exception, stackTrace) {
                  return Text("Error loading the image");
                }
            )]),
            ),
          )
      );
    }
  }
  void download2(Dio dio, String? url, String fullPath, BuildContext context) async  {
    try{
      String url2=url?? "f";
      Response response = await dio.get(
        url2,
        onReceiveProgress: showDownloadProgress,
        //Received data with List<int>
        options: Options(
            responseType: ResponseType.bytes,
            followRedirects: false,
            validateStatus: (status) {
              return status! < 500;
            }),
      );

      //write in download folder
      File file = File(fullPath);
      var raf = file.openSync(mode: FileMode.write);
      raf.writeFromSync(response.data);
      await raf.close();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('File successfully downloaded!'),
          backgroundColor: Colors.green,
        ),
      );
      setState(() {
        loading=false;
      });
    }
    catch(e){
      setState(() {
        loading=false;
      });
      debugPrint(e.toString());
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error downloading file,please try again'),
          backgroundColor: Colors.red,
        ),
      );
    }


  }
  void showDownloadProgress(receivedBytes,totalBytes){
    if(totalBytes!=-1){
      setState(() {
        perc = (receivedBytes / totalBytes * 100)/100;
      });
      print((receivedBytes / totalBytes * 100).toStringAsFixed(0) + "%");

    }
  }
}
