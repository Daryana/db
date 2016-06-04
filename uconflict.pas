unit uconflict;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  Metadata;

type

  { TFormConflict }

  TFormConflict = class(TForm)
  private
    { private declarations }
  public
    { public declarations }
    procedure NewConflict;
  end;

implementation

{$R *.lfm}

{ TFormConflict }

procedure TFormConflict.NewConflict;
var
  i, j, k,  t: integer;
  lb: TLabel;
  b: boolean;
  s: string;
begin
  t := 5;
  for i := 0 to High(DataConflicts) do
  begin
    lb := TLabel.Create(nil);
    lb.Parent := self;
    lb.Top := t;
    lb.Left := 25;
    lb.Caption := DataConflicts[i].Name;
    t += 20;
    b := true;
    s := DataConflicts[i].Name;
    for k := 0 to High(Conflicts) do
      if Conflicts[k].idConflict = i then
      begin
        if b then
        begin
          lb := TLabel.Create(nil);
          lb.Parent := self;
          lb.Top := t;
          lb.Left := 50;
          t += 20;
          s := 'ID: ';
          b := false;
        end;
        for j := 0 to High(Conflicts[k].IdField) do
        begin
          if s <> 'ID: ' then s += ', ';
          s += inttostr(Conflicts[k].IdField[j]);
        end;
      end;
      lb.Caption := s;
  end;
end;

end.

