unit Udatabase;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, IBConnection, FileUtil;

type

  { TDBDataModule }

  TDBDataModule = class(TDataModule)
    IBConnection: TIBConnection;
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



end.

