unit frame;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, sqldb, FBEventMonitor, db, FileUtil, Forms, Controls,
  Graphics, Dialogs, ExtCtrls, StdCtrls, DbCtrls, Metadata, Udatabase, UFormContainer;

type

  { TCard }

  TCard = class(TFormSQL)
    BSave: TButton;
    BExit: TButton;
    DataSource: TDataSource;
    Panel: TPanel;
    CPanel: TPanel;
    SQLQuery: TSQLQuery;
    SQLTransaction: TSQLTransaction;
    procedure BExitClick(Sender: TObject);
    procedure BSaveClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
  private
    { private declarations }
    idTable: integer;
    nameTable: string;
  public
    { public declarations }
    procedure NewCard(tbl: TTable; id: integer);
    procedure UpdateContent; override;
  end;

    { TArrCard }

    TArrCard = record
      Table: string;
      id: integer;
    end;
var
  arrCard: array of TArrCard;

implementation

{$R *.lfm}

{ TArrCard }


procedure TCard.BSaveClick(Sender: TObject);
begin
  Datasource.DataSet.FieldByName('id').Required := false;
  SQLQuery.Post;
  SQLQuery.ApplyUpdates;
  FormContainer.UpdateContent;
  close;
end;

procedure TCard.FormClose(Sender: TObject; var CloseAction: TCloseAction);
var
  i: integer;
  b: Boolean;
begin
  if idTable > -1 then
  begin
    b := False;
    for i := 0 to High(arrCard) - 1 do
    begin
      if (arrCard[i].Table = nameTable) and (arrCard[i].id = idTable) then b := True;
      if b then
      begin
        arrCard[i].Table := arrCard[i + 1].Table;
        arrCard[i].id := arrCard[i + 1].id;
      end;
    end;
    SetLength(arrCard, Length(arrCard) - 1);
  end;
end;

procedure TCard.BExitClick(Sender: TObject);
begin
  close;
end;

{ TCard }
//-1: не может существовать
procedure TCard.NewCard(tbl: TTable; id: integer);
var
  i, j: integer;
  pl: TPanel;
  ed: TDBEdit;
  lb: TLabel;
  cmb: TDBLookupComboBox;
  SQL: TSQLQuery;
  s: string;
begin
  idTable := id;
  nameTable := tbl.name;
  self.Caption := tbl.caption;
  s :=  'SELECT ';
  for i := 0 to  Length(tbl.fileds) - 1 do
  begin
    s += tbl.fileds[i].name;
    if i < Length(tbl.fileds) - 1 then s += ', ';
  end;
  s +=  ' FROM ' + tbl.name + ' WHERE ID = ' + inttostr(id);
  SQLQuery.SQL.Text := s;
  s :=  'UPDATE ' + tbl.name + ' set ';
  for i := 0 to  Length(tbl.fileds) - 1 do
  begin
    s += tbl.fileds[i].name + ' = :' + tbl.fileds[i].name;
    if i < Length(tbl.fileds) - 1 then s += ', ';
  end;
  s += ' WHERE ID = ' + inttostr(id);
  SQLQuery.UpdateSQL.Text := s;
  s :=  'INSERT INTO ' + tbl.name + ' (';
  for i := 0 to  Length(tbl.fileds) - 1 do
  begin
    s += tbl.fileds[i].name;
    if i < Length(tbl.fileds) - 1 then s += ', '
    else s += ')';
  end;
  s += ' VALUES (';
  for i := 0 to  Length(tbl.fileds) - 1 do
  begin
    s += ' :' + tbl.fileds[i].name;
    if i < Length(tbl.fileds) - 1 then s += ', '
    else s += ')';
  end;
  SQLQuery.InsertSQL.Text := s;
  UpdateContent;
  for i := Length(tbl.fileds) - 1 downto 1 do
  begin
    pl := TPanel.Create(CPanel);
    pl.Parent := CPanel;
    Pl.Align := alTop;
    pl.Height := 35;
    lb := TLabel.Create(pl);
    lb.Parent := pl;
    lb.Top := 5 + pl.top;
    lb.Height := 20;
    lb.Width := 100;
    lb.Left := 130;
    lb.Caption := tbl.fileds[i].caption;
    if tbl.fileds[i].link = -1 then
    begin
      ed := TDBEdit.Create(pl);
      ed.Parent := pl;
      ed.Top := 5 + pl.top;
      ed.Height := 20;
      ed.Width := tbl.fileds[i].fwidth;
      ed.Left := 240;
      ed.DataSource := DataSource;
      ed.DataField := tbl.fileds[i].name;
    end
    else
    begin
      cmb := TDBLookupComboBox.Create(pl);
      cmb.Parent := pl;
      cmb.Top := 5 + pl.top;
      cmb.Height := 20;
      cmb.Width := tbl.fileds[i].fwidth;
      cmb.Left := 240;
      cmb.DataSource := DataSource;
      cmb.DataField := tbl.fileds[i].name;
      cmb.ListSource := TDataSource.Create(pl);
      SQL := TSQLQuery.Create(pl);
      SQL.Transaction := SQLTransaction;
      cmb.ListSource.DataSet := SQL;
      s := 'SELECT ID, ';
      for j := 1 to High(TimeTable.Tables[tbl.fileds[i].link].fileds) do
      begin
        if j > 1 then s += ' || '' '' || ';
        s += TimeTable.Tables[tbl.fileds[i].link].fileds[j].name;
      end;
      s += ' as name';
      s += ' FROM ' + TimeTable.Tables[tbl.fileds[i].link].name;
      SQL.SQL.Text := s;
      SQL.Open;
      cmb.ListField := 'name';
      cmb.KeyField := 'id';
    end;
  end;
end;

procedure TCard.UpdateContent;
begin
  SQLTransaction.CommitRetaining;
  SQLQuery.Close;
  SQLQuery.Open;
  if idTable = -1 then SQLQuery.Append
  else SQLQuery.Edit;
end;


end.

