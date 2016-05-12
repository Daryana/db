unit directory;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, sqldb, db, FileUtil, Forms, Controls, Graphics, Dialogs,
  DBGrids, ExtCtrls, Metadata, StdCtrls, Buttons, frame, UFormContainer;

type

    { TMyButton }

  TMyButton = class(TSpeedButton)
    procedure Click; override;
  end;

    { TFilter }

  TFilter = record
    pl: TPanel;
    edcondition: TEdit;
    cbfilter: TCombobox;
    cbValue: TCombobox;
    b: TMyButton;
  end;

  { TDBForm }

  TDBForm = class(TFormSQL)
    BtnPluse: TBitBtn;
    BtnDelete: TBitBtn;
    BtnCorrect: TBitBtn;
    Button: TButton;
    DataSource: TDataSource;
    DBGrid: TDBGrid;
    Panel: TPanel;
    FPanel: TPanel;
    PanelSort: TPanel;
    SQLQuery: TSQLQuery;
    SQLTransaction: TSQLTransaction;
    procedure BtnCorrectClick(Sender: TObject);
    procedure BtnDeleteClick(Sender: TObject);
    procedure BtnPluseClick(Sender: TObject);
    procedure ButtonClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure NewTable(TableName, TableCaption: String; n: integer);

  private
    { private declarations }
    arrString: array of string;
    arrWight: array of integer;
    SQLText: string;
    idTable: TTable;
    arrFilter: array of TFilter;
    procedure NewFilter();
    procedure ButClick(Sender: TObject);
  public
    { public declarations }
    procedure UpdateContent; override;
  end;


implementation

{$R *.lfm}

{ TMyButton }

procedure TMyButton.Click;
begin
  if Caption = '-' then
  begin
    inherited Click;
    Free;
  end
  else
    inherited Click;
end;



{ TDBForm }

procedure TDBForm.NewTable(TableName, TableCaption: String;
  n: integer);
var
  s, t: string;
  i, j: integer;
  b: boolean;
begin
  self.Caption := TableCaption;
  s := 'SELECT ';
  b := true;
  t := '';
  SetLength(arrString, 0);
  SetLength(arrWight, 0);
  SetLength(arrString, Length(arrString) + 1);
  arrString[High(arrString)] := TimeTable.Tables[n].fileds[0].caption;
  SetLength(arrWight, Length(arrWight) + 1);
  arrWight[High(arrWight)] := TimeTable.Tables[n].fileds[0].fwidth;
  for i := 1 to Length(TimeTable.Tables[n].fileds) - 1 do
    if TimeTable.Tables[n].fileds[i].link >= 0 then
    begin
      if b then
        s += TimeTable.Tables[n].name + '.' + TimeTable.Tables[n].fileds[0].name + ', ';
      b := false;
      for j := 1 to Length(TimeTable.Tables[TimeTable.Tables[n].fileds[i].link].fileds) - 1 do
      begin
        s += TimeTable.Tables[TimeTable.Tables[n].fileds[i].link].name + '.' + TimeTable.Tables[TimeTable.Tables[n].fileds[i].link].fileds[j].name;
        if (j <> Length(TimeTable.Tables[TimeTable.Tables[n].fileds[i].link].fileds) - 1) or (i <> Length(TimeTable.Tables[n].fileds) - 1)  then s += ', ';
        SetLength(arrString, Length(arrString) + 1);
        arrString[High(arrString)] := TimeTable.Tables[TimeTable.Tables[n].fileds[i].link].fileds[j].caption;
        SetLength(arrWight, Length(arrWight) + 1);
        arrWight[High(arrWight)] := TimeTable.Tables[TimeTable.Tables[n].fileds[i].link].fileds[j].fwidth;
      end;
      t += ' INNER JOIN ' + TimeTable.Tables[TimeTable.Tables[n].fileds[i].link].name + ' ON ' +
           TimeTable.Tables[TimeTable.Tables[n].fileds[i].link].name +
           '.ID = ' + TimeTable.Tables[n].name + '.' + TimeTable.Tables[n].fileds[i].name;
    end
    else
    begin
      SetLength(arrString, Length(arrString) + 1);
      arrString[High(arrString)] := TimeTable.Tables[n].fileds[i].caption;
      SetLength(arrWight, Length(arrWight) + 1);
      arrWight[High(arrWight)] := TimeTable.Tables[n].fileds[i].fwidth;
    end;
  if b then s += '*';
  s +=  ' FROM ' + TableName + t;
  try
    SQLQuery.SQL.Text := s;
    UpdateContent;
  except
    on E: Exception do
    begin
      ShowMessage('Error');
      self.Close;
    end;
  end;
  SetLength(arrFilter, 0);
  idTable := TimeTable.Tables[n];
  NewFilter();
  SQLText := s;
end;

procedure TDBForm.ButtonClick(Sender: TObject);
var
  s: string;
  i: integer;
begin
  s := SQLText;
  for i := 0 to Length(arrFilter) - 1 do
  begin
    if (arrFilter[i].cbfilter.caption + arrFilter[i].cbValue.Caption + arrFilter[i].edcondition.text) <> '' then
    begin
      if (s = SQLText) then s += ' WHERE '
      else s += ' AND ';
    if idTable.fileds[arrFilter[i].cbfilter.ItemIndex].link = -1 then
      s += idTable.name + '.' + idTable.fileds[arrFilter[i].cbfilter.ItemIndex].name
    else
      s += TimeTable.Tables[idTable.fileds[arrFilter[i].cbfilter.ItemIndex].link].name + '.' +
        idTable.fileds[idTable.fileds[arrFilter[i].cbfilter.ItemIndex].link].name;
    s += ' ' + arrFilter[i].cbValue.Caption + ' :p' + inttostr(i);
    end;
  end;
  try
    SQLQuery.Close;
    SQLQuery.SQL.Text := s;
    for i := 0 to Length(arrFilter) - 1 do
      if (arrFilter[i].cbfilter.caption + arrFilter[i].cbValue.Caption + arrFilter[i].edcondition.text) <> '' then
          SQLQuery.ParamByName('p' + intToStr(i)).AsString:= arrFilter[i].edcondition.text;
    SQLQuery.Open;
    for i := 0 to Length(arrString) - 1 do
    begin
          DBGrid.Columns[i].Width := arrWight[i];
          DBGrid.Columns[i].Title.Caption := arrString[i];
    end;
  except
    on E: Exception do
    begin
      ShowMessage('Error');
      self.Close;
    end;
  end;
end;


procedure TDBForm.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  SQLTransaction.Commit;
end;

procedure TDBForm.BtnDeleteClick(Sender: TObject);
var
  i, butval: integer;
  b: Boolean;
  SQL: TSQLQuery;
begin
  b := true;
  for i := 0 to High(arrCard) do
      if (arrCard[i].Table = idTable.name) and
        (arrCard[i].ID = DBGrid.DataSource.DataSet.FieldByName(DBGrid.Columns[0].FieldName).AsInteger) then
        begin
          b := false;
          ShowMessage('Эта запись уже редактируется!');
        end;

    if b then
    begin
     ButVal:= messagedlg('Вы точно хотите удалить запись?', mtCustom, [mbYes,mbNo], 0);
     if ButVal = 6 then
     begin
       SQL := TSQLQuery.Create(nil);
       SQL.Transaction := SQLTransaction;
       SQL.SQL.Text:= 'DELETE FROM ' + idTable.name + ' WHERE ' + 'ID = :p0';
       SQL.Params[0].AsInteger:= DBGrid.DataSource.DataSet.FieldByName(DBGrid.Columns[0].FieldName).AsInteger;
       SQL.ExecSQL;
       SQL.Free;
       FormContainer.UpdateContent;
     end;
    end;
end;

procedure TDBForm.BtnCorrectClick(Sender: TObject);
var
  c: TCard;
  i: integer;
  b: Boolean;
begin
  b := true;
  for i := 0 to High(arrCard) do
    if (arrCard[i].Table = idTable.name) and
      (arrCard[i].ID = DBGrid.DataSource.DataSet.FieldByName(DBGrid.Columns[0].FieldName).AsInteger) then
      begin
        b := false;
        ShowMessage('Эта запись уже редактируется!');
      end;

  if b then
  begin
    c := TCard.Create(self);
    c.NewCard(idTable, DBGrid.DataSource.DataSet.FieldByName(DBGrid.Columns[0].FieldName).AsInteger);
    c.Show();
    SetLength(arrCard, Length(arrCard) + 1);
    arrCard[High(arrCard)].Table := idTable.name;
    arrCard[High(arrCard)].id := DBGrid.DataSource.DataSet.FieldByName(DBGrid.Columns[0].FieldName).AsInteger;
  end;
end;

procedure TDBForm.BtnPluseClick(Sender: TObject);
var
  c: TCard;
begin
  c := TCard.Create(self);
  c.NewCard(idTable, -1);
  c.Show();
end;

procedure TDBForm.NewFilter;
var
  i, j: integer;
begin
  SetLength(arrFilter, Length(arrFilter) + 1);
  with arrFilter[High(arrFilter)] do
  begin
    pl := TPanel.Create(FPanel);
    pl.Parent := FPanel;
    Pl.Align := alTop;
    pl.Height := 35;
    cbfilter := TCombobox.Create(pl);
    cbfilter.Parent := pl;
    cbfilter.Top := 5 + pl.top;
    cbfilter.Height := 20;
    cbfilter.Width := 100;
    cbfilter.Left := 10;
    cbfilter.Caption := '';
    cbfilter.ReadOnly := True;
    for i := 0 to Length(idTable.fileds) - 1 do
    begin
      if idTable.fileds[i].link = -1 then
        cbfilter.Items.Add(idTable.fileds[i].caption)
      else
        for j := 1 to Length(TimeTable.Tables[idTable.fileds[i].link].fileds) - 1 do
          cbfilter.Items.Add(TimeTable.Tables[idTable.fileds[i].link].fileds[j].caption)
    end;
    cbValue := TCombobox.Create(pl);
    cbValue.Parent := pl;
    cbValue.Top := 5 + pl.top;
    cbValue.Height := 20;
    cbValue.Width := 100;
    cbValue.Left := 130;
    cbValue.ReadOnly := True;
    cbValue.Caption := '';
    cbValue.Items.Add('=');
    cbValue.Items.Add('>');
    cbValue.Items.Add('!=');
    cbValue.Items.Add('<');
    cbValue.Items.Add('>=');
    cbValue.Items.Add('<=');
    edcondition := TEdit.Create(pl);
    edcondition.Parent := pl;
    edcondition.Top := 5 + pl.top;
    edcondition.Height := 20;
    edcondition.Width := 100;
    edcondition.Left := 240;
    edcondition.Caption := '';
    b := TMyButton.Create(nil);
    b.Parent := pl;
    b.Top := 5 + pl.top;
    b.Height := 20;
    b.Width := 20;
    b.Left := 350;
    b.Caption := '+';
    b.Tag := High(arrFilter);
    b.OnClick := @ButClick;
  end;
end;

procedure TDBForm.ButClick(Sender: TObject);
var
  i, x: integer;
begin
  x := TButton(Sender).Tag;
  if (TButton(Sender).Caption = '+') then
  begin
    TButton(Sender).Caption := '-';
    NewFilter();
    exit;
  end
  else
  begin
    arrFilter[x].edcondition.Free;
    arrFilter[x].cbfilter.Free;
    arrFilter[x].cbValue.Free;
    arrFilter[x].pl.Free;
    for i := x to High(arrFilter) - 1 do
    begin
      arrFilter[i] := arrFilter[i + 1];
      arrFilter[i].b.Tag := i;
    end;
    SetLength(arrFilter, Length(arrFilter) - 1);
  end;
end;

procedure TDBForm.UpdateContent;
var
  i: integer;
begin
  SQLTransaction.CommitRetaining;
  SQLQuery.Close;
  for i := 0 to Length(arrFilter) - 1 do
      if (arrFilter[i].cbfilter.caption + arrFilter[i].cbValue.Caption + arrFilter[i].edcondition.text) <> '' then
          SQLQuery.ParamByName('p' + intToStr(i)).AsString:= arrFilter[i].edcondition.text;
    SQLQuery.Open;
    for i := 0 to Length(arrString) - 1 do
    begin
          DBGrid.Columns[i].Width := arrWight[i];
          DBGrid.Columns[i].Title.Caption := arrString[i];
    end;
end;

end.

