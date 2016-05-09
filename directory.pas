unit directory;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, sqldb, db, FileUtil, Forms, Controls, Graphics, Dialogs,
  DBGrids, ExtCtrls, Metadata, StdCtrls, Buttons;

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

  TDBForm = class(TForm)
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
    procedure NewTable(DB: TDatabase; TableName, TableCaption: String; n: integer);

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
  end;


var
  DBForm: TDBForm;


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

procedure TDBForm.NewTable(DB: TDatabase; TableName, TableCaption: String;
  n: integer);
var
  s, t: string;
  i, j: integer;
  b: boolean;
begin
  self.Caption := TableCaption;
  SQLTransaction.DataBase := DB;
  SQLQuery.Transaction := SQLTransaction;
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
    SQLQuery.Close;
    SQLQuery.SQL.Text := s;
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
    if ((idTable.fileds[arrFilter[i].cbfilter.ItemIndex].name <> 'Фильтр') and
    (arrFilter[i].cbValue.Caption <> '') and
    (arrFilter[i].edcondition.text <> '')) then
      if (s = SQLText) then s += ' WHERE '
      else s += ' AND ';
    if idTable.fileds[arrFilter[i].cbfilter.ItemIndex].link = -1 then
      s += idTable.name + '.' + idTable.fileds[arrFilter[i].cbfilter.ItemIndex].name + ' ' +
        arrFilter[i].cbValue.Caption + ' ' + arrFilter[i].edcondition.text
    else
      s += TimeTable.Tables[idTable.fileds[arrFilter[i].cbfilter.ItemIndex].link].name + '.' +
        idTable.fileds[idTable.fileds[arrFilter[i].cbfilter.ItemIndex].link].name + ' ' +
        arrFilter[i].cbValue.Caption + ' ' + arrFilter[i].edcondition.text;
  end;

  {при генирации запроса вместо значений подставляется имя параметра и потом sql.prepere, params(param by name), и туда введенное пользователем. open.}

  try
    SQLQuery.Close;
    SQLQuery.SQL.Text := s;
    ShowMessage(s);
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

procedure TDBForm.BtnDeleteClick(Sender: TObject);
begin
  DBGrid.DataSource.DataSet.Delete;

end;

procedure TDBForm.BtnCorrectClick(Sender: TObject);
begin

end;

procedure TDBForm.BtnPluseClick(Sender: TObject);
begin

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
    cbfilter.Caption := 'Фильтр';
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

end.

