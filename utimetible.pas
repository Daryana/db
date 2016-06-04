unit utimetible;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  StdCtrls, Grids, DbCtrls, Menus, Metadata, UFormContainer, sqldb, db, directory, Buttons, math, uconflict, frame, Udatabase;

type
  fielTable = record
    text: array of string;
    id: integer;
    frect: TRect;

    AvailabilityConflict: boolean;
    IdConflict: array of integer;
  end;

  { TCell }

  TCell = class
    cell: array of fielTable;
    procedure Draw(canvas: TCanvas; cRect: TRect);
    private
      size: TPoint;
      start: TPoint;
      AvailabilityConflict: boolean;
      IdConflict: integer;
  end;

  { TFormTimeTable }

  TFormTimeTable = class(TFormSQL)
    BitBtn: TBitBtn;
    ComboBoxX: TComboBox;
    ComboBoxY: TComboBox;
    DataSource: TDataSource;
    DrawGrid: TDrawGrid;
    LabelX: TLabel;
    LabelY: TLabel;
    CMemo: TMemo;
    PaintBox: TPaintBox;
    Panel: TPanel;
    DrawPanel: TPanel;
    PanelF: TPanel;
    PanelXY: TPanel;
    SQLQuery: TSQLQuery;
    procedure BitBtnClick(Sender: TObject);
    procedure ComboBoxChange(Sender: TObject);
    procedure DrawGridClick(Sender: TObject);
    procedure PaintBoxClick(Sender: TObject);
    procedure DrawGridDblClick(Sender: TObject);
    procedure DrawGridDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure DrawGridDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure DrawGridDrawCell(Sender: TObject; aCol, aRow: Integer;
      aRect: TRect; aState: TGridDrawState);
    procedure DrawGridMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure DrawGridMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure DrawGridStartDrag(Sender: TObject; var DragObject: TDragObject);
    procedure PaintBoxMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure PaintBoxMouseLeave(Sender: TObject);
    procedure PaintBoxPaint(Sender: TObject);
    procedure PaintBoxStartDrag(Sender: TObject; var DragObject: TDragObject);
  private
    { private declarations }
    referenceX: array of string;
    referenceY: array of string;
    MousePos: TPoint;
    DragId: integer;
    FieldCeils: array of array of TCell;
    procedure GenTableText();
  public
    { public declarations }
    procedure NewTimeTable();
    procedure UpdateContent; override;
  end;

implementation

{$R *.lfm}

{ TCell }

procedure TCell.Draw(canvas: TCanvas; cRect: TRect);
var
  i, j, s, k, z: integer;
begin
  size.y := 5;
  if Length(cell) = 0 then
  begin
    canvas.Pen.Color := clGreen;
    canvas.Pen.Width := 3;
    canvas.Rectangle(cRect.Left + 75, cRect.Top + 25, cRect.Left + 125,cRect.Top + 75);
    canvas.Line(cRect.Left + 100, cRect.Top + 25, cRect.Left + 99,cRect.Top + 74);
    canvas.Line(cRect.Left + 75, cRect.Top + 50, cRect.Left + 124,cRect.Top + 49);
  end
  else
    for i := 0 to High(cell) do
    begin
      s := cRect.Right;
      for j := 0 to High(cell[i].text) do
      begin
        canvas.TextOut(cRect.Left, cRect.Top + i * 20 + (j + High(cell[i].text) * i) * 15, ' ' + cell[i].text[j]);
        s := max(canvas.TextWidth('  ' + cell[i].text[j]) + cRect.Left, s);
      end;
      cell[i].frect.Left := cRect.Left;
      cell[i].frect.Top := cRect.Top + i * 20 + j * i * 15;
      cell[i].frect.Right := s + 5;
      cell[i].frect.Bottom := cell[i].frect.Top + (j + 1) * 15;
      start.x := cRect.Left;
      start.y := cRect.Top + 100;
      size.y += cell[i].frect.Bottom - cell[i].frect.Top;
      size.x := max(s - cell[i].frect.Left, size.x);
      cell[i].AvailabilityConflict := False;
      SetLength(cell[i].IdConflict, 0);
      for k := 0 to High(Conflicts) do
        for z := 0 to High(Conflicts[k].IdField) do
          if cell[i].id = Conflicts[k].IdField[z] then
          begin
            cell[i].AvailabilityConflict := true;
            SetLength(cell[i].IdConflict, Length(cell[i].IdConflict) + 1);
            cell[i].IdConflict[High(cell[i].IdConflict)] := Conflicts[k].idConflict;
          end;
      canvas.Brush.Style := bsClear;
      if cell[i].AvailabilityConflict then
      begin
        canvas.Brush.Style := bsBDiagonal;
        canvas.Brush.Color := clAqua;
      end;
      canvas.Rectangle(cell[i].frect);
      canvas.Brush.Style := bsClear;
    end;
end;

{ TFormTimeTable }

procedure TFormTimeTable.DrawGridDrawCell(Sender: TObject; aCol, aRow: Integer;
  aRect: TRect; aState: TGridDrawState);
begin
  if (aCol = 0) and (aRow > 0) then
  begin
    canvas.Brush.Style := bsClear;
    canvas.Rectangle(arect);
    DrawGrid.Canvas.TextOut(aRect.TopLeft.x, aRect.TopLeft.y, referenceY[aRow - 1]);
    exit();
  end;
  if (aRow = 0) and (aCol > 0) then
  begin
    canvas.Brush.Style := bsClear;
    canvas.Rectangle(arect);
    DrawGrid.Canvas.TextOut(aRect.TopLeft.x, aRect.TopLeft.y, referenceX[aCol - 1]);
    exit();
  end;
  if (aCol > 0) and (aRow > 0) then
   FieldCeils[aCol - 1][aRow - 1].Draw(DrawGrid.Canvas, aRect);
end;

procedure TFormTimeTable.DrawGridMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  DrawGrid.BeginDrag(False, 5);
end;

procedure TFormTimeTable.DrawGridMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
begin
  MousePos.x := x;
  MousePos.y := y;
end;

procedure TFormTimeTable.DrawGridStartDrag(Sender: TObject;
  var DragObject: TDragObject);
var
  c, r, i: integer;
begin
  DrawGrid.MouseToCell(MousePos.x, MousePos.y, c, r);
  if (c > 0) and (r > 0) then
  begin
    for i := 0 to high(FieldCeils[c - 1][r - 1].cell) do
      if (MousePos.y < FieldCeils[c - 1][r - 1].cell[i].frect.Bottom) and (MousePos.y > FieldCeils[c - 1][r - 1].cell[i].frect.Top) then
        DragId := FieldCeils[c - 1][r - 1].cell[i].id;
  end;
end;


procedure TFormTimeTable.PaintBoxMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  PaintBox.BeginDrag(False, 5);
end;

procedure TFormTimeTable.PaintBoxMouseLeave(Sender: TObject);
begin
  DrawPanel.Visible := false;
end;

procedure TFormTimeTable.PaintBoxPaint(Sender: TObject);
var
  c: TCell;
  pb: TPaintBox;
  i: integer;
begin
  pb := TPaintBox(Sender);
  c := TCell(pb.Tag);
  pb.Canvas.Rectangle(0, 0, pb.Width, pb.Height);
  pb.Canvas.Pen.Color := clBlack;
  pb.Canvas.Pen.Width := 1;
  c.Draw(pb.Canvas, Rect(0, 0, pb.Width, pb.Height));
  for i := 0 to high(c.cell) do
  begin
    pb.Canvas.Pen.Width := 2;
    pb.Canvas.Pen.Color := clGreen;
    pb.Canvas.Rectangle(pb.Left + pb.Width - 20 ,c.cell[i].frect.Top + 5, pb.Left + pb.Width - 5 ,c.cell[i].frect.Top + 20);
    pb.Canvas.line(pb.Left + pb.Width - 20 ,c.cell[i].frect.Top + 13, pb.Left + pb.Width - 5 ,c.cell[i].frect.Top + 13);
    pb.Canvas.line(pb.Left + pb.Width - 13 ,c.cell[i].frect.Top + 5, pb.Left + pb.Width - 13 ,c.cell[i].frect.Top + 20);
    pb.Canvas.Pen.Color := clRed;
    pb.Canvas.Rectangle(pb.Left + pb.Width - 20 ,c.cell[i].frect.Top + 25, pb.Left + pb.Width - 5 ,c.cell[i].frect.Top + 40);
    pb.Canvas.line(pb.Left + pb.Width - 20 ,c.cell[i].frect.Top + 33, pb.Left + pb.Width - 5 ,c.cell[i].frect.Top + 33);
    pb.Canvas.Pen.Color := clBlue;
    pb.Canvas.Rectangle(pb.Left + pb.Width - 20 ,c.cell[i].frect.Top + 45, pb.Left + pb.Width - 5 ,c.cell[i].frect.Top + 60);
    pb.Canvas.Ellipse(pb.Left + pb.Width - 20 ,c.cell[i].frect.Top + 45, pb.Left + pb.Width - 5 ,c.cell[i].frect.Top + 60);
  end;
end;

procedure TFormTimeTable.PaintBoxStartDrag(Sender: TObject;
  var DragObject: TDragObject);
var
  c, r, i: integer;
  cl: TCell;
begin
  cl := TCell(PaintBox.Tag);
    for i := 0 to high(cl.cell) do
      if (MousePos.y + DrawPanel.Top - PanelF.Height < cl.cell[i].frect.Bottom) and
         (MousePos.y + DrawPanel.Top - PanelF.Height > cl.cell[i].frect.Top) then
            DragId := cl.cell[i].id;
end;


procedure TFormTimeTable.ComboBoxChange(Sender: TObject);
begin
  GenTableText();
end;

procedure TFormTimeTable.BitBtnClick(Sender: TObject);
var
  f: TFormConflict;
begin
  f := TFormConflict.Create(nil);
  f.NewConflict;
  f.Show();
end;

procedure TFormTimeTable.DrawGridClick(Sender: TObject);
var
  i, c, r: integer;
  fCon: fielTable;
  cr: TCard;
begin
  CMemo.Lines.Clear;
  if ((DrawGrid.Col > 0) and (DrawGrid.Row > 0)) then
  begin
    c := DrawGrid.Col;
    r := DrawGrid.Row;
    if  Length(FieldCeils[c - 1][r - 1].cell) = 0 then
    begin
      if (MousePos.x < DrawGrid.CellRect(c, r).Left + 125) and (MousePos.x > DrawGrid.CellRect(c, r).Left + 75)then
        if (MousePos.y < DrawGrid.CellRect(c, r).Top + 75) and (MousePos.y > DrawGrid.CellRect(c, r).Top + 25) then
        begin
          cr := TCard.Create(nil);
          cr.NewCard(TimeTable.Tables[High(TimeTable.Tables)], -1, ComboBoxX.ItemIndex + 1, ComboBoxY.ItemIndex + 1, c, r);
          cr.Show();

        end;
    end
    else
    begin
      for i := 0 to high(FieldCeils[c - 1][r - 1].cell) do
        if (MousePos.y < FieldCeils[c - 1][r - 1].cell[i].frect.Bottom) and (MousePos.y > FieldCeils[c - 1][r - 1].cell[i].frect.Top) then
          fCon := FieldCeils[DrawGrid.Col - 1][DrawGrid.Row - 1].cell[i];
      if fCon.AvailabilityConflict then
        for i := 0 to High(fCon.IdConflict) do
          CMemo.Lines.Add(inttostr(i + 1) + '. ' +DataConflicts[fCon.IdConflict[i]].Name);
      PaintBox.Visible := True;
      DrawPanel.Visible := True;
      DrawPanel.Left := FieldCeils[c - 1][r - 1].start.x;
      DrawPanel.Top := FieldCeils[c - 1][r - 1].start.y;
      DrawPanel.Width := FieldCeils[c - 1][r - 1].size.x + 25;
      DrawPanel.Height := FieldCeils[c - 1][r - 1].size.y;
      PaintBox.Tag := PtrInt(FieldCeils[c - 1][r - 1]);
      PaintBox.Invalidate;
    end;
  end;
end;

procedure TFormTimeTable.PaintBoxClick(Sender: TObject);
var
  cl: TCell;
  pb: TPaintBox;
  i, c, r, butval, id: integer;
  SQL: TSQLQuery;
  cr: TCard;
begin
  DrawGrid.MouseToCell(MousePos.x + DrawPanel.Left, MousePos.y + DrawPanel.Top - PanelF.Height, c, r);
  pb := TPaintBox(Sender);
  cl := TCell(pb.Tag);
  for i := 0 to high(cl.cell) do
  begin
    if (MousePos.x <= pb.Width - 5) and (MousePos.x >= pb.Width - 20) then
    begin
      if (MousePos.y + DrawPanel.Top - PanelF.Height >= cl.cell[i].frect.Top + 5) and
         (MousePos.y + DrawPanel.Top - PanelF.Height <= cl.cell[i].frect.Top + 20) then
         begin
           cr := TCard.Create(nil);
           cr.NewCard(TimeTable.Tables[High(TimeTable.Tables)], -1, ComboBoxX.ItemIndex + 1, ComboBoxY.ItemIndex + 1, c, r);
           cr.Show();
         end;
      if (MousePos.y + DrawPanel.Top - PanelF.Height >= cl.cell[i].frect.Top + 25) and
         (MousePos.y + DrawPanel.Top - PanelF.Height <= cl.cell[i].frect.Top + 40) then
         begin
           ButVal:= messagedlg('Вы точно хотите удалить запись?', mtCustom, [mbYes,mbNo], 0);
           if ButVal = mrYes then
           begin
             SQL := TSQLQuery.Create(nil);
             SQL.Transaction := DBDataModule.SQLTransaction;
             SQL.SQL.Text:= 'DELETE FROM ' + TimeTable.Tables[High(TimeTable.Tables)].name + ' WHERE ' + 'ID = :p0';
             SQL.Params[0].AsInteger:= cl.cell[i].id;
             SQL.ExecSQL;
             SQLQuery.ApplyUpdates;
             DBDataModule.SQLTransaction.CommitRetaining;
             SQL.Free;
             FormContainer.UpdateContent;
           end;
         end;
      if (MousePos.y + DrawPanel.Top - PanelF.Height >= cl.cell[i].frect.Top + 45) and
         (MousePos.y + DrawPanel.Top - PanelF.Height <= cl.cell[i].frect.Top + 60) then
         begin
              cr := TCard.Create(nil);
              cr.NewCard(TimeTable.Tables[High(TimeTable.Tables)], cl.cell[i].id, ComboBoxX.ItemIndex + 1, ComboBoxY.ItemIndex + 1, c, r);
              cr.Show();
         end;
    end
    else
      if (MousePos.y + DrawPanel.Top - PanelF.Height >= cl.cell[i].frect.Top) and
         (MousePos.y + DrawPanel.Top - PanelF.Height <= cl.cell[i].frect.Bottom) then
           id := cl.cell[i].id;
  end;
  CMemo.Lines.Clear;
  if cl.cell[id].AvailabilityConflict then
  for i := 0 to High(cl.cell[id].IdConflict) do
    CMemo.Lines.Add(DataConflicts[cl.cell[id].IdConflict[i]].Name);
end;

procedure TFormTimeTable.DrawGridDblClick(Sender: TObject);
var
  f: TDBForm;
begin
  f := TDBForm.Create(self);
  f.NewTable(TimeTable.Tables[high(TimeTable.Tables)].name, TimeTable.Tables[high(TimeTable.Tables)].caption, high(TimeTable.Tables));
  f.NewFilter();
  f.arrFilter[High(f.arrFilter)].cbfilter.ItemIndex := ComboBoxX.ItemIndex + 1;
  f.arrFilter[High(f.arrFilter)].edcondition.Text := referenceX[DrawGrid.Col - 1];
  f.arrFilter[High(f.arrFilter)].cbValue.ItemIndex := 0;
  f.arrFilter[High(f.arrFilter)].pl.Visible := False;
  f.NewFilter();
  f.arrFilter[High(f.arrFilter)].cbfilter.ItemIndex := ComboBoxY.ItemIndex + 1;
  f.arrFilter[High(f.arrFilter)].edcondition.Text := referenceY[DrawGrid.Row - 1];
  f.arrFilter[High(f.arrFilter)].cbValue.ItemIndex := 0;
  f.arrFilter[High(f.arrFilter)].pl.Visible := False;
  f.ButtonClick(nil);
  f.Show();

end;

procedure TFormTimeTable.DrawGridDragDrop(Sender, Source: TObject; X, Y: Integer
  );
var
  c, r: integer;
  s: string;
begin
  DrawGrid.MouseToCell(x, y, c, r);
  s :=  'UPDATE ' + TimeTable.Tables[High(TimeTable.Tables)].name + ' set '+
    TimeTable.Tables[High(TimeTable.Tables)].fileds[ComboBoxX.ItemIndex + 1].name + ' = ' + inttostr(c) + ' , ' +
    TimeTable.Tables[High(TimeTable.Tables)].fileds[ComboBoxY.ItemIndex + 1].name + ' = ' + inttostr(r) +
    ' WHERE ID = ' + inttostr(DragId);
  SQLQuery.Close;
  SQLQuery.SQL.Text := s;
  SQLQuery.ExecSQL;
  DBDataModule.SQLTransaction.CommitRetaining;
  GenTableText();
end;

procedure TFormTimeTable.DrawGridDragOver(Sender, Source: TObject; X,
  Y: Integer; State: TDragState; var Accept: Boolean);
  var
  c, r: integer;
begin
  DrawGrid.MouseToCell(MousePos.x, MousePos.y, c, r);
  Accept := (Sender = Source) and(c > 0) and (r > 0);
  if Sender <> Source then Accept := True;
end;

procedure TFormTimeTable.GenTableText;
var
  i, j, k: integer;
  s, t: string;
begin
  s := 'SELECT ';
  for j := 1 to High(TimeTable.Tables[TimeTable.Tables[high(TimeTable.Tables)].fileds[ComboBoxX.ItemIndex + 1].link].fileds) do
  begin
    if j > 1 then s += ' || '' '' || ';
    s += TimeTable.Tables[TimeTable.Tables[high(TimeTable.Tables)].fileds[ComboBoxX.ItemIndex + 1].link].fileds[j].name;
  end;
  s += ' as name';
  s += ' FROM ' + TimeTable.Tables[TimeTable.Tables[high(TimeTable.Tables)].fileds[ComboBoxX.ItemIndex + 1].link].name;
  SQLQuery.Close;
  SQLQuery.SQL.Text := s;
  SQLQuery.Open;
  SetLength(referenceX, 0);
  with Datasource.DataSet do
    while not EOF do begin
      SetLength(referenceX, Length(referenceX) + 1);
      referenceX[High(referenceX)] := Fields.Fields[0].AsString;
      Next;
    end;
  //НЕЗАБЫТЬ ВЫНЕСТИ ПОВТОРЯЮЩИЙСЯ КОД!!!!!!!!!!!!
  s := 'SELECT ';
  for j := 1 to High(TimeTable.Tables[TimeTable.Tables[high(TimeTable.Tables)].fileds[ComboBoxY.ItemIndex + 1].link].fileds) do
  begin
    if j > 1 then s += ' || '' '' || ';
    s += TimeTable.Tables[TimeTable.Tables[high(TimeTable.Tables)].fileds[ComboBoxY.ItemIndex + 1].link].fileds[j].name;
  end;
  s += ' as name';
  s += ' FROM ' + TimeTable.Tables[TimeTable.Tables[high(TimeTable.Tables)].fileds[ComboBoxY.ItemIndex + 1].link].name;
  SQLQuery.Close;
  SQLQuery.SQL.Text := s;
  SQLQuery.Open;
  SetLength(referenceY, 0);
  with Datasource.DataSet do
    while not EOF do begin
      SetLength(referenceY, Length(referenceY) + 1);
      referenceY[High(referenceY)] := Fields.Fields[0].AsString;
      Next;
    end;
  s := 'SELECT p.CONFLICT_TYPE, p.CONFLICTS_ID FROM CONFLICT p';
  SQLQuery.Close;
  SQLQuery.SQL.Text := s;
  SQLQuery.Open;
  SetLength(Conflicts, 0);
  with Datasource.DataSet do
    while not EOF do begin
      SetLength(Conflicts, Length(Conflicts) + 1);
      Conflicts[High(Conflicts)] := TConflict.Create(Fields.Fields[1].AsString, Fields.Fields[0].AsInteger);
      Next;
    end;
  s := 'SELECT Timetable.ID, ';
  t := '';
  for i := 1 to Length(TimeTable.Tables[High(TimeTable.Tables)].fileds) - 1 do
    with TimeTable.Tables[TimeTable.Tables[High(TimeTable.Tables)].fileds[i].link] do
    begin
      if i > 1 then s += ' , ';
      for j := 1 to Length(fileds) - 1 do
      begin
        if j > 1 then s += ' || '' '' || ';
        s += name + '.' + fileds[j].name;
      end;
      t += ' INNER JOIN ' + name + ' ON ' + name + '.ID = ' + TimeTable.Tables[High(TimeTable.Tables)].name + '.' + TimeTable.Tables[High(TimeTable.Tables)].fileds[i].name;
    end;
  s += ' as name';
  s +=  ' FROM ' + TimeTable.Tables[High(TimeTable.Tables)].name + t  + ' ORDER BY '
    + TimeTable.Tables[TimeTable.Tables[High(TimeTable.Tables)].fileds[ComboBoxX.ItemIndex + 1].link].name + '.ID, ' +
    TimeTable.Tables[TimeTable.Tables[High(TimeTable.Tables)].fileds[ComboBoxY.ItemIndex + 1].link].name + '.ID';
  SQLQuery.Close;
  SQLQuery.SQL.Text := s;
  SQLQuery.Open;
  SetLength(FieldCeils, 0);
  for i := 0 to high(referenceX) do
  begin
  SetLength(FieldCeils, i + 1);
  SetLength(FieldCeils[i], 0);
    for j := 0 to High(referenceY) do
    begin
      SetLength(FieldCeils[i], j + 1);
      FieldCeils[i][j] := TCell.Create;

      SetLength(FieldCeils[i][j].cell, 0);
      while (not Datasource.DataSet.EOF) and (Datasource.DataSet.Fields.Fields[ComboBoxX.ItemIndex + 1].AsString = referenceX[i]) and (Datasource.DataSet.Fields.Fields[ComboBoxY.ItemIndex + 1].AsString = referenceY[j]) do
      begin
        SetLength(FieldCeils[i][j].cell, Length(FieldCeils[i][j].cell) + 1);
        FieldCeils[i][j].cell[High(FieldCeils[i][j].cell)].id := Datasource.DataSet.Fields.Fields[0].AsInteger;
        SetLength(FieldCeils[i][j].cell[High(FieldCeils[i][j].cell)].text, 0);
        for k := 1 to high(TimeTable.Tables[High(TimeTable.Tables)].fileds) do
        begin
          if (k <> ComboBoxX.ItemIndex + 1) and (k <> ComboBoxY.ItemIndex + 1) then
          begin
            SetLength(FieldCeils[i][j].cell[High(FieldCeils[i][j].cell)].text, Length(FieldCeils[i][j].cell[High(FieldCeils[i][j].cell)].text) + 1);
            FieldCeils[i][j].cell[High(FieldCeils[i][j].cell)].text[high(FieldCeils[i][j].cell[High(FieldCeils[i][j].cell)].text)] := Datasource.DataSet.Fields.Fields[k].AsString;
          end;
        end;
        Datasource.DataSet.Next;
      end;
    end;
    end;
  DrawGrid.ColCount := Length(referenceX) + 1;
  DrawGrid.RowCount := Length(referenceY) + 1;
  for i := 0 to Length(referenceY) do
    DrawGrid.RowHeights[i] := 100;
  for i := 0 to Length(referenceX) do
    DrawGrid.ColWidths[i] := 200;
  DrawGrid.Invalidate;
end;

procedure TFormTimeTable.NewTimeTable;
var
  i: integer;
begin
  for i := 1 to High(TimeTable.Tables[High(TimeTable.Tables)].fileds) do
  begin
    ComboBoxX.AddItem(TimeTable.Tables[High(TimeTable.Tables)].fileds[i].caption, nil);
    ComboBoxY.AddItem(TimeTable.Tables[High(TimeTable.Tables)].fileds[i].caption, nil);
  end;
  ComboBoxX.ItemIndex := 5;
  ComboBoxY.ItemIndex := 6;
  SetLength(Conflicts, 0);
  GenTableText();
end;

procedure TFormTimeTable.UpdateContent;
begin
  DBDataModule.SQLTransaction.CommitRetaining;
  SQLQuery.Close;
  SQLQuery.Open;
  GenTableText;
end;

end.

