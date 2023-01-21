import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:note_app/data/get_all_notes_resp/get_all_notes_resp.dart';
import 'package:note_app/data/note_model/note_model.dart';
import 'package:note_app/data/url.dart';

abstract class ApiCalls {
  Future<NoteModel?> createNote(NoteModel value);
  Future<List<NoteModel?>> getAllNotes();
  Future<NoteModel?> updateNote(NoteModel value);
  Future<void> deleteNote(String id);
}

class NoteDB extends ApiCalls {
//singleton

  NoteDB.internal();
  static NoteDB instance = NoteDB.internal();

  NoteDB factory() {
    return instance;
  }

  final dio = Dio();
  final url = Url();

  ValueNotifier<List<NoteModel>> notelistnotifier = ValueNotifier([]);

  NoteDB() {
    dio.options = BaseOptions(
      baseUrl: url.baseUrl,
      responseType: ResponseType.plain,
    );
  }

  @override
  Future<NoteModel?> createNote(NoteModel value) async {
    try {
      final result = await dio.post(
        url.baseUrl + url.createNote,
        data: value.toJson(),
      );
      final note = NoteModel.fromJson(result.data as Map<String, dynamic>);
      notelistnotifier.value.insert(0, note);
      notelistnotifier.notifyListeners();
      return note;
    } on DioError catch (_) {
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> deleteNote(String id) async {
    final result =
        await dio.delete(url.baseUrl + url.deleteNote.replaceFirst('{id}', id));
    if (result.data == null) {
      return;
    } else {
      final index = notelistnotifier.value.indexWhere((note) => note.id == id);
      if (index == -1) {
        return;
      }
      notelistnotifier.value.removeAt(index);
      notelistnotifier.notifyListeners();
    }
  }

  @override
  Future<List<NoteModel>> getAllNotes() async {
    final result = await dio.get(url.baseUrl + url.getAllNote);

    if (result.data != null) {
      // final Map<String, dynamic>resultAsJson = jsonDecode(result.data);
      final getNoteResp = GetAllNotesResp.fromJson(result.data);
      // final note = NoteModel.fromJson(result.data);
      notelistnotifier.value.clear();
      // notelistnotifier.value.addAll(note);
      notelistnotifier.value.addAll(getNoteResp.data.reversed);
      notelistnotifier.notifyListeners();
      return getNoteResp.data;
    } else {
      notelistnotifier.value.clear();

      return [];
    }
  }

  @override
  Future<NoteModel?> updateNote(NoteModel value) async {
    final result =
        await dio.put(url.baseUrl + url.updateNote, data: value.toJson());
    if (result.data == null) {
      return null;
    }
    final index =
        notelistnotifier.value.indexWhere((note) => note.id == value.id);
    if (index == -1) {
      return null;
    }

    notelistnotifier.value.removeAt(index);

    notelistnotifier.value.insert(index, value);
    notelistnotifier.notifyListeners();
    return value;
  }

  NoteModel? getNoteByID(String id) {
    try {
      return notelistnotifier.value.firstWhere((note) => note.id == id);
    } catch (_) {
      return null;
    }
  }
}
