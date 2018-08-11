import 'package:flutter/material.dart';
import 'package:contacts_service/contacts_service.dart';
import 'dart:math';
import 'dart:async';
import 'package:simple_permissions/simple_permissions.dart';
import 'package:flutter/scheduler.dart';

class ContactsListView extends StatefulWidget {
  _ContactsListViewState createState() => new _ContactsListViewState();
}

class _ContactsListViewState extends State<ContactsListView> {
  ScrollController _scrollController = new ScrollController();
  final _contactList = <Contact>[];
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

  // Method to ask for permissions if not requested before
  _requestContactsPermissions() async {
    bool res =
        await SimplePermissions.requestPermission(Permission.WriteContacts);
    bool res2 =
        await SimplePermissions.requestPermission(Permission.ReadContacts);
    print("permission request result is " + res.toString());
    print("permission request result is " + res2.toString());
  }

  void buildList() {
    Contact c1 = new Contact(givenName: 'Zeyad', jobTitle: 'Macbook seller');
    Contact c2 = new Contact(givenName: 'Khaled', jobTitle: 'Aramex Delievery');
    Contact c3 = new Contact(givenName: 'Mohamed', jobTitle: 'Pizza Guy');
    _contactList.add(c1);
    _contactList.add(c2);
    _contactList.add(c3);
  }

  void initState() {
    super.initState();
    buildList();
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
      itemCount: _contactList.length * 2,
    );
  }

  Widget _contactTile(Contact contact) {
    Divider();
    return Material(
        color: Colors.transparent,
        child: Container(
            height: 100.0,
            child: InkWell(
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

  addContact() {
    Contact z =
        new Contact(givenName: "Zeyad", familyName: "Test", jobTitle: "Hacker");
    ContactsService.addContact(z);
    _contactList.add(z);
  }

  Widget actionButton() {
    return FloatingActionButton(
      backgroundColor: Colors.blue,
      child: Icon(Icons.add),
      onPressed: () {
        addContact();
        print("Success");
        setState(() {
          _buildListView();
        });
        //Scroll to top of list after item has been added
        SchedulerBinding.instance.addPostFrameCallback((_) {
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
