import 'package:flutter/material.dart';
import 'contacts_listview.dart';


void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Temp Contacts',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ContactsListView(),
    );
  }
}

