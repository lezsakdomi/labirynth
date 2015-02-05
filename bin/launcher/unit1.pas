unit Unit1;

{$mode objfpc}{$H+}
{$IncludePath ..}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  LIniFiles, LTypes;

type

  { TForm1 }

  TForm1 = class(TForm)
    procedure FormCreate(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
    {$Include h.inc}
  end;

var
  Form1: TForm1;
  ini: TLIniFile;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.FormCreate(Sender: TObject);
begin
  {$Include c.inc}
end;

{$Include f.inc}

end.

