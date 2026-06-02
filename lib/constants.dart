const dbName = 'phloura.db';

const noteTable = 'noteTable';
const noteId = 'noteId';
const noteDate = 'noteDate';
const noteAction = 'noteAction';
const noteVaxt = 'noteVaxt';
const notePlace = 'notePlace';
const createNoteTable = ''' CREATE TABLE IF NOT EXISTS "noteTable" (
"noteId" INTEGER NOT NULL,
"noteDate" TEXT,
"noteAction" INTEGER,
"noteVaxt" INTEGER,
"notePlace" INTEGER,
PRIMARY KEY ("noteId" AUTOINCREMENT)
)''';

const actionTable = 'actionTable';
const actionIdColumn = 'actionId';
const actionTextColumn = 'actionText';
const createActionTable = '''CREATE TABLE IF NOT EXISTS "actionTable"(
"actionId" INTEGER NOT NULL,
"actionText" TEXT,
PRIMARY KEY ("actionId" AUTOINCREMENT)
)  ''';

const placeTable = 'placeTable';
const placeIdColumn = 'placeId';
const placeNameColumn = 'placeName';
const createPlaceTable = ''' CREATE TABLE IF NOT EXISTS "placeTable" (
"placeId" INTEGER NOT NULL,
"placeName" TEXT NOT NULL,
PRIMARY KEY ("placeId" AUTOINCREMENT)
)  ''';

const vaxtTable = 'vaxtTable';
const vaxtIdColumn = 'vaxtId';
const vaxtNameColumn = 'vaxtName';
const vaxtLatinColumn = 'vaxtLatin';
const vaxtTextColumn = 'vaxtText';
const vaxtImgColumn = 'vaxtImg';
const vaxtAmountColumn = 'vaxtAmount';
const createVaxtTable = ''' CREATE TABLE IF NOT EXISTS "vaxtTable"(
"vaxtId" INTEGER NOT NULL,
"vaxtName" TEXT,
"vaxtLatin" TEXT,
"vaxtText" TEXT,
"vaxtImg" TEXT,
"vaxtAmount" INTEGER,
PRIMARY KEY("vaxtId" AUTOINCREMENT)
)  ''';
