import 'package:flutter/material.dart';

class HelpDialog extends StatefulWidget {
  @override
  HelpDialogState createState() => new HelpDialogState();
}

class HelpDialogState extends State<HelpDialog> {

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
        title: new Text("Help and FAQ"),
      ),
      body: _createDialogBody(),
    );
  }
}
