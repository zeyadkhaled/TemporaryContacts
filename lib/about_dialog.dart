import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutAppDialog extends StatefulWidget {
  @override
  AboutDialogState createState() => new AboutDialogState();
}

class AboutDialogState extends State<AboutAppDialog> {
  Widget _createDialogBody() {
    return new Container(
      height: MediaQuery.of(context).size.height,
      decoration: new BoxDecoration(
        image: new DecorationImage(
          image: new AssetImage("assets/img/background.png"),
          fit: BoxFit.cover,
        ),
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomRight,
          stops: [0.1, 0.5, 0.7, 1.0],
          colors: [
            Colors.blue[500],
            Colors.blue[400],
            Colors.blue[300],
            Colors.blue[200],
          ],
        ),
      ),
      child: Padding(
          padding: const EdgeInsets.only(top: 16.0),
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Image.asset(
                  'assets/icon/logo.png',
                  fit: BoxFit.cover,
                  scale: 8.0,
                ),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Text(
                          "This app provides an interface that allows users to quickly add contacts and not to have to worry about them craming their address book after a while",
                          style: TextStyle(fontSize: 20.0, color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ),
                Divider(
                  height: 4.0,
                  color: Colors.blue[700],
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: <Widget>[
                      Text("Connect with us",
                          style: TextStyle(color: Colors.white, fontSize: 18.0))
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListTile(
                    leading: Icon(FontAwesomeIcons.github),
                    title: Text(
                      "View on Github",
                      style: TextStyle(color: Colors.grey[800], fontSize: 18.0),
                    ),
                    trailing: Icon(Icons.keyboard_arrow_right),
                    onTap: () => launch("https://github.com/zeyadkhaled/TemporaryContacts"),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListTile(
                    leading: Icon(Icons.web),
                    title: Text(
                      "Visit Website",
                      style: TextStyle(color: Colors.grey[800], fontSize: 18.0),
                    ),
                    trailing: Icon(Icons.keyboard_arrow_right),
                    onTap: ()  => launch("https://zeyadk.me"),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListTile(
                    leading: Icon(FontAwesomeIcons.linkedin),
                    title: Text(
                      "Zeyad Abuamer",
                      style: TextStyle(color: Colors.grey[800], fontSize: 18.0),
                    ),
                    trailing: Icon(Icons.keyboard_arrow_right),
                    onTap: ()  => launch("https://linkedin.com/in/zeyadkhaled"),
                  ),
                ),
                Divider(
                  height: 4.0,
                  color: Colors.blue[700],
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: <Widget>[
                      Text("App info",
                          style: TextStyle(color: Colors.white, fontSize: 18.0))
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListTile(
                    leading: Icon(Icons.confirmation_number),
                    title: Text(
                      "Version 1.1",
                      style: TextStyle(color: Colors.grey[800], fontSize: 18.0),
                    ),
                  ),
                ),
              ],
            ),
          )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        elevation: 0.0,
        backgroundColor: Colors.blue[500],
        centerTitle: true,
        title: const Text('About'),
      ),
      body: _createDialogBody(),
    );
  }
}
