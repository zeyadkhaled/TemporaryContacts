import 'package:flutter/material.dart';
import 'package:contacts_service/contacts_service.dart';

class AddContactDialog extends StatefulWidget {
  @override
  AddContactDialogState createState() => new AddContactDialogState();
}

class AddContactDialogState extends State<AddContactDialog> {
  Contact contact = new Contact();
  Iterable<Item> phones;

  _createPhone(String number) {
    phones = [new Item(label: "Mobile", value: number)];
    contact.phones = phones;
  }

  Widget _createDialogBody() {
    return Padding(
        padding: const EdgeInsets.only(top: 16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: new ListTile(
                  //leading: new Icon(Icons.info, color: Colors.grey[500]),
                  title: new TextField(
                    maxLength: 10,
                    decoration: new InputDecoration(
                      labelStyle: Theme.of(context).textTheme.display1,
                      labelText: 'First Name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(0.0),
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
                  //leading: new Icon(Icons.info, color: Colors.grey[500]),
                  title: new TextField(
                    maxLength: 10,
                    decoration: new InputDecoration(
                      labelStyle: Theme.of(context).textTheme.display1,
                      //errorText: _showValidationError ? 'Invalid number entered' : null,
                      labelText: 'Family Name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(0.0),
                      ),
                    ),
                    keyboardType: TextInputType.text,
                    onChanged: (value) => contact.familyName = value,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: new ListTile(
                  //leading: new Icon(Icons.info, color: Colors.grey[500]),
                  title: new TextField(
                    maxLength: 50,
                    decoration: new InputDecoration(
                      labelStyle: Theme.of(context).textTheme.display1,
                      //errorText: _showValidationError ? 'Invalid number entered' : null,
                      labelText: 'Description',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(0.0),
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
                    decoration: new InputDecoration(
                      labelStyle: Theme.of(context).textTheme.display1,
                      labelText: 'Phone Number',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(0.0),
                      ),
                    ),
                    keyboardType: TextInputType.phone,
                    onChanged: (value) => _createPhone(value),
                  ),
                ),
              )
            ],
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: const Text('New entry'),
        actions: [
          new FlatButton(
              onPressed: () {
                Navigator.of(context).pop(
                    contact.givenName == "" || contact.familyName == ""
                        ? null
                        : contact);
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
