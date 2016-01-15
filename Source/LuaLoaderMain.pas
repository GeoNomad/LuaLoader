unit LuaLoaderMain;

//  LuaLoader http://benlo.com/esp8266  https://github.com/GeoNomad/LuaLoader/

//  LuaLoader uses the SerialNG component included in the package
//  SerialNG is open source GNU licensed as of 2002
//  The component needs to be installed before compiling this code.
//
//  This is the Delphi 4 version. Changes may be required for porting to other versions of Delphi.
//
//  LuaLoaderMain.pas is open source MIT License, but the SerialNG component has its separate license
//
//  netstat.pas is not included, comment out lines containing net. or replace with your own net.geturl function
//     geturl is not necessary for functionality - just for checking latest versions, etc.
//
//  const ThisVersion  is set below

//  TODO - add tmr.stop on restart automatically, also resume higher baud rate

//  0.90 manually add a COM port that is not detected automatically  + user OpenKeyReadOnly to get W10 HARDWARE key
//  0.90 change to ini files instead of registry
//  0.89 removed Hard Restart and Soft Restart messages which appeared out of sequence and confused
//  0.88 allow more baud rates, fix the reset to 9600
//  0.87 set default DTR and RTS on each connect

//  0.86 changed the default value of DTR and RTS to false = HI
//  0.86 updated latest firmware URL to github/releases
//  0.86 fixed upload all .lua files bug (uploading .lua.bak)
//  0.86 added right click to Read - set autoread repeat rate

//  0.85 fix bug in upload all aborting
//  0.85 added download binary
//  0.95 added compile button
//  0.85 added do(lc) button - executes lc version of selected .lua file

//  0.84 fixed bug in < Upload all .lua files (! and < were included)

//  0.83 check for new ports when opening dialog (no need to restart LL)
//  0.83 add Upload all .lua files
//  0.83 add Custom button to execute short lua file from PC

//  0.82 add Upload all changed files command to filename dropdown list
//  0.82 add ! to mark recently changed files in filename dropdown list
//  0.82 tell user if there is a new NodeMCU firmware version available
//  0.82 dofile('LLbin.lua') automatically after upload
//  0.82 right click DTR and RTS to set defaults at startup

//  0.81 add check mark on recently accessed documentation
//  0.81 automatically load LLbin.lua if missing
//  0.81 changed net.ShowURL to ShowURL in several places

//  0.80 Add 'Remove Current Workspace' to Workspace menu
//  0.80 Fixed bug in file list after remove
//  0.80 Added more error handling on failed binary transfers

//  0.79 binary upload option
//  0.79 run file.list if needed when looking at FilenameE

//  0.78 add filter options to file list drop down menu (right click)

//  0.77 Hide Restart Garbage default changed to off
//  0.77 removed dofile() at end of load
//  0.77 added wifi.setmode(wifi.STATIONAP) to [Survey]

//  0.76 added link to buy NodeMCU boards

//  0.75 added read ADC input to [Read] button and autorepeat

//  0.74 Added DTR and RTS output control
//  0.74 Added CTS input monitor

//  0.73 fix crash on illegal com port names
//  0.73 fix changed restart name (NodeMcu became NodeMCU) affecting Hide Garbage setting
//  0.73 added file.format() button [Format]

//  0.72 improve file.list formatting
//  0.72 add [remove all] button
//  0.72 add Help - Local Documentation - opens files or shortcuts in a local folder

//  0.71 reformatted [survey] button
//  0.71 updated link to latest firmware

//  0.70 fixed = node.heap() after upload
//  0.70 fixed version grab with newer format

//  0.69 Revised GPIO pin numbers
//  0.69 Added bit module to Help menu

//  0.68 fixed high comm port numbers to 255
//  0.68 fast uploads automatically uses 921600 if checked
//  0.68 color the baud rate if disconnected
//  0.68 refactored the Help menu
//  0.68 fixed check for Logging turned on in .Log

//  0.67 fixed bug in getting long file lists from the board
//  0.67 color scheme skin

//  0.66 added Workspaces to File menu - added by uploading a file
//  0.66 Try except around log file writing

//  0.65 fixed random characters in entry window
//  0.65 tmr.stop menu - right click to choose 0 to 7 timers
//  0.65 Changed parsing of api document revision date

//  0.64 [Load] file list populated with Working Directory contents (*.lua)

//  0.63 Send history in text edit

//  0.62 reconnect COM port automatically after bin reflash

//  0.61 log time stamps for Hard restart and soft restart
//  0.61 added Wifi status button
//  0.61 automatically revert to 9600 baud on connection errors (usually restart)

//  0.6 upload with no echo
//  0.6 set baud rate for communications
//

//  0.55 date stamp in log file each time [dofile] click
//  Tools menu - download latest firmware, flasher
//  Added 75000 to baud rate list   - search for baudrate if problems...
//  Allow non-standard baud rates as text entry

//  0.54 tmr.stop() - timers 0 and 1 on click and upload
//

//  0.53 View Log  (file association must be set for .log)
//  0.53 Edit button (file association must be set for .lua)

//  0.52 added PULLUP support

//  0.51
//  one line GPIO monitoring
//  start with crlf to show prompt
//  logging fixed

//   0.5 GPIO read


interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,SerialNG,
  StdCtrls, ExtCtrls, ComCtrls, ImgList, Buttons, URLLabel, ClipBrd, Registry,
  Menus, ShellAPI, SuperTimer, Math, IniFiles;

type
  TForm1 = class(TForm)
    SerialPortNG1: TSerialPortNG;
    OpenDialog1: TOpenDialog;
    MainMenu1: TMainMenu;
    File1: TMenuItem;
    Help1: TMenuItem;
    NodeMcuLua1: TMenuItem;
    Lua1: TMenuItem;
    LuaLoaderUpdates1: TMenuItem;
    N2: TMenuItem;
    Luainminutes1: TMenuItem;
    BugReports1: TMenuItem;
    BuyESP8266Boards1: TMenuItem;
    Settings1: TMenuItem;
    CommPortSettings1: TMenuItem;
    SaveSettings1: TMenuItem;
    LoadSavedSettings1: TMenuItem;
    Panel1: TPanel;
    Panel2: TPanel;
    SSID: TEdit;
    Password: TEdit;
    SetAPBtn: TButton;
    Panel3: TPanel;
    FileListBtn: TButton;
    FilenameE: TComboBox;
    DoFileBtn: TButton;
    RemoveBtn: TButton;
    CatBtn: TButton;
    UploadBtn: TButton;
    UploadFileBtn: TButton;
    SendFileBtn: TButton;
    SendBtn: TButton;
    PasteBtn: TButton;
    Terminal: TMemo;
    ClearBtn: TButton;
    Panel4: TPanel;
    NodeHeapBtn: TButton;
    ChipIDBtn: TButton;
    TmrStop: TButton;
    StatusBar: TStatusBar;
    APSurveyBtn: TButton;
    GetIPBtn: TButton;
    DisconnectBtn: TButton;
    ConnectM: TMenuItem;
    GroupBox1: TGroupBox;
    GPIO: TComboBox;
    SetMode: TButton;
    ReadBtn: TButton;
    HighBtn: TButton;
    LowBtn: TButton;
    LuaBooksM: TMenuItem;
    LogTerminalM: TMenuItem;
    SaveTerminalM: TMenuItem;
    SaveDialog1: TSaveDialog;
    N3: TMenuItem;
    LuaReferenceManual1: TMenuItem;
    N4: TMenuItem;
    Connect1: TMenuItem;
    ConnectedStatusTimer: TSuperTimer;
    Autorepeat: TSpeedButton;
    RepeatTimer: TTimer;
    LuaUsersWikiiCodeSamples1: TMenuItem;
    N5: TMenuItem;
    HideRestartGarbageM: TMenuItem;
    Mode1: TComboBox;
    Mode2: TComboBox;
    ViewLog1: TMenuItem;
    N6: TMenuItem;
    EditBtn: TSpeedButton;
    Tools1: TMenuItem;
    Downloadlatestfirmware1: TMenuItem;
    DownloadESP8266Flasherexe1: TMenuItem;
    Runesp8266flasherexe1: TMenuItem;
    N8: TMenuItem;
    Tutorialonflashing1: TMenuItem;
    NurdSpaceLuaReference1: TMenuItem;
    GPIOrateM: TMenuItem;
    WifiStatusBtn: TSpeedButton;
    ResetBaudTimer: TSuperTimer;
    SendEdit: TComboBox;
    AutoResetBaudRateM: TMenuItem;

    tmrM: TPopupMenu;
    tmrstop01: TMenuItem;
    tmrstop11: TMenuItem;
    tmrstop21: TMenuItem;
    tmrstop31: TMenuItem;
    tmrstop41: TMenuItem;
    tmrstop51: TMenuItem;
    tmrstop61: TMenuItem;
    Checkall1: TMenuItem;
    CheckNone1: TMenuItem;

    N7: TMenuItem;
    Workspace: TMenuItem;
    c1: TMenuItem;
    DownloadNodeMcuesp8266flasherexe1: TMenuItem;
    FixFilename: TSuperTimer;
    CommPanel: TGroupBox;
    BaudRate: TComboBox;
    FastUp: TMenuItem;
    NodeMCUFirmware1: TMenuItem;
    NodeMCULuaFirmwaregithub1: TMenuItem;
    NodeMCUFlasher1: TMenuItem;
    N9: TMenuItem;
    ESP82661: TMenuItem;
    EspressifSystems1: TMenuItem;
    ESP8266WikiReference1: TMenuItem;
    ESP8266Flasher1: TMenuItem;
    ESP8266Forum1: TMenuItem;
    LuaLanguage1: TMenuItem;
    About1: TMenuItem;
    LuaFAQ1: TMenuItem;
    LuaGotchas1: TMenuItem;
    Node1: TMenuItem;
    FileModule1: TMenuItem;
    WifiModule1: TMenuItem;
    TimerModule1: TMenuItem;
    GPIOModule1: TMenuItem;
    PWMModule1: TMenuItem;
    NetModule1: TMenuItem;
    I2CModule1: TMenuItem;
    ADCModule1: TMenuItem;
    UARTModule1: TMenuItem;
    OneWireModule1: TMenuItem;
    esp8266ForumLuaLanguage1: TMenuItem;
    N1: TMenuItem;
    Quit1: TMenuItem;
    BitModule: TMenuItem;
    APIOverviewandChangeLog1: TMenuItem;
    LocalM: TMenuItem;
    LocalSM: TMenuItem;
    RestartBtn: TSpeedButton;
    FormatBtn: TButton;
    DTRbtn: TSpeedButton;
    RTSbtn: TSpeedButton;
    CTSbtn: TSpeedButton;
    BuyNodeMCUdevelopmentboards1: TMenuItem;
    QuickStartforBeginners1: TMenuItem;
    UploadMenu: TPopupMenu;
    ESPLua: TMenuItem;
    WSLua: TMenuItem;
    N10: TMenuItem;
    UseBin: TMenuItem;
    BinM: TPopupMenu;
    UploadBinary1: TMenuItem;
    UploadText1: TMenuItem;
    OpenMenu: TPopupMenu;
    OpenWorkspaceFolderinExplorer1: TMenuItem;
    DTRm: TPopupMenu;
    Setcurrentvalueasstartupdefault1: TMenuItem;
    Custom: TButton;
    CustomPopup: TPopupMenu;
    Resetfunctionality1: TMenuItem;
    Compile: TButton;
    DownLoadBtn: TButton;
    DoFileCompiled: TButton;
    DLDecoder: TSuperTimer;
    ListlcM: TMenuItem;
    ListallM: TMenuItem;
    ReadRateM: TPopupMenu;
    Setrepeatrateforread1: TMenuItem;
    NodeMCUCustomBuilds1: TMenuItem;
    procedure AdvSettingsBtnClick(Sender: TObject);
    procedure SerialPortNG1RxClusterEvent(Sender: TObject);
    procedure SerialPortNG1ProcessError(Sender: TObject; Place,Code: DWord; Msg: String);
    procedure SendBtnClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure SerialPortNG1RxCharEvent(Sender: TObject);
    procedure SerialPortNG1TxQueueEmptyEvent(Sender: TObject);
    procedure SaveSettingsBtnClick(Sender: TObject);
    procedure SerialPortNG1CommStat(Sender: TObject);
    procedure SerialPortNG1WriteDone(Sender: TObject);
    procedure SendFileBtnClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure GetIPBtnClick(Sender: TObject);
    procedure SetAPBtnClick(Sender: TObject);
    procedure UploadFileBtnClick(Sender: TObject);
    procedure DoFileBtnClick(Sender: TObject);
    procedure TmrStopClick(Sender: TObject);
    procedure APSurveyBtnClick(Sender: TObject);
    procedure NodeHeapBtnClick(Sender: TObject);
    procedure RestartBtnClick(Sender: TObject);
    procedure RemoveBtnClick(Sender: TObject);
    procedure ChipIDBtnClick(Sender: TObject);
    procedure FileListBtnClick(Sender: TObject);
    procedure ClearBtnClick(Sender: TObject);
    procedure TerminalKeyPress(Sender: TObject; var Key: Char);
    procedure PasteBtnClick(Sender: TObject);
    procedure CatBtnClick(Sender: TObject);
    procedure LuaLoaderUpdates1Click(Sender: TObject);
    procedure ShowURL( URL : string);
    procedure NodeMcuLua1Click(Sender: TObject);
    procedure ESP8266Forum1Click(Sender: TObject);
    procedure Lua1Click(Sender: TObject);
    procedure Espressif1Click(Sender: TObject);
    procedure Luainminutes1Click(Sender: TObject);
    procedure BugReports1Click(Sender: TObject);
    procedure WikiReference1Click(Sender: TObject);
    procedure BuyESP8266Boards1Click(Sender: TObject);
    procedure UploadBtnClick(Sender: TObject);
    procedure Settings1Click(Sender: TObject);
    procedure ConnectMClick(Sender: TObject);
    procedure SetModeClick(Sender: TObject);
    procedure ReadBtnClick(Sender: TObject);
    procedure LowBtnClick(Sender: TObject);
    procedure HighBtnClick(Sender: TObject);
    procedure DisconnectBtnClick(Sender: TObject);
    procedure LuaBooksMClick(Sender: TObject);
    procedure LogTerminalMClick(Sender: TObject);
    procedure SaveTerminalMClick(Sender: TObject);
    procedure NodeMCULuaFirmware1Click(Sender: TObject);
    procedure LuaReferenceManual1Click(Sender: TObject);
    procedure NodeMCUFlasher1Click(Sender: TObject);
    procedure Connect1Click(Sender: TObject);
    procedure ConnectedStatusTimerTimer(Sender: TObject);
    procedure AutorepeatClick(Sender: TObject);
    procedure RepeatTimerTimer(Sender: TObject);
    procedure LuaUsersWikiiCodeSamples1Click(Sender: TObject);
    procedure ESP8266Flasher1Click(Sender: TObject);
    procedure HideRestartGarbageMClick(Sender: TObject);
    procedure ViewLog1Click(Sender: TObject);
    procedure EditBtnClick(Sender: TObject);
    procedure Downloadlatestfirmware1Click(Sender: TObject);
    procedure DownloadESP8266Flasherexe1Click(Sender: TObject);
    procedure Runesp8266flasherexe1Click(Sender: TObject);
    procedure BaudRateChange(Sender: TObject);
    procedure SaveSettings1Click(Sender: TObject);
    procedure NurdSpaceLuaReference1Click(Sender: TObject);
    procedure GPIOrateMClick(Sender: TObject);
    procedure WifiStatusBtnClick(Sender: TObject);
    procedure ResetBaudTimerStop(Sender: TObject);
    procedure AutoResetBaudRateMClick(Sender: TObject);
    procedure FilenameEDropDown(Sender: TObject);
    procedure tmrstop01Click(Sender: TObject);
    procedure WSMenuClick(Sender: TObject);
    procedure DownloadNodeMcuesp8266flasherexe1Click(Sender: TObject);
    procedure FilenameEExit(Sender: TObject);
    procedure FilenameEClick(Sender: TObject);
    procedure FixFilenameStop(Sender: TObject);
    procedure FastUpClick(Sender: TObject);
    procedure LuaFAQ1Click(Sender: TObject);
    procedure LuaGotchas1Click(Sender: TObject);
    procedure About1Click(Sender: TObject);
    procedure Node1Click(Sender: TObject);
    procedure FileModule1Click(Sender: TObject);
    procedure WifiModule1Click(Sender: TObject);
    procedure TimerModule1Click(Sender: TObject);
    procedure GPIOModule1Click(Sender: TObject);
    procedure PWMModule1Click(Sender: TObject);
    procedure NetModule1Click(Sender: TObject);
    procedure I2CModule1Click(Sender: TObject);
    procedure ADCModule1Click(Sender: TObject);
    procedure UARTModule1Click(Sender: TObject);
    procedure OneWireModule1Click(Sender: TObject);
    procedure Quit1Click(Sender: TObject);
    procedure BitModuleClick(Sender: TObject);
    procedure APIOverviewandChangeLog1Click(Sender: TObject);
    procedure ESP8266WikiReference1Click(Sender: TObject);
    procedure DeleteAllClick(Sender: TObject);
    procedure LocalMClick(Sender: TObject);
    procedure LocalSMClick(Sender: TObject);
    procedure FormatBtnClick(Sender: TObject);
    procedure ShowHint(Sender: TObject);
    procedure DTRbtnClick(Sender: TObject);
    procedure RTSbtnClick(Sender: TObject);
    procedure CTSbtnClick(Sender: TObject);
    procedure BuyNodeMCUdevelopmentboards1Click(Sender: TObject);
    procedure QuickStartforBeginners1Click(Sender: TObject);
    procedure ESPLuaClick(Sender: TObject);
    procedure WSLuaClick(Sender: TObject);
    procedure UseBinClick(Sender: TObject);
    procedure UploadBinary1Click(Sender: TObject);
    procedure UploadText1Click(Sender: TObject);
    procedure WorkspaceClick(Sender: TObject);
    procedure Checkall1Click(Sender: TObject);
    procedure CheckNone1Click(Sender: TObject);
    procedure OpenWorkspaceFolderinExplorer1Click(Sender: TObject);
    procedure Setcurrentvalueasstartupdefault1Click(Sender: TObject);
    procedure CustomClick(Sender: TObject);
    procedure Resetfunctionality1Click(Sender: TObject);
    procedure CompileClick(Sender: TObject);
    procedure DoFileCompiledClick(Sender: TObject);
    procedure DownLoadBtnClick(Sender: TObject);
    procedure DecodeDL(Sender: TObject);
    procedure ListlcMClick(Sender: TObject);
    procedure ListallMClick(Sender: TObject);
    procedure NodeMCUCustomBuilds1Click(Sender: TObject);
  private
    { Private declarations }
    RxDCharStartTimer : Boolean;
    RxDCharResetTimer : Boolean;
    SendDataSize : DWord;
    procedure CheckLLVersion(Sender: TObject; filename : string; error : word);
    procedure Log(line : string);
    procedure Send(line : string; mode : integer);
    procedure Show(line : string; mode : integer);
    function  AwaitPrompt(delay : integer) : boolean;
    procedure ActivateSerial(Sender: TObject);
  public
    { Public declarations }
    function Upload(fname : string) : boolean ;
  end;

var
  Form1: TForm1;
  StartTime : double;
  GetFileNames : Boolean;
  GetFileBuf   : string;
  WorkingDir   : string;
  Version      : string;
  LogFile      : string;
  LatestNodeMCU : string;
  LatestLUA     : string;
  APIrevision   : string;

  VersionData   : string;
  
  HideRestartGarbage : boolean;
  FlasherPath   : string;
  Prompt        : boolean;
  Timeoutc      : integer;
  okc           : integer;
  SoftRestart   : boolean;
  CheckWiFiStatus : boolean;
  SendHistory   : TStringList;
  WasConnected  : boolean;
  LocalDocs     : string;
  FilesOnESP    : TStringList;
  StartingBin   : Boolean;
  LLBinNil      : Boolean;
  CannotOpen    : Boolean;
  DoingBin      : Boolean;

  xxdNil        : Boolean;
  DoingDL       : Boolean;
  StartingDL    : Boolean;
  CannotOpenxxd : Boolean;

AbortUnexpected : Boolean;

  DTRdefault    : Boolean;
  RTSdefault    : Boolean;

RecentDocFiles  : TStringList;
RecentFiles     : TStringList;
DLCapture       : string;
CustomLuaFile   : string;

const
  ThisVersion  = '0.90 ';                 // change with each version
  CRLF         = #$0d#$0a ;

implementation

uses SerialNGAdv, netstat; // Include Advanced Dialog


{$R *.DFM}
procedure AddHexString(S : String; Lines : TStrings );
var AddS, HexS, CopyS : String;
    i : Integer;
const SLen = 8;
begin
  while Length(S) > 0 do
    begin
      AddS := Copy(S,1,SLen);
      HexS := '';
      Delete(S,1,SLen);
      for i := 1 to SLen do
        begin
          CopyS := Copy(AddS,i,1);
          if CopyS <> '' then
            HexS := HexS + ' ' + Format('%2.2x',[Byte(CopyS[1])]) //
          else
            HexS := HexS + '   ';
        end;
       while Length(AddS) < SLen do
         AddS := AddS + ' ';
       for i := 1 to SLen do
         case AddS[i] of
           #0..#31 : AddS[i] := '.';
           #127    : AddS[i] := '.';
         end;
       Lines.Add(HexS+' : '+AddS);
    end;
end;

procedure pause( delay : integer );
var
t : double;
begin
t := Now + delay/(24*60*60*1000);
while ( Now < t ) do
   begin
   Application.ProcessMessages();
   end;
end;

function CommName : string;
var
port : string;
begin
port := Form1.SerialPortNG1.CommPort;
try
if port[1] <> '\' then
   begin
   result := port;
   exit;
   end;
result := Copy(port,5,99);
except;
result := '';
end;
end;

function FileTime( filename : string) : integer;
var
F : TSearchRec;
begin
if FileExists(filename) then
   begin
   FindFirst(filename,faAnyFile,F);
   Result := F.Time;
   FindClose(F);
   end
else
   Result := 0;
end;

procedure TForm1.FormCreate(Sender: TObject);
var
Regx : TIniFile;
timers : string;
i,n : integer;
ws : string;
MenuI : TMenuItem;
Temp : TStringList;
rtime : integer;
rfile : string;
begin
SerialPortNG1.Active := True;
HideRestartGarbage   := False;
WasConnected         := False;
StartingBin          := False;
DoingBin             := False;

Application.OnHint := ShowHint;
Application.HintHidePause := 5000;
Application.HintPause := 200;

SendHistory := TStringList.Create;

FilesOnESP  := TStringList.Create;
FilesOnESP.Sorted := True;
FilesOnESP.Duplicates := dupIgnore;
FilesOnESP.Add('< Run file.list to add ESP files');

RecentDocFiles := TStringList.Create;
RecentDocFiles.Sorted := True;
RecentDocFiles.Duplicates := dupIgnore;

RecentFiles := TStringList.Create;
RecentFiles.Sorted := True;
RecentFiles.Duplicates := dupIgnore;

Caption := 'ESP8266 LuaLoader '+ThisVersion;

Regx       := TIniFile.Create( ChangeFileExt(ParamStr(0),'.ini') );
Top        := Regx.ReadInteger('LuaLoader','Top',Top);
Left       := Regx.ReadInteger('LuaLoader','Left',Left);
Width      := Regx.ReadInteger('LuaLoader','Width',Width);
Height     := Regx.ReadInteger('LuaLoader','Height',Height);
WorkingDir := Regx.ReadString('LuaLoader','WorkingDir',ExtractFilePath(ParamStr(0)));

EditBtn.Hint := 'Edit '+workingDir+FilenameE.Text;
UploadBtn.Hint := 'Upload '+ workingDir+FilenameE.Text;

GPIO.Text      := Regx.ReadString('LuaLoader','GPIO',' 3 GPIO0');
SSID.Text      := Regx.ReadString('LuaLoader','SSID','SSID');
Password.Text  := Regx.ReadString('LuaLoader','Password','Password');
LogFile        := Regx.ReadString('LuaLoader','LogFile','');
FlasherPath    := Regx.ReadString('LuaLoader','FlasherPath','c:\esp8266_flasher.exe');
LocalDocs      := Regx.ReadString('LuaLoader','LocalDocumentation','');
LatestLua      := Regx.ReadString('LuaLoader','LatestLua','');

HideRestartGarbageM.Checked :=  Regx.ReadBool('LuaLoader','HideRestartGarbage',False);
LogTerminalM.Checked        :=  Regx.ReadBool('LuaLoader','Logging',False);
AutoResetBaudRateM.Checked  :=  Regx.ReadBool('LuaLoader','AutoResetBaudRate',True);
FastUp.Checked              :=  Regx.ReadBool('LuaLoader','FastUploads',False);

DTRdefault                  :=  Regx.ReadBool('LuaLoader','DTRdefault',False);
RTSdefault                  :=  Regx.ReadBool('LuaLoader','RTSdefault',False);

ESPLua.Checked              :=  Regx.ReadBool('LuaLoader','ESPLuaOnly',True);
WSLua.Checked               :=  Regx.ReadBool('LuaLoader','WSLuaOnly',True);
UseBin.Checked              :=  Regx.ReadBool('LuaLoader','BinaryUpload',False);
if UseBin.Checked then
   begin
   UploadBtn.Caption := 'Upload Bin';
   UploadBinary1.Checked := True;
   UploadText1.Checked := False;
   end
else
   begin
   UploadBtn.Caption := 'Upload Text';
   UploadBinary1.Checked := False;
   UploadText1.Checked := True;
   end;


timers := Regx.ReadString('LuaLoader','Timers','TTFFFFF');
for i := 1 to 7 do
   begin
   TmrM.Items[i-1].Checked := timers[i] = 'T';
   end;
Regx.WriteString('LuaLoader','Timers',timers);

for i := 0 to 25 do
   begin
   ws := Regx.ReadString('LuaLoader','Workspace'+IntToStr(i),'');
   if (ws <> '') and (ws <> 'c:\') then
      begin
      MenuI := TMenuItem.Create(self);
      MenuI.Caption := ws;
      MenuI.OnClick := WSMenuClick;
      Workspace.Insert(0,MenuI);
      end;
   end;

Custom.Caption :=  Regx.ReadString('LuaLoader','CustomButton','Custom');
CustomLuaFile  :=  Regx.ReadString('LuaLoader','CustomLuaFile','');
Regx.Free;

if LogTerminalM.Checked and (LogFile = '') then
   LogTerminalM.Checked := False;
   
BaudRate.ItemIndex := 0;
SoftRestart := False;
CheckWiFiStatus := False;

if FileExists(ExtractFilePath(ParamStr(0))+'RecentFiles.txt') then
   begin
   Temp := TStringList.Create;
   Temp.LoadFromFile(ExtractFilePath(ParamStr(0))+'RecentFiles.txt');
   for i := 0 to Temp.Count-1 do
      begin
      rtime := StrToIntDef(Copy(Temp[i],1,12),0);
      rfile := Copy(Temp[i],14,999);
      n := RecentFiles.Add(rfile);
      RecentFiles.Objects[n] := TObject(rtime);
      end;
   Temp.Free;
   end;
end;

procedure TForm1.ShowHint(Sender : TObject);
begin
if Length(FilenameE.Text) > 1 then
   RemoveBtn.Hint := 'Delete '+FilenameE.Text
else
   RemoveBtn.Hint := 'Delete file';
LowBtn.Hint := 'Set pin '+GPIO.Text+' Output Low';
HighBtn.Hint := 'Set pin '+GPIO.Text+' Output High';
end;

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
var
Regx : TIniFile;
i : integer;
timers : string;
Temp : TStringList;
begin
ConnectedStatusTimer.Enabled := False;
net.TimeOutAbort.Enabled := False;

//Action := caFree;
SerialPortNG1.WriteSettings('Software\Benlo.com','LuaLoader');
SerialPortNG1.Active := False;

Regx := TIniFile.Create( ChangeFileExt(ParamStr(0),'.ini') );
Regx.WriteInteger('LuaLoader','Top',Top);
Regx.WriteInteger('LuaLoader','Left',Left);
Regx.WriteInteger('LuaLoader','Width',Width);
Regx.WriteInteger('LuaLoader','Height',Height);
Regx.WriteString('LuaLoader','WorkingDir',WorkingDir);
Regx.WriteString('LuaLoader','GPIO',GPIO.Text);
Regx.WriteString('LuaLoader','SSID',SSID.Text);
Regx.WriteString('LuaLoader','Password',Password.Text);
Regx.WriteString('LuaLoader','LogFile',LogFile);
Regx.WriteString('LuaLoader','FlasherPath',FlasherPath);
Regx.WriteString('LuaLoader','LocalDocumentation',LocalDocs);
Regx.WriteString('LuaLoader','LatestLua',LatestLua);
Regx.WriteString('LuaLoader','CustomButton',Custom.Caption);
Regx.WriteString('LuaLoader','CustomLuaFile',CustomLuaFile);

Regx.WriteBool('LuaLoader','Logging',LogTerminalM.Checked);
Regx.WriteBool('LuaLoader','HideRestartGarbage',HideRestartGarbageM.Checked);
Regx.WriteBool('LuaLoader','AutoResetBaudRate',AutoResetBaudRateM.Checked);
Regx.WriteBool('LuaLoader','FastUploads',FastUp.Checked);
Regx.WriteBool('LuaLoader','DTRdefault',DTRdefault);
Regx.WriteBool('LuaLoader','RTSdefault',RTSdefault);
Regx.WriteBool('LuaLoader','ESPLuaOnly',ESPLua.Checked);
Regx.WriteBool('LuaLoader','WSLuaOnly', WSLua.Checked);
Regx.WriteBool('LuaLoader','BinaryUpload', UseBin.Checked);
//  Halt(1);

timers := 'TTFFFFF';
for i := 0 to 6 do
   begin
   if TmrM.Items[i].Checked then
      timers[i+1] := 'T'
   else
      timers[i+1] := 'F';
   end;
Regx.WriteString('LuaLoader','Timers',timers);

for i := 0 to min(25,Workspace.Count-1) do
   begin
   if Workspace.Items[i].caption <> 'Remove Current Workspace' then
      Regx.WriteString('LuaLoader','Workspace'+IntToStr(i),Workspace.Items[i].caption);
   end;

Regx.Free;

Temp := TStringList.Create;
for i := 0 to RecentFiles.Count-1 do
   begin
   Temp.Add( Format('%12.12d %s',[Integer(RecentFiles.Objects[i]),RecentFiles[i]]) );
   end;
Temp.SaveToFile(ExtractFilePath(ParamStr(0))+'RecentFiles.txt');
Temp.Free;
end;


procedure TForm1.FormShow(Sender: TObject);
var
i : integer;
begin
Net.StatusBar        := False;
SerialPortNG1.ReadSettings('Software\Benlo.com','LuaLoader');
i := BaudRate.Items.IndexOf(IntToStr(SerialPortNG1.BaudRate));
if i >= 0 then
   BaudRate.ItemIndex := i
else
   BaudRate.Text := IntToStr(SerialPortNG1.BaudRate);
SerialPortNG1.DTRState      :=  DTRdefault;
SerialPortNG1.RTSState      :=  RTSdefault;

Net.GetURL('http://benlo.com/esp8266/LuaLoader.php?LL=1&api=1&version='+ThisVersion,CheckLLVersion);
Send(CRLF,1);
end;

procedure TForm1.ActivateSerial(Sender: TObject);
begin
SerialPortNG1.Active := True;
SerialPortNG1.DTRState      :=  DTRdefault;
SerialPortNG1.RTSState      :=  RTSdefault;
end;

procedure TForm1.ShowURL( URL : string);
begin
ShellExecute( Application.Handle,'open', PChar(URL), PChar(URL), nil, SW_SHOWNORMAL);
end;

procedure TForm1.Log(line : string);
var
f    : textfile;
begin
if LogTerminalM.Checked then
    begin
    try
    AssignFile(f, LogFile);
    if not FileExists(LogFile) then
       begin
       Rewrite(f);
       end
    else
       begin
       Append(f);
       end;
    Write(f, line);
    Flush(f);
    CloseFile(f);
    except
    ShowMessage('Error writing to log file:'#13#13+LogFile);
    end
    end;
end;

procedure TForm1.Send(line : string; mode : integer);       // sends to comm and logs
begin
if SerialPortNG1.Active then
   begin
   SerialPortNG1.SendString(line);
   Log(line);
   if mode = 1 then pause(200);
   end
else
   begin
   Show('Not connected to comm port',1);
   end;
end;

procedure TForm1.Show(line : string; mode : integer);       // types on terminal and logs
begin
if mode = 1 then Terminal.Lines.Add('');
Terminal.Lines.Add(line);
if mode = 1 then Terminal.Lines.Add('');
Log(line);
end;

procedure TForm1.AdvSettingsBtnClick(Sender: TObject);
begin
  try
  SerialNGAdvDLG.SetDLGData(SerialPortNG1);
  if SerialNGAdvDLG.ShowModal = mrOK then
    SerialNGAdvDLG.GetDLGData(SerialPortNG1);
  except
  ShowMessage('Error loading COM dialog!');
  end;
end;

// All receiving is done here
// See how less Lines!
procedure TForm1.SerialPortNG1RxClusterEvent(Sender: TObject);
var
line : string;
x, y : integer;
newf : string;
DL : TStringList;
begin
  if SerialPortNG1.NextClusterSize >= 0 then // Data available?
    begin
      if SerialPortNG1.NextClusterCCError = 0 then // Error during receiveing?
      else
          begin
          Show('Communications Error - Check baud rate',1);
          if AutoResetBaudRateM.Checked then
             ResetBaudTimer.Enabled := True;
          end;
    line :=  SerialPortNG1.ReadNextClusterAsString;

    if Pos('€',line) > 0 then
        begin
        Show('Communications Error - Check baud rate',1);
        if AutoResetBaudRateM.Checked then
           ResetBaudTimer.Enabled := True;
        end;


    if CheckWifiStatus then
       begin
       x := Pos('>',line);
       if x > 0 then
          begin
          y := StrToIntDef(Copy(line,x-3,1),6);
          case y of
                    0: line := stringreplace(line,'0','0 IDLE',[]);
                    1: line := stringreplace(line,'1','1 CONNECTING',[]);
                    2: line := stringreplace(line,'2','2 INCORRECT PASSWORD',[]);
                    3: line := stringreplace(line,'3','3 AP NOT FOUND',[]);
                    4: line := stringreplace(line,'4','4 CONNECT FAILED',[]);
                    5: line := stringreplace(line,'5','5 GOT IP',[]);
             end;
          end;
       WifiStatusBtn.Down := False;
       CheckWiFiStatus := False;
       end;
    if StartingBin then
       begin
       if Pos('LLbin'' (a nil',line) > 0 then
          LLBinNil := True;
       if Pos('cannot open LLbin.lua',line) > 0 then
          CannotOpen := True;
       end;

    if DoingBin then
       begin
       if Pos('unexpected symbol',line) > 0 then
          begin
          AbortUnexpected := True;
          UploadBtn.Caption := 'Upload Bin';  // aborts bin when caption was Abort
          Show(CRLF+'Binary upload requires NodeMCU build 20150105 or newer'+CRLF,1);
          end;
       end;

    if StartingDL then
       begin
       if Pos('xxd'' (a nil',line) > 0 then
          begin
          xxdNil := True;
          DoingDL := False;
          end;
       if Pos('cannot open xxd.lua',line) > 0 then
          CannotOpenxxd := True;
       end;

    if DoingDL then
       begin
       DLCapture := DLCapture + line;
       if Pos('EOF',line) > 0 then
          begin
          DL := TStringList.Create;
          DL.Add(DLCapture);
          DL.SaveToFile(ExtractFilePath(ParamStr(0))+'xxd.temp');
          DL.Free;
          DLCapture := '';
          DoingDL := False;
          DLDecoder.Enabled := True;
          end;
       end;

    if 0 < Pos('>',line) then
       begin
       Prompt := True;
       end;

    if RepeatTimer.Enabled then
       begin
       x := Pos(CRLF+'>', line);
       Delete(line,x,4);
       end;

    if HideRestartGarbage then
       begin
       x := Pos('MCU',UpperCase(line));
       if x > 0 then
          begin
          Delete(line,1,x-5);
          HideRestartGarbage := False;
          end
        else line := '';
        end;
    Terminal.Text := Terminal.Text + line;
    SendMessage(Terminal.Handle, EM_LINESCROLL, 0,Terminal.Lines.Count); // scroll to end

    if GetFileNames then
        begin
        GetFileBuf := GetFileBuf + line;
        if Pos('for k,v',GetFileBuf) > 0 then Delete(GetFileBuf,1,Pos('for k,v',GetFileBuf));
        if Pos(') end',GetFileBuf) > 0 then Delete(GetFileBuf,1,Pos(') end',GetFileBuf));
        if Pos(')'#$D#$A'>',GetFileBuf) > 0 then Delete(GetFileBuf,1,Pos(')'#$D#$A'>',GetFileBuf)+3);
        if  Pos('>',GetFileBuf) > 0 then
            begin
            x := Pos(CRLF+CRLF,GetFileBuf);
            if x > 0 then Delete(GetFileBuf,1,x+1);
            repeat
                begin
                x := Pos(CRLF,GetFileBuf);
                if x > 0 then Delete(GetFileBuf,1,x+1);
                y := Pos('  ',GetFileBuf);
                if y > 0 then newf := Trim(Copy(GetFileBuf,1,y-1));
                if (Length(newf) > 0) and (newf <> '>') then
                   begin
                   FilesOnESP.Add('< '+newf);
                   end;
                Delete(GetFileBuf,1,y);
                end;
            until x = 0;
            GetFileBuf := '';
            GetFileNames := False;
            end;
        end;
    if LogTerminalM.Checked then
       begin
       Log(line);
       end;
    if (0 < Pos('NODEMCU ',UpperCase(line))) and  (0 < Pos('owered by Lua',line)) then
       begin
       line := Trim(Copy(line,9,Length(LatestNodeMCU)));
//       if not SoftRestart then
//           begin
//           Show('Hard Restart '+FormatDateTime('dddddd  hh:nn:ss',Now),1);
//           end;
       SoftRestart := False;
       if line < Trim(LatestNodeMCU) then
          begin
          Show('FYI: NodeMcu '+LatestNodeMCU+' is available',1);
          end;
       StatusBar.SimpleText := VersionData;
       end;
    end;

end;

function TForm1.AwaitPrompt(delay : integer) : boolean;   // delay in milliseconds
var
timeout : double;
begin
//timeout := Now+ 1/(24*60*60*4);  // 1/4 second
timeout := Now + delay/(24*60*60*1000);
Prompt := False;
while (not Prompt) and (Now < timeout) do Application.ProcessMessages();
result := Now < timeout;
if result then
   begin
   inc(okc);
   Pause(100);
   end
else inc (timeoutc)
end;



procedure TForm1.SendBtnClick(Sender: TObject);
var
SendStr : String;
begin
SendStr := SendEdit.Text +CRLF;
SendDataSize := Length(SendStr);
SendBtn.Enabled := False;

Send(SendStr,0);
//SerialPortNG1.SendString(SendStr);

if Length(SendEdit.Text) > 2 then
   begin
   SendEdit.Items.insert(0,SendEdit.Text);
   if SendEdit.Items.Count > 10 then
      SendEdit.Items.Delete(SendEdit.Items.Count-1);
   end;
SendEdit.Text := '';
end;

procedure TForm1.SerialPortNG1RxCharEvent(Sender: TObject);
begin
//  LedImageList.GetBitmap(LedGreenOn,RxDImage.Picture.Bitmap);
//  RxDImage.Repaint;
  RxDCharStartTimer := True;
  RxDCharResetTimer := False;
end;

procedure TForm1.SerialPortNG1TxQueueEmptyEvent(Sender: TObject);
begin
//  LedImageList.GetBitmap(LedGreenOff,TxDImage.Picture.Bitmap);
//  TxDImage.Repaint;
end;

procedure TForm1.SaveSettingsBtnClick(Sender: TObject);
begin
  SerialPortNG1.WriteSettings('Software\Benlo.com','LuaLoader');
end;

procedure TForm1.SerialPortNG1CommStat(Sender: TObject);
var s: String;
begin
  s := '';
  if fCtlHold in SerialPortNG1.CommStateFlags then
    begin
      s := s + 'Transmission is waiting for the CTS (clear-to-send) signal to be sent.'+CRLF;
    end
  else
  if fDsrHold in SerialPortNG1.CommStateFlags then
    begin
      s := s + 'Transmission is waiting for the DSR (data-set-ready) signal to be sent.'+CRLF;
    end
  else
  if fRlsHold in SerialPortNG1.CommStateFlags then
    begin
      s := s + 'Transmission is waiting for the RLSD (receive-line-signal-detect) signal.'+CRLF;
    end
  else
  if fXoffHold in SerialPortNG1.CommStateFlags then
    begin
      s := s + 'Transmission is waiting because the XOFF character was received.'+CRLF;
    end
  else
  if fXoffSent in SerialPortNG1.CommStateFlags then
    begin
      s := s + 'Transmission is waiting because the XOFF character was transmitted.'+CRLF;
    end
  else
  if fEof in SerialPortNG1.CommStateFlags then
    s := s + 'The end-of-file (EOF) character has been received.'+CRLF;
  if fTxim in SerialPortNG1.CommStateFlags then
    s := s + 'There is a character queued for transmission that has come to the communications device by way of the TransmitCommChar function.'+CRLF;
  if s <> '' then
    SerialPortNG1ProcessError(Self, 0000, 0, s);
end;

procedure TForm1.SerialPortNG1WriteDone(Sender: TObject);
begin
  if SerialPortNG1.WrittenBytes <> SendDataSize then
    SerialPortNG1ProcessError(Self, 0001, 0, 'Not all Bytes send');
  SendBtn.Enabled := True;
end;

procedure TForm1.SerialPortNG1ProcessError(Sender: TObject; Place,
  Code: DWord; Msg: String);
begin
//Show(FormatDateTime('"Msg  " dd.mm.yy hh:mm:ss" :"', Now)+Format('Code %d at %d Text: %s',[Code,Place,Msg]));
end;

procedure TForm1.SendFileBtnClick(Sender: TObject);
var SendStr : String;
lines : TStringList;
i : integer;
begin
if not OpenDialog1.Execute then exit;

lines := TStringList.Create;
lines.LoadFromFile(OpenDialog1.Filename);

for i := 0 to lines.Count-1 do
    begin
    SendStr := lines[i];
    SendStr := SendStr+CRLF;
    SendDataSize := Length(SendStr);
    SendBtn.Enabled := False;
    Send(SendStr,1);
//    SerialPortNG1.SendString(SendStr); // Send the String: Thats really all
//    pause(200);
    end;
end;




procedure TForm1.GetIPBtnClick(Sender: TObject);
begin
Send('= wifi.sta.getip()'+CRLF , 1);
//SerialPortNG1.SendString('= wifi.sta.getip()'+CRLF);
end;

procedure TForm1.SetAPBtnClick(Sender: TObject);
begin
Send('wifi.setmode(wifi.STATION)'+CRLF,1);
Send('wifi.sta.config("'+SSID.Text+'","'+Password.Text+'")'+CRLF,1);
end;

function TForm1.Upload(fname : string) : boolean;
var
SendStr : String;
lines : TStringList;
i : integer;
name : string;
newrate : integer;
MenuI : TMenuItem;
addr : integer;
block : integer;
buffer : string;
csum : integer;
f : file of byte;
x : byte;
nbytes : integer;
begin
UploadBtn.Caption := 'Abort';
Result := True;

timeoutc := 0;
okc := 0;
name := extractFileName(fname);
workingDir := ExtractFilePath(fname);
StatusBar.SimpleText := 'Working Directory: '+workingDir;


for i := 0 to Workspace.Count-1 do
   begin
   if Workspace.Items[i].caption = workingDir then break
   end;
if i = Workspace.Count then
   begin
   MenuI := TMenuItem.Create(self);
   MenuI.Caption := workingDir;
   MenuI.OnClick := WSMenuClick;
   Workspace.Insert(0,MenuI);
   end;

if not FileExists(fname) then
   begin
   if UseBin.Checked then UploadBtn.Caption := 'Upload Bin'
   else UploadBtn.Caption := 'Upload Text';
   if Pos('LLbin.lua',fname) = 0 then                   // don't stop all when LLbin.lua asked for
      ShowMessage(fname + ' not found');
   exit;
   end;


FilenameE.Text := name;
FilesOnESP.Add('< '+name);

EditBtn.Hint := 'Edit '+workingDir+FilenameE.Text;
UploadBtn.Hint := 'Upload '+ workingDir+FilenameE.Text;

i := RecentFiles.Add(workingDir+FilenameE.Text);
RecentFiles.Objects[i] := TObject(FileTime(workingDir+FilenameE.Text));
//ShowMessage(workingDir+FilenameE.Text+'$'+IntToStr(FileTime(workingDir+FilenameE.Text)));

newrate := SerialPortNG1.BaudRate;
if FastUp.Checked and (SerialPortNG1.BaudRate <> 921600) then
   begin
   newrate := 921600;
   SerialPortNG1.BaudRate := newrate;
   i := BaudRate.Items.IndexOf(IntToStr(SerialPortNG1.BaudRate));
   if i >= 0 then
      BaudRate.ItemIndex := i
   else
      BaudRate.Text := IntToStr(SerialPortNG1.BaudRate);
   BaudRate.ItemIndex := 8;
   Show('Baud rate changed to '+IntToStr(newrate),1);
   end;

Send('uart.setup(0,'+IntToStr(newrate)+',8,0,1,0)'+CRLF,0);
Pause(300);  // allow command to be sent

SerialPortNG1.BaudRate := newrate;
SerialPortNG1.WriteSettings('Software\Benlo.com','LuaLoader');

AwaitPrompt(2000);
Send('tmr.stop(0)'+CRLF,0);
AwaitPrompt(250);
Send('tmr.stop(1)'+CRLF,0);
AwaitPrompt(250);
Show(FormatDateTime('dddddd  hh:nn:ss',Now),1);

if UseBin.Checked then
    begin
    Show('Binary upload: '+  workingDir+FilenameE.Text,0);
//    Log( 'Binary upload: '+  workingDir+FilenameE.Text);

    StartingBin := True;
    LLBinNil := False;
    Send('LLbin("'+name+'")'+CRLF,1);
    AwaitPrompt(500);
    if LLBinNil then       // LLBin function doesn't exist
       begin
       Send('uart.setup(0,'+IntToStr(SerialPortNG1.BaudRate)+',8,0,1,1)'+CRLF,0);
       AwaitPrompt(500);
       CannotOpen := False;
       Send('dofile("LLbin.lua")'+CRLF,1);      // create LLBin()
       AwaitPrompt(500);
       if CannotOpen then
          begin
          Show('LLbin.lua not found. Installing LLbin.lua...',1);
          if FileExists( ExtractFilePath(ParamStr(0))+'LLbin.lua') then
             begin
             FilenameE.Text := 'LLbin.lua';
             UseBin.Checked := False;
             UploadBtn.Caption := 'Upload Text';
             if Upload(ExtractFilePath(ParamStr(0))+'LLbin.lua') then
                begin
                Send(CRLF,1);
                Send('dofile("LLbin.lua")'+CRLF,1);
                AwaitPrompt(500);
                result := Upload(fname);
                exit;
                end
             else
                begin
                result := False;
                exit;
                end;
             end
          else
             begin
             Show(CRLF+ExtractFilePath(ParamStr(0))+'LLbin.lua not found',1);
             FilenameE.Text := 'LLbin.lua';
             UseBin.Checked := False;
             UploadBtn.Caption := 'Upload Text';
             Send(CRLF,1);
             result := false;
             exit;
             end;
          end;
       result := Upload(fname);
       exit;
       end;
    StartingBin := False;
    DoingBin := True;
    addr := 0;
    block := 1;
    buffer := '';
    csum := 0;
    assignFile(f,fname);
    reset(f);
    nbytes := 0;
    AbortUnexpected := False;
    while( not eof(f) ) do
        begin
        if AbortUnexpected then
           begin
           Show(CRLF+'Aborting upload...',1);
           nbytes := 0;
           break;
           end;
        read(f,x);
        inc(nbytes);
        csum := csum + x;
        buffer := buffer + Format('%02.2X',[x]);
        inc(block);
        if block > 120 then
           begin
           SendStr := Format('%d %s %d',[addr,buffer,csum]);
           Send(SendStr+#$0D,0);
           AwaitPrompt(5000);
           addr := addr + block-1;
           csum := 0;
           buffer := '';
           block := 1;
           end;
        end;
    closefile(f);
    if not AbortUnexpected then
       begin
       SendStr := Format('%d %s %d',[addr,buffer,csum]);
       Send(SendStr+#$0D,0);
       AwaitPrompt(5000);
       end;
    if not AbortUnexpected then
       Send('EOF EOF EOF'+CRLF,1)
    else
       Result := False;
    AbortUnexpected := False;
    AwaitPrompt(5000);
    Send('uart.setup(0,'+IntToStr(SerialPortNG1.BaudRate)+',8,0,1,1)'+CRLF,0);
    Show(IntToStr(nbytes)+' bytes uploaded to '+name,1);
    AwaitPrompt(500);
    Send('= node.heap()'+CRLF,0);
    AwaitPrompt(250);
    StatusBar.SimpleText := 'Timeouts: '+IntToStr(timeoutc)+'  OK: '+IntToStr(okc);
    end
else
    begin
    Show('Text upload: '+  workingDir+FilenameE.Text,1);
//    Log( 'Text upload: '+  workingDir+FilenameE.Text);

    lines := TStringList.Create;
    lines.LoadFromFile(fname);
    Send('file.remove( "'+name+'" )'+CRLF,0);
    AwaitPrompt(250);
    Send('file.open( "'+name+'" , "w" )'+CRLF,0);
    AwaitPrompt(250);
    nbytes := 0;
    for i := 0 to lines.Count-1 do
        begin
        if Pos('Upload',UploadBtn.Caption) > 0 then
           begin
           break;
           end;
        SendStr := 'file.writeline([['+lines[i]+']])'+CRLF;
        nbytes := nbytes + Length(lines[i])+1;
        if SerialPortNG1.BaudRate < 70000 then
           AwaitPrompt(2000)
        else
           AwaitPrompt(250);
        SendDataSize := Length(SendStr);
        SendBtn.Enabled := False;
        Send(SendStr,1);
        end;
    AwaitPrompt(250);
    Send('file.close()'+CRLF,0);
    AwaitPrompt(2000);
    Send('uart.setup(0,'+IntToStr(SerialPortNG1.BaudRate)+',8,0,1,1)'+CRLF,0);
    Show(IntToStr(nbytes)+' bytes uploaded to '+name,1);
    AwaitPrompt(500);
    Send('= node.heap()'+CRLF,0);
    AwaitPrompt(250);
    StatusBar.SimpleText := 'Timeouts: '+IntToStr(timeoutc)+'  OK: '+IntToStr(okc);
    lines.Free;
    end;


{if UploadBtn.Caption = 'Abort' then
    begin
    if mrYes = MessageDlg('DoFile( '+name+' ) now?', mtInformation,[mbYes,mbNo], 0) then
       begin
       DoFileBtnClick(Self);
       end;
    end; }
DoingBin := False;
if Pos('LLbin.lua',FilenameE.Text) > 0 then UseBin.Checked := True;

if UseBin.Checked then UploadBtn.Caption := 'Upload Bin'
else UploadBtn.Caption := 'Upload Text';
end;




procedure TForm1.UploadFileBtnClick(Sender: TObject);
begin
OpenDialog1.Title := 'Choose File to Upload';
OpenDialog1.Filename := workingDir + FilenameE.Text;
OpenDialog1.FilterIndex := 1;
if not OpenDialog1.Execute then
   begin
   if UseBin.Checked then UploadBtn.Caption := 'Upload Bin'
   else UploadBtn.Caption := 'Upload Text';
   exit;
   end;
Upload(OpenDialog1.Filename)
end;




procedure TForm1.DoFileBtnClick(Sender: TObject);
begin
Show('dofile('+FileNameE.Text+')  '+ FormatDateTime('dddddd  hh:nn:ss',Now),1);
Send('dofile("'+FileNameE.Text+'")'+CRLF,1);
end;

procedure TForm1.TmrStopClick(Sender: TObject);
var
i : integer;
begin
for i := 0 to 6 do
   begin
   if TmrM.Items[i].Checked then
      begin
      Send('tmr.stop('+IntToStr(i)+')'+CRLF,1);
      end;
   end;
end;

procedure TForm1.APSurveyBtnClick(Sender: TObject);
begin
Send('wifi.setmode(wifi.STATION) wifi.sta.getap(function(t) if t then print("\n\nVisible Access Points:\n") for k,v in pairs(t) do l = string.format("%-10s",k) print(l.."  "..v) end else print("Try again") end  end)'+CRLF,1);
end;

procedure TForm1.NodeHeapBtnClick(Sender: TObject);
begin
Send('= node.heap()'+CRLF,1);
end;

procedure TForm1.RestartBtnClick(Sender: TObject);
var
i : integer;
begin
RepeatTimer.Enabled := False;
if HideRestartGarbageM.checked then
    begin
    HideRestartGarbage := True;
    Show('node.restart()',1);
    end;

Send('node.restart()'+CRLF,1);

if AutoResetBaudRateM.Checked and (SerialPortNG1.BaudRate <> 9600) then
    begin
    SerialPortNG1.BaudRate := 9600;
    StatusBar.SimpleText := 'Baud rate reduced to 9600';
    i := BaudRate.Items.IndexOf(IntToStr(SerialPortNG1.BaudRate));
    if i >= 0 then
       BaudRate.ItemIndex := i
    else
       BaudRate.Text := IntToStr(SerialPortNG1.BaudRate);
    end;

//Show('Soft Restart '+FormatDateTime('dddddd  hh:nn:ss',Now),1);
SoftRestart := True;
end;

procedure TForm1.RemoveBtnClick(Sender: TObject);
begin
Send('file.remove("'+FileNameE.Text+'")'+CRLF,1);
FileListBtnClick(Self);
end;

procedure TForm1.ChipIDBtnClick(Sender: TObject);
begin
Send('= node.chipid()'+CRLF,1);
end;

procedure TForm1.FileListBtnClick(Sender: TObject);
begin
FilesOnESP.clear;
GetFileNames := True;
GetFileBuf := '';
Send('for k,v in pairs(file.list()) do l = string.format("%-15s",k) print(l.."   "..v.." bytes") end'+CRLF+CRLF,1);
end;

procedure TForm1.ClearBtnClick(Sender: TObject);
begin
Terminal.Text := '';
end;

procedure TForm1.TerminalKeyPress(Sender: TObject; var Key: Char);
begin
if (Key >= ' ') and (Key <= '~') then
   SendEdit.Text := SendEdit.Text + Key;
if Key = #$0D then SendBtn.Click()
end;

procedure TForm1.PasteBtnClick(Sender: TObject);
var
lines : TStringList;
i     : integer;
begin
if Length( Clipboard.AsText) > 0 then
   begin
   lines := TStringList.Create;
   lines.Text := Clipboard.AsText;
   for i := 0 to lines.Count-1 do
      begin
      Send(lines[i]+CRLF,0);
      pause(400);
      end;
   lines.free;
   end;
end;

procedure TForm1.CatBtnClick(Sender: TObject);
begin
Send('print("\n\ncat '+FileNameE.Text+'\n") file.open( "'+FileNameE.Text+'", "r") while true do line = file.readline() if (line == nil) then break end print(string.sub(line, 1, -2)) tmr.wdclr() end file.close()'+CRLF+CRLF,1);
end;

procedure TForm1.LuaLoaderUpdates1Click(Sender: TObject);
begin
ShowURL('http://benlo.com/esp8266/index.html#LuaLoader');
Net.GetURL('http://benlo.com/esp8266/LuaLoader.php?LL=1&version='+ThisVersion,CheckLLVersion);
end;

procedure TForm1.NodeMcuLua1Click(Sender: TObject);
begin
ShowURL('https://github.com/nodemcu/nodemcu-firmware/wiki/nodemcu_api_en');
end;

procedure TForm1.ESP8266Forum1Click(Sender: TObject);
begin
ShowURL('http://www.esp8266.com/viewforum.php?f=17');
end;

procedure TForm1.Lua1Click(Sender: TObject);
begin
ShowURL('http://lua.org');
end;

procedure TForm1.Espressif1Click(Sender: TObject);
begin
ShowURL('https://espressif.com/en/products/esp8266/');
end;

procedure TForm1.Luainminutes1Click(Sender: TObject);
begin
ShowURL('http://learnxinyminutes.com/docs/lua/');
end;

procedure TForm1.BugReports1Click(Sender: TObject);
begin
ShowURL('http://www.benlo.com/comments.html');
end;

procedure TForm1.WikiReference1Click(Sender: TObject);
begin
ShowURL('https://github.com/esp8266/esp8266-wiki/wiki/Pin-definition');
end;

procedure TForm1.BuyESP8266Boards1Click(Sender: TObject);
begin
ShowURL('http://www.benlo.com/shop/shop.php?shop=e&for=ESP8266');
end;


procedure TForm1.LuaBooksMClick(Sender: TObject);
begin
ShowURL('http://www.benlo.com/shop/shop.php?shop=a&for=Programming+in+Lua');
end;

procedure TForm1.UploadBtnClick(Sender: TObject);
begin
if  UploadBtn.Caption = 'Abort' then
   begin
   if UseBin.Checked then UploadBtn.Caption := 'Upload Bin'
   else UploadBtn.Caption := 'Upload Text' ;
   AbortUnexpected := True;
   end
else
   begin
   UploadBtn.Caption := 'Abort';
   Upload( workingDir+FilenameE.Text );
   EditBtn.Hint := 'Edit '+workingDir+FilenameE.Text;
   UploadBtn.Hint := 'Upload '+ workingDir+FilenameE.Text;
   RemoveBtn.Hint := 'Delete '+FilenameE.Text;
   end;
end;

procedure TForm1.Settings1Click(Sender: TObject);
begin
if SerialPortNG1.Active then
   ConnectM.Caption := 'Close '+ CommName
else
   ConnectM.Caption := 'Open '+ CommName;
end;

procedure TForm1.ConnectMClick(Sender: TObject);
begin
if Pos('Open',ConnectM.Caption) = 1 then
   ActivateSerial(Sender)
else
   SerialPortNG1.Active := False;
end;


procedure TForm1.Connect1Click(Sender: TObject);
begin
if Connect1.Caption = 'Connect' then ActivateSerial(Sender)
else SerialPortNG1.Active := False;
end;

procedure TForm1.SetModeClick(Sender: TObject);
var
pin : string;
m1, m2 : string;
begin
pin := Trim(Copy( GPIO.Text,1,3));
m1 := 'gpio.INPUT';
m2 := 'gpio.FLOAT';
if Pos('Pullup',Mode2.Text) > 0 then m2 := 'gpio.PULLUP';
if Pos('Pulldown',Mode2.Text) > 0 then
   begin
   m2 := 'gpio.PULLDOWN';
   Show('WARNING: Pulldown was not implemented as of build 14-12-08',1);
   end;

if Pos('Output',Mode1.Text)    > 0 then
   begin
   m1 := 'gpio.OUTPUT';
   Send('gpio.mode('+pin+','+m1+')'+CRLF,1);
   end;
if Pos('Interrupt',Mode1.Text) > 0 then
   begin
   m1 := 'gpio.INT';
   Send('gpio.mode('+pin+','+m1+','+m2+')'+CRLF,1);
   end;
if Pos('Input',Mode1.Text ) > 0 then
   begin
   Send('gpio.mode('+pin+','+m1+','+m2+')'+CRLF,1);
   end;
end;

procedure TForm1.ReadBtnClick(Sender: TObject);
var
pin : string;
begin
pin := Trim(Copy( GPIO.Text,1,3));
if pin = 'ADC' then
   begin
   Send('print(" "..adc.read(0))'+CRLF,1);
   end
else
   Send('= gpio.read('+pin+')'+CRLF,1);
end;

procedure TForm1.LowBtnClick(Sender: TObject);
var
pin : string;
begin
pin := Trim(Copy( GPIO.Text,1,3));
Send('gpio.write('+pin+',gpio.LOW)'+CRLF,1);
end;

procedure TForm1.HighBtnClick(Sender: TObject);
var
pin : string;
begin
pin := Trim(Copy( GPIO.Text,1,3));
Send('gpio.write('+pin+',gpio.HIGH)'+CRLF,1);
end;

procedure TForm1.DisconnectBtnClick(Sender: TObject);
begin
Send('wifi.sta.disconnect()'+CRLF,1);
end;


procedure TForm1.LogTerminalMClick(Sender: TObject);
begin
LogTerminalM.Checked := not LogTerminalM.Checked;
if LogTerminalM.Checked then
   begin
   SaveDialog1.Title := 'Log Terminal to File';
   SaveDialog1.Options:=SaveDialog1.Options-[ofOverwritePrompt];
   SaveDialog1.Filename := 'LuaLoader.log';
   if SaveDialog1.Execute then
      LogFile := SaveDialog1.Filename;
   end;
end;

procedure TForm1.SaveTerminalMClick(Sender: TObject);
begin
SaveDialog1.Title := 'Save Terminal to File';
SaveDialog1.Options:=SaveDialog1.Options+[ofOverwritePrompt];
if SaveDialog1.Execute then
   begin
   Terminal.Lines.SaveToFile(SaveDialog1.Filename);
   end;
end;

procedure TForm1.CheckLLVersion(Sender: TObject; filename : string; error : word);
var
Items : TStringList;
NewestLL : string;
begin
if not FileExists(filename) or (error > 0) then exit;

Items := TStringList.Create;
Items.LoadFromFile(filename);
DeleteFile(filename);

StatusBar.SimpleText := Items[0];
VersionData := Items[0];
NewestLL := Trim(Copy(VersionData,Pos('version ',VersionData)+8,4));
if ( ThisVersion < NewestLL ) then
   begin
   Show('FYI: LuaLoader version '+NewestLL+' is available for download!',1);
   end;
LatestNodeMCU := Trim(Copy(VersionData, Pos('Latest NodeMCU', VersionData),99));
LatestNodeMCU := Trim(Copy(LatestNodeMCU, 8+Pos('version', LatestNodeMCU),99));
LatestNodeMCU := StringReplace( LatestNodeMCU, '-','', [rfReplaceAll]);

if LatestNodeMCU > LatestLua then
   begin
   Show('NodeMCU Lua firmware '+LatestNodeMCU+' is now available for download',1);
   LatestLua := LatestNodeMCU;
   end;

APIrevision := '';
if Items.Count > 1 then APIrevision := Items[1];
NodeMcuLua1.Caption := 'NodeMCU Lua API '+LatestNodeMCU;
//if length(APIrevision) > 5 then
//   NodeMcuLua1.Caption := NodeMcuLua1.Caption +'  (revised '+APIrevision+ ')' ;
Items.Free;
end;

procedure TForm1.NodeMCULuaFirmware1Click(Sender: TObject);
begin
ShowURL('https://github.com/nodemcu/nodemcu-firmware');
end;

procedure TForm1.LuaReferenceManual1Click(Sender: TObject);
begin
ShowURL('http://www.lua.org/manual/5.1/');
end;

procedure TForm1.NodeMCUFlasher1Click(Sender: TObject);
begin
ShowURL('https://github.com/nodemcu/nodemcu-flasher');
end;


procedure TForm1.ConnectedStatusTimerTimer(Sender: TObject);
begin
if SerialPortNG1.Active then
   begin
   Connect1.Caption := 'Disconnect';
   if not WasConnected then
      Show('Connected to '+ CommName +' at '+ IntToStr(SerialPortNG1.BaudRate) +' baud',1);
   CommPanel.Color := clGreen;
   CommPanel.Caption := CommName;

   if SerialPortNG1.DTRState then
      DTRBtn.Font.Color := clGreen
   else
      DTRBtn.Font.Color := clRed;

   if SerialPortNG1.RTSState then
      RTSBtn.Font.Color := clGreen
   else
      RTSBtn.Font.Color := clRed;

   if SerialPortNG1.CTSState then
      CTSBtn.Font.Color := clGreen
   else
      CTSBtn.Font.Color := clRed;
   end
else
   begin
   Connect1.Caption := 'Connect';
   if WasConnected then
      Show('WARNING! Comm port is disconnected',1);
   CommPanel.Color := clRed;
   DTRBtn.Font.Color := clGray;
   RTSBtn.Font.Color := clGray;
   CTSBtn.Font.Color := clGray;
   CommPanel.Caption := 'Baud Rate';
   end;
WasConnected := SerialPortNG1.Active;
end;

procedure TForm1.AutorepeatClick(Sender: TObject);
begin
repeatTimer.Enabled := not RepeatTimer.Enabled;
AutoRepeat.Down := RepeatTimer.Enabled;
if RepeatTimer.Enabled then
   begin
   Send('uart.setup(0,'+IntToStr(SerialPortNG1.BaudRate)+',8,0,1,0)'+CRLF,0);
   AwaitPrompt(2000);
   Show('Monitoring '+Copy( GPIO.Text, 4,99)+': ',1);
   AwaitPrompt(250);
   end
else
   begin
   Terminal.Lines.Add('');
   Send(CRLF,1);
   AwaitPrompt(250);
   Send('uart.setup(0,'+IntToStr(SerialPortNG1.BaudRate)+',8,0,1,1)'+CRLF,0);
   AwaitPrompt(250);
   end;
end;

procedure TForm1.RepeatTimerTimer(Sender: TObject);
begin
ReadBtnClick(self);
end;

procedure TForm1.LuaUsersWikiiCodeSamples1Click(Sender: TObject);
begin
ShowURL('http://lua-users.org/wiki/');
end;

procedure TForm1.ESP8266Flasher1Click(Sender: TObject);
begin
ShowURL('https://docs.google.com/file/d/0B3dUKfqzZnlwVGc1YnFyUjgxelE/edit');
end;

procedure TForm1.HideRestartGarbageMClick(Sender: TObject);
begin
HideRestartGarbageM.Checked := not HideRestartGarbageM.Checked;
if not HideRestartGarbageM.Checked then
   HideRestartGarbage := False;
end;

procedure TForm1.ViewLog1Click(Sender: TObject);
begin
ShowURL(LogFile);
end;

procedure TForm1.EditBtnClick(Sender: TObject);
begin
ShowURL(workingDir+FilenameE.Text);
EditBtn.Down := False;
end;

procedure TForm1.Downloadlatestfirmware1Click(Sender: TObject);
begin
ShowMessage('Save the latest bin file in the same folder as the flasher app');
ShowURL('https://github.com/nodemcu/nodemcu-firmware/releases');
end;


procedure TForm1.DownloadESP8266Flasherexe1Click(Sender: TObject);
begin
ShowMessage('Download the flasher program zip file'#13'Then, extract the esp8266_flasher.exe program');
ShowURL('https://github.com/nodemcu/nodemcu-flasher');
end;

procedure TForm1.Runesp8266flasherexe1Click(Sender: TObject);
begin
SerialPortNG1.Active := False;
StatusBar.SimpleText := 'Disconnecting from '+CommName;
if not FileExists(FlasherPath) then
   begin
   OpenDialog1.Title := 'Please locate the flasher exe file';
   OpenDialog1.Filename := 'esp8266_flasher.exe';
   OpenDialog1.FilterIndex := 2;
   if OpenDialog1.Execute then
      begin
      FlasherPath := OpenDialog1.FileName;
      OpenDialog1.Title := 'Open File';
      end
   else
      begin
      OpenDialog1.Title := 'Open File';
      exit;
      end;
   end;
ShowURL(FlasherPath);
ShowMessage('LuaLoader has disconnected from the COM port.'#13#13 +
            'Enter the correct COM port on the flasher app.'#13#13 +
            'Click [Config] and locate the correct file (use gear beside 0x00000): (nodemcu_512k.bin)'#13#13 +
            'Uncheck all internal files'#13#13 +
            'Power down the ESP board and connect GPIO0 to ground.'#13#13 +
            'Power up the board'#13#13'[Operation] Click on [Flash(E)] and watch the progress.'#13#13 +
            'When done, disconnect the reflash jumper and power cycle the board.'#13#13 +
            'Click OK to reconnect LuaLoader to the COM port..'#13#13);
ActivateSerial(Sender);
end;

procedure TForm1.BaudRateChange(Sender: TObject);
var
newrate : string;
begin
newrate := Trim(BaudRate.Items[BaudRate.ItemIndex]);
Send('uart.setup(0,'+newrate+',8,0,1,1)'+CRLF,0);
Pause(200);  // allow command to be sent
SerialPortNG1.BaudRate := StrToIntDef(newrate,9600);
AwaitPrompt(1000);
Show('Baud rate changed to '+newrate,1);
Send('= node.heap()'+CRLF,1);
SerialPortNG1.WriteSettings('Software\Benlo.com','LuaLoader');
end;

procedure TForm1.SaveSettings1Click(Sender: TObject);
begin
SerialPortNG1.WriteSettings('Software\Benlo.com','LuaLoader');
end;

procedure TForm1.NurdSpaceLuaReference1Click(Sender: TObject);
begin
ShowURL('https://nurdspace.nl/ESP8266#Technical_Overview');
end;

procedure TForm1.GPIOrateMClick(Sender: TObject);
begin
RepeatTimer.Interval := StrToIntDef(InputBox('Set GPIO Monitor Rate', 'Delay (mSec)', IntToStr(RepeatTimer.Interval)),1000);
end;


procedure TForm1.WifiStatusBtnClick(Sender: TObject);
begin
Send('= wifi.sta.status()'+CRLF,1);
CheckWiFiStatus := True;
end;

procedure TForm1.ResetBaudTimerStop(Sender: TObject);
var
newrate : string;
i : integer;
begin
if BaudRate.Text <> '9600' then
    begin
    SerialPortNG1.BaudRate := 9600;
    i := BaudRate.Items.IndexOf(IntToStr(SerialPortNG1.BaudRate));
    if i >= 0 then
       BaudRate.ItemIndex := i
    else
       BaudRate.Text := IntToStr(SerialPortNG1.BaudRate);
    newrate := Trim(BaudRate.Items[BaudRate.ItemIndex]);
    SerialPortNG1.BaudRate := StrToIntDef(newrate,9600);
    Show('Baud rate changed to '+newrate,1);
    SerialPortNG1.WriteSettings('Software\Benlo.com','LuaLoader');
    end;
end;

procedure TForm1.AutoResetBaudRateMClick(Sender: TObject);
begin
AutoResetBaudRateM.Checked := not  AutoResetBaudRateM.Checked;

if AutoResetBaudRateM.Checked then
   begin
   ShowMessage('Baud rate will reset to 9600 baud on Restart or comm port errors');
   end
else
   begin
   ShowMessage('Baud rate will not reset on Restart or comm port errors'#13#10#13#10 +
               'init.lua should reset the baud rate using'#13#10#13#10 +
               'uart.setup(0,921600,8,0,1,1)   for example');
   end;
end;

procedure TForm1.FilenameEDropDown(Sender: TObject);
var
SearchRec : TSearchRec;
i,j : integer;
ext : string;
curdate : integer;
fname : string;
changed : integer;
begin
FilenameE.Items.Clear;

for i := 0 to FilesOnESP.Count-1 do
    begin
    if ESPLua.Checked then
       begin
       if Pos('.lua'+'$',FilesOnESP[i]+'$') > 0 then FilenameE.Items.Add(FilesOnESP[i]);
       end
    else
       FilenameE.Items.Add(FilesOnESP[i]);
    end;

ext := '*.*';
if WSLua.Checked then ext := '*.lua';
if ListlcM.Checked then ext := '*.lc';

if 0 = FindFirst(WorkingDir +ext, faAnyFile, SearchRec) then
   begin
      if (FilenameE.Items.IndexOf(SearchRec.Name) < 0) and
         (FilenameE.Items.IndexOf('< '+SearchRec.Name) < 0) and
         (SearchRec.Name <> '.') and
         (SearchRec.Name <> '..') then
         FilenameE.Items.Add(SearchRec.Name);
   while 0 = FindNext(SearchRec) do
      begin
      if (FilenameE.Items.IndexOf(SearchRec.Name) < 0) and
         (FilenameE.Items.IndexOf('< '+SearchRec.Name) < 0) and
         (SearchRec.Name <> '.') and
         (SearchRec.Name <> '..') then
         begin
         FilenameE.Items.Add(SearchRec.Name)
         end;
      end;
   end;
SysUtils.FindClose(SearchRec);

changed := 0;
for i := 0 to FilenameE.Items.Count-1 do
   begin
   fname := FilenameE.Items[i];
   if Pos('< ',fname) = 1 then  fname := Copy(fname,3,999);
   j := RecentFiles.IndexOf(workingDir + fname);
   if j >= 0 then
      begin
      curdate := FileTime(workingDir + fname);
      if curdate >  Integer(RecentFiles.Objects[j]) then
         begin
         inc(changed);
         FilenameE.Items[i] := '! '+ fname;
         end;
      end
   else
      begin
      if FileExists(workingDir + fname) then
         begin
         inc(changed);
         FilenameE.Items[i] := '! '+ fname;
         end;
      end;
   end;
if changed > 0 then FilenameE.Items.Add('< Upload all changed files');
FilenameE.Items.Add('< Upload all .lua files' );
end;

procedure TForm1.tmrstop01Click(Sender: TObject);
begin
TMenuItem(Sender).Checked := not TMenuItem(Sender).Checked;
end;

procedure TForm1.WSMenuClick(Sender: TObject);
var
i : integer;
begin
if TMenuItem(sender).Caption = 'Remove Current Workspace' then
   begin
   for i := 0 to Workspace.Count-1 do
      begin
      if Workspace.Items[i].Checked then
         begin
         Workspace.Delete(i);
         break;
         end;
      end;
   end
else
   begin
   workingDir := TMenuItem(sender).Caption;
   EditBtn.Hint := 'Edit '+workingDir+FilenameE.Text;
   UploadBtn.Hint := 'Upload '+ workingDir+FilenameE.Text;
   StatusBar.SimpleText := 'Working Directory: '+workingDir;
   end;
end;

procedure TForm1.DownloadNodeMcuesp8266flasherexe1Click(Sender: TObject);
begin
ShowMessage('Choose Win32 or Win64'#13#10#13#10'Right click on View Raw to download');
ShowURL('https://github.com/nodemcu/nodemcu-flasher');
end;

procedure TForm1.FilenameEExit(Sender: TObject);
begin
if Pos('< ',FilenameE.Text) = 1 then
   begin
   FilenameE.Text := Copy(FilenameE.Text,3,999);
   RemoveBtn.Hint := 'Delete '+FilenameE.Text;
   end;
end;

procedure TForm1.FilenameEClick(Sender: TObject);
begin
FixFilename.Enabled := True;
end;

procedure TForm1.FixFilenameStop(Sender: TObject);
var
i : integer;
fname : string;
begin
FixFilename.Enabled := False;
if Pos('< ',FilenameE.Text) = 1 then
   begin
   FilenameE.Text := Copy(FilenameE.Text,3,999);
   RemoveBtn.Hint := 'Delete '+FilenameE.Text;
   end;
if Pos('! ',FilenameE.Text) = 1 then
   begin
   FilenameE.Text := Copy(FilenameE.Text,3,999);
   RemoveBtn.Hint := 'Delete '+FilenameE.Text;
   end;
if Pos('file.list',FilenameE.Text) > 0 then
   begin
   FileListBtnClick(Self);
   FilenameE.Text := '';
   end;
if Pos('Upload all changed',FilenameE.Text) > 0 then
   begin
   FilenameE.Text := '';
   for i := 0 to FilenameE.Items.Count-1 do
      begin
      if Pos('! ',FilenameE.Items[i]) = 1 then
         begin
         if  UploadBtn.Caption = 'Abort' then break;
         if not Upload(workingDir + Copy(FilenameE.Items[i],3,999)) then
            break;
         end;
      end;
   end;
if Pos('Upload all .lua',FilenameE.Text) > 0 then
   begin
   FilenameE.Text := '';
   for i := 0 to FilenameE.Items.Count-1 do
      begin
      fname :=  FilenameE.Items[i];
      if Pos('.lua'+'$', fname+'$') > 1 then
         begin
         if Pos('Upload all',fname) > 0 then continue;
         if Pos('< ',fname) = 1 then fname := Copy(fname,3,999);
         if Pos('! ',fname) = 1 then fname := Copy(fname,3,999);
         if not Upload(workingDir + fname) then
            break;
         end;
      end;
   end;
end;

procedure TForm1.FastUpClick(Sender: TObject);
begin
FastUp.Checked := not FastUp.Checked;
if FastUp.Checked then
   begin
   ShowMessage('Uploads will automatically change the baud rate to 921600');
   end
else
   begin
   ShowMessage('Baud rate will remain unchanged on uploads');
   end;
end;

procedure TForm1.LuaFAQ1Click(Sender: TObject);
begin
ShowURL('http://www.luafaq.org/');
end;

procedure TForm1.LuaGotchas1Click(Sender: TObject);
begin
ShowURL('http://www.luafaq.org/gotchas.html');
end;

procedure TForm1.About1Click(Sender: TObject);
begin
ShowURL('http://benlo.com/esp8266/index.html#LuaLoader');
end;

procedure TForm1.Node1Click(Sender: TObject);
begin
ShowURL('https://github.com/nodemcu/nodemcu-firmware/wiki/nodemcu_api_en#node-module');
end;

procedure TForm1.FileModule1Click(Sender: TObject);
begin
ShowURL('https://github.com/nodemcu/nodemcu-firmware/wiki/nodemcu_api_en#file-module');
end;

procedure TForm1.WifiModule1Click(Sender: TObject);
begin
ShowURL('https://github.com/nodemcu/nodemcu-firmware/wiki/nodemcu_api_en#wifi-module');
end;

procedure TForm1.TimerModule1Click(Sender: TObject);
begin
ShowURL('https://github.com/nodemcu/nodemcu-firmware/wiki/nodemcu_api_en#timer-module');
end;

procedure TForm1.GPIOModule1Click(Sender: TObject);
begin
ShowURL('https://github.com/nodemcu/nodemcu-firmware/wiki/nodemcu_api_en#gpio-module');
end;

procedure TForm1.PWMModule1Click(Sender: TObject);
begin
ShowURL('https://github.com/nodemcu/nodemcu-firmware/wiki/nodemcu_api_en#pwm-module');
end;

procedure TForm1.NetModule1Click(Sender: TObject);
begin
ShowURL('https://github.com/nodemcu/nodemcu-firmware/wiki/nodemcu_api_en#net-module');
end;

procedure TForm1.I2CModule1Click(Sender: TObject);
begin
ShowURL('https://github.com/nodemcu/nodemcu-firmware/wiki/nodemcu_api_en#i2c-module');
end;

procedure TForm1.ADCModule1Click(Sender: TObject);
begin
ShowURL('https://github.com/nodemcu/nodemcu-firmware/wiki/nodemcu_api_en#adc-module');
end;

procedure TForm1.UARTModule1Click(Sender: TObject);
begin
ShowURL('https://github.com/nodemcu/nodemcu-firmware/wiki/nodemcu_api_en#uart-module');
end;

procedure TForm1.OneWireModule1Click(Sender: TObject);
begin
ShowURL('https://github.com/nodemcu/nodemcu-firmware/wiki/nodemcu_api_en#onewire-module');
end;

procedure TForm1.Quit1Click(Sender: TObject);
begin
Close;
end;

procedure TForm1.BitModuleClick(Sender: TObject);
begin
ShowURL('https://github.com/nodemcu/nodemcu-firmware/wiki/nodemcu_api_en#bit-module');
end;

procedure TForm1.APIOverviewandChangeLog1Click(Sender: TObject);
begin
ShowURL('https://github.com/nodemcu/nodemcu-firmware/wiki/nodemcu_api_en#nodemcu-api-instruction');
end;

procedure TForm1.ESP8266WikiReference1Click(Sender: TObject);
begin
ShowURL('http://www.esp8266.com/wiki');
end;

procedure TForm1.DeleteAllClick(Sender: TObject);
begin
TmrStopClick(Self);
Send('l = file.list() for k,v in pairs(l) do file.remove(k) end'+CRLF,1);
FileListBtnClick(Self);
end;

procedure TForm1.LocalMClick(Sender: TObject);
var
i : integer;
MenuI : TMenuItem;
SearchRec : TSearchRec;
begin
if LocalDocs = '' then
   begin
   OpenDialog1.Title := 'Choose any document in Local Documentation Folder';
   OpenDialog1.Filename := '';
   OpenDialog1.FilterIndex := 3;
   if not OpenDialog1.Execute then
      begin
      exit;
      end;
   LocalDocs := ExtractFilePath(OpenDialog1.Filename);
   exit;
   end;
for i := LocalM.Count-1 downto 1 do
   begin
   LocalM.Delete(i);
   end;
LocalSM.Caption := LocalDocs;
if 0 = FindFirst(LocalDocs +'*.*', faAnyFile, SearchRec) then
   begin
   // ignore .
   while 0 = FindNext(SearchRec) do
      begin
      if SearchRec.Name <> '..' then
         begin
         MenuI := TMenuItem.Create(self);
         MenuI.Caption := SearchRec.name;
         MenuI.OnClick := LocalSMClick;
         if 0 <= RecentDocFiles.IndexOf(SearchRec.name) then
            MenuI.Checked := True;
         LocalM.Add(MenuI);
         end;
      end;
   end;
MenuI := TMenuItem.Create(self);
MenuI.Caption := 'Change Folder...';
MenuI.OnClick := LocalSMClick;
LocalM.Add(MenuI);
end;

procedure TForm1.LocalSMClick(Sender: TObject);
var
filename : string;
begin
if TmenuItem(sender).Caption = 'Change Folder...' then
   begin
   LocalDocs := '';
   LocalMClick(Self);
   exit;
   end
else
   begin
   TMenuItem(sender).Checked := True;
   filename := TMenuItem(sender).Caption;
   RecentDocFiles.Add(filename);
   if filename <> LocalDocs then
      filename := LocalDocs + filename;
   ShowURL(filename);
   end;
end;

procedure TForm1.FormatBtnClick(Sender: TObject);
begin
TmrStopClick(Self);
Send('file.format()'+CRLF,1);
FilesOnESP.Clear;
end;

procedure TForm1.DTRbtnClick(Sender: TObject);
begin
SerialPortNG1.DTRState := not SerialPortNG1.DTRState;
end;

procedure TForm1.RTSbtnClick(Sender: TObject);
begin
SerialPortNG1.RTSState := not SerialPortNG1.RTSState;
end;

procedure TForm1.CTSbtnClick(Sender: TObject);
begin
ShowMessage('CTS is read only');
end;

procedure TForm1.BuyNodeMCUdevelopmentboards1Click(Sender: TObject);
begin
ShowURL('http://www.benlo.com/shop/shop.php?shop=e&for=NodeMCU');
end;

procedure TForm1.QuickStartforBeginners1Click(Sender: TObject);
begin
ShowURL('http://www.benlo.com/esp8266/esp8266QuickStart.html');
end;

procedure TForm1.ESPLuaClick(Sender: TObject);
begin
ESPLua.Checked := not ESPLua.Checked;
end;

procedure TForm1.WSLuaClick(Sender: TObject);
begin
WSLua.Checked := not WSLua.Checked;
end;

procedure TForm1.UseBinClick(Sender: TObject);
begin
UseBin.Checked := not UseBin.Checked;
if UseBin.Checked then
   begin
   UploadBtn.Caption := 'Upload Bin';
   UploadBinary1.Checked := True;
   UploadText1.Checked := False;
   end
else
   begin
   UploadBtn.Caption := 'Upload Text';
   UploadBinary1.Checked := False;
   UploadText1.Checked := True;
   end;
end;

procedure TForm1.UploadBinary1Click(Sender: TObject);
begin
UseBin.Checked := True;
UploadBtn.Caption := 'Upload Bin';
UploadBinary1.Checked := True;
end;

procedure TForm1.UploadText1Click(Sender: TObject);
begin
UseBin.Checked := False;
UploadBtn.Caption := 'Upload Text';
UploadText1.Checked := True;
end;

procedure TForm1.WorkspaceClick(Sender: TObject);
var
i : integer;
begin
for i := 0 to Workspace.Count-1 do
   begin
   if Workspace.Items[i].caption = workingDir then
      Workspace.Items[i].Checked := True
   else
      Workspace.Items[i].Checked := False;
   end;
if Workspace.Count > 1 then
   begin
   for i := 0 to Workspace.Count-1 do
       begin
       if Workspace.Items[i].caption = 'c:\' then
       Workspace.Items[i].caption := 'Remove Current Workspace';
       end;
   end;

end;

procedure TForm1.Checkall1Click(Sender: TObject);
var
i : integer;
begin
for i := 0 to 6 do
   tmrM.Items[i].Checked := True;
end;

procedure TForm1.CheckNone1Click(Sender: TObject);
var
i : integer;
begin
for i := 0 to 6 do
   tmrM.Items[i].Checked := False;
end;

procedure TForm1.OpenWorkspaceFolderinExplorer1Click(Sender: TObject);
begin
ShowURL(WorkingDir);
end;

procedure TForm1.Setcurrentvalueasstartupdefault1Click(Sender: TObject);
begin
DTRdefault := SerialPortNG1.DTRState;
RTSdefault := SerialPortNG1.RTSState;
end;

procedure TForm1.CustomClick(Sender: TObject);
var
cap : string;
i : integer;
lines : TStringList;
begin
if not fileExists(CustomLuaFile) then
   begin
   OpenDialog1.Title := 'Select Lua file';
   OpenDialog1.FilterIndex := 0;
   if OpenDialog1.Execute then
      begin
      CustomLuaFile := OpenDialog1.Filename;
      Custom.Caption := 'Custom';
      end
   else
      exit;
   end;
if Custom.Caption = 'Custom' then
   begin
   cap := Custom.Caption;
   if InputQuery('Enter new button caption','Caption: ',cap) then
      Custom.Caption := cap;
   exit;
   end;
lines := TStringList.Create;
lines.LoadFromFile(CustomLuaFile);
   begin
   for i := 0 to lines.Count-1 do
      begin
      Send(lines[i]+CRLF,0);
      pause(400);
      end;
   end;
lines.free;


end;

procedure TForm1.Resetfunctionality1Click(Sender: TObject);
begin
Custom.Caption := 'Custom';
CustomLuaFile  := '';
end;

procedure TForm1.CompileClick(Sender: TObject);
begin
Send('node.compile("'+FileNameE.Text+'")'+CRLF,1);
end;

procedure TForm1.DoFileCompiledClick(Sender: TObject);
var
fname : string;
begin
fname := FilenameE.Text;
if Pos('.lua',fname) > 0 then
fname := StringReplace(fname,'.lua','.lc',[]);
Show('dofile('+fname+')  '+ FormatDateTime('dddddd  hh:nn:ss',Now),1);
Send('dofile("'+fname+'")'+CRLF,1);
end;

procedure TForm1.DownLoadBtnClick(Sender: TObject);
var
fname : string;
i : integer;
begin
DLCapture := '';

if FastUp.Checked and (SerialPortNG1.BaudRate <> 921600) then
   begin
   SerialPortNG1.BaudRate := 921600;
   i := BaudRate.Items.IndexOf(IntToStr(SerialPortNG1.BaudRate));
   if i >= 0 then
      BaudRate.ItemIndex := i
   else
      BaudRate.Text := IntToStr(SerialPortNG1.BaudRate);
   Show('Baud rate changed to '+IntToStr(SerialPortNG1.BaudRate),1);
   end;

Send('uart.setup(0,'+IntToStr(SerialPortNG1.BaudRate)+',8,0,1,1)'+CRLF,0);
Pause(300);  // allow command to be sent

SerialPortNG1.WriteSettings('Software\Benlo.com','LuaLoader');

AwaitPrompt(2000);
Send('tmr.stop(0)'+CRLF,0);
AwaitPrompt(250);
Send('tmr.stop(1)'+CRLF,0);
AwaitPrompt(250);

StartingDL := True;
DoingDL    := True;
xxdNil := False;
fname := FilenameE.Text;

Send('xxd("'+fname+'")'+CRLF,1);
AwaitPrompt(500);


if xxdNil then       // LLBin function doesn't exist
   begin
   Send('uart.setup(0,'+IntToStr(SerialPortNG1.BaudRate)+',8,0,1,1)'+CRLF,0);
    AwaitPrompt(500);
    CannotOpenxxd := False;
    Send('dofile("xxd.lua")'+CRLF,1);      // create LLBin()
    AwaitPrompt(500);
    if CannotOpenxxd then
       begin
       Show('xxd.lua not found. Installing xxd.lua...',1);
       if FileExists( ExtractFilePath(ParamStr(0))+'xxd.lua') then
          begin
          FilenameE.Text := 'xxd.lua';
          UseBin.Checked := True;
          UploadBtn.Caption := 'Upload Bin';
          if Upload(ExtractFilePath(ParamStr(0))+'xxd.lua') then
             begin
             Send(CRLF,1);
             Send('dofile("xxd.lua")'+CRLF,1);
             AwaitPrompt(500);
             DoingDL := True;
             Send('xxd("'+fname+'")'+CRLF,1);
             AwaitPrompt(500);
             end
          else
             begin
             exit;
             end;
          end
       else
          begin
          Show(CRLF+ExtractFilePath(ParamStr(0))+'xxd.lua not found',1);
          Send(CRLF,1);
          exit;
          end;
       end
    else        // CannotOpenxxd false
       begin
       DLCapture := '';
       DoingDL    := True;
       xxdNil := False;
       Send('xxd("'+fname+'")'+CRLF,1);
       AwaitPrompt(500);
       end;
    end;
FilenameE.Text := Fname;
StartingDL := False;
end;

procedure TForm1.DecodeDL(Sender: TObject);
var
dldata : TStringList;
f : file of byte;
x : string;
buffer : array of byte;
buflen : integer;
n,i,j : integer;
fname : string;
line : string;
csum : integer;
linesum : integer;
waitstart : Boolean;
errors : Boolean;
begin
dldata := TStringList.Create;
dldata.LoadFromFile(ExtractFilePath(ParamStr(0))+'xxd.temp');
n := Pos('xxd("',dldata.Text);
if n = 0 then exit;

fname := copy(dldata.Text,n+5,99);
delete(fname,Pos('"',fname),999);

errors := False;
buflen := 0;
waitstart := True;
for i := 0 to dldata.count-1 do
   begin
   if Pos('xxd("',dldata[i]) > 0 then continue;
   if Pos('EOF',dldata[i]) > 0 then break;
   if Pos('Downloading',dldata[i]) > 0 then
      begin
      waitstart := False;
      continue;
      end;
   if waitstart then continue;
   line := dldata[i];
   csum := 0;
   for j := 0 to 15 do
      begin
      SetLength(buffer, buflen+32);
      if Length(line) > j*3 then
         begin
         x := Copy(line,j*3+1,2);
         try
         buffer[buflen] := byte(strtoint('$'+ x[1]+x[2]));
         except;
         errors := True;
         end;
         csum := csum + ord(buffer[buflen]);
         inc(buflen);
         end
      else
         break;
      end;
   if Length(line) > 49 then
      begin
      linesum := StrToInt(Copy(line,49,99));
      if linesum <> csum then
         errors := True;
      end;
   end;
SaveDialog1.Title := 'Save downloaded file';
SaveDialog1.Filename := fname;
SaveDialog1.FilterIndex := 4;
if SaveDialog1.Execute then
   begin
   assignFile(f,SaveDialog1.Filename);
   rewrite(f);
   for i := 0 to buflen-1 do
      write(f,buffer[i]);
   CloseFile(f);
   end;
//dldata.free;
if errors then
   ShowMessage('CSUM errors detected');
end;

procedure TForm1.ListlcMClick(Sender: TObject);
begin
ListlcM.Checked := not ListlcM.Checked;
end;

procedure TForm1.ListallMClick(Sender: TObject);
begin
ListallM.Checked := not ListAllM.Checked;
end;

procedure TForm1.NodeMCUCustomBuilds1Click(Sender: TObject);
begin
ShowMessage('Save the latest bin file in the same folder as the flasher app');
ShowURL('http://nodemcu-build.com/');
end;

end.
