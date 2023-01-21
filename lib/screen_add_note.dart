import 'package:flutter/material.dart';
import 'package:note_app/data/data.dart';
import 'package:note_app/data/note_model/note_model.dart';

enum ActionType {
  addNote,
  editNOte,
}

class ScreenAddNotes extends StatelessWidget {
  final ActionType type;
  String? id;
  ScreenAddNotes({super.key, required this.type, this.id});

  Widget get savebutton => TextButton.icon(
        onPressed: () {
          switch (type) {
            case ActionType.addNote:
              saveNote();
              break;
            case ActionType.editNOte:
              saveEditedNote();
              break;
          }
        },
        icon: const Icon(Icons.save),
        label: const Text(
          'Save',
          style: TextStyle(color: Colors.white),
        ),
      );

  final titleController = TextEditingController();
  final contentController = TextEditingController();
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    if (type == ActionType.editNOte) {
      if (id == null) {
        Navigator.of(context).pop();
      }

      final note = NoteDB.instance.getNoteByID(id!);
      if (note == null) {
        Navigator.of(context).pop();
      }

      titleController.text = note!.title ?? 'No title';
      contentController.text = note.content ?? 'No Content';
    }

    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Text(
          type.name.toUpperCase(),
        ),
        actions: [savebutton],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              TextFormField(
                controller: titleController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Title',
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              TextFormField(
                controller: contentController,
                maxLines: 4,
                maxLength: 100,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Content',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> saveNote() async {
    final newNote = NoteModel.create(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: titleController.text,
      content: contentController.text,
    );
    final newnote = await NoteDB.instance.createNote(newNote);
    if (newnote != null) {
      print('Note saved');
      Navigator.of(scaffoldKey.currentContext!).pop();
    } else {
      print('Error while saving note');
    }
  }

  Future<void> saveEditedNote() async {
    final editedNote = NoteModel.create(
      id: id,
      title: titleController.text,
      content: contentController.text,
    );
    final note = await NoteDB.instance.updateNote(editedNote);
    if (note == null) {
      print('unable to update');
    } else {
      Navigator.of(scaffoldKey.currentContext!).pop();
    }
  }
}
