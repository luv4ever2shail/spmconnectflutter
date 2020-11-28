import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spmconnectapp/Resource/database_helper.dart';
import 'package:spmconnectapp/Resource/tasks_repository.dart';
import 'package:spmconnectapp/screens/Reports/report_detail_pg2.dart';
import 'package:spmconnectapp/models/tasks.dart';

class TaskList extends StatefulWidget {
  final String reportid;
  final DBProvider helper;
  TaskList(this.reportid, this.helper);
  @override
  State<StatefulWidget> createState() {
    return _TaskListState(this.reportid);
  }
}

class _TaskListState extends State<TaskList> {
  String reportid;
  _TaskListState(this.reportid);
  @override
  Widget build(BuildContext context) {
    ReportTasks reportTasks = Provider.of<ReportTasks>(context);
    return Scaffold(
      body: Scrollbar(
        child: reportTasks.count > 0
            ? getReportListView(reportTasks)
            : Container(),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            debugPrint('FAB clicked');
            navigateToDetail(
              Tasks(
                reportid,
                '',
                null,
                null,
                '',
                '',
                '',
                0,
                '',
                '',
                '',
                '',
                '',
              ),
              'Add New Task',
              reportid,
              reportTasks,
            );
          },
          icon: Icon(
            Icons.add,
            color: Colors.white,
          ),
          label: Text(
            'Add a new task',
            style: TextStyle(
              color: Colors.white,
            ),
          )),
    );
  }

  ListView getReportListView(ReportTasks reportTasks) {
    TextStyle titleStyle = Theme.of(context).textTheme.subtitle1;

    return ListView.builder(
      itemCount: reportTasks.getCount,
      itemBuilder: (BuildContext context, int position) {
        return Dismissible(
          background: stackBehindDismiss(),
          key: ObjectKey(reportTasks.getTasks[position]),
          child: Padding(
            padding: EdgeInsets.all(3),
            child: Card(
              color: Colors.white,
              elevation: 2.0,
              child: ListTile(
                leading: CircleAvatar(
                  child: Icon(Icons.description),
                ),
                title: Text(
                  reportTasks.getTasks[position].getitem,
                  style: titleStyle.apply(fontSizeFactor: 1.5),
                ),
                subtitle: Text(
                  (reportTasks.getTasks[position].getdate == null
                      ? ''
                      : 'Added on :-' + reportTasks.getTasks[position].getdate),
                ),
                onTap: () {
                  debugPrint("ListTile Tapped");
                  navigateToDetail(reportTasks.getTasks[position], 'Edit Task',
                      reportid, reportTasks);
                },
                trailing: IconButton(
                  onPressed: () async {
                    var item = reportTasks.getTasks.elementAt(position);
                    print('object');
                    await deleteItem(position, reportTasks);
                    Scaffold.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            "Task deleted ${reportTasks.getTasks[position].getitem}"),
                        action: SnackBarAction(
                          label: "UNDO",
                          onPressed: () async {
                            await undoDeletion(item, reportTasks);
                          },
                        ),
                      ),
                    );
                  },
                  icon: Icon(
                    Icons.delete,
                    size: 40,
                  ),
                  color: Colors.grey,
                ),
              ),
            ),
          ),
          direction: DismissDirection.horizontal,
          onDismissed: (direction) async {
            var item = reportTasks.getTasks.elementAt(position);
            //To delete
            await deleteItem(position, reportTasks);
            //To show a snackbar with the UNDO button
            Scaffold.of(context).showSnackBar(SnackBar(
                content: Text(
                    "Task deleted ${reportTasks.getTasks[position].getitem}"),
                action: SnackBarAction(
                    label: "UNDO",
                    onPressed: () {
                      //To undo deletion
                      undoDeletion(item, reportTasks);
                    })));
          },
        );
      },
    );
  }

  Future<void> deleteItem(index, ReportTasks reportTasks) async {
    if (index > -1) {
      await _delete(reportTasks.getTasks[index]);
      // await reportTasks.fetchTasks(reportid);
    }
  }

  Future<void> undoDeletion(item, ReportTasks reportTasks) async {
    await widget.helper.insertTask(item);
    await reportTasks.fetchTasks(reportid);
  }

  Widget stackBehindDismiss() {
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.only(right: 20.0),
      color: Colors.red,
      child: Icon(
        Icons.delete,
        color: Colors.white,
      ),
    );
  }

  void movetolastscreen() {
    Navigator.pop(context, true);
  }

  Future<void> _delete(Tasks task) async {
    await widget.helper.deleteTask(task.getid);
  }

  Future<void> navigateToDetail(
      Tasks task, String title, String reportid, ReportTasks reportTask) async {
    bool result =
        await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return ReportDetail2(task, title, reportid, widget.helper);
    }));
    if (result == true) {
      await reportTask.fetchTasks(reportid);
    }
  }
}
