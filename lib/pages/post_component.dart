import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PostComponent extends StatefulWidget {
  final String postId; // Add postId to identify the post
  String message;
  final String user;
  final Timestamp createdAt;
  final Timestamp? disappearanceTime;
  final bool isDisappearing;
  final bool isPublic;

  PostComponent(
      {super.key,
      required this.postId,
      required this.message,
      required this.user,
      required this.createdAt,
      this.disappearanceTime,
      required this.isDisappearing,
      required this.isPublic});

  @override
  State<PostComponent> createState() => _PostComponentState();
}

class _PostComponentState extends State<PostComponent> {
  void _editPost() {
    TextEditingController messageController =
        TextEditingController(text: widget.message);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Post'),
          content: TextField(
            controller: messageController,
            decoration: const InputDecoration(labelText: 'Message'),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Save'),
              onPressed: () {
                FirebaseFirestore.instance
                    .collection('Posts')
                    .doc(widget.postId)
                    .update({'Message': messageController.text}).then((value) {
                  setState(() {
                    widget.message = messageController.text;
                  });
                  Navigator.of(context).pop();
                });
              },
            ),
          ],
        );
      },
    );
  }

  void deletePost() {
    FirebaseFirestore.instance
        .collection('Posts')
        .doc(widget.postId)
        .delete()
        .then((value) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Post deleted')),
      );
    });
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: const Text('Are you sure you want to delete this post?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                deletePost();
              },
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final DateFormat formatter = DateFormat.yMMMMd().add_jm();
    final String formattedCreatedAt =
        formatter.format(widget.createdAt.toDate());
    final String? formattedDisappearanceTime = widget.disappearanceTime != null
        ? formatter.format(widget.disappearanceTime!.toDate())
        : null;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            padding: const EdgeInsets.all(8.0),
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(15)),
              color: Color.fromARGB(183, 222, 222, 222),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          widget.user,
                          style:
                              TextStyle(color: Colors.black.withOpacity(0.5)),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        formattedCreatedAt,
                        style: TextStyle(
                            color: Colors.black.withOpacity(0.3), fontSize: 10),
                      ),
                    ),
                    PopupMenuButton<String>(
                      onSelected: (String value) {
                        if (value == 'Edit') {
                          _editPost();
                        } else if (value == 'Delete') {
                          _confirmDelete();
                        }
                      },
                      itemBuilder: (BuildContext context) {
                        return {'Edit', 'Delete'}.map((String choice) {
                          return PopupMenuItem<String>(
                            value: choice,
                            child: Text(choice),
                          );
                        }).toList();
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.all(50.0),
                  child: Center(
                    child: Text(
                      widget.message,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          widget.isPublic ? 'Public' : 'Not Public',
                          style: const TextStyle(
                              fontSize: 10,
                              color: Color.fromARGB(150, 158, 158, 158)),
                        ),
                        Text(
                          widget.isDisappearing &&
                                  formattedDisappearanceTime != null
                              ? 'Disappears on: $formattedDisappearanceTime'
                              : 'Permanent',
                          style: const TextStyle(
                              fontSize: 10,
                              color: Color.fromARGB(150, 158, 158, 158)),
                        ),
                      ],
                    ),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.favorite),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.insert_comment),
                    ),
                  ],
                ),
              ],
            ),
          ),
        )
      ],
    );
  }
}
