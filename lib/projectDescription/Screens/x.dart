import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../config/colors.dart';
import '../../config/text_styles.dart';
import 'package:external_path/external_path.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:percent_indicator/percent_indicator.dart';

class PDFViewerPage extends StatefulWidget {
  final File file;
  final String ? url;
  final String ? basenamee;

  const PDFViewerPage({
    required this.file,
    required this.url,
    required this.basenamee
  });

  @override
  _PDFViewerPageState createState() => _PDFViewerPageState();
}

class _PDFViewerPageState extends State<PDFViewerPage> {

 // PDFViewController controller;
  int pages = 0;
  int indexPage = 0;
  bool isReady = false;
  String errorMessage = '';
  bool downloading=false;
  double perc=0;

  @override
  void initState() {
    getPermission();
  }

  void getPermission() async{
    debugPrint("getting permission");
    var status = await Permission.storage.status;
    debugPrint("status $status");
    if (!status.isGranted) {
      debugPrint("not granted");
      await Permission.storage.request();
    }
  }
  @override
  Widget build(BuildContext context) {
    final name = basename(widget.file.path);
    final text = '${indexPage + 1} of $pages';

    return SafeArea(
      child: Scaffold(
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
        body:
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(child: Text("${name}",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20),)),
                 downloading==true? CircularPercentIndicator(
                   radius: 20.0,
                   lineWidth: 5.0,
                   percent: perc,
                   progressColor: AppColorss.darkmainColor,
                 ): IconButton(onPressed: ()async{
                   setState(() {
                     downloading=true;
                   });
                    debugPrint("url aho${widget.basenamee}");
                    String path=await ExternalPath.getExternalStoragePublicDirectory(
                        ExternalPath.DIRECTORY_DOWNLOADS);
                    debugPrint("path ahoe $path");
                    String fullPath = "$path/${widget.basenamee}";
                   debugPrint("full path $fullPath");

                   Dio dio = Dio();
                    download2(dio,widget.url,fullPath, context);
                  }, icon: const Icon(Icons.download))
                ],
              ),
              Expanded(
                child: PDFView(
                  filePath: widget.file.path,
                  autoSpacing: true,
                  swipeHorizontal: true,
                  onRender: (_pages) {
                    setState(() {
                     // pages = _pages;
                      isReady = true;
                    });
                  },
                  onError: (error) {
                    setState(() {
                      errorMessage = error.toString();
                    });
                    print(error.toString());
                  },

                ),
              ),
            ],
          ),
        ),
        

      ),
    );
  }
  Future<File> _getLocalFile(String filename) async {
    // get the path to the document directory.
    String dir = (await getApplicationDocumentsDirectory()).path;
    // create the directory if it doesn't exist
    await Directory('$dir/Download').create(recursive: true);
    // create the file path
    String path = '$dir/Download/$filename';
    return File(path);
  }
  void download2(Dio dio, String? url, String fullPath, BuildContext context) async  {
    try{
      debugPrint("downloadinv value $downloading");
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
        downloading=false;
      });
    }
    catch(e){
      setState(() {
        downloading=false;
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
