// ignore_for_file: file_names
import 'Globals.dart';
import 'package:flutter/material.dart';
import '../database/database.dart';

class datelimit {
  datelimit(this.Date, this.member, [this.isExpanded = false]);
  String Date;
  List<String> member;
  bool isExpanded;
}

class TimeList extends StatefulWidget {
  const TimeList({super.key});

  @override
  State<TimeList> createState() => _TimeList();
}

class _TimeList extends State<TimeList> {
  List<datelimit> notices = [];
  final rec = <String, List<String>>{};
  datelimit tmp = datelimit('', []);

  void initList() async {
    final list = await WarningDB.getRecord('All', Warningdb);

    setState(() {
      for (int i = 0; i < list.length; i++) {
        if (rec[list[i].Date] == null) {
          rec[list[i].Date] = [];
        }
        rec[list[i].Date]!.add(list[i].Name);
      }
      for (var key in rec.keys) {
        notices.add(datelimit(key, rec[key]!));
      }
      notices.sort(((a, b) => b.Date.compareTo(a.Date)));
    });
  }

  @override
  void initState() {
    super.initState();
    initList();
    setState(() {
      notices.sort(((a, b) => b.Date.compareTo(a.Date)));
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(10),
      itemBuilder: (BuildContext context, int index) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: _buildTiles(notices[index]),
      ),
      itemCount: notices.length,
    );
  }

  Widget strlist(List<String> s) {
    return Column(
      children: List<Widget>.generate(
        s.length,
        (idx) {
          return ListTile(
            title: Text(
              s[idx],
              style: const TextStyle(
                color: Color.fromARGB(255, 82, 82, 82),
                fontSize: 23.0,
              ),
            ),
          );
        },
      ).toList(),
    );
  }

  Widget _buildTiles(datelimit notic) {
    // if (root.children.isEmpty) return ListTile(title: Text(root.title));
    return Card(
      child: ExpansionTile(
        tilePadding: EdgeInsets.fromLTRB(10, 10, 10, 10),
        subtitle: Text(
          '共${notic.member.length}筆',
          style: const TextStyle(
            fontSize: 16.0,
          ),
        ),
        leading: const Icon(
          size: 40,
          Icons.warning,
          color: Color.fromARGB(255, 226, 67, 67),
        ),
        key: PageStorageKey<datelimit>(notic),
        title: Text(
          notic.Date,
          style: const TextStyle(
            color: Color.fromARGB(255, 82, 82, 82),
            fontSize: 23.0,
          ),
        ),
        children: [
          strlist(notic.member),
        ],
      ),
    );
  }
}
