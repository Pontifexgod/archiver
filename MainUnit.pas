unit MainUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Dialogs, Menus, ComCtrls,
  ExtCtrls, UnitAbout, FileUtil, LazFileUtils, Zipper, Controls, LazUTF8, LConvEncoding, SettingsUnit, Registry;

const DefaultExt = '.zip';
      ApplicationName = 'Archivator';
      RegKeyName='Software\MyCompanyName\'+ ApplicationName +'\';

type
  TFileInfo = record
    Directory: TFileName;
    FileName: TFileName;
    Size: longint;
    DateTime:TDateTime;
  end;

  PFileInfo = ^TFileInfo;
  TFileList = TList;

  { TFormMain }

  TFormMain = class(TForm)
    FilesList: TListView;
    MainMenu1: TMainMenu;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    MenuItem5: TMenuItem;
    MenuItemSaveArchiveAs: TMenuItem;
    MenuItemDecompressAllFiles: TMenuItem;
    MenuItemDecompressSelected: TMenuItem;
    MenuItemCreateArchive: TMenuItem;
    MenuItemDelete: TMenuItem;
    MenuItemAddDirectory: TMenuItem;
    MenuItemSaveArchive: TMenuItem;
    MenuItemSettings: TMenuItem;
    MenuItemAppendFile: TMenuItem;
    MenuItemAbout: TMenuItem;
    MenuItemOpenArchive: TMenuItem;
    MenuItemExit: TMenuItem;
    OpenDialog1: TOpenDialog;
    Panel1: TPanel;
    ProgressBar1: TProgressBar;
    SaveDialog1: TSaveDialog;
    SelectDirectoryDialog1: TSelectDirectoryDialog;
    StatusBar1: TStatusBar;
    AutoSaveTimer: TTimer;
    procedure AutoSaveTimerTimer(Sender: TObject);
    procedure FilesListDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure FilesListEndDrag(Sender, Target: TObject; X, Y: Integer);
    procedure FilesListSelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
    procedure FilesListStartDrag(Sender: TObject; var DragObject: TDragObject);
    procedure FormActivate(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure FormCreate(Sender: TObject);
    procedure MenuItemAddDirectoryClick(Sender: TObject);
    procedure MenuItemDecompressAllFilesClick(Sender: TObject);
    procedure MenuItemCompressDirectoryClick(Sender: TObject);
    procedure MenuItemAppendFileClick(Sender: TObject);
    procedure MenuItemAboutClick(Sender: TObject);
    procedure MenuItemCreateArchiveClick(Sender: TObject);
    procedure MenuItemDecompressSelectedClick(Sender: TObject);
    procedure MenuItemDeleteClick(Sender: TObject);
    procedure MenuItemExitClick(Sender: TObject);
    procedure MenuItemOpenArchiveClick(Sender: TObject);
    procedure MenuItemSaveArchiveAsClick(Sender: TObject);
    procedure MenuItemSaveArchiveClick(Sender: TObject);
    procedure MenuItemSettingsClick(Sender: TObject);
    procedure TreeView1SelectionChanged(Sender: TObject);
  private
    currentfilecounter, totalfilescounter:integer;
    function GetDirectory(const FileName: string):TStringList;
    procedure SaveArchive(const FileName: string);
    procedure OpenArchiveFile(FileName:TFileName);
    procedure AddFile(fn:TFileName);
    procedure SetStatus;
    procedure SetCaptionAndArchiveFileName(FileName:TFilename);
    procedure ProgressHandler(Sender : TObject; Const Pct: Double);
    procedure RepackFiles(const FileName: string);
    function SaveArchiveIfChanged:boolean;
    function UnPackFiles(Filename, UnPackPath: String): Integer;
  public

  end;

var
  FormMain: TFormMain;
  ArchiveFileName: TFileName = ''; // Имя и путь файла текущего архива
  ArchiveChanged:Boolean=False; // Признак изменённого архива
  AutoSaveEnabled:Boolean=False;

implementation

{$R *.lfm}

{ TFormMain }

function TFormMain.GetDirectory(const FileName: string):TStringList;

var
  sr: TSearchRec;
  path: TFileName;
  files: TStringList;

begin
  path := IncludeTrailingPathDelimiter(FileName);
  files:=TStringList.Create;
  // Сначала ищем папки
  if FindFirstUTF8(path + '*.*', faDirectory, sr) = 0 then
  try
    repeat
      if (sr.Name = '.') or (sr.Name = '..') or
         (sr.Attr and faDirectory <> faDirectory) then Continue;
      // Нашли Folder - вызываем рекурсивно GetDir
      files.AddStrings(GetDirectory(path + sr.Name));
    until FindNextUTF8(sr) <> 0;
  finally
    FindCloseUTF8(sr);
  end;
  // теперь - файлы
  if FindFirstUTF8(path + '*.*', faAnyFile, sr) = 0 then
  try
    repeat
      if (sr.Name = '.') or (sr.Name = '..') or
         (sr.Attr and faDirectory = faDirectory) then Continue;
      // Нашли файл - просто добавляем его
       files.Add(path + sr.Name);
    until FindNextUTF8(sr) <> 0;
  finally
    FindCloseUTF8(sr);
  end;
  Result:=Files;
end;

procedure TFormMain.MenuItemAddDirectoryClick(Sender: TObject);
var FullFileName:TFileName;
    node : TTreeNode;
    sl:TStringList;
    i:integer;
begin
  SelectDirectoryDialog1.Title:='Выбор папки для добавления в архив';
  if SelectDirectoryDialog1.Execute then
  begin
    FullFileName:=SelectDirectoryDialog1.FileName;
    sl:=GetDirectory(FullFileName);
    for i:=0 to sl.Count -1 do
    begin
      AddFile(sl[i]);
    end;
    SetStatus;
  end;
end;

procedure TFormMain.MenuItemDecompressAllFilesClick(Sender: TObject);
begin
  FilesList.SelectAll;
  MenuItemDecompressSelectedClick(Sender);
end;

procedure TFormMain.FilesListDragDrop(Sender, Source: TObject; X, Y: Integer);
begin

end;

procedure TFormMain.AutoSaveTimerTimer(Sender: TObject);
begin
  if AutoSaveEnabled and ArchiveChanged then
     MenuItemSaveArchiveClick(nil);
end;

procedure TFormMain.FilesListEndDrag(Sender, Target: TObject; X, Y: Integer);
begin

end;

procedure TFormMain.SetStatus;
begin
  MenuItemDecompressAllFiles.Enabled:=FilesList.Items.Count > 0;
  MenuItemSaveArchiveAs.Enabled:=FilesList.Items.Count > 0;
  MenuItemSaveArchive.Enabled:=ArchiveChanged;
  MenuItemDecompressSelected.Enabled:=FilesList.Selected <> nil;
  MenuItemDelete.Enabled:=FilesList.Selected <> nil;
end;

procedure TFormMain.FilesListSelectItem(Sender: TObject; Item: TListItem;
  Selected: Boolean);
begin
  SetStatus;
end;

procedure TFormMain.FilesListStartDrag(Sender: TObject;
  var DragObject: TDragObject);
begin

end;

procedure TFormMain.FormActivate(Sender: TObject);
begin
  SetStatus;
end;

procedure TFormMain.FormClose(Sender: TObject; var CloseAction: TCloseAction);
  var reg:TRegistry;
      i, j:integer;
begin
  reg := TRegistry.Create(KEY_WRITE);
  reg.RootKey := HKEY_CURRENT_USER;
  reg.Access := KEY_WRITE;
  if reg.OpenKey(regkeyname, true) then
  begin
    reg.WriteInteger('Top', Top);
    reg.WriteInteger('Left', Left);
    reg.WriteInteger('Width', Width);
    reg.WriteInteger('Height', Height);
    reg.WriteBool('AutoSave', AutoSaveEnabled);
    reg.CloseKey;
  end;
end;

procedure TFormMain.FormCloseQuery(Sender: TObject; var CanClose: boolean);
begin
   CanClose:=SaveArchiveIfChanged;
end;

procedure TFormMain.FormCreate(Sender: TObject);
var reg:TRegistry;
begin
  reg := TRegistry.Create(KEY_READ);
  reg.RootKey := HKEY_CURRENT_USER;
  if reg.KeyExists(regkeyname) and reg.OpenKey(regkeyname, false) then
  begin
    Top:=reg.ReadInteger('Top');
    Left:=reg.ReadInteger('Left');
    Width:=reg.ReadInteger('Width');
    Height:=reg.ReadInteger('Height');
    AutoSaveEnabled:=reg.ReadBool('AutoSave');
    reg.CloseKey;
  end;
end;

procedure TFormMain.MenuItemCompressDirectoryClick(Sender: TObject);
begin
  if SelectDirectoryDialog1.Execute then
//    CompressDirectory(SelectDirectoryDialog1.FileName, True, SelectDirectoryDialog1.FileName+DefaultExt);
end;

procedure TFormMain.AddFile(fn:TFileName);
var
   li: TListItem;
begin
  // Заполнение списка свойств файла
  li:=FilesList.Items.Add;
  li.Caption:=ExtractFileName(fn);
  li.SubItems.Add(IntToStr(FileSize(fn)));
  li.SubItems.Add(DateTimeToStr(FileDateToDateTime(FileAge(fn))));
  li.SubItems.Add(ExtractFilePath(fn));
  li.SubItems.Add(fn);
  li.SubItems.Add(''); // Файл локальный
  ArchiveChanged:=True;
  AutoSaveTimer.Enabled:=False;
  AutoSaveTimer.Enabled:=True;
  SetStatus;
end;

procedure TFormMain.MenuItemAppendFileClick(Sender: TObject);
var i:integer;
begin
  OpenDialog1.FilterIndex:=1;
  OpenDialog1.Title:='Выбор файла для добавления в архив';
  If OpenDialog1.Execute then
    for i:=0 to OpenDialog1.Files.Count-1 do
        AddFile(OpenDialog1.Files[i]);
end;

procedure TFormMain.MenuItemAboutClick(Sender: TObject);
begin
  formabout.showmodal;
end;

function TFormMain.SaveArchiveIfChanged:boolean;
var mr:TModalResult;
begin
  if ArchiveChanged then
  begin
    mr:= MessageDlg('Запрос на сохранение архива', 'Архив был изменён, сохранить?',
    mtConfirmation, mbYesNoCancel, 0);
    case mr of
         mrYes: MenuItemSaveArchiveClick(nil);
         mrNo:  begin
                  Result:=True;
                  exit;
                end;
    end;
  end;
  Result:=not ArchiveChanged;
end;

procedure TFormMain.MenuItemCreateArchiveClick(Sender: TObject);
begin
  if SaveArchiveIfChanged then
  begin
    FilesList.ClearSelection;
    FilesList.Clear;
    ArchiveFileName:='';
    Caption:=ApplicationName;
    ArchiveChanged:=False;
    SetStatus;
  end;
end;

function EndPathCP866ToUTF8(AText:string):string;
var
  c,i:integer;
  s,s1,s2,chr:string;
begin
  s:='';
  c:=UTF8Length(AText);
  for i:=c downto 1 do
  begin
       chr:=UTF8Copy(AText,i,1);
       if ((not(chr='/')) and (not(chr='\')))or(i=c) then
       begin
            s:=UTF8Copy(AText,i,1)+s;
       end
       else begin
            s:=UTF8Copy(AText,i,1)+s;
            break;
       end;
  end;
  dec(i);
  s1:=UTF8Copy(AText,1,i);
  s2:=CP866ToUTF8(s);
  Result:=s1+s2;
end;

procedure TFormMain.ProgressHandler(Sender : TObject; Const Pct: Double);
begin
  Progressbar1.Position := Round(((pct + currentfilecounter)/totalfilescounter) * 100);
  ProgressBar1.Update;
  Application.ProcessMessages;
end;


procedure TFormMain.MenuItemDecompressSelectedClick(Sender: TObject);
var i:integer;
    fn:TFileName;
    uz:TUnZipper;
    AArchiveFileName, ADiskFileName, ANewDiskFileName, UnPackFileDir:string;

begin
  SelectDirectoryDialog1.Title:='Выбор папки для распаковки выбранных файлов';
  if (FilesList.Selected <> nil) and SelectDirectoryDialog1.Execute then
  begin
    uz:=TUnZipper.Create;
    try
      uz.OnProgress:=@ProgressHandler;
      uz.OnPercent:=1;
      ProgressBar1.Position:=0;
      ProgressBar1.Visible:=True;
      uz.FileName:=ArchiveFileName;
      uz.OutputPath:=SelectDirectoryDialog1.FileName;
      totalfilescounter:=FilesList.SelCount;
      currentfilecounter:=1;
      for i:=0 to FilesList.Items.Count - 1 do
          if FilesList.Items[i].Selected then
          begin
              fn := UTF8ToCP866(FilesList.Items[i].SubItems[3]);
              AArchiveFileName:=fn;
              uz.UnZipFile(fn);
              inc(currentfilecounter);
              AArchiveFileName:=EndPathCP866ToUTF8(AArchiveFileName);
              AArchiveFileName:=UTF8ToSys(AArchiveFileName);
              UnPackFileDir :=SysUtils.IncludeTrailingPathDelimiter(uz.OutputPath);
              ADiskFileName   :=UnPackFileDir+fn;
              ANewDiskFileName:=uz.OutputPath+ExtractFileName(AArchiveFileName);
              if FileExists(ADiskFileName) then
              begin
                 RenameFileUTF8(ADiskFileName, ANewDiskFileName);
                 RemoveDir(ExtractFilePath(ADiskFileName));
              end
              else if DirectoryExists(ADiskFileName) then
              begin
                 ADiskFileName    :=SysUtils.IncludeTrailingPathDelimiter(ADiskFileName);
                 ANewDiskFileName :=SysUtils.IncludeTrailingPathDelimiter(ANewDiskFileName);
                 RenameFile(ADiskFileName, ANewDiskFileName);
              end;
          end;
    finally
      ProgressBar1.Visible:=False;
      uz.Free;
    end;
  end;
end;

procedure TFormMain.MenuItemDeleteClick(Sender: TObject);
var i:integer;
begin
  if FilesList.Selected <> nil then
  begin
    for i:=FilesList.Items.Count - 1 downto 0 do
      if FilesList.Items[i].Selected then
      begin
        FilesList.Items[i].Delete;
        ArchiveChanged:=True;
        AutoSaveTimer.Enabled:=False;
        AutoSaveTimer.Enabled:=True;
      end;
    SetStatus;
  end;
end;

procedure TFormMain.MenuItemExitClick(Sender: TObject);
begin
  application.Terminate;
end;

procedure TFormMain.SetCaptionAndArchiveFileName(FileName:TFilename);
begin
  ArchiveFileName:=FileName;
  Caption:=ApplicationName + ' - [' + ExtractFileName(ArchiveFileName) + ']';
end;

procedure TFormMain.OpenArchiveFile(FileName:TFileName);
var
  B, LastPos: Byte;
  S: string;
  Count: Integer;
  Buffer: array [0..1023] of Byte;
  TotalByteCount: Longword;
  WriteMe: Boolean;
  FileStreamSize, StreamSize: Int64;
  fd, kz: string;
  unZipper: TUnZipper;
  li: TListItem;
  i:integer;
  Size, CompressedSize: int64;
begin
  FilesList.Items.Clear;
  try
      SetCaptionAndArchiveFileName(FileName);
      unZipper := TUnZipper.Create;
      unZipper.FileName := FileName;
      unZipper.Examine;
      for i:=0 to unZipper.Entries.Count - 1 do
      begin
        S:=CP866ToUTF8(unZipper.Entries[i].ArchiveFileName);
        if not unZipper.Entries[i].IsDirectory then
        begin
            li:=FilesList.Items.Add;
            li.Caption:=ExtractFileName(S);
            Size:=unZipper.Entries[i].Size;
            CompressedSize:=unZipper.Entries[i].CompressedSize;
            if size <> 0 then kz:=' (' + IntToStr(Round(CompressedSize * 100 / Size)) +'%)'
                         else kz:='';
            li.SubItems.Add(IntToStr(Size) + ' / ' + IntToStr(CompressedSize) + kz);
            li.SubItems.Add(DateTimeToStr(unZipper.Entries[i].DateTime));
            li.SubItems.Add('['+ExtractFileName(FileName)+']');
            li.SubItems.Add(S); // Полный путь
            li.SubItems.Add('*'); // Файл в архиве
        end;
      end;
    finally
      unZipper.Free;
    end;
end;

procedure TFormMain.MenuItemOpenArchiveClick(Sender: TObject);
begin
  if SaveArchiveIfChanged then
  begin
    OpenDialog1.FilterIndex:=2;
    OpenDialog1.Title:='Открытие архива';
    If OpenDialog1.Execute then
    begin
      OpenArchiveFile(OpenDialog1.FileName);
    end;
    SetStatus;
  end;
end;

function TFormMain.UnPackFiles(Filename, UnPackPath: String): Integer;
var
  UnZipper          :TUnZipper; //PasZLib
  UnPackFileDir,
  ADiskFileName,
  ANewDiskFileName,
  AArchiveFileName  :String;
  i                 :integer;
begin
  Result:=-1;
  if FileExists(Filename)and DirectoryExists(UnPackPath) then
  begin
       UnPackFileDir :=SysUtils.IncludeTrailingPathDelimiter(UnPackPath);
       UnZipper      :=TUnZipper.Create;
       try
          UnZipper.FileName   := Filename;
          UnZipper.OutputPath := UnPackPath;
          UnZipper.OnProgress:=@ProgressHandler;
          UnZipper.OnPercent:=1;
          ProgressBar1.Position:=0;
          ProgressBar1.Visible:=True;
          totalfilescounter:=1;
          currentfilecounter:=1;
          UnZipper.Examine;
          UnZipper.UnZipAllFiles;
          for i:=UnZipper.Entries.Count-1 downto 0 do
          begin
              AArchiveFileName:=UnZipper.Entries.Entries[i].ArchiveFileName;
              AArchiveFileName:=EndPathCP866ToUTF8(AArchiveFileName);
              AArchiveFileName:=UTF8ToSys(AArchiveFileName);
              ANewDiskFileName:=UnPackFileDir+AArchiveFileName;
              ADiskFileName   :=UnPackFileDir+UnZipper.Entries.Entries[i].DiskFileName;
              if FileExists(ADiskFileName) then
              begin
                 RenameFile(ADiskFileName, ANewDiskFileName);
              end
              else if DirectoryExists(ADiskFileName) then
              begin
                 ADiskFileName    :=SysUtils.IncludeTrailingPathDelimiter(ADiskFileName);
                 ANewDiskFileName :=SysUtils.IncludeTrailingPathDelimiter(ANewDiskFileName);
                 RenameFile(ADiskFileName, ANewDiskFileName);
              end;
          end;
          Result:=1;
       finally
          UnZipper.Free;
          ProgressBar1.Visible:=False;
       end;
  end;
end;

procedure TFormMain.RepackFiles(const FileName: string);
var fn:TFileName;
    Zipper : TZipper;
    i:integer;
    fe:TZipFileEntry;
begin
  begin
    fn:=GetTempFileName(GetTempDir,'Arc');
    CreateDir(fn);
    // Распаковка файлов во временную папку
    UnPackFiles(ArchiveFileName, fn);
    // Архивация файлов из временной папки
    try
      Zipper := TZipper.Create;
      Zipper.FileName := FileName;
      Zipper.OnProgress:=@ProgressHandler;
      Zipper.OnPercent:=1;
      ProgressBar1.Position:=0;
      ProgressBar1.Visible:=True;
      totalfilescounter:=1;
      currentfilecounter:=1;
      for i:=0 to FilesList.Items.Count-1 do
      begin
        if FilesList.Items[i].SubItems[4] ='' then // Локальный файл
        begin
          fe:=Zipper.Entries.AddFileEntry(FilesList.Items[i].SubItems[3]);
        end
        else // Файл из архива находится во временной папке
        fe:=Zipper.Entries.AddFileEntry(fn + DirectorySeparator + FilesList.Items[i].SubItems[3]);
        fe.ArchiveFileName:=UTF8ToCP866(ExtractFileName(FilesList.Items[i].Caption));
      end;
      Zipper.ZipAllFiles;
    finally
        Zipper.Free;
        ProgressBar1.Style:=pbstMarquee;
//          SetCaptionAndArchiveFileName(FileName);
    end;
    // Удаление временной папки
    DeleteDirectory(fn, False);
  end;
end;

procedure TFormMain.SaveArchive(const FileName: string);
var zipper:TZipper;
    uz:TUnZipper;
    i:integer;
    fn:TFileName;
    fe:TZipFileEntry;
    AllFilesLocal, AllFilesinArchive:boolean;
begin
    AllFilesLocal:=true;
    AllFilesinArchive:=true;
    // Проверим, все ли файлы находятся на локальных дисках
    for i:=0 to FilesList.Items.Count-1 do
      if FilesList.Items[i].SubItems[4] ='' then
         AllFilesinArchive:=false
      else AllFilesLocal:=false;
    // Ни один файл не находится в архиве
    if AllFilesLocal then
    try
      Zipper := TZipper.Create;
      Zipper.FileName := FileName;
      Zipper.OnProgress:=@ProgressHandler;
      Zipper.OnPercent:=1;
      ProgressBar1.Position:=0;
      ProgressBar1.Visible:=True;
      totalfilescounter:=FilesList.Items.Count;
      for i:=0 to FilesList.Items.Count-1 do
      begin
        currentfilecounter:=i + 1;
        fe:=Zipper.Entries.AddFileEntry(FilesList.Items[i].SubItems[3]);
        fe.ArchiveFileName:=UTF8ToCP866(ExtractFileName(FilesList.Items[i].Caption));
      end;
      Zipper.ZipAllFiles;
    finally
        Zipper.Free;
        SetCaptionAndArchiveFileName(FileName);
        ProgressBar1.Visible:=False;
    end;
    // Все файлы только в архиве
    if AllFilesinArchive and ArchiveChanged then // Состав файлов в архиве изменился, надо перепаковывать
        RepackFiles(FileName);
    if AllFilesinArchive and (FileName<>ArchiveFileName) and not ArchiveChanged then
      // Все файлы в архиве и не изменялись, не надо перепаковывать
      begin
        ProgressBar1.Visible:=True;
        ProgressBar1.Style:=pbstMarquee;
        ProgressBar1.Position:=50;
        CopyFile(ArchiveFileName, FileName); // Просто копируем архив
        ProgressBar1.Visible:=False;
        ProgressBar1.Style:=pbstNormal;
      end;
    if not (AllFilesinArchive or AllFilesLocal) then
    // Перепаковка файлов через временную папку
      RepackFiles(FileName);
    OpenArchiveFile(FileName);
    ProgressBar1.Visible:=False;
    ProgressBar1.Style:=pbstNormal;
    ArchiveChanged:=False;
    SetStatus;
end;

procedure TFormMain.MenuItemSaveArchiveClick(Sender: TObject);
begin
  if ArchiveFileName = '' then
     MenuItemSaveArchiveAsClick(Sender)
  else SaveArchive(ArchiveFileName);
end;

procedure TFormMain.MenuItemSettingsClick(Sender: TObject);
begin
  SettingsForm.AutoSaveCheckBox.Checked:=AutoSaveEnabled;
  if SettingsForm.ShowModal = mrOk then
  begin
    AutoSaveEnabled:=SettingsForm.AutoSaveCheckBox.Checked;
  end;
end;

procedure TFormMain.MenuItemSaveArchiveAsClick(Sender: TObject);
begin
  SaveDialog1.Title:='Сохранение архива';
  If SaveDialog1.Execute then
    SaveArchive(SaveDialog1.FileName);
end;

procedure TFormMain.TreeView1SelectionChanged(Sender: TObject);
var info: TFileInfo;
    pinfo:PFileInfo;
    filelist:TFileList;
    i:integer;
    li:TListItem;

begin
end;

end.

