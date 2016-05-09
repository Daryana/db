program DataBase;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, main, metadata, Udatabase, directory, frame;

{$R *.res}

begin
  RequireDerivedFormResource:=True;
  Application.Initialize;
  Application.CreateForm(TMyForm, MyForm);
  Application.CreateForm(TDBDataModule, DBDataModule);
  Application.CreateForm(TDBForm, DBForm);
  Application.CreateForm(TCard, Card);
  Application.Run;
end.

