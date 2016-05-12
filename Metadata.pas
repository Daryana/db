unit Metadata;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;
type

  { TFiled }

  TFiled  = class
  public
    name: string;
    caption: string;
    link: integer;
    fwidth: integer;
    constructor Create(n, c: string; id, w: integer);
  end;

  { TTable }

  TTable = class
  public
    name: string;
    caption: string;
    fileds: array of TFiled;
    constructor Create(tcaption, tname: string; filed: array of TFiled);
  end;

  { TDataBaseList }

  TDataBaseList = class
  public
    Tables: array of TTable;
    n: integer;
    constructor Create(table: array of TTable);
  end;

var
  TimeTable: TDataBaseList;
  tb: TTable;
  tbs: array of TTable;
  fl: TFiled;
  fls: array of TFiled;
implementation

{ TDataBaseList }

constructor TDataBaseList.Create(table: array of TTable);
var
  i: integer;
begin
  n := Length(table);
  SetLength(tables, n);
  for i := 1 to n do
    tables[i - 1] := table[i - 1];
end;

{ TFiled }

constructor TFiled.Create(n, c: string; id, w: integer);
begin
  name := n;
  caption := c;
  link := id;
  fwidth := w;
end;

{ TTable }

constructor TTable.Create(tcaption, tname: string; filed: array of TFiled);
var
  i: integer;
begin
  name := tname;
  caption := tcaption;
  SetLength(fileds, Length(filed));
  for i := 1 to Length(filed) do
    fileds[i - 1] := filed[i - 1];
end;

initialization
SetLength(tbs, 8);

SetLength(fls, 2);
fl := TFiled.Create('id', 'ID', -1, 50);
fls[0] := fl;
fl := TFiled.Create('name', 'Имя', -1, 100);
fls[1] := fl;
tb := TTable.Create('Группы', 'Groups', fls);
tbs[0] := tb;

SetLength(fls, 2);
fl := TFiled.Create('id', 'ID', -1, 50);
fls[0] := fl;
fl := TFiled.Create('name', 'Имя', -1, 280);
fls[1] := fl;
tb := TTable.Create('Предмет', 'Lessons', fls);
tbs[1] := tb;

SetLength(fls, 4);
fl := TFiled.Create('id', 'ID', -1, 50);
fls[0] := fl;
fl := TFiled.Create('last_name', 'Фамилия', -1, 150);
fls[1] := fl;
fl := TFiled.Create('first_name', 'Имя', -1, 150);
fls[2] := fl;
fl := TFiled.Create('middle_name', 'Отчество', -1, 150);
fls[3] := fl;
tb := TTable.Create('Преподаватели', 'Teachers', fls);
tbs[2] := tb;

SetLength(fls, 2);
fl := TFiled.Create('id', 'ID', -1, 50);
fls[0] := fl;
fl := TFiled.Create('name', 'Имя', -1, 100);
fls[1] := fl;
tb := TTable.Create('Аудитория', 'Classrooms', fls);
tbs[3] := tb;

SetLength(fls, 3);
fl := TFiled.Create('id', 'ID', -1, 50);
fls[0] := fl;
fl := TFiled.Create('begin_', 'Начало', -1, 100);
fls[1] := fl;
fl := TFiled.Create('end_', 'Конец', -1, 100);
fls[2] := fl;
tb := TTable.Create('Время занятий', 'Lessons_Times', fls);
tbs[4] := tb;

SetLength(fls, 2);
fl := TFiled.Create('id', 'ID', -1, 50);
fls[0] := fl;
fl := TFiled.Create('name', 'Имя', -1, 120);
fls[1] := fl;
tb := TTable.Create('Недели', 'Weekdays', fls);
tbs[5] := tb;

SetLength(fls, 2);
fl := TFiled.Create('id', 'ID', -1, 50);
fls[0] := fl;
fl := TFiled.Create('name', 'Имя', -1, 180);
fls[1] := fl;
tb := TTable.Create('Тип занятий', 'Lessons_Types', fls);
tbs[6] := tb;

SetLength(fls, 8);
fl := TFiled.Create('id', 'ID', -1, 50);
fls[0] := fl;
fl := TFiled.Create('lesson_id', 'Предмет', 1, 300);
fls[1] := fl;
fl := TFiled.Create('lesson_type_id', 'Тип занятия', 6, 150);
fls[2] := fl;
fl := TFiled.Create('teacher_id', 'Преподаватели', 2, 100);
fls[3] := fl;
fl := TFiled.Create('group_id', 'Группа', 0, 100);
fls[4] := fl;
fl := TFiled.Create('classroom_id', 'Аудитория', 3, 100);
fls[5] := fl;
fl := TFiled.Create('weekday_id', 'Неделя', 5, 100);
fls[6] := fl;
fl := TFiled.Create('lesson_time_id', 'Время Занятия', 4, 200);
fls[7] := fl;
tb := TTable.Create('Рассписание', 'Timetable', fls);
tbs[7] := tb;

TimeTable := TDataBaseList.Create(tbs);
end.

