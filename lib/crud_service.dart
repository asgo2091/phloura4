import 'dart:async';
import 'package:flutter/material.dart';
import 'package:phloura/constants.dart';
import 'package:phloura/exceptions.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' show join;

import 'package:path_provider/path_provider.dart'
    show MissingPlatformDirectoryException, getApplicationDocumentsDirectory;

class CrudService {
  Database? _phloura;

  Future<void> initializeApp() async {}

  // *****************************************/
  //Note
  Future<int> createNote({
    required String noteDate,
    int? noteAction,
    int? noteVaxt,
    int? notePlace,
  }) async {
    await ensureDbIsOpen();
    final db = _getDatabaseOrThrow();

    final data = {
      'noteDate': noteDate,
      'noteAction': noteAction,
      'noteVaxt': noteVaxt,
      'notePlace': notePlace,
    };
    final id = await db.insert(
      'noteTable',
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return id;
  }

  Future<void> editNote({required int noteId, required String noteDate}) async {
    await ensureDbIsOpen();
    final db = _getDatabaseOrThrow();

    final data = {'noteDate': noteDate};
    await db.update(
      'noteTable',
      data,
      where: 'noteId = ?',
      whereArgs: [noteId],
    );
  }

  Future<List<Map<String, dynamic>>> getAllNotes() async {
    await ensureDbIsOpen();
    final db = _getDatabaseOrThrow();

    return await db.query('noteTable', orderBy: 'noteDate DESC');
  }

  Future<List<Map<String, dynamic>>> getNote(int id) async {
    await ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    return db.query(
      'noteTable',
      where: 'noteId = ?',
      whereArgs: [id],
      limit: 1,
    );
  }

  Future<void> deleteNote(int id) async {
    await ensureDbIsOpen();
    final db = _getDatabaseOrThrow();

    try {
      await db.delete('noteTable', where: 'noteId = ?', whereArgs: [id]);
    } catch (err) {
      debugPrint('Something went wrong when deleting a note: $err');
    }
  }

  Future<List<Map<String, dynamic>>> noteListPart(
    String fromDate,
    String toDate,
  ) async {
    await ensureDbIsOpen();
    final db = _getDatabaseOrThrow();

    return db.rawQuery(
      "SELECT * FROM noteTable WHERE noteDate BETWEEN '$fromDate' AND '$toDate' ORDER BY noteDate",
    );
  }

  Future<List<Map<String, dynamic>>> getFirstDate() async {
    await ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    return await db.query('noteTable', orderBy: 'noteDate ASC', limit: 1);
  }

  Future<List<Map<String, dynamic>>> getLastDate() async {
    await ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    return await db.query('noteTable', orderBy: 'noteDate DESC', limit: 1);
  }
  //******************************************************** */

  // Plant
  Future<int> createVaxt({
    required String vaxtName,
    required String vaxtLatin,
    required String vaxtText,
    required String vaxtImg,
  }) async {
    await ensureDbIsOpen();
    final db = _getDatabaseOrThrow();

    final test = await db.query(
      'vaxtTable',
      where: 'vaxtName =?',
      whereArgs: [vaxtName],
      limit: 1,
    );

    if (test.isEmpty) {
      final data = {
        'vaxtName': vaxtName,
        'vaxtLatin': vaxtLatin,
        'vaxtText': vaxtText,
        'vaxtImg': vaxtImg,
      };
      final id = await db.insert('vaxtTable', data);
      return id;
    } else {
      return 0;
    }
  }

  // Update an plant by id
  Future editVaxt({
    required int vaxtId,
    required String vaxtName,
    required String vaxtLatin,
    required String vaxtText,
    required String vaxtImg,
  }) async {
    await ensureDbIsOpen();
    final db = _getDatabaseOrThrow();

    final data = {
      'vaxtName': vaxtName,
      'vaxtLatin': vaxtLatin,
      'vaxtText': vaxtText,
      'vaxtImg': vaxtImg,
    };

    await db.update(
      'vaxtTable',
      data,
      where: 'vaxtId = ?',
      whereArgs: [vaxtId],
    );
  }

  Future<List<Map<String, dynamic>>> getAllVaxts() async {
    await ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    return db.query('vaxtTable', orderBy: 'vaxtName');
  }

  Future<List<Map<String, dynamic>>> getVaxt(int id) async {
    await ensureDbIsOpen();
    final db = _getDatabaseOrThrow();

    return db.query(
      'vaxtTable',
      where: 'vaxtId = ?',
      whereArgs: [id],
      limit: 1,
    );
  }

  Future<void> deleteVaxt(int id) async {
    await ensureDbIsOpen();
    final db = _getDatabaseOrThrow();

    try {
      await db.delete('vaxtTable', where: 'vaxtId =?', whereArgs: [id]);
    } catch (err) {
      debugPrint('Something went wrong when deleting a plant: $err');
    }
  }

  Future<List<Map<String, dynamic>>> checkOldVaxt({
    required String vaxtName,
  }) async {
    await ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    return db.query(
      'vaxtTable',
      where: 'vaxtName =?',
      whereArgs: [vaxtName],
      limit: 1,
    );
  }

  //********************************************* */
  //Place

  Future<int> createPlace({required String placeName}) async {
    await ensureDbIsOpen();
    final db = _getDatabaseOrThrow();

    final data = {'placeName': placeName};

    final test = await db.query(
      'placeTable',
      where: 'placeName =?',
      whereArgs: [placeName],
      limit: 1,
    );

    if (test.isEmpty) {
      final id = await db.insert('placeTable', data);
      return id;
    } else {
      return 0;
    }
  }

  Future editPlace({required int placeId, required String placeName}) async {
    await ensureDbIsOpen();
    final db = _getDatabaseOrThrow();

    final data = {'placeName': placeName};

    await db.update(
      'placeTable',
      data,
      where: 'placeId =?',
      whereArgs: [placeId],
    );
  }

  Future<List<Map<String, dynamic>>> getAllPlaces() async {
    await ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    return db.query('placeTable', orderBy: 'placeName');
  }

  Future<List<Map<String, dynamic>>> getPlace(int placeId) async {
    await ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    return db.query(
      'placeTable',
      where: 'placeId =?',
      whereArgs: [placeId],
      limit: 1,
    );
  }

  Future<void> deletePlace(int placeId) async {
    await ensureDbIsOpen();
    final db = _getDatabaseOrThrow();

    try {
      await db.delete('placeTable', where: 'placeId =?', whereArgs: [placeId]);
    } catch (err) {
      debugPrint('Something went wrong when deleting a place: $err');
    }
  }

  Future<List<Map<String, dynamic>>> checkOldPlace({
    required String placeName,
  }) async {
    await ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    return db.query(
      'placeTable',
      where: 'placeName=?',
      whereArgs: [placeName],
      limit: 1,
    );
  }

  //*********************************************** */
  //Actions

  Future<int> createAction({required String actionText}) async {
    await ensureDbIsOpen();
    final db = _getDatabaseOrThrow();

    final test = await db.query(
      'actionTable',
      where: 'actionText =?',
      whereArgs: [actionText],
      limit: 1,
    );

    if (test.isEmpty) {
      final data = {'actionText': actionText};
      final id = await db.insert(
        'actionTable',
        data,
        //  conflictAlgorithm: ConflictAlgorithm.replace,
      );
      return id;
    } else {
      return 0;
    }
  }

  Future editAction({required int actionId, required String actionText}) async {
    await ensureDbIsOpen();
    final db = _getDatabaseOrThrow();

    final data = {'actionText': actionText};

    await db.update(
      'actionTable',
      data,
      where: 'actionId =?',
      whereArgs: [actionId],
    );
  }

  Future<List<Map<String, dynamic>>> getActionText(int actionId) async {
    await ensureDbIsOpen();
    final db = _getDatabaseOrThrow();

    return db.query(
      'actionTable',
      columns: ['actionText'],
      where: 'actionId = ?',
      whereArgs: [actionId],
      limit: 1,
    );
  }

  Future<List<Map<String, dynamic>>> getAction(int actionId) async {
    await ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    return db.query(
      'actionTable',
      where: 'actionId =?',
      whereArgs: [actionId],
      limit: 1,
    );
  }

  Future<void> deleteAction(int actionId) async {
    await ensureDbIsOpen();
    final db = _getDatabaseOrThrow();

    try {
      await db.delete(
        'actionTable',
        where: 'actionId =?',
        whereArgs: [actionId],
      );
    } catch (err) {
      debugPrint('Something went wrong when deleting an action: $err');
    }
  }

  Future<List<Map<String, dynamic>>> getAllActions() async {
    await ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    return db.query('actionTable', orderBy: 'actionText');
  }

  Future<List<Map<String, dynamic>>> checkOldAction({
    required String actionText,
  }) async {
    await ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    return db.query(
      'actionTable',
      where: 'actionText =?',
      whereArgs: [actionText],
      limit: 1,
    );
  }

  //**************************************************** */
  //Autocomplete
  Future<List> getActions() async {
    await ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    return db.rawQuery('SELECT actionText FROM actionTable');
  }

  Future<List> getPlants() async {
    await ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    return db.rawQuery('SELECT vaxtName FROM vaxtTable');
  }

  Future<List> getPlaces() async {
    await ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    return db.rawQuery('SELECT placeName FROM placeTable');
  }

  //*********************************************** */

  //Database
  Future<void> deleteEmptyRows() async {
    await ensureDbIsOpen();
    final db = _getDatabaseOrThrow();

    try {
      await db.delete('dateTable', where: 'dateDate = ?', whereArgs: ['']);
    } catch (err) {
      debugPrint(
        'Something went wrong when deleting empty rows dateTable: $err',
      );
    }

    try {
      await db.delete('actionTable', where: 'actionText = ?', whereArgs: ['']);
    } catch (err) {
      debugPrint(
        'Something went wrong when deleting empty rows actionTable: $err',
      );
    }

    try {
      await db.delete('placeTable', where: 'placeName= ?', whereArgs: ['']);
    } catch (err) {
      debugPrint(
        'Something went wrong when deleting empty rows placeTable: $err',
      );
    }

    try {
      await db.delete('vaxtTable', where: 'vaxtName = ?', whereArgs: ['']);
    } catch (err) {
      debugPrint(
        'Something went wrong when deleting empty rows vaxtTable: $err',
      );
    }
  }

  Future<void> ensureDbIsOpen() async {
    try {
      await open();
    } on DatabaseAlreadyOpenException {
      //empty
    }
  }

  Database _getDatabaseOrThrow() {
    final db = _phloura;
    if (db == null) {
      throw DatabaseIsNotOpen();
    } else {
      return db;
    }
  }

  Future<void> open() async {
    if (_phloura != null) {
      throw DatabaseAlreadyOpenException();
    }
    try {
      final docsPath = await getApplicationDocumentsDirectory();
      final dbPath = join(docsPath.path, dbName);
      final db = await openDatabase(dbPath);
      _phloura = db;

      await db.execute(createNoteTable);
      await db.execute(createVaxtTable);
      await db.execute(createPlaceTable);
      await db.execute(createActionTable);
    } on MissingPlatformDirectoryException {
      throw UnableToGetDocumentsDirectory();
    }
  }
}
