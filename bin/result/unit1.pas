unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  StdCtrls, ComCtrls, LIniFiles, LTypes, LSize, LPoint, LPosition;

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
    function getPos: TL2DPosition;
    procedure setPos(value: TL2DPosition);
    property Pos: TL2DPosition read getPos write setPos;
    function getSize: TL2DSize;
    procedure setSize(Value: TL2DSize);
    property Size: TL2DSize read getSize write setSize;
  end;

var
  Form1: TForm1;
  elapsed: TTime;
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
  Image1.Stretch:=ini.ReadBool('Result', 'stretch',
    ini.ReadBool('Form', 'stretch',
      ini.ReadBool('Visualisator', 'stretch',
        True)));
  Size:=ini.ReadL2DSize('Result', 'size',
    ini.ReadL2DSize('Form', 'size',
      Size));
  Pos:=ini.ReadL2DPosition('Result', 'pos',
    ini.ReadL2DPosition('Form', 'pos',
      Pos));
  elapsed:=Default(
    StrToFloat(Default(Application.GetOptionValue('t', 'time'), '0')),
    Now-StrToFloat(Default(Application.GetOptionValue('s', 'start'), '0'))
  );
  steps:=StrToInt(Default(Application.GetOptionValue('s', 'steps'), '0'));
  points:=round(1000000/time/steps);
  case Default(Application.GetOptionValue('a', 'action'), 'win') of
    'dead':
      begin
        Image1.Picture.LoadFromFile(ini.ReadFn('Result', 'dead'));
        points:=-points;
      end;
    'win': Image1.Picture.LoadFromFile(ini.ReadFn('Result', 'win'));
  end;
  StatusBar1.Panels[1].Text:=TimeToStr(time);
  StatusBar1.Panels[3].Text:=IntToStr(steps);
  StatusBar1.Panels[5].Text:=IntToStr(points);
  allpoints:=ini.ReadInteger('Player', 'points', 0)+points;
  StatusBar1.Panels[6].Text:=IntToStr(allpoints);
  ini.WriteInteger('Player', 'points', allpoints);
end;

function TForm1.getPos:TL2DPosition;
begin
  Result:=TL2DPosition.Create(Left, Top);
end;

procedure TForm1.setPos(Value: TL2DPosition);
begin
  Left:=Value.X;
  Top:=Value.Y;
end;

function TForm1.getSize: TL2DSize;
begin
  Result:=TL2DSize.Create(Width, Height);
end;

procedure TForm1.setSize(Value: TL2DSize);
begin
  Width:=Value.x;
  Height:=Value.y;
end;

end.

