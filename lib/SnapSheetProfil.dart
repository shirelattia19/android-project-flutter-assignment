import 'package:flutter/material.dart';
import 'package:hello_me/user_repository.dart';
import 'package:provider/provider.dart';
import 'package:snapping_sheet/snapping_sheet.dart';


class GrabSection extends StatelessWidget {
/*  GrabSection({Key key, this.controller}) : super(key: key);

  SnappingSheetController controller;*/

  @override
  Widget build(BuildContext context) {
    return Consumer<UserRepository>(builder: (context, user, _) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.grey[400],
          boxShadow: [
            BoxShadow(
              blurRadius: 20.0,
              color: Colors.black.withOpacity(0.2),
            )
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Wrap(
              direction: Axis.vertical,
              children: [
                Text(
                  '   Welcome back, ' + user.user.email,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            Container(
                alignment: Alignment.centerRight,
                padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                child: Icon(
                    //controller.currentSnapPosition.positionPixel != 0
                    //  ? Icons.keyboard_arrow_down_rounded:
                    Icons.keyboard_arrow_up_rounded,
                    color: Colors.black)),
          ],
        ),
      );
    });
  }
}
