import 'package:flutter/material.dart';
import 'contacts_listview.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Temporary Contacts',
      theme: new ThemeData(

          primaryColor: Colors.blue[700],
          backgroundColor: Colors.blue[700],
          accentColor: Colors.blue[500],
          inputDecorationTheme: InputDecorationTheme(
            labelStyle: TextStyle(
              color: Colors.white,
            ),
            helperStyle:  TextStyle(
              color: Colors.white,
            ),
      )),
      home: ContactsListView(),
    );
  }
}
