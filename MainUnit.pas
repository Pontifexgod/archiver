unit MainUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, Menus, UnitAbout;

type

  { TFormMain }

  TFormMain = class(TForm)
    MainMenu1: TMainMenu;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItemSettings: TMenuItem;
    MenuItemAppent: TMenuItem;
    MenuItemAbout: TMenuItem;
    MenuItemOpenArchive: TMenuItem;
    MenuItemExit: TMenuItem;
    OpenDialog1: TOpenDialog;
    procedure FormCreate(Sender: TObject);
    procedure MenuItem2Click(Sender: TObject);
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

  end;
end;

end.

