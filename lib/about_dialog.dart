import 'package:flutter/material.dart';

class AboutAppDialog extends StatefulWidget {
  @override
  AboutDialogState createState() => new AboutDialogState();
}

class AboutDialogState extends State<AboutAppDialog> {

  Widget _createDialogBody() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: new Container(
          child: new Row(
            children: <Widget>[
              new Text("Help will be here")
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        centerTitle: true,
        title: new Text("About"),
      ),
      body: _createDialogBody(),
    );
  }
}
