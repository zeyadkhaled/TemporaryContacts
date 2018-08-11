import 'package:flutter/material.dart';
import 'package:contacts_service/contacts_service.dart';
import 'dart:math';
import 'dart:async';
import 'package:simple_permissions/simple_permissions.dart';
import 'package:flutter/scheduler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ContactsListView extends StatefulWidget {
  _ContactsListViewState createState() => new _ContactsListViewState();
}

class _ContactsListViewState extends State<ContactsListView> {
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  final _contactList = <Contact>[];

  ScrollController _scrollController =
      new ScrollController(); //For ListView Scrolling

  final _colorList = <Color>[
    Colors.pink[600],
    Colors.red[600],
    Colors.blue[600],
    Colors.green[600],
    Colors.cyan[600],
    Colors.amber[600],
    Colors.brown[600],
  ];

  //Generate Random Color
  Color _randColor() {
    Random rand = new Random();
    return _colorList[rand.nextInt(_colorList.length)];
  }

  /**
   * Application
   */
  _getContacts() async {
    final SharedPreferences prefs = await _prefs;
    final List<String> contacts = (prefs.getStringList('contacts') ?? null);
    if (contacts != null) {
      for (String name in contacts) {
        final List<String> details = (prefs.getStringList(name) ?? null);
        if (details != null) {
          Contact c = new Contact(
            givenName: details[0],
            familyName: details[1],
            jobTitle: details[2],
          );
          _contactList.add(c);
          setState(() {
            _buildListView();
          });
        }
      }
    }
  }

  _addContacts(Contact c) async {
    String name = c.givenName + c.familyName;
    List<String> details = new List<String>();
    details.add(c.givenName);
    details.add(c.familyName);
    details.add(c.jobTitle);

    final SharedPreferences prefs = await _prefs;
    final List<String> contacts = (prefs.getStringList('contacts') ?? null);


    if (contacts == null) {
      List<String> contacts = new List<String>();
      contacts.add(name);
      prefs.setStringList('contacts', contacts);
      prefs.setStringList(name, details);
      _contactList.add(c);
      ContactsService.addContact(c);

    } else {
      if ( !contacts.contains(name))  {
        contacts.add(name);
        prefs.setStringList('contacts', contacts);
        prefs.setStringList(name, details);
        _contactList.add(c);
        ContactsService.addContact(c);
      }
    }
  }

  _deleteContact(Contact c) async {
    String name = c.givenName + c.familyName;
    final SharedPreferences prefs = await _prefs;

    prefs.remove(name);
    prefs.getStringList('contacts').remove(name);
    _contactList.remove(c);

    Iterable<Contact> test = await ContactsService.getContacts(
        query: (name));
    if (test.length > 0) {
      Contact deleteable = test.toList()[0];
      await ContactsService.deleteContact(deleteable);
    }
    setState(() {
      _buildListView();
    });
  }

  // Method to ask for permissions if not requested before
  _requestContactsPermissions() async {
    bool res =
        await SimplePermissions.requestPermission(Permission.WriteContacts);
    bool res2 =
        await SimplePermissions.requestPermission(Permission.ReadContacts);
    print("permission request result is " + res.toString());
    print("permission request result is " + res2.toString());
  }

  //Shows delete dialog when Contact tile is long pressed
  _showDeleteDialog(Contact c) {
    showDialog(
      barrierDismissible: true,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text("Delete Contact"),
          content: new Text("Are you sure you want to delete  " +
              "\n" +
              c.givenName +
              " " +
              c.familyName +
              "?"),
          actions: <Widget>[
            new FlatButton(
              child: new Text(
                "Delete",
                style: TextStyle(
                  color: Colors.red,
                ),
              ),
              onPressed: () {
                _deleteContact(c);
                Navigator.of(context).pop();
              },
            ),
            new FlatButton(
              child: new Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _getContacts();
    _requestContactsPermissions();
  }

  Widget _buildListView() {
    return ListView.builder(
      controller: _scrollController,
      reverse: true,
      shrinkWrap: true,
      padding: const EdgeInsets.all(16.0),
      itemBuilder: (BuildContext context, int index) {
        if (index.isOdd) {
          return Divider(
            height: 2.0,
          );
        }
        final i = index ~/ 2;
        var contact = _contactList[i];
        return _contactTile(contact);
      },
      itemCount: (_contactList.length * 2) - 1,
    );
  }

  Widget _contactTile(Contact contact) {
    return Material(
        color: Colors.transparent,
        child: Container(
            height: 100.0,
            child: InkWell(
                onLongPress: () {
                  _showDeleteDialog(contact);
                },
                onTap: () {},
                highlightColor: Colors.red[400],
                splashColor: Colors.red[100],
                borderRadius: BorderRadius.all(Radius.circular(15.0)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(right: 16.0),
                        child: new CircleAvatar(
                          child: Text(
                              contact.givenName.substring(0, 1).toUpperCase(),
                              style: TextStyle(
                                fontSize: 20.0,
                              )),
                          radius: 30.0,
                          backgroundColor: _randColor(),
                          foregroundColor: Colors.black,
                        ),
                      ),
                      Flexible(
                          child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Text(
                                contact.givenName,
                                style: TextStyle(fontSize: 18.0),
                                maxLines: 1,
                              ),
                            ),
                            Text(
                              contact.jobTitle,
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 14.0,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ))
                    ],
                  ),
                ))));
  }

  Widget actionButton() {
    return FloatingActionButton(
      backgroundColor: Colors.blue,
      child: Icon(Icons.add),
      onPressed: () {
        _addContacts(new Contact(
            givenName: "Zeyad", familyName: "Test", jobTitle: "Hacker"));
        setState(() {
          _buildListView();
        });

        //Scroll to top of list after item has been added
        SchedulerBinding.instance.addPostFrameCallback(
          (_) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          },
        );
      },
      elevation: 2.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Contacts App'),
      ),
      body: _buildListView(),
      floatingActionButton: actionButton(),
    );
  }
}
