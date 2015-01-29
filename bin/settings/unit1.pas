unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ComCtrls, ExtCtrls, LIniFiles, LSize;

type

  { TForm1 }

  TForm1 = class(TForm)
    sizeText: TEdit;
    Size: TButton;
    musicFn: TEdit;
    OpenDialog1: TOpenDialog;
    music: TToggleBox;
    drawcorner: TToggleBox;
    animate: TToggleBox;
    ToggleBox1: TToggleBox;
    procedure animateChange(Sender: TObject);
    procedure drawcornerChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure musicChange(Sender: TObject);
    procedure SizeClick(Sender: TObject);
    procedure Update;
  private
    { private declarations }
    var
      updatingInProgress: Boolean;
  public
    { public declarations }
  end;

var
  Form1: TForm1;
  MainIni, VisualisatorIni: TLIniFile;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.FormCreate(Sender: TObject);
begin
  MainIni:=TLIniFile.Create('../../main.ini');
  Update;
end;

procedure TForm1.Update;
begin
  updatingInProgress:=True;
  VisualisatorIni:=MainIni.ReadIni('Visualisator');
  music.Checked:=MainIni.ReadFn('Form', 'music')<>'';
  musicFn.Text:=MainIni.ReadFn('Form', 'music');
  drawcorner.Checked:=VisualisatorIni.ReadBool('Visualisator', 'drawcorner', True);
  animate.Checked:=VisualisatorIni.ReadBool('Visualisator', 'animate', True);
  sizeText.Text:=MainIni.ReadString('Form', 'size');
  updatingInProgress:=False;
end;

procedure TForm1.musicChange(Sender: TObject);
begin
  if not updatingInProgress then
  begin
    if music.Checked and OpenDialog1.Execute then
      MainIni.WriteFn('Form', 'music', OpenDialog1.FileName)
    else
      MainIni.WriteString('Form', 'music', '');
    Update;
  end;
end;

procedure TForm1.SizeClick(Sender: TObject);
var value: TL2DSize;
begin
  if not updatingInProgress then
  begin
    value:=StrToL2DSize(
      InputBox(
        'Méret',
        'Add meg a méretet valahogy  így: "x;y"',
        L2DSizeToStr(
          MainIni.ReadL2DSize(
            'Form',
            'size'
          )
        )
      )
    );
    MainIni.WriteL2DSize('Form', 'size', value);
    //VisualisatorIni.WriteL2DSize('Visaualisator', 'size', value);
    Update;
  end;
end;

procedure TForm1.drawcornerChange(Sender: TObject);
begin
  if not updatingInProgress then
  begin
    VisualisatorIni.WriteBool('Visualisator', 'drawcorner', drawcorner.Checked);
    Update;
  end;
end;

procedure TForm1.animateChange(Sender: TObject);
begin
  if not updatingInProgress then
  begin
    VisualisatorIni.WriteBool('Visualisator', 'animate', animate.Checked);
    Update;
  end;
end;

end.

