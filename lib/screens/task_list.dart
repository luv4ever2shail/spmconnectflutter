import 'dart:async';
import 'package:flutter/material.dart';
import 'package:spmconnectapp/screens/report_detail_pg2.dart';
import 'package:spmconnectapp/models/tasks.dart';
import 'package:spmconnectapp/utils/database_helper.dart';
import 'package:sqflite/sqflite.dart';

class TaskList extends StatefulWidget {
  final String projectno;

  TaskList(this.projectno);
  @override
  State<StatefulWidget> createState() {
    return _TaskListState(this.projectno);
  }
}

class _TaskListState extends State<TaskList> {
  DatabaseHelper databaseHelper = DatabaseHelper();
  List<Tasks> tasklist;
  int count = 0;
  String projectno;
  _TaskListState(this.projectno);
  @override
  Widget build(BuildContext context) {
    if (tasklist == null) {
      tasklist = List<Tasks>();
      updateListView();
    }
    return WillPopScope(
      onWillPop: () {
        movetolastscreen();
      },
      child: Scaffold(
        body: getReportListView(),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            debugPrint('FAB clicked');
            navigateToDetail(
                Tasks('', '', '', '', ''), 'Add New Item', projectno);
          },
          tooltip: 'Create New Item',
          child: Icon(Icons.add),
        ),
      ),
    );
  }

  ListView getReportListView() {
    TextStyle titleStyle = Theme.of(context).textTheme.subhead;

    return ListView.builder(
      itemCount: count,
      itemBuilder: (BuildContext context, int position) {
        return Card(
          color: Colors.white,
          elevation: 2.0,
          child: ListTile(
            title: Text(
              this.projectno + ' - ' + this.tasklist[position].item,
              style: titleStyle,
            ),
            trailing: GestureDetector(
              child: Icon(
                Icons.delete,
                color: Colors.grey,
              ),
              onTap: () {
                //_delete(context, reportlist[position]);
                _neverSatisfied(position);
              },
            ),
            onTap: () {
              debugPrint("ListTile Tapped");

              navigateToDetail(this.tasklist[position], 'Edit Item', projectno);
            },
          ),
        );
      },
    );
  }

  void movetolastscreen() {
    Navigator.pop(context, true);
  }

  void _delete(BuildContext context, Tasks task) async {
    await databaseHelper.deleteTask(task.id);
    // if (result != 0) {
    //   debugPrint('delete cleared');
    //   _showSnackBar(context, 'Report Deleted Successfully');
    //   updateListView();
    // }
  }

  void navigateToDetail(Tasks task, String title, String projectno) async {
    bool result =
        await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return ReportDetail2(task, title, projectno);
    }));
    if (result == true) {
      updateListView();
    }
  }

  void updateListView() {
    final Future<Database> dbFuture = databaseHelper.initializeDatabase();
    dbFuture.then((database) {
      Future<List<Tasks>> taskListFuture =
          databaseHelper.getTasksList(projectno);
      taskListFuture.then((tasklist) {
        setState(() {
          this.tasklist = tasklist;
          this.count = tasklist.length;
        });
      });
    });
  }

  Future<void> _neverSatisfied(int position) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Item?'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Are you sure want to delete this line item?')
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text('Discard'),
              onPressed: () {
                Navigator.of(context).pop();
                _delete(context, tasklist[position]);
                updateListView();
              },
            ),
          ],
        );
      },
    );
  }
}
