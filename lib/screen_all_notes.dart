import 'package:flutter/material.dart';
import 'package:note_app/data/data.dart';
import 'package:note_app/data/note_model/note_model.dart';
import 'package:note_app/screen_about.dart';
import 'package:note_app/screen_add_note.dart';

class ScreenAllNotes extends StatelessWidget {
  const ScreenAllNotes({super.key});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await NoteDB.instance.getAllNotes();
    });

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('TODO-NOTE'),
      ),
      drawer: Drawer(
          backgroundColor: Colors.blueGrey.shade400,
          child: ListView(
            children: [
              DrawerHeader(
                decoration: const BoxDecoration(color: Colors.black26),
                child: Column(
                  children: const [
                    Icon(
                      Icons.note_alt_outlined,
                      size: 80,
                    ),
                    Text(
                      'TODO-NOTE',
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    )
                  ],
                ),
              ),
              ListTile(
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const ScreenAbout(),
                )),
                title: const Text(
                  'About',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
                leading: const Icon(Icons.info_outline_rounded, size: 40),
              )
            ],
          )),
      body: SafeArea(
        child: ValueListenableBuilder(
          valueListenable: NoteDB.instance.notelistnotifier,
          builder: (context, List<NoteModel> newNotes, _) => newNotes.isEmpty
              ? const Center(
                  child: Text('Note list empty'),
                )
              : GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  padding: const EdgeInsets.all(20),
                  children: List.generate(newNotes.length, (index) {
                    final note = NoteDB.instance.notelistnotifier.value[index];
                    if (note.id == null) {
                      const SizedBox();
                    }
                    return NoteItem(
                      id: note.id!,
                      title: note.title ?? 'No Title',
                      content: note.content ?? 'No Content',
                    );
                  }),
                ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => ScreenAddNotes(type: ActionType.addNote),
        )),
        label: const Text('Add'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}

class NoteItem extends StatelessWidget {
  final String id;
  final String title;
  final String content;
  const NoteItem(
      {super.key,
      required this.id,
      required this.title,
      required this.content});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) =>
                ScreenAddNotes(type: ActionType.editNOte, id: id),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: Colors.grey, strokeAlign: StrokeAlign.center, width: 2),
        ),
        child: Column(children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title.toUpperCase(),
                  overflow: TextOverflow.fade,
                  style: const TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
              ),
              IconButton(
                onPressed: () {
                  NoteDB.instance.deleteNote(id);
                },
                icon: const Icon(
                  Icons.delete,
                  color: Colors.red,
                ),
              ),
            ],
          ),
          Text(
            content.toLowerCase(),
            maxLines: 5,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.black, fontSize: 14),
          )
        ]),
      ),
    );
  }
}
