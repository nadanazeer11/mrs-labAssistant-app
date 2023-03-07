
import 'package:mrs/screens/project_descrip.dart';

import '../colors.dart';
import '../consts/consts.dart';

class Project_item extends StatelessWidget {
  final String id;
  final String name;
  final DateTime deadline;
  Project_item(this.id,this.name,this.deadline);
  @override
  Widget build(BuildContext context) {
    return
      GestureDetector(
        child: Column(
          children: [
            ListTile(
              title: Text(name),
              subtitle: Text('Deadline: ${deadline.day.toString().padLeft(2, '0')}/${deadline.month.toString().padLeft(2, '0')}/${deadline.year.toString()}'),
            ),
            Divider(height: 4,color: AppColorss.darkmainColor,indent: 20,endIndent: 20,)
          ],
        ),
        onTap: () async {
          await Get.to(ProjDescrip());
        },
      );
  }
}
