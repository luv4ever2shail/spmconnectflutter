import 'dart:async';
import 'package:flutter/material.dart';
import 'package:spmconnectapp/screens/report_detail_pg2.dart';
import 'package:spmconnectapp/models/tasks.dart';
import 'package:spmconnectapp/utils/database_helper.dart';
import 'package:sqflite/sqflite.dart';

class TaskList extends StatefulWidget {
  final int reportid;

  TaskList(this.reportid);
  @override
  State<StatefulWidget> createState() {
    return _TaskListState(this.reportid);
  }
}

class _TaskListState extends State<TaskList> {
  DatabaseHelper databaseHelper = DatabaseHelper();
  List<Tasks> tasklist;
  int count = 0;
  int reportid;
  _TaskListState(this.reportid);
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
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              debugPrint('FAB clicked');
              navigateToDetail(
                  Tasks(0, '', '', '', '', '', ''), 'Add New Item', reportid);
            },
            icon: Icon(Icons.add),
            label: Text('Add a new task')),
      ),
    );
  }

  ListView getReportListView() {
    TextStyle titleStyle = Theme.of(context).textTheme.subhead;

    return ListView.builder(
      itemCount: count,
      itemBuilder: (BuildContext context, int position) {
        return Dismissible(
          background: stackBehindDismiss2(),
          secondaryBackground: stackBehindDismiss(),
          key: ObjectKey(tasklist[position]),
          child: Card(
            color: Colors.white,
            elevation: 2.0,
            child: ListTile(
              leading: CircleAvatar(child: Icon(Icons.description),),
              title: Text(
                this.tasklist[position].item,
                style: titleStyle.apply(fontSizeFactor: 1.5),
              ),
              subtitle: Text(
                'Added on :-'+this.tasklist[position].date,
              ),
              onTap: () {
                debugPrint("ListTile Tapped");
                navigateToDetail(
                    this.tasklist[position], 'Edit Item', reportid);
              },
            ),
          ),
          direction: DismissDirection.horizontal,
          onDismissed: (direction) {
            if (direction == DismissDirection.startToEnd) {
              navigateToDetail(this.tasklist[position], 'Edit Item', reportid);
            } else {
              var item = tasklist.elementAt(position);
              //To delete
              deleteItem(position);
              //To show a snackbar with the UNDO button
              Scaffold.of(context).showSnackBar(SnackBar(
                  content: Text("Task deleted"),
                  action: SnackBarAction(
                      label: "UNDO",
                      onPressed: () {
                        //To undo deletion
                        undoDeletion(item);
                      })));
            }
          },
        );
      },
    );
  }

  void deleteItem(index) {
    _delete(context, tasklist[index]);
    updateListView();
  }

  void undoDeletion(item) async {
    await databaseHelper.inserTask(item);
    updateListView();
  }

  Widget stackBehindDismiss() {
    return Container(
      alignment: Alignment.centerRight,
      padding: EdgeInsets.only(right: 20.0),
      color: Colors.red,
      child: Icon(
        Icons.delete,
        color: Colors.white,
      ),
    );
  }

  Widget stackBehindDismiss2() {
    return Container(
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.only(right: 20.0),
      child: Icon(
        Icons.mode_edit,
        color: Colors.white,
      ),
      color: Colors.green,
    );
  }

  void movetolastscreen() {
    Navigator.pop(context, true);
  }

  void _delete(BuildContext context, Tasks task) async {
    await databaseHelper.deleteTask(task.id);
  }

  void navigateToDetail(Tasks task, String title, int reportid) async {
    bool result =
        await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return ReportDetail2(task, title, reportid);
    }));
    if (result == true) {
      updateListView();
    }
  }

  void updateListView() {
    final Future<Database> dbFuture = databaseHelper.initializeDatabase();
    dbFuture.then((database) {
      Future<List<Tasks>> taskListFuture =
          databaseHelper.getTasksList(reportid);
      taskListFuture.then((tasklist) {
        setState(() {
          this.tasklist = tasklist;
          this.count = tasklist.length;
        });
      });
    });
  }
}
