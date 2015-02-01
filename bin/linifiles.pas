unit LIniFiles;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, IniFiles, FileUtil, strutils, Graphics,
  LSize, LPosition, LTypes;

type
  TLIniFile=class(TIniFile)
  {$Define PARENT_AS_L}
  private
    var
      FParent: {$IfDef PARENT_AS_L}TLIniFile{$Else}TCustomIniFile{$EndIf};
  public
    {types and variables}
    type
      TLIniFileArray=array of TLIniFile;
  public
    {functions and procedures}
    constructor Create(AFileName: string; AEscapeLineFeeds: Boolean=False; AParent: {$IfDef PARENT_AS_L}TLIniFile{$Else}TCustomIniFile{$EndIf}=Nil);
    function ReadString(const Section, Ident: String; Default: string=''; UseParent: Boolean=True): string;
    procedure ParseFn(var AFn: TLFn);
    function ReadFn(const Section, Ident: String; Default: TLFn=''; UseParent: Boolean=True): TLFn;
    function ReadFnArray(const Ident: String): TLFnArray;
    procedure WriteFn(const Section, Ident: String; Value: TLFn);
    function ReadIni(const Section: String; Ident: String='ini'; Default: TLIniFile=Nil): TLIniFile;
    function ReadIniArray(const Ident: String): TLIniFileArray;
    procedure WriteIni(const Section: String; Ident: String='ini'; Value: TLIniFile=Nil);
    function ReadArray(const Section, Ident: String; Default: TStringArray=Nil; Delimeter: Char=','): TStringArray;
    procedure WriteArray(const Section, Ident: String; Value: TStringArray; Delimeter: Char=',');
    function ReadPoint(const Section, Ident: String; Default: TPoint): TPoint;
    procedure WritePoint(const Section, Ident: String; Value: TPoint);
    function ReadL2DPosition(const Section, Ident: String; Default: TL2DPosition=Nil): TL2DPosition;
    procedure WriteL2DPosition(const Section, Ident: String; Value: TL2DPosition);
    function ReadL3DPosition(const Section, Ident: String; Default: TL3DPosition=Nil): TL3DPosition;
    procedure WriteL3DPosition(const Section, Ident: String; Value: TL3DPosition);
    function ReadL2DSize(const Section, Ident: String; Default: TL2DSize=Nil): TL2DSize;
    procedure WriteL2DSize(const Section, Ident: String; Value: TL2DSize);
    function ReadL3DSize(const Section, Ident: String; Default: TL3DSize=Nil): TL3DSize;
    procedure WriteL3DSize(const Section, Ident: String; Value: TL3DSize);
    function ReadBitmap(const Section, Ident: String; Default: TBitmap): TBitmap;
  public
    {propertyes}
    property Parent: {$IfDef PARENT_AS_L}TLIniFile{$Else}TCustomIniFile{$EndIf} read FParent;
  protected
    //property FSectionList: TIniFileSectionList read FSectionList write FSectionList;
  end;

  TLIniFileArray=TLIniFile.TLIniFileArray;

implementation

constructor TLIniFile.Create(AFileName: string; AEscapeLineFeeds: Boolean=False; AParent: {$IfDef PARENT_AS_L}TLIniFile{$Else}TCustomIniFile{$EndIf}=Nil);
begin
  ParseFn(AFileName);
  inherited Create(AFileName, AEscapeLineFeeds);
  FParent:=AParent;
end;

function TLIniFile.ReadString(const Section, Ident: String; Default: string=''; UseParent: Boolean=True): string;
(*
var
  oSection: TIniFileSection;
  oKey: TIniFileKey;
  J: integer;
  found: Boolean;
begin
  Result := Default;
  oSection := SectionList.SectionByName(Section,CaseSensitive);
  if oSection <> nil then begin
    oKey := oSection.KeyList.KeyByName(Ident,CaseSensitive);
    if oKey <> nil then
      If StripQuotes then
      begin
        J:=Length(oKey.Value);
        If (J>1) and ((oKey.Value[1] in ['"','''']) and (oKey.Value[J]=oKey.Value[1])) then
           Result:=Copy(oKey.Value,2,J-2)
        else
           Result:=oKey.Value;
        found:=True;
      end
      else Result:=oKey.Value;
  end;
  if ((not found) and (Parent<>Nil)) then
    Result:=Parent.ReadString(Section, Ident, Default);
end;
*)
begin
  Result:=inherited ReadString(Section, Ident, '');
  if Result='' then
    if ((Parent=Nil) or (not UseParent)) then
      Result:=Default
    else
    begin
      Result:=Parent.ReadString(Section, Ident, Default);
    end;
end;

procedure TLIniFile.ParseFn(var AFn: TLFn);
var appname, appdir, inipath, inidir: TLFn;
begin
  (*
  appname:=ApplicationName;
  appdir:=ExtractFileDir(appdir);
  inipath:=CreateAbsolutePath(FileName, appdir);
  *)
  inipath:=ExpandFileName(FileName);
  inidir:=ExtractFileDir(inipath);
  AFn:=CreateAbsolutePath(AFn, inidir);
  AFn:=UTF8ToSys(AFn);
end;

function TLIniFile.ReadFn(const Section, Ident: String; Default: TLFn; UseParent: Boolean=True):TLFn;
begin
  Result:=ReadString(Section, Ident, '', False);
  if Result='' then
    if ((Parent=Nil) or (not UseParent)) then
      Result:=Default
    else
    begin
      Result:=Parent.ReadFn(Section, Ident, Default);
    end;
  ParseFn(Result);
end;

function TLIniFile.ReadFnArray(const Ident: String): TLFnArray;
var t: Text;
    strings: TStringList;
    section: String;
    i: Integer;
begin
  section:=UpperCase(LeftStr(Ident, 1))+RightStr(Ident, Length(Ident)-1);
  strings:=TStringList.Create;

  ReadSectionRaw(section, strings);

  SetLength(Result, strings.Count);
  for i:=0 to strings.Count-1 do
  begin
    Result[i]:=strings.Strings[i];
    ParseFn(Result[i]);
  end;
end;

procedure TLIniFile.WriteFn(const Section, Ident: String; Value: TLFn);
var fnFrom, fnTo: TLFn;
begin
  fnFrom:=Value;
  fnTo:=ReadFn(Section, Ident, 'RAND_'+IntToStr(Random(MaxInt))+'_'+ExtractFileNameOnly(Value));
  CopyFile(fnFrom, fnTo);
end;

function TLIniFile.ReadIni(const Section: String; Ident: String='ini'; Default: TLIniFile=Nil): TLIniFile;
var fn: TLFn;
begin
  fn:=ReadFn(Section, Ident, '');
  if fn<>'' then
  begin
    Result:=TLIniFile.Create(fn, EscapeLineFeeds, Self);
  end
  else
  begin
    if Default=Nil then
    begin
      Result:=Self;
    end
    else
    begin
      Result:=Default;
    end;
  end;
end;

function TLIniFile.ReadIniArray(const Ident: String): TLIniFileArray;
var fns: TLFnArray;
    i: Integer;
begin
  fns:=ReadFnArray(Ident);

  SetLength(Result, Length(fns));
  for i:=0 to Length(fns)-1 do
  begin
    Result[i]:=TLIniFile.Create(fns[i], EscapeLineFeeds, Self);
  end;
end;

procedure TLIniFile.WriteIni(const Section: String; Ident: String='ini'; Value: TLIniFile=nil);
var fn: TLFn;
begin
  fn:=Value.FileName;
  Value.Free;
  WriteFn(Section, Ident, fn);
end;

function TLIniFile.ReadArray(const Section, Ident: String; Default: TStringArray=Nil; Delimeter: Char=','): TStringArray;
var s: String;
begin
  s:=ReadString(Section, Ident, '');
  if (s='') then
    Result:=Default
  else
    Result:=StrToArray(s, Delimeter);
end;

procedure TLIniFile.WriteArray(const Section, Ident: String; Value: TStringArray; Delimeter: Char=',');
begin
  WriteString(Section, Ident, ArrayToStr(Value, Delimeter));
end;

function TLIniFile.ReadPoint(const Section, Ident: String; Default: TPoint): TPoint;
var s: String;
    Strings: TStringList;
begin
  s:=ReadString(Section, Ident, PointToStr(Default));
  Result:=StrToPoint(s);
end;

procedure TLIniFile.WritePoint(const Section, Ident: String; Value: TPoint);
begin
  WriteString(Section, Ident, PointToStr(Value));
end;

function TLIniFile.ReadL2DSize(const Section, Ident: String; Default: TL2DSize): TL2DSize;
var s: String;
begin
  if Default=Nil then Default:=TL2DSize.Create;
  s:=ReadString(Section, Ident, L2DSizeToStr(Default));
  Result:=StrToL2DSize(s);
end;

procedure TLIniFile.WriteL2DSize(const Section, Ident: String; Value: TL2DSize);
begin
  WriteString(Section, Ident, L2DSizeToStr(Value));
end;

function TLIniFile.ReadL3DSize(const Section, Ident: String; Default: TL3DSize): TL3DSize;
var s: String;
begin
  if Default=Nil then Default:=TL3DSize.Create;
  s:=ReadString(Section, Ident, L3DSizeToStr(Default));
  Result:=StrToL3DSize(s);
end;

procedure TLIniFile.WriteL3DSize(const Section, Ident: String; Value: TL3DSize);
begin
  WriteString(Section, Ident, L3DSizeToStr(Value));
end;

function TLIniFile.ReadL2DPosition(const Section, Ident: String; Default: TL2DPosition): TL2DPosition;
var s: String;
begin
  if Default=Nil then Default:=TL2DPosition.Create;
  s:=ReadString(Section, Ident, L2DPositionToStr(Default));
  Result:=StrToL2DPosition(s);
end;

procedure TLIniFile.WriteL2DPosition(const Section, Ident: String; Value: TL2DPosition);
begin
  WriteString(Section, Ident, L2DPositionToStr(Value));
end;

function TLIniFile.ReadL3DPosition(const Section, Ident: String; Default: TL3DPosition): TL3DPosition;
var s: String;
begin
  if Default=Nil then Default:=TL3DPosition.Create;
  s:=ReadString(Section, Ident, L3DPositionToStr(Default));
  Result:=StrToL3DPosition(s);
end;

procedure TLIniFile.WriteL3DPosition(const Section, Ident: String; Value: TL3DPosition);
begin
  WriteString(Section, Ident, L3DPositionToStr(Value));
end;

function TLIniFile.ReadBitmap(const Section, Ident: String; Default: TBitmap): TBitmap;
var fn: TLFn;
begin
  Result:=TBitmap.Create;
  fn:=ReadFn(Section, Ident, '');
  if fn<>'' then
  begin
    Result.LoadFromFile(fn);
  end
  else
  begin
    Result:=Default;
  end;
end;

end.

