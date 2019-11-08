import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(),
      initialRoute: Home.id,
      routes: {
        Home.id: (context) => Home(),
        DangKi.id: (context) => DangKi(),
        Chat.id: (context) => Chat(),
      },
    );
  }
}

class Home extends StatefulWidget {
  static const String id = "/";

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String email;
  String password;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> DangNhap() async {
    FirebaseUser user = (await _auth.signInWithEmailAndPassword(
            email: email, password: password))
        .user;
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => Chat(
                  user: user,
                )));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Image(
                  image: AssetImage('assets/logo.png'),
                  width: 80,
                  height: 80,
                ),
                Padding(
                  padding: const EdgeInsets.all(0),
                  child: Text(
                    'ChatApp',
                    style: TextStyle(fontSize: 45),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 20,
            ),
            TextField(
              decoration: InputDecoration(
                  hintText: 'Email...', border: const OutlineInputBorder()),
              keyboardType: TextInputType.emailAddress,
              onChanged: (value) => email = value,
            ),
            SizedBox(
              height: 20,
            ),
            TextField(
              decoration: InputDecoration(
                  hintText: 'Mật khẩu...', border: const OutlineInputBorder()),
              onChanged: (value) => password = value,
              obscureText: true,
              autocorrect: false,
            ),
            SizedBox(
              height: 20,
            ),
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  CustomButton(
                    text: 'Đăng kí',
                    callback: () async {
                      Navigator.of(context).pushNamed(DangKi.id);
                    },
                  ),
                  CustomButton(
                    text: 'Đăng nhập',
                    callback: () async {
                      await DangNhap();
                    },
                  )
                ])
          ],
        ),
      ),
    );
  }
}

class CustomButton extends StatelessWidget {
  final VoidCallback callback;
  final String text;

  const CustomButton({Key key, this.callback, this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Material(
        color: Colors.cyan,
        elevation: 6.0,
        borderRadius: BorderRadius.circular(30.0),
        child: MaterialButton(
          onPressed: callback,
          minWidth: 150.0,
          height: 20.0,
          child: Text(
            text,
            style: TextStyle(fontSize: 20.0),
          ),
        ),
      ),
    );
  }
}

class DangKi extends StatefulWidget {
  static const String id = "/DangKi";

  @override
  _DangKiState createState() => _DangKiState();
}

class _DangKiState extends State<DangKi> {
  String email;
  String password;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> DangKyUser() async {
    FirebaseUser user = (await _auth.createUserWithEmailAndPassword(
            email: email, password: password))
        .user;
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => Chat(
                  user: user,
                )));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Image(
                  image: AssetImage('assets/logo.png'),
                  width: 80,
                  height: 80,
                ),
                Padding(
                  padding: const EdgeInsets.all(0),
                  child: Text(
                    'ChatApp',
                    style: TextStyle(fontSize: 45),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 20,
            ),
            TextField(
              decoration: InputDecoration(
                  hintText: 'Email...', border: const OutlineInputBorder()),
              keyboardType: TextInputType.emailAddress,
              onChanged: (value) => email = value,
            ),
            SizedBox(
              height: 20,
            ),
            TextField(
              decoration: InputDecoration(
                  hintText: 'Mật khẩu...', border: const OutlineInputBorder()),
              onChanged: (value) => password = value,
              obscureText: true,
              autocorrect: false,
            ),
            SizedBox(
              height: 20,
            ),
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  CustomButton(
                    text: 'Đăng kí',
                    callback: () async {
                      await DangKyUser();
                    },
                  ),
                  CustomButton(
                    text: 'Quay lại đăng nhập',
                    callback: () {
                      Navigator.of(context).pushNamed(Home.id);
                    },
                  )
                ])
          ],
        ),
      ),
    );
  }
}

class Chat extends StatefulWidget {
  static const String id = "/Chat";
  final FirebaseUser user;

  const Chat({Key key, this.user}) : super(key: key);

  @override
  _ChatState createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Firestore _firestore = Firestore.instance;


  TextEditingController messageController = TextEditingController();
  ScrollController scrollController = ScrollController();
  Future<void> callback() async {
    if (messageController.text.length > 0) {
      await _firestore.collection(
          'messages').add(
          {
            'text': messageController.text,
            'from': widget.user.email,
            'date': DateTime.now(
            ).toIso8601String(
            ).toString(
            ),
          });
      messageController.clear(
      );
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        curve: Curves.easeOut,
        duration: const Duration(
            milliseconds: 300),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ChatApp'),
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('messages')
                    .orderBy('date')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData)
                    return Center(
                      child: CircularProgressIndicator(),
                    );

                  List<DocumentSnapshot> docs = snapshot.data.documents;

                  List<Widget> messages = docs
                      .map((doc) => Message(
                    from: doc.data['from'],
                    text: doc.data['text'],
                    me: widget.user.email == doc.data['from'],
                  ))
                      .toList();

                  return ListView(
                    controller: scrollController,
                    children: <Widget>[
                      ...messages,
                    ],
                  );
                },
              ),
            ),
            Container(
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      onSubmitted: (value) => callback(),
                      decoration: InputDecoration(
                        hintText: "Nhập nội dung...",
                        border: const OutlineInputBorder(),
                      ),
                      controller: messageController,
                    ),
                  ),
                  SendButton(
                    text: "Send",
                    callback: callback,
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
class SendButton extends StatelessWidget {
  final String text;
  final VoidCallback callback;

  const SendButton({Key key, this.text, this.callback}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return FlatButton(
      color: Colors.blueAccent,
      onPressed: callback,
      child: Text(text),
    );
  }
}

class Message extends StatelessWidget {
  final String from;
  final String text;

  final bool me;

  const Message({Key key, this.from, this.text, this.me}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment:
        me ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            from,
          ),
          Material(
            color: me ? Colors.teal : Colors.red,
            borderRadius: BorderRadius.circular(10.0),
            elevation: 6.0,
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
              child: Text(
                text,
              ),
            ),
          )
        ],
      ),
    );
  }
}