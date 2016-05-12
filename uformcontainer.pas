unit UFormContainer;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms;

type

  { TFormSQL }

  TFormSQL = class(TForm)
  public
    constructor Create(TheOwner: TComponent); override;
    procedure UpdateContent; virtual; Abstract;
  end;
  { TFormContainer }

  TFormContainer = class
  public
    procedure UpdateContent;
  private
    arrForm: array of TFormSQL;
  end;

var
   FormContainer: TFormContainer;

 implementation

 { TFormSQL }

constructor TFormSQL.Create(TheOwner: TComponent);
begin
  inherited Create(TheOwner);
  SetLength(FormContainer.arrForm, Length(FormContainer.arrForm) + 1);
  FormContainer.arrForm[High(FormContainer.arrForm)] := self;
end;

 { TFormContainer }

procedure TFormContainer.UpdateContent;
var
   i: integer;
begin
   for i := 0 to high(arrForm) do
     arrForm[i].UpdateContent;
end;
initialization
  FormContainer := TFormContainer.Create;

finalization
  FormContainer.Free;
end.

