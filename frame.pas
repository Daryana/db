unit frame;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, sqldb, db, FileUtil, Forms, Controls, Graphics, Dialogs,
  ExtCtrls, StdCtrls, Metadata;

type

  { TCard }

  TCard = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    DataSource: TDataSource;
    Panel: TPanel;
    CPanel: TPanel;
    SQLQuery: TSQLQuery;
    SQLTransaction: TSQLTransaction;
  private
    { private declarations }
  public
    { public declarations }
    //constructor Create(tbl: TTable); override;
  end;

var
  Card: TCard;

implementation

{$R *.lfm}

{ TCard }

                                  {
constructor TCard.Create(tbl: TTable);
var
  i: integer;
  b: TButton;
  pl: TPanel;
  edcondition: TEdit;
  cbfilter: TCombobox;
  cbValue: TCombobox;
begin
  inherited Create;
  for i := 0 to Length(tbl) - 1 then




end;     }

end.

