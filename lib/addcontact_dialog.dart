import 'package:flutter/material.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/scheduler.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AddContactDialog extends StatefulWidget {
  @override
  AddContactDialogState createState() => new AddContactDialogState();
}

class AddContactDialogState extends State<AddContactDialog> {
  Contact contact = new Contact();
  Iterable<Item> phones;

  _createPhone(String number) {
    phones = [new Item(label: "Work", value: number)];
    contact.phones = phones;
  }


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
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 12.0),
                  child: new ListTile(
                    title: new TextField(
                      maxLength: 10,
                      decoration: new InputDecoration(
                        labelStyle:
                            Theme.of(context).textTheme.display1.copyWith(
                                  color: Colors.white,
                                ),
                        labelText: 'First Name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                      ),
                      keyboardType: TextInputType.text,
                      onChanged: (value) => contact.givenName = value,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: new ListTile(
                    title: new TextField(
                      maxLength: 10,
                      decoration: new InputDecoration(
                          labelStyle:
                              Theme.of(context).textTheme.display1.copyWith(
                                    color: Colors.white,
                                  ),
                          labelText: 'Family Name',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16.0),
                          )),
                      keyboardType: TextInputType.text,
                      onChanged: (value) => contact.familyName = value,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: new ListTile(
                    title: new TextField(
                      maxLength: 50,
                      decoration: new InputDecoration(
                        labelStyle:
                            Theme.of(context).textTheme.display1.copyWith(
                                  color: Colors.white,
                                ),
                        labelText: 'Description',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                      ),
                      keyboardType: TextInputType.text,
                      onChanged: (value) => contact.jobTitle = value,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: new ListTile(
                    title: new TextField(
                      maxLength: 15,
                      decoration: new InputDecoration(
                        labelStyle:
                            Theme.of(context).textTheme.display1.copyWith(
                                  color: Colors.white,
                                ),
                        labelText: 'Phone Number',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                      ),
                      keyboardType: TextInputType.phone,
                      onChanged: (value) => _createPhone(value),
                    ),
                  ),
                )
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
        title: const Text('Add Contact'),
        actions: [
          new FlatButton(
              onPressed: () {
                if (contact.givenName == null ||
                    contact.familyName == null ||
                    contact.jobTitle == null ||
                    contact.phones == null) {
                  Fluttertoast.showToast(
                      msg: "Please fill all forms!",
                      toastLength: Toast.LENGTH_LONG,
                      gravity: ToastGravity.BOTTOM,
                      timeInSecForIos: 1,
                      bgcolor: "#e74c3c",
                      textcolor: '#ffffff');
                } else {
                  Navigator.of(context).pop(contact);
                }
              },
              child: new Text('SAVE',
                  style: Theme
                      .of(context)
                      .textTheme
                      .subhead
                      .copyWith(color: Colors.white))),
        ],
      ),
      body: _createDialogBody(),
    );
  }
}
