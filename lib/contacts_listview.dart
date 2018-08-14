import 'package:flutter/material.dart';
import 'package:contacts_service/contacts_service.dart';
import 'dart:math';
import 'dart:async';
import 'package:simple_permissions/simple_permissions.dart';
import 'package:flutter/scheduler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:temp_contact/help_dialog.dart';
import 'package:temp_contact/about_dialog.dart';
import 'addcontact_dialog.dart';
import 'dart:core';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:url_launcher/url_launcher.dart';

//TODO: Organize project structure
//TODO: Edit Contact

class ContactsListView extends StatefulWidget {
  _ContactsListViewState createState() => new _ContactsListViewState();
}

class _ContactsListViewState extends State<ContactsListView> {
  //###################Properties######################
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  List<Contact> _contactList = <Contact>[];
  List<Contact> _deleteList = <Contact>[];
  ScrollController _scrollController = new ScrollController();
  int _intervalValue;
  final _colorList = <Color>[
    Colors.pink[600],
    Colors.red[600],
    //Colors.blue[600],
    Colors.green[600],
    Colors.cyan[600],
    Colors.amber[600],
    //Colors.indigo[600],
    Colors.lime[600],
    Colors.deepOrange[600],
    Colors.deepPurple[600],
    Colors.lightBlue[600],
    Colors.teal[600],
    //Colors.grey[600]
  ];

  // Application Flow:
  // (1) _getContacts() is called to retrieve data from shared preferences
  //     Format is {'contacts' : {'givenName+familyName',''givenName+familyName'}}
  //               {'givenName+familyName' : { 'givenName' , 'familyName', 'jobName'}}
  //
  // (2) _requestPermission() asks for Contact Read/Write permissions on both platforms
  // (3) _addContacts() adds contact if not duplicated in _contactsList , SharedPrefs, ContactsService
  // (4) _deleteContacts() removes the contact from _contactsList, SharedPrefs, ContactsService "Using a query"

  //############################Intialization##########################

  //Initialize the state of the app
  @override
  void initState() {
    super.initState();
    _requestContactsPermissions();
    _initializeInterval();
    _getContacts();
  }

  // Method to ask for permissions if not requested before
  _requestContactsPermissions() async {
    await SimplePermissions.requestPermission(Permission.WriteContacts);
    await SimplePermissions.requestPermission(Permission.ReadContacts);
  }

  //#########################HELPING METHODS#########################

  //Generate Random Color
  Color _randColor() {
    Random rand = new Random();
    return _colorList[rand.nextInt(_colorList.length)];
  }

  //#########################CONTACTS WORK#########################

  //Retrieves contacts from SharedPreferences and adds them to _contactsList
  //Also checks for Contacts to be removed if they passed the interval
  _getContacts() async {
    _initializeInterval();
    _contactList = <Contact>[];
    final SharedPreferences prefs = await _prefs;
    final List<String> contacts = (prefs.getStringList('contacts') ?? null);
    if (contacts != null) {
      for (String name in contacts) {
        final List<String> details = (prefs.getStringList(name) ?? null);
        if (details != null) {
          Iterable<Item> phones = [
            new Item(label: "Mobile", value: details[3])
          ];
          Contact c = new Contact(
              givenName: details[0],
              familyName: details[1],
              jobTitle: details[2],
              phones: phones);
          //Check if its time to remove this contact, if so added to a
          // deleteList not to interfere with the retrieval of shared
          // preferences thread
          if (_shouldBeRemoved(details[4])) {
            _deleteList.add(c);
          } else {
            _contactList.add(c);
          }
        }
      }
      //Check if there was found any contacts to be deleted and deleted them
      for (Contact c in _deleteList) {
        await _deleteContact(c);
      }
      _deleteList =
          <Contact>[]; // Reset DeleteList for later usage in same session

      setState(() {
        _buildListView();
      });
    }
  }

  //Adds contacts to SharedPrefs, ContactsServices, and _contactsList
  _addContacts(Contact c) async {
    //Contact details
    String name = c.givenName + c.familyName;
    List<String> details = new List<String>();
    details.add(c.givenName);
    details.add(c.familyName);
    details.add(c.jobTitle);
    details.add(c.phones.toList().removeLast().value);

    // Timestamp of creation in milliseconds
    String time = new DateTime.now().millisecondsSinceEpoch.toString();
    details.add(time);

    //Retrieve SharePreferences
    final SharedPreferences prefs = await _prefs;
    final List<String> contacts = (prefs.getStringList('contacts') ?? null);

    if (contacts == null) {
      List<String> contacts = new List<String>();
      contacts.add(name);
      prefs.setStringList('contacts', contacts);
      prefs.setStringList(name, details);
      _contactList.add(c);
      ContactsService.addContact(c);
      _handleScrolling();
    } else {
      //Check for duplicate
      if (!contacts.contains(name)) {
        contacts.add(name);
        prefs.setStringList('contacts', contacts);
        prefs.setStringList(name, details);
        _contactList.add(c);
        ContactsService.addContact(c);
        _handleScrolling();
      } else {
        //Handle duplicate found
        Fluttertoast.showToast(
            msg: "A duplicate contact was found!",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIos: 1,
            bgcolor: "#e74c3c",
            textcolor: '#ffffff');
      }
    }
  }

  //Delete contact from SharedPrefs, ContactsServices, and _contactsList
  _deleteContact(Contact c) async {
    //ContactsList removal
    if (_contactList.contains(c)) {
      setState(() {
        _contactList.remove(c);
      });
    }
    String name = c.givenName + c.familyName;

    //Shared Preferences removal
    final SharedPreferences prefs = await _prefs;
    prefs.remove(name);
    List<String> tmp = prefs.getStringList('contacts');
    tmp.remove(name);
    prefs.setStringList('contacts', tmp);

    //ContactsService removal
    Iterable<Contact> test = await ContactsService.getContacts(
        //Query using givenName + SPACE + familyName
        query: (c.givenName + " " + c.familyName));
    if (test.length > 0) {
      Contact delete = test.toList()[0];
      await ContactsService.deleteContact(delete);
    }
  }

  //########################INTERVAL WORK############################

  //The Contact AutoRemoval algorithm
  bool _shouldBeRemoved(String time) {
    //Parse time of creation from String
    DateTime dateOfCreation =
        new DateTime.fromMillisecondsSinceEpoch(int.parse(time));
    //Retrieve current time and find difference between the two
    DateTime currentTime = new DateTime.now();
    Duration difference = currentTime.difference(dateOfCreation);

    //If difference is more than a specific period, return true
    if (difference.inMinutes >= _intervalValue) return true;

    return false;
  }

  //Initialize interval based on shared preferences or default value of 7 days
  _initializeInterval() async {
    final SharedPreferences prefs = await _prefs;
    int interval = prefs.getInt('interval');
    if (interval != null) {
      _intervalValue = interval;
    } else {
      _intervalValue = 7;
      prefs.setInt('interval', 7);
    }
  }

  //Change Interval value in Shared Preferences
  _changeInterval(int value) async {
    final SharedPreferences prefs = await _prefs;
    prefs.setInt('interval', value);
    _intervalValue = value;
  }

  //######################HANDLERS###############################

  Future<Null> _handleRefresh() async {
    await new Future.delayed(new Duration(seconds: 1));
    setState(() {
      _getContacts();
    });
    return null;
  }

  _handleScrolling() {
    SchedulerBinding.instance.addPostFrameCallback(
      (_) {
        _scrollController.animateTo(
          _scrollController.position.minScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      },
    );
  }

  //###########################DIALOGS###########################

  //View the Add contact Full screen dialog
  Future _showAddContactDialog() async {
    Contact returnedContact =
        await Navigator.of(context).push(new MaterialPageRoute<Contact>(
            builder: (BuildContext context) {
              return new AddContactDialog();
            },
            fullscreenDialog: true));
    if (returnedContact != null) {
      _addContacts(returnedContact);
    } else {
      setState(() {
        _buildListView();
      });
    }
  }

  Future _showIntervalDialog() async {
    await showDialog<int>(
      context: context,
      builder: (BuildContext context) {
        return new NumberPickerDialog.integer(
          minValue: 1,
          maxValue: 100,
          step: 1,
          initialIntegerValue: _intervalValue,
          title: new Text("Pick DAYS after which contacts are removed"),
        );
      },
    ).then((value) => value != null ? _changeInterval(value) : null);
  }

  //View the help dialog
  _showHelpDialog() {
    Navigator.of(context).push(new MaterialPageRoute<Contact>(
        builder: (BuildContext context) {
          return new HelpDialog();
        },
        fullscreenDialog: true));
  }

  //View the about app dialog
  _showAboutDialog() {
    Navigator.of(context).push(new MaterialPageRoute<Contact>(
        builder: (BuildContext context) {
          return new AboutAppDialog();
        },
        fullscreenDialog: true));
  }

  //Shows delete dialog when Contact tile is long pressed
  _showDeleteDialog(Contact c) {
    showDialog(
      barrierDismissible: false,
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

  //Side menu
  void _sideMenuAction(String choice) {
    if (choice == "interval") {
      _showIntervalDialog();
    } else if (choice == "help") {
      _showHelpDialog();
    } else if (choice == "about") {
      _showAboutDialog();
    }
  }

  //########################BUILD###############################

  Widget _buildListView() {
    //Check if the contact list has time to be viewed
    if (_contactList.length == 0) {
      return Center(
          child: SingleChildScrollView(
        child: Dismissible(
          background: Container(
            color: Colors.green,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                new Icon(
                  Icons.keyboard_arrow_right,
                  size: 36.0,
                  color: Colors.white,
                ),
              ],
            ),
          ),
          direction: DismissDirection.startToEnd,
          onDismissed: (direction) {
            _showAddContactDialog();
          },
          key: Key(new DateTime.now().millisecondsSinceEpoch.toString()),
          child: Padding(
            padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
            child: new ListTile(
              title: Center(
                child: new Text(
                  "Swipe To Start",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28.0,
                  ),
                  maxLines: 1,
                ),
              ),
              leading: new Icon(
                Icons.keyboard_arrow_right,
                size: 36.0,
                color: Colors.lightGreen,
              ),
              trailing:new Icon(
                Icons.keyboard_arrow_right,
                size: 36.0,
                color: Colors.lightGreen,
              ) ,
            ),
          ),
        ),
      ));
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16.0),
      itemBuilder: (BuildContext context, int index) {
        var contact = _contactList[_contactList.length - 1 - index];
        return _customTile(contact);
      },
      itemCount: (_contactList.length),
    );
  }

  //Customized tile for contacts view in the list view
  Widget _customTile(Contact contact) {
    return new Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Dismissible(
        background: Container(
          color: Colors.red,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              new Icon(
                Icons.delete_forever,
                size: 36.0,
                color: Colors.white,
              ),
            ],
          ),
        ),
        key: Key(contact.givenName + contact.familyName),
        direction: DismissDirection.endToStart,
        onDismissed: (direction) {
          _deleteContact(contact);
          Fluttertoast.showToast(
              msg: "Contact deleted successfully!",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIos: 1,
              bgcolor: "#e74c3c",
              textcolor: '#ffffff');
        },
        child: new ExpansionTile(
          leading: new CircleAvatar(
            child: Text(contact.givenName.substring(0, 1).toUpperCase(),
                style: TextStyle(
                  fontSize: 20.0,
                )),
            radius: 25.0,
            backgroundColor: _randColor(),
            foregroundColor: Colors.white,
          ),
          title: new Text(
            contact.givenName + " " + contact.familyName,
            style: new TextStyle(fontSize: 18.0, color: Colors.white),
          ),
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: new ListTile(
                title: new Text(
                  contact.jobTitle,
                  maxLines: 2,
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
                subtitle: new Text(
                  contact.phones == null
                      ? "No Number"
                      : contact.phones.toList()[0].value,
                  style: TextStyle(
                    color: Colors.white70,
                  ),
                ),
                trailing: new Icon(
                  Icons.call,
                  size: 36.0,
                  color: Colors.green,
                ),
                onTap: () => launch("tel://" + contact.phones.toList()[0].value),
              ),
            )
          ],
        ),
      ),
    );
  }

  //Action button to show up add contact form
  Widget actionButton() {
    return FloatingActionButton(
      tooltip: "Add contacts",
      child: Icon(Icons.add),
      onPressed: () {
        _showAddContactDialog();
      },
      elevation: 2.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).backgroundColor,
        elevation: 0.0,
        leading: new IconButton(
          icon: new Icon(Icons.refresh),
          tooltip: 'Refresh',
          onPressed: () {
            _getContacts();
          },
        ),
        centerTitle: true,
        title: Image.asset(
          'assets/icon/logo.png',
          fit: BoxFit.cover,
        ),
        actions: <Widget>[
          PopupMenuButton<String>(
              onSelected: _sideMenuAction,
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                    const PopupMenuItem(
                        value: "interval", child: Text("Set interval")),
                    const PopupMenuItem(value: "help", child: Text("Help")),
                    const PopupMenuItem(value: "about", child: Text("About")),
                  ])
        ],
      ),
      body: Stack(children: <Widget>[
        new Container(
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
                Colors.blue[700],
                Colors.blue[600],
                Colors.blue[400],
                Colors.blue[200],
              ],
            ),
          ),
          child: new RefreshIndicator(
            child: _buildListView(),
            onRefresh: _handleRefresh,
          ),
        ),
      ]),
      floatingActionButton: _contactList.length != 0 ? actionButton() : null,
    );
  }
}
