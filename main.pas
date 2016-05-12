unit main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, IBConnection, sqldb, db, FileUtil, Forms, Controls,
  Graphics, Dialogs, Menus, DBGrids, Metadata, Udatabase, Directory, frame;

type

  { TMyForm }

  TMyForm = class(TForm)
    MainMenu: TMainMenu;
    MenuItemTables: TMenuItem;
    MenuItemFile: TMenuItem;
    MenuItemReference: TMenuItem;
    MenuItemAbout: TMenuItem;
    MenuItemExit: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure MenuItemAboutClick(Sender: TObject);
    procedure MenuItemExitClick(Sender: TObject);
    procedure tablesClick(Sender: TObject);
  private
    { private declarations }
    DBConnection: TIBConnection;
  public
    { public declarations }
  end;

var
  MyForm: TMyForm;

implementation

{$R *.lfm}

{ TMyForm }

procedure TMyForm.FormCreate(Sender: TObject);
var
  iitem: TMenuItem;
  i:integer;
  db: TDBDataModule;
begin
  for i := 0 to TimeTable.n - 1 do
  begin
    iitem := TMenuItem.Create(nil);
    iitem.Name := TimeTable.Tables[i].name;
    iitem.Caption := TimeTable.Tables[i].caption;
    iitem.Tag := i;
    iitem.OnClick := @tablesClick;
    MenuItemTables.Add(iitem);
  end;
  db := TDBDataModule.Create(self);
  DBConnection :=db.IBConnection;
  SetLength(arrCard, 0);
end;

procedure TMyForm.MenuItemAboutClick(Sender: TObject);
begin
  ShowMessage('Терехина Дарьяна Александровна, группа Б8103а1, 2016г');
end;

procedure TMyForm.MenuItemExitClick(Sender: TObject);
begin
  MyForm.Close;
end;

procedure TMyForm.tablesClick(Sender: TObject);
var
  f: TDBForm;
begin
  f := TDBForm.Create(self);
  f.NewTable(TMenuItem(Sender).Name, TMenuItem(Sender).Caption, TMenuItem(Sender).Tag);
  f.Show();
end;


end.

