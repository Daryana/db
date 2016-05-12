unit Udatabase;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, IBConnection, sqldb, FileUtil;

type

  { TDBDataModule }

  TDBDataModule = class(TDataModule)
    IBConnection: TIBConnection;
    procedure DataModuleCreate(Sender: TObject);
    procedure IBConnectionAfterConnect(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  DBDataModule: TDBDataModule;

implementation

{$R *.lfm}

{ TDBDataModule }



procedure TDBDataModule.DataModuleCreate(Sender: TObject);
begin

end;

procedure TDBDataModule.IBConnectionAfterConnect(Sender: TObject);
begin

end;

end.

