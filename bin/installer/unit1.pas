unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ShellCtrls, LIniFiles, windows, RegExpr, Regex, LTypes, ComCtrls;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Edit1: TEdit;
    path: TEdit;
    SelectDirectoryDialog1: TSelectDirectoryDialog;
    ShellTreeView1: TShellTreeView;
    ListBox1: TListBox;
    files: TListBox;
    procedure Button1Click(Sender: TObject);
    procedure Edit1KeyPress(Sender: TObject; var Key: char);
    procedure filesMeasureItem(Control: TWinControl; Index: Integer;
      var AHeight: Integer);
    procedure ListBox1Click(Sender: TObject);
    procedure ListBox1KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState
      );
    procedure ListBox1MeasureItem(Control: TWinControl; Index: Integer;
      var AHeight: Integer);
    procedure pathExit(Sender: TObject);
    procedure procDir(fn: TLFn);
    procedure procFile(fn: TLFn);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  Form1: TForm1;
  ini: TLIniFile;
  tpl: array of record
    regexpr: TRegExpr;
    usage: String;
  end;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.Edit1KeyPress(Sender: TObject; var Key: char);
begin
  case Key of
    #13: begin
      ListBox1.Items.Values[Edit1.Text]:=InputBox('Adding file', 'include/start', 'include');
      Edit1.Clear;
    end;
  end;
end;

procedure TForm1.filesMeasureItem(Control: TWinControl; Index: Integer;
  var AHeight: Integer);
begin
  files.Items.ValueFromIndex[Index]:=InputBox('Modify entry', files.Items.Names[Index], files.Items.ValueFromIndex[Index]);
end;

procedure TForm1.ListBox1Click(Sender: TObject);
begin

end;

procedure TForm1.Button1Click(Sender: TObject);
var i: Integer;
begin
  files.Hide;
  with ListBox1.Items do
  begin
    SetLength(tpl, ListBox1.Items.Count);
    for i:=0 to ListBox1.Items.Count-1 do
    begin
      tpl[i].regexpr:=TRegExpr.Create;
      tpl[i].regexpr.Expression:=Names[i];
      tpl[i].usage:=ValueFromIndex[i];
    end;
  end;
  procDir(path.Text);
  files.Show;
end;

procedure TForm1.ListBox1KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  case Key of
    VK_DELETE: ListBox1.Items.Delete(ListBox1.ItemIndex);
  end;
end;

procedure TForm1.ListBox1MeasureItem(Control: TWinControl; Index: Integer;
  var AHeight: Integer);
begin

end;

procedure TForm1.pathExit(Sender: TObject);
begin
  path.Text:=RParseFn(path.Text);
end;

procedure TForm1.procDir(fn: TLFn);
var
  SR: TSearchRec;
begin
  //ParseFn(fn);
  Caption:=fn;
  if FindFirst(IncludeTrailingBackslash(fn) + '*.*', faAnyFile or faDirectory, SR) = 0 then
    try
      repeat
        if (SR.Attr and faDirectory) = 0 then
          procFile(SR.Name)
        else if (SR.Name <> '.') and (SR.Name <> '..') then
          procDir(IncludeTrailingBackslash(fn) + SR.Name);  // recursive call!
      until FindNext(Sr) <> 0;
    finally
      //FindClose(SR);
    end;
end;

procedure TForm1.procFile(fn: TLFn);
var
  i: Integer;
begin
  //ParseFn(fn);
  for i:=0 to Length(tpl)-1 do
    if tpl[i].regexpr.Exec(fn) then
      files.Items.Values[fn]:=tpl[i].usage;
end;

end.

