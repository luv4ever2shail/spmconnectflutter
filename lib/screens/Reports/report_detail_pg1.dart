import 'package:flutter/material.dart';
import 'package:spmconnectapp/models/report.dart';
import 'package:spmconnectapp/utils/database_helper.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';

class ReportDetail extends StatefulWidget {
  final Report report;

  ReportDetail(this.report);
  @override
  State<StatefulWidget> createState() {
    return _ReportDetail(this.report);
  }
}

class _ReportDetail extends State<ReportDetail> {
  DatabaseHelper helper = DatabaseHelper();

  String _placemark = '';
  bool _validate = false;
  _ReportDetail(this.report);

  Report report;
  FocusNode customerFocusNode;
  FocusNode plantlocFocusNode;
  FocusNode contactnameFocusNode;
  FocusNode authorbyFocusNode;
  FocusNode technameFocusNode;
  FocusNode equipFocusNode;

  Geolocator geolocator = Geolocator();
  Position userLocation;
  @override
  void initState() {
    super.initState();
    customerFocusNode = FocusNode();
    plantlocFocusNode = FocusNode();
    contactnameFocusNode = FocusNode();
    authorbyFocusNode = FocusNode();
    technameFocusNode = FocusNode();
    equipFocusNode = FocusNode();
    _getLocation().then((position) {
      userLocation = position;
      _onLookupAddressPressed();
    });
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
    super.dispose();
  }

  TextEditingController projectController = TextEditingController();
  TextEditingController customerController = TextEditingController();
  TextEditingController planlocController = TextEditingController();
  TextEditingController contactnameController = TextEditingController();
  TextEditingController authorizedbyController = TextEditingController();
  TextEditingController equipmentController = TextEditingController();
  TextEditingController technameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    TextStyle textStyle = Theme.of(context).textTheme.title;

    projectController.text = report.projectno;
    customerController.text = report.customer;
    planlocController.text = report.plantloc;
    contactnameController.text = report.contactname;
    authorizedbyController.text = report.authorby;
    equipmentController.text = report.equipment;
    technameController.text = report.techname;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Padding(
        padding: EdgeInsets.only(top: 15.0, left: 10.0, right: 10.0),
        child: ListView(
          children: <Widget>[
            // First Element - Project Number
            Padding(
              padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
              child: TextField(
                keyboardType: TextInputType.numberWithOptions(),
                textInputAction: TextInputAction.next,
                //autofocus: true,
                controller: projectController,
                style: textStyle,
                onEditingComplete: () {
                  projectController.text.isEmpty
                      ? _validate = true
                      : _validate = false;
                  FocusScope.of(context).requestFocus(customerFocusNode);
                },
                onChanged: (value) {
                  debugPrint('Something changed in Project Text Field');
                  projectController.text.isEmpty
                      ? _validate = true
                      : _validate = false;
                  updateProjectno();
                },
                decoration: InputDecoration(
                    labelText: 'Project No.',
                    labelStyle: textStyle,
                    errorText: _validate ? 'Project No. Can\'t Be Empty' : null,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0))),
              ),
            ),

            // Second Element - Customer Name
            Padding(
              padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
              child: TextField(
                controller: customerController,
                style: textStyle,
                focusNode: customerFocusNode,
                textInputAction: TextInputAction.next,
                onEditingComplete: () =>
                    FocusScope.of(context).requestFocus(plantlocFocusNode),
                onChanged: (value) {
                  debugPrint('Something changed in Customer Text Field');
                  updateCustomername();
                },
                decoration: InputDecoration(
                    labelText: 'Customer',
                    labelStyle: textStyle,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0))),
              ),
            ),

            // Third Element - Plant Location
            Padding(
              padding: EdgeInsets.only(top: 15.0, bottom: 0.0),
              child: Column(
                children: <Widget>[
                  TextField(
                    controller: planlocController,
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
                        labelText: 'Plant Location',
                        labelStyle: textStyle,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0))),
                  ),
                  FutureBuilder<GeolocationStatus>(
                      future: Geolocator().checkGeolocationPermissionStatus(),
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
                controller: contactnameController,
                style: textStyle,
                focusNode: contactnameFocusNode,
                textInputAction: TextInputAction.next,
                onEditingComplete: () =>
                    FocusScope.of(context).requestFocus(authorbyFocusNode),
                onChanged: (value) {
                  updateContactname();
                },
                decoration: InputDecoration(
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
                controller: authorizedbyController,
                style: textStyle,
                focusNode: authorbyFocusNode,
                textInputAction: TextInputAction.next,
                onEditingComplete: () =>
                    FocusScope.of(context).requestFocus(equipFocusNode),
                onChanged: (value) {
                  updateAuthorby();
                },
                decoration: InputDecoration(
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
                controller: equipmentController,
                style: textStyle,
                focusNode: equipFocusNode,
                textInputAction: TextInputAction.next,
                onEditingComplete: () =>
                    FocusScope.of(context).requestFocus(technameFocusNode),
                onChanged: (value) {
                  updateEquipment();
                },
                decoration: InputDecoration(
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
                controller: technameController,
                style: textStyle,
                focusNode: technameFocusNode,
                onChanged: (value) {
                  updateTechname();
                },
                decoration: InputDecoration(
                    labelText: 'SPM Tech Name',
                    labelStyle: textStyle,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0))),
              ),
            ),
          ],
        ),
      ),
    );
  }

// Update the project no.
  void updateProjectno() {
    report.projectno = projectController.text;
  }

  // Update the customer namme of Note object
  void updateCustomername() {
    report.customer = customerController.text;
  }

  // Update the plant location namme of Note object
  void updatePlantloc() {
    report.plantloc = planlocController.text;
  }

  // Update the customer namme of Note object
  void updateContactname() {
    report.contactname = contactnameController.text;
  }

  // Update the customer namme of Note object
  void updateAuthorby() {
    report.authorby = authorizedbyController.text;
  }

  // Update the customer namme of Note object
  void updateEquipment() {
    report.equipment = equipmentController.text;
  }

  // Update the customer namme of Note object
  void updateTechname() {
    report.techname = technameController.text;
  }
}
