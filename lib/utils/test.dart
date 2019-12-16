import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:spmconnectapp/models/customers.dart';
import 'package:spmconnectapp/screens/Reports/report_detail_pg1.dart';
import 'package:spmconnectapp/utils/adropdown.dart';

class Drop extends StatefulWidget {
  @override
  _DropState createState() => _DropState();
}

class _DropState extends State<Drop> {
  List<DropdownMenuItem> items = [];
  String selectedValue;

  List<Customer> customerList;
  Customer selectedPerson;
  @override
  void initState() {
    // for (int i = 0; i < 20; i++) {
    //   items.add(new DropdownMenuItem(
    //     child: new Text(
    //       'test ' + i.toString(),
    //     ),
    //     value: 'test ' + i.toString(),
    //   ));
    // }
    getStatesList();
    super.initState();
  }

  void getStatesList() async {
    customerList = CustomersList().getCustomerListFromJson(json.decode(
        await DefaultAssetBundle.of(context)
            .loadString("assets/customers.json")));

    customerList.forEach((v) {
      String data = v.name;
      items.add(new DropdownMenuItem(
        child: new Text(
          data,
        ),
        value: data,
      ));
    });

    setState(() {
      selectedValue = items[0].value.toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Searchable Dropdown Demo'),
        ),
        body: new Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                new Container(
                    child: new Text(
                  'Searchable Dropdown',
                  style:
                      new TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                )),
                new SearchableDropdown(
                  items: items,
                  isExpanded: true,
                  value: selectedValue,
                  isCaseSensitiveSearch: false,
                  hint: new Text('Select Customer'),
                  searchHint: new Text(
                    'Select Customer',
                    style: new TextStyle(fontSize: 20),
                  ),
                  onChanged: (value) {
                    setState(() {
                      selectedValue = value;
                    });
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
