unit SettingsUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, Buttons;

type

  { TSettingsForm }

  TSettingsForm = class(TForm)
    AutoSaveCheckBox: TCheckBox;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
  private

  public

  end;

var
  SettingsForm: TSettingsForm;

implementation

{$R *.lfm}

end.

