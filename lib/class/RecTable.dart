import 'Globals.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../database/database.dart';
import 'package:date_format/date_format.dart';

class MyTable extends StatefulWidget {
  const MyTable({required this.who, required this.when, super.key});
  final Member who;
  final DateTime when;

  @override
  MyTableButtonState createState() => MyTableButtonState();
}

class MyTableButtonState extends State<MyTable> {
  // int? _value = -1;
  // Uint8List nowsheet = Uint8List.fromList(initlist());
  WorkSheet tabledata = WorkSheet(
    SheetId: 0,
    MemberId: '0',
    Date: '0',
    State: 0,
    Sheet: [],
  );
  // List<int> recsheet =

  //     List<int>.generate(31, (int index) => 0, growable: false);

  List<int> selectedChoices = [];

  List<int> iconstate = List<int>.generate(48, (int index) => 0, growable: false);

  List<int> iconstate_prev = List<int>.generate(48, (int index) => 0, growable: false);

  // List<int> iconstate =
  //     List<int>.generate(31, (int index) => 0, growable: false);
  // List<int> iconstate_prev =
  //     List<int>.generate(31, (int index) => 0, growable: false);
  // List<int> selectedChoices = [];

  void initList() async {
    final sheetList = await SheetDB.getsheet(widget.who.Id, formatDate(widget.when, [yyyy, '/', mm, '/', dd]), Sheetdb);

    setState(() {
      debugPrint('Load DATA...');
      if (sheetList.isNotEmpty) {
        debugPrint("Success:D");
        tabledata.State = sheetList[0].State;
        // tabledata = sheetList[0];
        // iconstate = sheetList[0].Sheet;
        for (int i = 0; i < sheetList[0].Sheet.length; i++) {
          iconstate[i] = sheetList[0].Sheet[i];
          if (sheetList[0].Sheet[i] != 0) {
            selectedChoices.add(i);
          }
        }
      } else {
        debugPrint('Data Not found:(');
      }
    });
  }

  @override
  void initState() {
    super.initState();
    initList();

    tabledata.SheetId = int.parse('${widget.who.Id}${formatDate(widget.when, [yyyy, mm, dd])}');
    tabledata.MemberId = widget.who.Id;
    tabledata.Date = formatDate(widget.when, [yyyy, '/', mm, '/', dd]);
    debugPrint(tabledata.toString());
  }

  Widget build(BuildContext context) {
    // if (ButtonState == 0) {
    //   return Center(child: Text('請先在上方選「工作 / 用餐」再點時間格',
    //       style: TextStyle(color: Colors.red)));
    // }
    //
    // if ((tabledata.State ?? 0) != 0) {
    //   return Center(child: Text('這一天已確認，無法編輯',
    //       style: TextStyle(color: Colors.orange)));
    // }

    return Container(
      padding: const EdgeInsets.only(left: 15, right: 15, bottom: 15),
      child: _fourTimes(),
      // Column(children: [_row()]),
    );
  }

  bool canTap() {
    return (ButtonState != 0) && ((tabledata.State ?? 0) == 0);
  }

  Widget _fourTimes() {
    void toggleSlot(int idx) {
      if (!canTap()) {
        final snackBar = SnackBar(
          content: Row(children: const [
            Icon(Icons.warning, color: Colors.white),
            SizedBox(width: 12),
            Text('未選擇登記狀態（工作/用餐）或該日已確認，無法編輯',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
          ]),
          backgroundColor: const Color.fromARGB(255, 237, 110, 74),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: const StadiumBorder(),
          duration: const Duration(milliseconds: 800),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        return;
      }

      setState(() {
        if (selectedChoices.contains(idx)) {
          if (iconstate_prev[idx] == ButtonState || ButtonState == 0) {
            selectedChoices.remove(idx);
            iconstate[idx] = 0;
          } else {
            iconstate[idx] = ButtonState; // 覆蓋模式
          }
        } else {
          iconstate[idx] = ButtonState;    // 1=工作、2=用餐
          selectedChoices.add(idx);
        }
        iconstate_prev[idx] = iconstate[idx];
        checkState = selectedChoices.isNotEmpty;
        tabledata.Sheet = iconstate;
        update_queue[tabledata.MemberId] = tabledata;
      });
    }

    const double outerPad = 15.0;   // 你的外層 Container 左右 padding
    const double gap = 16.0;        // Chip 之間間距（可調大）
    const double chipHeight = 48.0; // Chip 高度（可調大）
    const double fontSize = 20.0;   // 文字大小（可調大）

    return LayoutBuilder(
      builder: (context, constraints) {
        // 一排 4 顆：可用寬度 - 3 個間距 - 左右外邊距，再除以 4
        final double itemWidth =
            (constraints.maxWidth - gap * 3) / 4;

        return Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Wrap(
            spacing: gap,
            runSpacing: gap,
            children: List.generate(48, (i) {
              final String start = numtoTime[i];      // numtoTime 長度 49（含 24:00）
              final String end   = numtoTime[i + 1];
              final bool selected = selectedChoices.contains(i);
              final bool isMeal   = iconstate[i] == 2;

              return SizedBox(
                width: itemWidth,
                height: chipHeight,
                child: ChoiceChip(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  backgroundColor: const Color(0xFFE8EFFD),
                  selectedColor: isMeal
                      ? const Color(0xFF2C5479)   // 用餐
                      : const Color(0xFF4676A3),  // 工作
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  label: Text(
                    '$start ~ $end',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: fontSize,
                      color: selected ? Colors.white : const Color(0xFF465E7B),
                    ),
                  ),
                  selected: selected,
                  onSelected: (_) => toggleSlot(i),
                ),
              );
            }),
          ),
        );
      },
    );
  }

}
