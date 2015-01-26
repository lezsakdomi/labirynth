unit LGraphics;

{$mode objfpc}{$H+}{$Define LGRAPHICS}

interface

uses
  Classes, SysUtils, Graphics, ExtCtrls, Forms, Controls, math,
  LTypes, LLevel, LIniFiles, LSize, LPosition;

type

  TVisualisator=class(TImage)
  private
    {types and vars}
    var
      //FScreen: TCanvas;
      FLevel: TLLevel;
      FDbg, FAnimate, FDrawcorner: Boolean;
      Fini: TLIniFile;
      FMinimap: TCustomControl;
    const
      iniSection='Visualisator';
  public
    {functions and procedures}
    constructor Create(AOwner: TForm; Aini: TLIniFile);
    //procedure drawAll();
    procedure drawpixel(AColor: TColor; ARel: TL3DPosition);
    procedure draw;
    destructor Destroy; override;
  private
    {propertyes}
    property ini: TLIniFile read Fini write Fini;
  public
    {propertyes}
    procedure setLevel(Value: TLLevel);
    property Level: TLLevel read FLevel write setLevel;
    property dbg: Boolean read FDbg write FDbg;
    property Animate: Boolean read FAnimate write FAnimate;
    property DrawCorner: Boolean read FDrawcorner write FDrawcorner;
    function getPos: TL2DPosition;
    procedure setPos(value: TL2DPosition);
    property Pos: TL2DPosition read getPos write setPos;
    function getSize: TL2DSize;
    procedure setSize(Value: TL2DSize);
    property Size: TL2DSize read getSize write setSize;
    property Minimap: TCustomControl read FMinimap write FMinimap;
  end;

implementation

constructor TVisualisator.Create(AOwner: TForm; Aini: TLIniFile);
begin
  inherited Create(AOwner);
  Fini:=Aini;
  Pos:=ini.ReadL2DPosition(iniSection, 'pos', Pos);
  Size:=ini.ReadL2DSize(iniSection, 'size', Size);
  //Level:=TLLevel.Create(TIniFile.Create(ini.ReadFn('level', 'ini', '')));
  {
  FScreen:=TCanvas.Create;
  FScreen.Width:=FMap.data.Width;
  FScreen.Height:=FMap.data.Height;
  }
  Parent:=AOwner;
  if (ini.ReadFn(iniSection, 'splash', '')<>'') then Picture.Bitmap.LoadFromFile(ini.ReadFn(iniSection, 'splash', ''));
  //Picture.Bitmap.LoadFromFile('C:\Users\lezsakd12a\Desktop\Labirynth\source\motortest\splash.bmp');
  dbg:=ini.ReadBool(iniSection, 'dbg', false);
  Animate:=ini.ReadBool(iniSection, 'animate', false);
  DrawCorner:=ini.ReadBool(iniSection, 'drawcorner', true);
end;

procedure TVisualisator.setLevel(Value: TLLevel);
var x, y: Integer;
begin
  FLevel:=Value;
  draw;
  if Minimap<>Nil then
  begin
    for x:=0 to Minimap.Canvas.Width-1 do
    begin
      for y:=0 to Minimap.Canvas.Height-1 do
      begin
        Minimap.Canvas.Pixels[x, y]:=Level.data.Canvas.Pixels[
          round((x/Minimap.Canvas.Width)*Level.Width),
          round((y/Minimap.Canvas.Height)*Level.Height)
        ];
      end;
    end;
  end;
end;

procedure TVisualisator.drawpixel(AColor: TColor; ARel: TL3DPosition);
var
  ximax, ximin, xi, yimax, yimin, yi: Integer;
  currviewsize: TL2Dsize;
  xdiv, ydiv, zdiv: Extended;
begin
  currviewsize:=Level.ViewSize;
  ydiv:=currviewsize.Y/ARel.y;
  currviewsize.X:=round(currviewsize.X*ydiv);
  //currviewsize.Z:=round(currviewsize.Z*ydiv);
  xdiv:=currviewsize.X/ARel.x/2;
  //zdiv:=currviewsize.Z/ARel.z/2;

  ximin:=round(Canvas.Width/2-Canvas.Width/2*xdiv);
  ximax:=round(Canvas.Width/2-Canvas.Width/2*xdiv);
  yimin:=round(Canvas.Height/2-Canvas.Height/2*zdiv);
  yimin:=round(Canvas.Height/2-Canvas.Height/2*zdiv);

  for xi:=ximin to ximax do
  begin
    for yi:=yimin to yimax do
    begin
      Canvas.Pixels[xi, yi]:=AColor;
    end;
  end;
end;

procedure TVisualisator.draw;
//(*
var cw, ch: Integer; //canvas
    cXmax, cYmax: Extended;
    mmcw, mmch, mmx, mmy, mmi, mmj: Integer; //Minimap
    dpiX: Extended;         //DrawPixelI()
    dpiR, dpiG, dpiB: Byte;
    dpiCl: TColor;
    wasWall: Boolean;
    wallCnt: Word;
    X, Xmax, Y, Ymax, imax, jmax, dir:Extended;
    fullPosition: TLPlayerPosition;
    mX, mY, i, j: Integer;
  procedure drawPixelI(
    X, Y: Extended; i, j: Integer;
    cl: TColor
  );
  begin
    if (round(imax+i)<>0) and ((round(imax+i) mod max(1, round((imax+imax)/5)))=0) then
      cl:=clYellow;
    if (Random(round(imax/5))=1) then
      cl:=clBlack;
    Canvas.Pixels[
      round(dpiX+j),
      round(cYmax+i)
    ]:=cl;
  end;
begin
  { $Define BITMAP}
  cw:={$IfDef BITMAP}Picture.Bitmap.{$EndIf}Canvas.Width;
  ch:={$IfDef BITMAP}Picture.Bitmap.{$EndIf}Canvas.Height;
  cXmax:=cw/2;
  cYmax:=ch/2;
  if Minimap<>Nil then
  begin;
    mmcw:=Minimap.Canvas.Width;
    mmch:=Minimap.Canvas.Height;
    //Minimap.Hide;
    //Minimap.Canvas.Clear;
  end;
  if not (dbg or animate) then Visible:=False;
  {$IfDef BITMAP}Picture.Bitmap.{$EndIf}Canvas.Clear;
  {$IfDef BITMAP}Picture.Bitmap.BeginUpdate(True);{$EndIf}
  Ymax:=Level.ViewSize.y;
  for mY:=-round(Ymax) to 0 do
  begin
    Y:=-mY;
    dpiR:=round(255*(Y*Y)/(Level.ViewSize.y*Level.ViewSize.y));
    dpiB:=round(255*Y/Level.ViewSize.y/2);
    //mmj:=abs(round(mmch/Ymax/2));
    mmj:=0;
    if y<>0 then mmy:=mmch-2*round(mmch/(Ymax/Y));
    imax:=(*Ymax-*)(ch/2)*(Y/Ymax);
    //imax:=abs(imax);
    imax:=ch/2-imax;
    imax:=Max(imax, 1);
    Xmax:=Level.ViewSize.x/2;
    Xmax:=Xmax*(Y)/Ymax;

    //wasWall:=False;
    for mX:=-round(Xmax) to round(Xmax) do
    begin
      X:=-mX;
      {$IfDef WINDOWS}
        if xmax=0 then xmax:=1;
      {$EndIf}
      {$IfNDef WINDOWS}
        if animate then Sleep(1);
      {$EndIf}
      if dbg or Animate then Application.ProcessMessages;
      dir:=Level.PlayerPosition.direction;
      fullPosition:=TLPlayerPosition.Create;
      fullPosition.X:=Level.PlayerPosition.coords.X+round(sin(dir)*Y+cos(dir)*X);
      fullPosition.Y:=Level.PlayerPosition.coords.Y-round(cos(dir)*Y-sin(dir)*X);
      fullPosition.direction:=Level.PlayerPosition.direction+0;
      if Level.isPlayerPosition(fullPosition) then
      begin
        if dbg then {$IfDef BITMAP}Picture.Bitmap.{$EndIf}Canvas.Pixels[fullPosition.coords.X, fullPosition.coords.Y]:=clGreen;
        if (Minimap<>Nil) and (X<>0) and (Y<>0) then
        begin
          mmx:=round(mmcw/2+mmcw/(Xmax/X/Y*Ymax));

          //mmi:=round(mmcw/2+mmcw/(Xmax/2/Y*Ymax));;
          mmi:=0;

          for i:=-mmi to mmi do
          for j:=-mmj to mmj do
            Minimap.Canvas.Pixels[
              mmx-i,
              mmy-i
            ]:=clGreen;
        end;
        dpiX:=cXmax+cXmax*X/Xmax;
        if Level.isWall[fullPosition.X, fullPosition.Y] then
        begin
          //wasWall:=not wasWall;
          wallCnt:=0;
          if Level.isWall[fullPosition.X+1, fullPosition.Y] then Inc(wallCnt);
          if Level.isWall[fullPosition.X+1, fullPosition.Y+1] then Inc(wallCnt);
          if Level.isWall[fullPosition.X+1, fullPosition.Y-1] then Inc(wallCnt);

          if Level.isWall[fullPosition.X, fullPosition.Y+1] then Inc(wallCnt);
         //if Level.isWall[fullPosition.X, fullPosition.Y] then Inc(wallCnt);
          if Level.isWall[fullPosition.X, fullPosition.Y-1] then Inc(wallCnt);

          if Level.isWall[fullPosition.X-1, fullPosition.Y+1] then Inc(wallCnt);
          if Level.isWall[fullPosition.X-1, fullPosition.Y] then Inc(wallCnt);
          if Level.isWall[fullPosition.X-1, fullPosition.Y-1] then Inc(wallCnt);
          if dbg then {$IfDef BITMAP}Picture.Bitmap.{$EndIf}Canvas.Pixels[fullPosition.coords.X, fullPosition.coords.Y]:=clRed;
          if (Minimap<>Nil) and (X<>0) and (Y<>0) then
          begin
            Minimap.Canvas.Pixels[
              mmx,
              mmy
            ]:=clRed;
          end;
          jmax:=cw/Xmax/2;
          if dbg then jmax:=0;
          //if animate then jmax:=0;
          for i:=-round(imax) to round(imax) do
          begin
            dpiG:=round(255*abs(imax+i)/max(1, abs(imax+imax)));
            dpiCl:=RGBToColor(dpiR, dpiG, dpiB);
            //dpiCl:=clWhite;
            for j:=-round(jmax) to round(jmax) do
              drawPixelI(x, y, i, j, dpiCl);
            if (*not animate and*) DrawCorner then
            begin
              drawPixelI(x, y, round(-imax), j, clBlack);
              drawPixelI(x, y, round(+imax), j, clBlack);
            end;
          end;
          if wallCnt=1 then
          begin
            for i:=-round(imax) to round(imax) do
            begin
              if (round(Xmax)<>0) and ((cw mod round(Xmax))>(jmax*2)) then
                drawPixelI(x, y, i, round(+jmax), clBlack)
              else
                drawPixelI(x, y, i, round(-jmax), clBlack);
            end;
          end;{ TODO 3 -oLezsák Domonkos -cminimap : else Minimap.Canvas.Pixels:=clDefault }
        end;
      end;
    end;
  end;
  {$IfDef BITMAP}Picture.Bitmap.EndUpdate(False);{$EndIf}
  Visible:=True;
  //if animate then Animate:=False;

  if Minimap<>Nil then
  begin
    //Minimap.Show;
    Minimap.Canvas.Pixels[
      round(mmcw/2)-2,
      mmch-2
    ]:=clLime;
    Minimap.Canvas.Pixels[
      round(mmcw/2)+2,
      mmch-2
    ]:=clLime;
    repeat
      wasWall:=False;
      for mX:=0 to mmcw-1 do
      for mY:=0 to mmch-1 do
        begin
          if (*Minimap.Canvas.Pixels[mX, mY]<>clRed) and
             (Minimap.Canvas.Pixels[mX, mY]<>clLime) and ( **)
             (Minimap.Canvas.Pixels[mX, mY]=clGreen)
          then
          begin
            if
              (Minimap.Canvas.Pixels[mX-1, mY]=clLime) or
              (Minimap.Canvas.Pixels[mX+1, mY]=clLime) or
              (Minimap.Canvas.Pixels[mX, mY-1]=clLime) or
              (Minimap.Canvas.Pixels[mX, mY+1]=clLime)
            then
            begin
              Minimap.Canvas.Pixels[mX, mY]:=clLime;
              wasWall:=True;
            end;
          end;
          if dbg or Animate then Application.ProcessMessages;
        end;
    until not wasWall;
  end;
end;
(*
var ximin, ximax, xi, yimin, yimax, yi, zimin, zimax, zi: Integer;
begin
  if not (dbg or animate) then Visible:=False;
  Canvas.Clear;
  ximin:=Level.PlayerPosition.X;
  ximax:=ximin+Level.ViewSize.X;
  for xi:=ximin to ximax do
  begin
    yimin:=1;
    yimax:=Level.ViewSize.Y;
    for yi:=1 to Level.ViewSize.Y do
    begin
      if Level.isWall[xi, yi] then
      begin
        zimin:=0;
        zimax:=Level.ViewSize.Z;
        for zi:=zimin to zimax do
        begin
          drawpixel(clBlack, TL3DPosition.Create(xi, yi, zi));
        end;
      end;
    end;
  end;
  Visible:=True;
  //if animate then Animate:=False;
end;
*)

destructor TVisualisator.Destroy;
begin
  inherited Destroy;
end;

function TVisualisator.getPos:TL2DPosition;
begin
  Result:=TL2DPosition.Create(Left, Top);
end;

procedure TVisualisator.setPos(Value: TL2DPosition);
begin
  Left:=Value.X;
  Top:=Value.Y;
end;

function TVisualisator.getSize: TL2DSize;
begin
  Result:=TL2DSize.Create(Width, Height);
end;

procedure TVisualisator.setSize(Value: TL2DSize);
begin
  Width:=Value.x;
  Height:=Value.y;
  Picture.Bitmap.Width:=Value.X;
  Picture.Bitmap.Height:=Value.Y;
end;

end.

