unit utimetible;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  StdCtrls;

type

  { TFormTimeTible }

  TFormTimeTible = class(TForm)
    EditX: TEdit;
    EditY: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Panel: TPanel;
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  FormTimeTible: TFormTimeTible;

implementation

{$R *.lfm}

end.

