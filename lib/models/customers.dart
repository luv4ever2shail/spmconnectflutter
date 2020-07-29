import 'package:spmconnectapp/screens/Reports/report_detail_pg1.dart';

class CustomersList {
  List<Customer> getCustomerListFromJson(Map<String, dynamic> json) {
    List<Customer> countryList = List<Customer>();
    if (json['Customers'] != null) {
      json['Customers'].forEach((v) {
        Customer data = Customer(v["Name"]);
        countryList.add(data);
      });
    }
    return countryList;
  }
}
