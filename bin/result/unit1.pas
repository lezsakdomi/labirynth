unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  StdCtrls, ComCtrls, Time, LIniFiles, LTypes;

type

  { TForm1 }

  TForm1 = class(TForm)
    Image1: TImage;
    StatusBar1: TStatusBar;
    procedure FormCreate(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  Form1: TForm1;
  time: TTime;
  steps: Integer;
  points: Integer;
  allpoints: Integer;
  ini: TLIniFile;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.FormCreate(Sender: TObject);
begin
  ini:=TLIniFile.Create(Default(Application.GetOptionValue('f', 'ini'), '../../main.ini'));
  time:=StrToFloat(Default(Application.GetOptionValue('t', 'time'), '0'));
  steps:=StrToInt(Default(Application.GetOptionValue('s', 'steps'), '0'));
  case Application.GetOptionValue('a', 'action') of
    'dead': Image1.Picture.LoadFromFile(ini.ReadFn('Result', 'dead'));
    'win': Image1.Picture.LoadFromFile(ini.ReadFn('Result', 'win'));
  end;
  StatusBar1.Panels[1].Text:=TimeToStr(time);
  StatusBar1.Panels[3].Text:=IntToStr(steps);
  StatusBar1.Panels[5].Text:=IntToStr(points);
  allpoints:=ini.ReadInteger('Player', 'points', 0)+points;
  StatusBar1.Panels[6].Text:=IntToStr(allpoints);
  ini.WriteString('Player', 'points', allpoints);
end;

end.

