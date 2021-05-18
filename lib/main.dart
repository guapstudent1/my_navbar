import 'package:flutter/material.dart';
import 'navbar.dart';
void main() {
  runApp(StateContainer(child: MyApp()));
}
class User {
  String firstName;
  String lastName;
  String email;

  User(this.firstName, this.lastName, this.email);
}
class _InheritedStateContainer extends InheritedWidget {
  // Data is your entire state. In our case just 'User'
  final StateContainerState data;

  // You must pass through a child and your state.
  _InheritedStateContainer({
    Key? key,
    required this.data,
    required child,
  }) : super(key: key, child: child);

  // This is a built in method which you can use to check if
  // any state has changed. If not, no reason to rebuild all the widgets
  // that rely on your state.
  @override
  bool updateShouldNotify(_InheritedStateContainer old) => true;
}

class StateContainer extends StatefulWidget {
  // You must pass through a child.
  final Widget child;
  final User? user;

  StateContainer({
    required this.child,
    this.user,
  });

  // This is the secret sauce. Write your own 'of' method that will behave
  // Exactly like MediaQuery.of and Theme.of
  // It basically says 'get the data from the widget of this type.
  static StateContainerState of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<_InheritedStateContainer>()!.data;
  }

  @override
  StateContainerState createState() => new StateContainerState();
}
class StateContainerState extends State<StateContainer> {
  // Whichever properties you wanna pass around your app as state
  User? user;

  // You can (and probably will) have methods on your StateContainer
  // These methods are then used through our your app to
  // change state.
  // Using setState() here tells Flutter to repaint all the
  // Widgets in the app that rely on the state you've changed.
  void updateUserInfo({firstName, lastName, email}) {
    if (user == null) {
      user = new User(firstName, lastName, email);
      setState(() {
        user = user;
      });
    } else {
      setState(() {
        user!.firstName = firstName ?? user!.firstName;
        user!.lastName = lastName ?? user!.lastName;
        user!.email = email ?? user!.email;
      });
    }
  }

  // Simple build method that just passes this state through
  // your InheritedWidget
  @override
  Widget build(BuildContext context) {
    return new _InheritedStateContainer(
      data: this,
      child: widget.child,
    );
  }
}

class MyApp extends StatelessWidget {

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final myController = TextEditingController();
  final List<String> _array = ["frodo", "gummy", "bear"];
  User? user;
  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    myController.dispose();
    super.dispose();
  }
  void _addWord(String word)
  {
    setState((){
      _array.add(word);
    });
  }
  // This Widget will display the users info:
  Widget get _userInfo {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          // This refers to the user in your store
          Text("${user!.firstName} ${user!.lastName}",
              style: TextStyle(fontSize: 24.0)),
          Text( user!.email, style: TextStyle(fontSize: 24.0)),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child:
            TextField(
              controller: myController,
            ),
          ),
          Center(
            child: ElevatedButton(
              child: Text('Add word'),
              onPressed: () {
                _addWord(myController.text);
              },
            ),
          ),
          Expanded(
              child: ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: _array.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Container(
                      height: 50,
                      margin: EdgeInsets.all(2),
                      child: Center(
                          child: Text('${_array[index]}',
                            style: TextStyle(fontSize: 18),
                          )
                      ),
                    );
                  }
              )
          ),
        ],
      ),
    );
  }


  Widget get _logInPrompt {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text(
            'Please add user information',
            style: const TextStyle(fontSize: 18.0),
          ),
        ],
      ),
    );
  }

  // All this method does is bring up the form page.
  void _updateUser(BuildContext context) {
    Navigator.push(
      context,
      new MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) {
          return UpdateUserScreen();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // This is how you access your store. This container
    // is where your properties and methods live
    final container = StateContainer.of(context);

    // set the class's user
    user = container.user;

    var body = user != null ? _userInfo : _logInPrompt;

    return new Scaffold(
      drawer: NavBar(),
      appBar: AppBar(
        title: Text('Inherited Widget Test'),
      ),
      body: body,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _updateUser(context),
        child: Icon(Icons.edit),
      ),
    );
  }
}

class UpdateUserScreen extends StatelessWidget {
  static final GlobalKey<FormState> formKey = new GlobalKey<FormState>();
  static final GlobalKey<FormFieldState<String>> firstNameKey =
  new GlobalKey<FormFieldState<String>>();
  static final GlobalKey<FormFieldState<String>> lastNameKey =
  new GlobalKey<FormFieldState<String>>();
  static final GlobalKey<FormFieldState<String>> emailKey =
  new GlobalKey<FormFieldState<String>>();

  const UpdateUserScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
// get reference to your store
    final container = StateContainer.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit User Info'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: formKey,
          child: ListView(
            children: [
              TextFormField(
                key: firstNameKey,
                style: Theme.of(context).textTheme.headline5,
                decoration: new InputDecoration(
                  hintText: 'First Name',
                ),
              ),
              TextFormField(
                key: lastNameKey,
                style: Theme.of(context).textTheme.headline5,
                decoration: new InputDecoration(
                  hintText: 'Last Name',
                ),
              ),
              TextFormField(
                key: emailKey,
                style: Theme.of(context).textTheme.headline5,
                decoration: InputDecoration(
                  hintText: 'Email Address',
                ),
              )
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          final form = formKey.currentState!;
          if (form.validate()) {
            var firstName = firstNameKey.currentState!.value;
            var lastName = lastNameKey.currentState!.value;
            var email = emailKey.currentState!.value;

            // Later, do some stuff here
// This is a hack that isn't important
            // To this lesson. Basically, it prevents
            // The store from overriding user info
            // with an empty string if you only want
            // to change a single attribute
            if (firstName == '') {
              firstName = null;
            }
            if (lastName == '') {
              lastName = null;
            }
            if (email == '') {
              email = null;
            }

            // You can call the method from your store,
            // which will call set state and rerender
            // the widgets that rely on the user slice of state.
            // In this case, thats the home page
            container.updateUserInfo(
              firstName: firstName,
              lastName: lastName,
              email: email,
            );

            Navigator.pop(context);
          }
        },
      ),
    );
  }
}