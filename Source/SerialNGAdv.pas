unit SerialNGAdv;
// Helper Unit for SerialNG Advanced Demo
// Includes a Dialog for Advanced Settings
// To use this Dialog, simply include this Unit to Your Project
// Version 1.0.1 18.9.2001 Create the Comportlist from the System Registry

interface

uses Windows, SysUtils, Classes, Graphics, Forms, Controls, StdCtrls, 
  Buttons, ExtCtrls, ComCtrls, SerialNG;

type
  TSerialNGAdvDLG = class(TForm)
    Panel1: TPanel;
    OKBtn: TButton;
    CancelBtn: TButton;
    DLGTabSheet: TPageControl;
    BasicSheet: TTabSheet;
    TimingSheet: TTabSheet;
    AdvancedSheet: TTabSheet;
    CBPort : TComboBox;
    CBBaud: TComboBox;
    CBData: TComboBox;
    CBStop: TComboBox;
    CBParity: TComboBox;
    CBFlow: TComboBox;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label1: TLabel;
    Label2: TLabel;
    Label9: TLabel;
    Label10: TLabel;
    WTOExtraDelayEdit: TEdit;
    RTOCharDelayEdit: TEdit;
    WTOCharDelayEdit: TEdit;
    RTOExtraDelayEdit: TEdit;
    CBXTOAuto: TCheckBox;
    GroupBox1: TGroupBox;
    Label11: TLabel;
    Label12: TLabel;
    XOffCharEdit: TEdit;
    XOnCharEdit: TEdit;
    Label13: TLabel;
    Label14: TLabel;
    XOnLimitEdit: TEdit;
    XOffLimitEdit: TEdit;
    GroupBox2: TGroupBox;
    CBParityErrorReplacement: TCheckBox;
    Label15: TLabel;
    ParityErrorCharEdit: TEdit;
    CBStripNullChars: TCheckBox;
    Label16: TLabel;
    CBReport: TComboBox;
    Label17: TLabel;
    EventCharEdit: TEdit;
    PortBtn: TButton;
    ManualPort: TEdit;
    Label18: TLabel;
    procedure ValidateCharInput(Sender: TObject);
    procedure ValidateInteger(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure PortBtnClick(Sender: TObject);
    procedure ManualPortExit(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure SetDLGData(SerialPortNG : TSerialPortNG);
    procedure GetDLGData(SerialPortNG : TSerialPortNG);
  end;

var
  SerialNGAdvDLG: TSerialNGAdvDLG;

function CharToEdit(C : Char):String;
function EditToChar(S : String; DefaultC : Char):Char;

implementation

uses netstat;

{$R *.DFM}

procedure TSerialNGAdvDLG.ValidateCharInput(Sender: TObject);
var S : String;
    N : LongInt;
begin
  S := TEdit(Sender).Text;
  if Length(S) > 1 then
    begin
      try
        EditToChar(S,#0);
      except
        Application.MessageBox('Input allowed single Char or 0..255. Leave empty to hold previous Value.','Invalid Input',mb_OK);
      end;
    end
  else if Length(S) = 0 then
    Application.MessageBox('Input allowed single Char or 0..255. Leave empty to hold previous Value.','Invalid Input',mb_OK);
end;

procedure TSerialNGAdvDLG.ValidateInteger(Sender: TObject);
var S : String;
    N : Cardinal;
begin
  S := TEdit(Sender).Text;
  if Length(S) > 1 then
    begin
      try
        N := StrToInt(S);
      except
        Application.MessageBox('Invalid Input. Leave empty to hold previous Value.','Invalid Input',mb_OK);
      end;
    end;
end;

function CharToEdit(C : Char):String;
var S : String;
begin
  case C of
    #0..#31,#127,#255 : S := Format('0x%2.2x',[Byte(C)]);
  else
    S := C;
  end;
  CharToEdit := S;
end;

function EditToChar(S : String; DefaultC : Char):Char;
var N : LongInt;
    C : Char;
begin
  if Length(S) > 1 then
    begin
      if Copy(S,1,2) = '0x' then
        S := '$'+Copy(S,3,Length(S));
      N := StrToInt(S);
      if (N < 0) or (N > 255) then
        raise ERangeError.CreateFmt(
          '%d is not within the valid range of %d..%d',
          [N, 0, 255])
      else
        C := Char(N);
     end
   else if Length(S) = 1 then
     C := S[1]
   else
     C := DefaultC;
  EditToChar := C;
end;

procedure TSerialNGAdvDLG.SetDLGData(SerialPortNG : TSerialPortNG);
var i : Integer;
begin
// Page 1 (Basic)
  try
  i := CBPort.Items.IndexOf(SerialPortNG.CommPort);
  except
  SerialPortNG.CommPort := '';
  i := 0;
  end;
  if i >= 0 then
    CBPort.ItemIndex := i
  else
    CBPort.ItemIndex := 1; //COM2
  i := CBBaud.Items.IndexOf(IntToStr(SerialPortNG.BaudRate));
  if i >= 0 then
    CBBaud.ItemIndex := i
  else
    CBBaud.Text := IntToStr(SerialPortNG.BaudRate);
//    CBBaud.ItemIndex := 6; // 9600
  i := CBData.Items.IndexOf(IntToStr(SerialPortNG.DataBits)+' Bit');
  if i >= 0 then
    CBData.ItemIndex := i
  else
    CBData.ItemIndex := 4; // 8 Bit
  CBStop.ItemIndex := SerialPortNG.StopBits;
  CBParity.ItemIndex := SerialPortNG.ParityType;
  case SerialPortNG.FlowControl of
    fcNone : CBFlow.ItemIndex := 0;
    fcXON_XOFF : CBFlow.ItemIndex := 1;
    fcRTS_CTS : CBFlow.ItemIndex := 2;
    fcDSR_DTR : CBFlow.ItemIndex := 3;
  else
    CBFlow.ItemIndex := 0;
  end;
//  CBOpenPort.Checked := SerialPortNG.Active;
// Page 2 Timing
  WTOCharDelayEdit.Text := IntToStr(SerialPortNG.WTOCharDelayTime);
  RTOCharDelayEdit.Text := IntToStr(SerialPortNG.RTOCharDelayTime);
  WTOExtraDelayEdit.Text := IntToStr(SerialPortNG.WTOExtraDelayTime);
  RTOExtraDelayEdit.Text := IntToStr(SerialPortNG.RTOExtraDelayTime);
  CBXTOAuto.Checked := SerialPortNG.XTOAuto;
// Page 3 Advanced
  XOnCharEdit.Text := CharToEdit(SerialPortNG.XOnChar);
  XOffCharEdit.Text := CharToEdit(SerialPortNG.XOffChar);
  XOnLimitEdit.Text := IntToStr(SerialPortNG.XOnLimDiv);
  XOffLimitEdit.Text := IntToStr(SerialPortNG.XOffLimDiv);
  CBParityErrorReplacement.Checked := SerialPortNG.ParityErrorReplacement;
  ParityErrorCharEdit.Text := CharToEdit(SerialPortNG.ParityErrorChar);
  EventCharEdit.Text := CharToEdit(SerialPortNG.EventChar);
  CBStripNullChars.Checked := SerialPortNG.StripNullChars;
  if SerialPortNG.ErrorNoise > CBReport.Items.Count then
    CBReport.ItemIndex := CBReport.Items.Count-1
  else
    CBReport.ItemIndex := SerialPortNG.ErrorNoise;
end;

procedure TSerialNGAdvDLG.GetDLGData(SerialPortNG : TSerialPortNG);
begin
  SerialPortNG.CommPort := CBPort.Items[CBPort.ItemIndex];
//  SerialPortNG.BaudRate := StrToIntDef(CBBaud.Items[CBBaud.ItemIndex],9600);
  SerialPortNG.BaudRate := StrToIntDef(CBBaud.Text,9600);
  SerialPortNG.DataBits := StrToIntDef(Copy(CBData.Items[CBData.ItemIndex],1,1),8);
  SerialPortNG.StopBits := CBStop.ItemIndex;
  SerialPortNG.ParityType := CBParity.ItemIndex;
  SerialPortNG.FlowControl := BasicFlowModes[CBFlow.ItemIndex];

// Page 2 Timing
  SerialPortNG.XTOAuto := CBXTOAuto.Checked;
  if not CBXTOAuto.Checked then
    begin
      SerialPortNG.WTOCharDelayTime := StrToInt(WTOCharDelayEdit.Text);
      SerialPortNG.RTOCharDelayTime := StrToInt(RTOCharDelayEdit.Text);
      SerialPortNG.WTOExtraDelayTime := StrToInt(WTOExtraDelayEdit.Text);
      SerialPortNG.RTOExtraDelayTime := StrToInt(RTOExtraDelayEdit.Text);
    end;

// Page 3 Advanced
  SerialPortNG.XOnChar := EditToChar(XOnCharEdit.Text,SerialPortNG.XOnChar);
  SerialPortNG.XOffChar := EditToChar(XOffCharEdit.Text,SerialPortNG.XOffChar);
  SerialPortNG.XOnLimDiv := StrToInt(XOnLimitEdit.Text);
  SerialPortNG.XOffLimDiv := StrToInt(XOffLimitEdit.Text);
  SerialPortNG.ParityErrorReplacement := CBParityErrorReplacement.Checked;
  SerialPortNG.ParityErrorChar := EditToChar(ParityErrorCharEdit.Text,SerialPortNG.ParityErrorChar);
  SerialPortNG.EventChar := EditToChar(EventCharEdit.Text,SerialPortNG.EventChar);
  SerialPortNG.StripNullChars := CBStripNullChars.Checked;
  SerialPortNG.ErrorNoise := CBReport.Itemindex;
// Try to Open the Port if wished
//  SerialPortNG.Active := CBOpenPort.Checked;
end;

procedure TSerialNGAdvDLG.FormCreate(Sender: TObject);
begin
  GetCommNames(CBPort.Items);
end;

procedure TSerialNGAdvDLG.FormShow(Sender: TObject);
begin
  GetCommNames(CBPort.Items);
end;

procedure TSerialNGAdvDLG.PortBtnClick(Sender: TObject);
begin
net.ShowURL('http://benlo.com/esp8266/index.html#faq');
end;

procedure TSerialNGAdvDLG.ManualPortExit(Sender: TObject);
begin
ManualPort.Text := UpperCase(ManualPort.Text);
if (ManualPort.Text <> '') and (CBPort.Items.IndexOf(ManualPort.Text) < 0) then
   begin
   CBPort.Items.Add(ManualPort.Text);
   end;
end;

end.
