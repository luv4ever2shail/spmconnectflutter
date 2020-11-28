import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:spmconnectapp/models/customers.dart';
import 'package:spmconnectapp/models/report.dart';
import 'package:spmconnectapp/themes/appTheme.dart';
import 'package:spmconnectapp/utils/adropdown.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:spmconnectapp/utils/dropdown.dart';

class ReportDetail extends StatefulWidget {
  final Report report;

  ReportDetail(this.report);
  @override
  State<StatefulWidget> createState() {
    return _ReportDetail(this.report);
  }
}

class _ReportDetail extends State<ReportDetail> {
  String _placemark = '';
  bool _validate = false;
  _ReportDetail(this.report);
  List<Customer> customerList;
  Customer selectedPerson;
  List<DropdownMenuItem> items = [];
  String selectedCustomer;
  String _projectManager;

  Report report;
  FocusNode customerFocusNode;
  FocusNode refjobFocusNode;
  FocusNode plantlocFocusNode;
  FocusNode contactnameFocusNode;
  FocusNode authorbyFocusNode;
  FocusNode technameFocusNode;
  FocusNode equipFocusNode;

  TextEditingController projectController;
  TextEditingController customerController;
  TextEditingController planlocController;
  TextEditingController contactnameController;
  TextEditingController authorizedbyController;
  TextEditingController equipmentController;
  TextEditingController technameController;
  TextEditingController refjobController;

  Geolocator geolocator = Geolocator();
  Position userLocation;
  @override
  void initState() {
    super.initState();
    customerFocusNode = new FocusNode();
    refjobFocusNode = new FocusNode();
    plantlocFocusNode = new FocusNode();
    contactnameFocusNode = new FocusNode();
    authorbyFocusNode = new FocusNode();
    technameFocusNode = new FocusNode();
    equipFocusNode = new FocusNode();

    projectController = new TextEditingController();
    customerController = new TextEditingController();
    planlocController = new TextEditingController();
    contactnameController = new TextEditingController();
    authorizedbyController = new TextEditingController();
    equipmentController = new TextEditingController();
    technameController = new TextEditingController();
    refjobController = new TextEditingController();

    projectController.text = report.getprojectno;
    customerController.text = report.getcustomer;
    planlocController.text = report.getplantloc;
    contactnameController.text = report.getcontactname;
    authorizedbyController.text = report.getauthorby;
    equipmentController.text = report.getequipment;
    technameController.text = report.gettechname;
    refjobController.text = report.getrefjob;
    _projectManager = report.getprojectmanager;

    _getLocation().then((position) {
      userLocation = position;
      _onLookupAddressPressed();
    });
    getStatesList();
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

    setState(() {});
  }

  Future<Position> _getLocation() async {
    var currentLocation;
    try {
      currentLocation = await geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best);
    } catch (e) {
      currentLocation = null;
    }
    return currentLocation;
  }

  Future<void> _onLookupAddressPressed() async {
    try {
      String cordinates = userLocation.latitude.toString() +
          ',' +
          userLocation.longitude.toString();
      final List<String> coords = cordinates.split(',');
      final double latitude = double.parse(coords[0]);
      final double longitude = double.parse(coords[1]);
      final List<Placemark> placemarks =
          await geolocator.placemarkFromCoordinates(latitude, longitude);

      if (placemarks != null && placemarks.isNotEmpty) {
        final Placemark pos = placemarks[0];
        setState(() {
          _placemark = pos.name +
              ', ' +
              pos.subThoroughfare +
              ' ' +
              pos.thoroughfare +
              ', ' +
              pos.locality +
              ', ' +
              pos.administrativeArea +
              ' ' +
              pos.postalCode +
              ', ' +
              pos.country;
        });
      }
      setState(() {});
    } catch (e) {}
  }

  @override
  void dispose() {
    // Clean up the focus node when the Form is disposed
    customerFocusNode.dispose();
    plantlocFocusNode.dispose();
    contactnameFocusNode.dispose();
    authorbyFocusNode.dispose();
    technameFocusNode.dispose();
    equipFocusNode.dispose();
    projectController.dispose();
    customerController.dispose();
    planlocController.dispose();
    contactnameController.dispose();
    authorizedbyController.dispose();
    equipmentController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    TextStyle textStyle = Theme.of(context).textTheme.headline6;

    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);

        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: Scaffold(
        backgroundColor: AppTheme.getTheme().backgroundColor,
        resizeToAvoidBottomInset: true,
        body: Padding(
          padding: EdgeInsets.only(top: 15.0, left: 10.0, right: 10.0),
          child: Scrollbar(
            child: ListView(
              children: <Widget>[
                // First Element - Project Number
                Padding(
                  padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                  child: TextField(
                    inputFormatters: [
                      new FilteringTextInputFormatter.deny(new RegExp(
                          '\u00a9|\u00ae|[\u2000-\u3300]|\ud83c[\ud000-\udfff]|\ud83d[\ud000-\udfff]|\ud83e[\ud000-\udfff]')),
                    ],
                    keyboardType: TextInputType.numberWithOptions(),
                    textInputAction: TextInputAction.next,
                    // autofocus: true,
                    maxLength: 10,
                    controller: projectController,
                    style: textStyle,
                    onEditingComplete: () {
                      projectController.text.isEmpty
                          ? _validate = true
                          : _validate = false;
                      FocusScope.of(context).requestFocus(refjobFocusNode);
                    },
                    onChanged: (value) {
                      debugPrint('Something changed in Project Text Field');
                      projectController.text.isEmpty
                          ? _validate = true
                          : _validate = false;
                      updateProjectno();
                    },
                    decoration: InputDecoration(
                        hintText: 'Enter SPM Job No',
                        labelText: 'Project No.',
                        labelStyle: textStyle,
                        errorText:
                            _validate ? 'Project No. Can\'t Be Empty' : null,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0))),
                  ),
                ),

                // Second Element - Customer Name
                Padding(
                  padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                  child: TextField(
                    inputFormatters: [
                      new FilteringTextInputFormatter.deny(new RegExp(
                          '\u00a9|\u00ae|[\u2000-\u3300]|\ud83c[\ud000-\udfff]|\ud83d[\ud000-\udfff]|\ud83e[\ud000-\udfff]')),
                    ],
                    controller: refjobController,
                    keyboardType: TextInputType.number,
                    style: textStyle,
                    maxLines: 1,
                    focusNode: refjobFocusNode,
                    maxLength: 10,
                    textInputAction: TextInputAction.next,
                    onEditingComplete: () =>
                        FocusScope.of(context).requestFocus(customerFocusNode),
                    onChanged: (value) {
                      debugPrint('Something changed in ref job Text Field');
                      updateRefjob();
                    },
                    decoration: InputDecoration(
                        hintText: 'Enter Ref. SPM Job No',
                        labelText: 'Ref. Job',
                        labelStyle: textStyle,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0))),
                  ),
                ),

                Padding(
                  padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                  child: DropDownFormField(
                    filled: false,
                    titleText: 'Project Manager',
                    hintText: 'Select project manager',
                    value: _projectManager,
                    onSaved: (value) {
                      updatePM(value);
                    },
                    onChanged: (value) {
                      setState(() {
                        _projectManager = value;
                        updatePM(value);
                      });
                    },
                    dataSource: [
                      {
                        "display": "Chris Holtkamp",
                        "value": "Chris Holtkamp",
                      },
                      {
                        "display": "Curtis Butler",
                        "value": "Curtis Butler",
                      },
                    ],
                    textField: 'display',
                    valueField: 'value',
                  ),
                ),

                Padding(
                  padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                  child: SearchableDropdown(
                    controller: customerController,
                    items: items,
                    report: report,
                    focusNode: customerFocusNode,
                    isExpanded: true,
                    value: selectedCustomer,
                    isCaseSensitiveSearch: false,
                    hint: new Text('Select Customer'),
                    searchHint: new Text(
                      'Select Customer',
                      style: new TextStyle(fontSize: 20),
                    ),
                    onChanged: (value) {
                      updateCustomername();
                      setState(() {
                        selectedCustomer = value;
                        customerController.text = value;
                      });
                    },
                  ),
                ),

                // Third Element - Plant Location
                Padding(
                  padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                  child: Column(
                    children: <Widget>[
                      TextField(
                        inputFormatters: [
                          new FilteringTextInputFormatter.deny(new RegExp(
                              '\u00a9|\u00ae|[\u2000-\u3300]|\ud83c[\ud000-\udfff]|\ud83d[\ud000-\udfff]|\ud83e[\ud000-\udfff]')),
                        ],
                        controller: planlocController,
                        keyboardType: TextInputType.text,
                        style: textStyle,
                        focusNode: plantlocFocusNode,
                        textInputAction: TextInputAction.next,
                        onEditingComplete: () => FocusScope.of(context)
                            .requestFocus(contactnameFocusNode),
                        onChanged: (value) {
                          updatePlantloc();
                        },
                        onTap: () {
                          if (planlocController.text.length <= 0) {
                            _getLocation().then((position) {
                              userLocation = position;
                              _onLookupAddressPressed();
                            });
                            planlocController.text = _placemark;
                            updatePlantloc();
                          }
                        },
                        decoration: InputDecoration(
                            hintText: 'Enter service plant location',
                            labelText: 'Plant Location',
                            labelStyle: textStyle,
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5.0))),
                      ),
                      FutureBuilder<GeolocationStatus>(
                          future:
                              Geolocator().checkGeolocationPermissionStatus(),
                          builder: (BuildContext context,
                              AsyncSnapshot<GeolocationStatus> snapshot) {
                            if (!snapshot.hasData) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }
                            if (snapshot.data == GeolocationStatus.denied) {
                              return const Text(
                                  'Allow access to the location services for this App using the device settings.');
                            }
                            if (userLocation == null) {
                              return Text('');
                            }
                            return Text(userLocation.toString());
                          }),
                      Text(_placemark),
                    ],
                  ),
                ),

                //Fourth Element - Contact Name
                Padding(
                  padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                  child: TextField(
                    inputFormatters: [
                      new FilteringTextInputFormatter.deny(new RegExp(
                          '\u00a9|\u00ae|[\u2000-\u3300]|\ud83c[\ud000-\udfff]|\ud83d[\ud000-\udfff]|\ud83e[\ud000-\udfff]')),
                    ],
                    controller: contactnameController,
                    maxLength: 30,
                    keyboardType: TextInputType.text,
                    style: textStyle,
                    focusNode: contactnameFocusNode,
                    textInputAction: TextInputAction.next,
                    onEditingComplete: () =>
                        FocusScope.of(context).requestFocus(authorbyFocusNode),
                    onChanged: (value) {
                      updateContactname();
                    },
                    decoration: InputDecoration(
                        hintText: 'Enter contact name',
                        labelText: 'Contact Name',
                        labelStyle: textStyle,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0))),
                  ),
                ),

                //Fifth Element - Authorized By
                Padding(
                  padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                  child: TextField(
                    inputFormatters: [
                      new FilteringTextInputFormatter.deny(new RegExp(
                          '\u00a9|\u00ae|[\u2000-\u3300]|\ud83c[\ud000-\udfff]|\ud83d[\ud000-\udfff]|\ud83e[\ud000-\udfff]')),
                    ],
                    controller: authorizedbyController,
                    keyboardType: TextInputType.text,
                    style: textStyle,
                    focusNode: authorbyFocusNode,
                    textInputAction: TextInputAction.next,
                    maxLength: 30,
                    onEditingComplete: () =>
                        FocusScope.of(context).requestFocus(equipFocusNode),
                    onChanged: (value) {
                      updateAuthorby();
                    },
                    decoration: InputDecoration(
                        hintText: 'Enter authorized by',
                        labelText: 'Authorized By',
                        labelStyle: textStyle,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0))),
                  ),
                ),

                //Sixth Element - Equipment
                Padding(
                  padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                  child: TextField(
                    inputFormatters: [
                      new FilteringTextInputFormatter.deny(new RegExp(
                          '\u00a9|\u00ae|[\u2000-\u3300]|\ud83c[\ud000-\udfff]|\ud83d[\ud000-\udfff]|\ud83e[\ud000-\udfff]')),
                    ],
                    controller: equipmentController,
                    keyboardType: TextInputType.text,
                    style: textStyle,
                    maxLength: 60,
                    focusNode: equipFocusNode,
                    textInputAction: TextInputAction.next,
                    onEditingComplete: () =>
                        FocusScope.of(context).requestFocus(technameFocusNode),
                    onChanged: (value) {
                      updateEquipment();
                    },
                    decoration: InputDecoration(
                        hintText: 'Enter equipment name',
                        labelText: 'Equipment',
                        labelStyle: textStyle,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0))),
                  ),
                ),

                //Seventh Element - Technician Name
                Padding(
                  padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                  child: TextField(
                    inputFormatters: [
                      new FilteringTextInputFormatter.deny(new RegExp(
                          '\u00a9|\u00ae|[\u2000-\u3300]|\ud83c[\ud000-\udfff]|\ud83d[\ud000-\udfff]|\ud83e[\ud000-\udfff]')),
                    ],
                    controller: technameController,
                    maxLength: 30,
                    keyboardType: TextInputType.text,
                    style: textStyle,
                    focusNode: technameFocusNode,
                    onChanged: (value) {
                      updateTechname();
                    },
                    decoration: InputDecoration(
                        hintText: 'Enter technician name',
                        labelText: 'SPM Tech Name',
                        labelStyle: textStyle,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0))),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

// Update the project no.
  void updateProjectno() {
    report.getprojectno = projectController.text.trim();
  }

  // Update the customer namme of Note object
  void updateCustomername() {
    report.getcustomer = customerController.text.trim();
  }

  // Update ref job
  void updateRefjob() {
    report.getrefjob = refjobController.text.trim();
  }

  // Update project manager
  void updatePM(String value) {
    report.getprojectmanager = value.trim();
  }

  // Update the plant location namme of Note object
  void updatePlantloc() {
    report.getplantloc = planlocController.text.trim();
  }

  // Update the customer namme of Note object
  void updateContactname() {
    report.getcontactname = contactnameController.text.trim();
  }

  // Update the customer namme of Note object
  void updateAuthorby() {
    report.getauthorby = authorizedbyController.text.trim();
  }

  // Update the customer namme of Note object
  void updateEquipment() {
    report.getequipment = equipmentController.text.trim();
  }

  // Update the customer namme of Note object
  void updateTechname() {
    report.gettechname = technameController.text.trim();
  }
}

class Customer {
  Customer(this.name);
  final String name;
  @override
  String toString() => name;
}
