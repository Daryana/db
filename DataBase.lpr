program DataBase;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, main, metadata, Udatabase, directory, frame, UFormContainer;

{$R *.res}

begin
  RequireDerivedFormResource:=True;
  Application.Initialize;
  Application.CreateForm(TMyForm, MyForm);
  Application.CreateForm(TDBDataModule, DBDataModule);
  Application.Run;
end.

