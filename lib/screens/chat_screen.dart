import 'package:flutter/material.dart';
import 'package:scholar_chat/constsnt.dart';
import 'package:scholar_chat/models/message.dart';
import 'package:scholar_chat/widgets/chat_buble.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// ignore: must_be_immutable
class ChatScreen extends StatelessWidget {
  ChatScreen({Key? key}) : super(key: key);

  final _controller = ScrollController();

  static String id = "ChatScreen";

  CollectionReference messages =
      FirebaseFirestore.instance.collection(KMessagesCollections);

  TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var email = ModalRoute.of(context)!.settings.arguments;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: kPrimaryColor,
        centerTitle: true,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              KLogo,
              height: 50,
            ),
            const Text(
              "Chat",
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  messages.orderBy(KCreatedAt, descending: true).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  List<Message> messagesList = [];
                  for (int i = 0; i < snapshot.data!.docs.length; i++) {
                    var data =
                        snapshot.data!.docs[i].data() as Map<String, dynamic>;
                    if (data.containsKey('message')) {
                      messagesList.add(Message.fromJson(data));
                    }
                  }
                  return ListView.builder(
                    reverse: true,
                    controller: _controller,
                    itemCount: messagesList.length,
                    itemBuilder: (context, index) {
                      return messagesList[index].id == email
                          ? ChatBuble(
                              message: messagesList[index],
                            )
                          : ChatBubleForFriend(message: messagesList[index]);
                    },
                  );
                } else if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: controller,
              onSubmitted: (data) {
                messages.add(
                  {
                    KMessage: data,
                    KCreatedAt: DateTime.now(),
                    'id': email,
                  },
                );
                controller.clear();

                _controller.animateTo(0,
                    duration: const Duration(seconds: 1), curve: Curves.easeIn);
              },
              decoration: InputDecoration(
                suffixIcon: const Icon(
                  Icons.send,
                  color: kPrimaryColor,
                ),
                hintText: "Send Message",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: kPrimaryColor),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
