import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cvrcak2/pages/post_component.dart';
import 'package:cvrcak2/pages/post_dialog.dart';
import 'package:flutter/material.dart';

class HomePageContent extends StatelessWidget {
  const HomePageContent({super.key});

  void _addPost(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return const PostDialog();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Column(
        children: [
          Expanded(
              child: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection("Posts")
                .orderBy("CreatedAt", descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final post = snapshot.data!.docs[index];
                    return PostComponent(
                        postId: post.id,
                        message: post['Message'],
                        user: post['UserEmail'],
                        createdAt: post['CreatedAt'],
                        disappearanceTime:
                            post.data().containsKey('DisappearanceDate')
                                ? post['DisappearanceDate']
                                : null,
                        isDisappearing: post['IsDisappearing'],
                        isPublic: post['IsPublic']);
                  },
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Text('Error: ${snapshot.error}'),
                );
              }
              return const Center(
                child: CircularProgressIndicator(),
              );
            },
          ))
        ],
      )),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addPost(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(
    home: HomePageContent(),
  ));
}
