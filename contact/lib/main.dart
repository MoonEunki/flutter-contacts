import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:contacts_service/contacts_service.dart';

void main() {
  runApp(
      MaterialApp(
          home:MyApp()
      ));
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {


  getPermission() async{
    var status = await Permission.contacts.status;
    if(status.isGranted) {
      print('허락');
      var contacts = await ContactsService.getContacts();
      setState(() {
        name = contacts;
      });
    }else if(status.isDenied){
      print('거절');
      Permission.contacts.request(); // 거절상태면 허락해달라고 창띄우기
      openAppSettings();
    }
  }


  @override
  void initState() {
    super.initState();
    getPermission();
  }

  // List<Contact> name = [];

  List<Contact> name = [];

   addItem(contacts) {
     setState(() {
       name.add(contacts);
     });

     //  var newPerson = Contact();
    //  newPerson.givenName=contacts;
    //  await ContactsService.addContact(newPerson);
    // setState(() {
    //   name.add(newPerson);
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          showDialog(context: context, barrierDismissible: false, builder: (context){
            return DialogUI(addItem:addItem);
          });

        },
      ),
      appBar: AppBar(
        title: Text(name.length.toString()),
        actions: [
          IconButton(onPressed: (){getPermission();}, icon: Icon(Icons.contacts))
      ],centerTitle: false,),
      body: ListView.builder(
        itemCount: name.length,
        itemBuilder: (context,index){
          return ListTile(
            leading: Icon(Icons.account_circle,size: 50,),
            title: Text(name[index].givenName??'이름없음'),
            );
          },
        ),
      );
  }
}

class DialogUI extends StatelessWidget {
  DialogUI({Key? key, this.state, this.addItem}) : super(key: key);
  final state;
  final addItem;
  var inputData = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('연락처 추가'),
      content: TextField(controller: inputData),
      actions: [
        TextButton(onPressed: (){
          Navigator.pop(context);
        }, child: Text('취소')),
        TextButton(onPressed: () async {
          var newContact = Contact();
          newContact.givenName = inputData.text;  //새로운 연락처 만들기
          await ContactsService.addContact(newContact);  //실제로 연락처에 집어넣기
          addItem(newContact);
          Navigator.pop(context);
        }, child: Text('확인')),
      ],
    );
  }
}