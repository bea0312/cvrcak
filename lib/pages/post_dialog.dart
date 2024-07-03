import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PostDialog extends StatefulWidget {
  const PostDialog({super.key});

  @override
  State<PostDialog> createState() => _PostDialogState();
}

class _PostDialogState extends State<PostDialog> {
  final currentUser = FirebaseAuth.instance.currentUser!;

  final TextEditingController _postController = TextEditingController();
  bool _isPublic = false;
  bool _isDisappearing = false;
  DateTime? _selectedDate;

  void _savePost() {
    if (_postController.text.trim().isNotEmpty) {
      final postData = {
        'UserEmail': currentUser.email,
        'Message': _postController.text.trim(),
        'IsPublic': _isPublic,
        'IsDisappearing': _isDisappearing,
        'CreatedAt': DateTime.now(),
      };

      if (_isDisappearing && _selectedDate != null) {
        postData['DisappearanceDate'] = _selectedDate;
      }

      FirebaseFirestore.instance.collection("Posts").add(postData);
    }

    Navigator.of(context).pop();
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? pickedDate;
    TimeOfDay? pickedTime;

    pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDate ?? DateTime.now()),
      );

      if (pickedTime != null) {
        setState(() {
          _selectedDate = DateTime(
            pickedDate!.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime!.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'New Post',
              style: TextStyle(
                fontSize: 24,
                color: Colors.deepOrange,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: TextField(
                controller: _postController,
                decoration: const InputDecoration(
                  hintText: 'Write something',
                  border: OutlineInputBorder(),
                ),
                autofocus: true,
                maxLength: 160,
                maxLines: null,
                expands: true,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Public Post'),
                Switch(
                  activeColor: Colors.deepOrange.shade400,
                  value: _isPublic,
                  onChanged: (bool value) {
                    setState(() {
                      _isPublic = value;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Disappearing'),
                Switch(
                  activeColor: Colors.deepOrange.shade400,
                  value: _isDisappearing,
                  onChanged: (bool value) {
                    setState(() {
                      _isDisappearing = value;
                    });
                  },
                ),
              ],
            ),
            if (_isDisappearing)
              Column(
                children: [
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => _selectDate(context),
                    child: Text(
                      _selectedDate == null
                          ? 'Select Date and Time'
                          : 'Selected: ${DateFormat.yMMMd().add_jm().format(_selectedDate!)}',
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: _savePost,
                  style: TextButton.styleFrom(
                    backgroundColor:
                        Colors.deepOrange.shade400, // Background color
                  ),
                  child: const Text(
                    'Post',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _postController.dispose();
    super.dispose();
  }
}
