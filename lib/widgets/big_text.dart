import 'package:flutter/cupertino.dart';

class Big_text extends StatelessWidget {
   Color? color;
  final String text;
  double size;
  TextOverflow overflow;


   Big_text({Key? key,
  this.color=const Color(0xFF332d2b),
  required this.text,
  this.overflow=TextOverflow.ellipsis,
  this.size=20}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return
      Text(
        text,
        overflow: overflow,
        maxLines: 1,
        style: TextStyle(color: color,
        fontWeight: FontWeight.w400,
          fontFamily: 'Roboto',
          fontSize: size
        ),
      );
  }
}
