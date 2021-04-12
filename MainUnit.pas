unit MainUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, Menus, ComCtrls, Grids,
  StdCtrls, UnitAbout;

const DefaultExt = '.zlb';

type

  { TFormMain }

  TFormMain = class(TForm)
    ListView1: TListView;
    MainMenu1: TMainMenu;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    MenuItemCreateArchive: TMenuItem;
    MenuItemDelete: TMenuItem;
    MenuItemAddDirectory: TMenuItem;
    MenuItem6: TMenuItem;
    MenuItemSaveArchive: TMenuItem;
    MenuItemCompressDirectory: TMenuItem;
    MenuItemSettings: TMenuItem;
    MenuItemAppent: TMenuItem;
    MenuItemAbout: TMenuItem;
    MenuItemOpenArchive: TMenuItem;
    MenuItemExit: TMenuItem;
    OpenDialog1: TOpenDialog;
    SelectDirectoryDialog1: TSelectDirectoryDialog;
    TreeView1: TTreeView;
    procedure FormCreate(Sender: TObject);
    procedure MenuItem2Click(Sender: TObject);
    procedure MenuItemCompressDirectoryClick(Sender: TObject);
    procedure MenuItemAppentClick(Sender: TObject);
    procedure MenuItemSettingsClick(Sender: TObject);
    procedure MenuItemAboutClick(Sender: TObject);
    procedure MenuItemExitClick(Sender: TObject);
    procedure MenuItemOpenArchiveClick(Sender: TObject);
  private

  public

  end;

var
  FormMain: TFormMain;

implementation

{$R *.lfm}

{ TFormMain }

procedure TFormMain.FormCreate(Sender: TObject);
begin

end;

procedure TFormMain.MenuItem2Click(Sender: TObject);
begin

end;

procedure TFormMain.MenuItemCompressDirectoryClick(Sender: TObject);
begin
  if SelectDirectoryDialog1.Execute then
    CompressDirectory(SelectDirectoryDialog1.FileName, True, SelectDirectoryDialog1.FileName+DefaultExt);
end;

procedure TFormMain.MenuItemAppentClick(Sender: TObject);
begin
  If OpenDialog1.Execute then
  begin

  end;
end;

procedure TFormMain.MenuItemSettingsClick(Sender: TObject);
begin

end;

procedure TFormMain.MenuItemAboutClick(Sender: TObject);
begin
  formabout.showmodal;
end;

procedure TFormMain.MenuItemExitClick(Sender: TObject);
begin
  application.Terminate;
end;

procedure TFormMain.MenuItemOpenArchiveClick(Sender: TObject);
begin
  If OpenDialog1.Execute then
  begin
    DecompressFile(OpenDialog1.FileName,'./', True, True);
  end;
end;

end.

