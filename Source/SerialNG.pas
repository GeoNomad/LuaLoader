unit SerialNG;
// DomIS Internet Solutions http://www.domis.de
// This Source is distributet under the terms of GNU Licence
// This mean You can use this Source free for Open-Source development
// Additionally I allow the use for inhouse Projects
// It is prohibited to use this source for military Products!!!
// If You want to make a Closed-Source Project with this Source, please contact me
// Any changes should be marked and this header should remain here

// This is Version 2 of the Basic Communication Component
// I've made a complete redesign of the whole Component
// So the Component is incompatible with the Version 1
// News:
// Using Overlapped features for Windows Platform Compatiblity
// Using CommEvents for state detection
// More (and more meaningfull) Events
// Sending will not block the main Program


// Usage
// You have to register this component with the Delphi funktion "Component/New"
// create a new component library and add this component
// the TSerialNG component appears in the "Samples" part of the component toolbar

// The Base of this unit is taken from "TSerialPort: Basic Serial Communications in Delphi"
// created by Jason "Wedge" Perry, but I could not find him again

// 2.0.0 28.August.2001, Basic stable Version
// 2.0.1 30.August.2001, Fixing Thread stoperror in PortWord
// 2.0.2 17. September 2001, Deleting double declared Property Error, use instead CommError
//                           Changed declaration of procedure GetCommNames(CommNames : TStrings);
//                           prevent duplicate Entries in this function
// 2.0.3 9. November 2001, Changed Cardinal type to DWORD in TWorkThread.Execute for
//                         Delphi 3 backcompatibility
// 2.0.4 28. November 2001, Problem in not Active Mode fixed (
//                         sleep(200) prevent consuming 100% of cpu-time in inactive mode)
// 2.0.5 8. Januar 2002, Problem in GetDataAsPChar fixed (
//                         The pending Zero was not patched in the right place)
// 2.0.6 4. April 2002, Changed *all* Cardinal type to DWORD and made several Changes in
//                         Demo Forms for Delphi 3 backcompatibility
// 2.0.7 16. April 2002, Found and fixed the norty Error which occours sometimes after
//                         the Termination of the Threads (the Overlapped Result wrote into undefined Memory)
//                         The Thread waits now until everything Pending Overlapped is done

interface

uses
  Windows, Messages, SysUtils, Classes,
  Graphics, Controls, Forms, Dialogs, IniFiles;

  // Definitions for the DCB found in windows.pas for reference only
  // All of the baud rates that the DCB supports.
const
  BaudRateCount = 15;
  BaudRates : array[0..BaudRateCount-1] of DWord =
    (CBR_110, CBR_300, CBR_600, CBR_1200, CBR_2400, CBR_4800, CBR_9600, CBR_14400, CBR_19200, CBR_38400, CBR_56000, CBR_57600, CBR_115200, CBR_128000, CBR_256000);
// The business with the TimeOuts during sending Data, and esspeccialy during
// reception of Data depends on the selected Baudrate.
// while on 9600 Baud every 1ms a Char is received, is this time on 256KBaud only 4탎
// Strange enough, windows support only 1ms as shortest Intervall!
// Below some standard TimeOuts for the given Baudrates in 탎
  XTOCharDelayDef : array [0..BaudRateCount-1] of DWord =
(100000, 37000, 18000, 9000, 4500, 2300, 1100, 760, 570, 290, 200, 190, 95, 85, 43);
  // Parity types for parity error checking
  // NOPARITY = 0;  ODDPARITY = 1;  EVENPARITY = 2;  MARKPARITY = 3;  SPACEPARITY = 4;
  // Stopbits
  // ONESTOPBIT = 0;   ONE5STOPBITS = 1;  TWOSTOPBITS = 2;
  // Bitmasks for the "Flags" Field of the DCB record
const
  bmfBinary = $0001;          // binary mode, no EOF check
  bmfParity = $0002;          // enable parity checking
  bmfOutxCtsFlow = $0004;      // CTS output flow control
  bmfOutxDsrFlow = $0008;      // DSR output flow control
// DTR Control Flow Values  DTR_CONTROL_DISABLE = 0;  DTR_CONTROL_ENABLE = 1;  DTR_CONTROL_HANDSHAKE = 2;
  bmfDtrControlEnable = $0010;       // DTR Enable
  bmfDtrControlHandshake = $0020;       // DTR Handshake
  bmfDsrSensitivity = $0040;   // DSR sensitivity
  bmfTXContinueOnXoff = $0080; // XOFF continues Tx
  bmfOutX = $0100;            // XON/XOFF out flow control
  bmfInX = $0200;             // XON/XOFF in flow control
  bmfErrorChar = $0400;       // enable error replacement
  bmfNull = $0800;            // enable null stripping
// RTS Control Flow Values  RTS_CONTROL_DISABLE = 0;  RTS_CONTROL_ENABLE = 1;  RTS_CONTROL_HANDSHAKE = 2;  RTS_CONTROL_TOGGLE = 3;
  bmfRtsControlEnable = $1000;       // RTS Enable
  bmfRtsControlHandshake = $2000;       // RTS Enable
  bmfRtsControlToggle = $3000;       // RTS Enable
  bmfAbortOnError = $4000;     // abort reads/writes on error

// Basic FlowControlModes
// You may declare more _exotic_ Modes, like Sending RTS/CTS, receiving XOn/XOff :-)
const
  fcNone = 0;
  fcXON_XOFF = bmfOutX or bmfInX or  bmfTXContinueOnXoff;
  fcRTS_CTS = bmfOutxCtsFlow or bmfRtsControlHandshake;
  fcDSR_DTR = bmfOutxDsrFlow or bmfDtrControlHandshake;
  fcClearFlowCtrl = Not (fcXON_XOFF or fcRTS_CTS or fcDSR_DTR or bmfDtrControlEnable or bmfRtsControlEnable);
const BasicFlowModes : array[0..3] of Word = (fcNone, fcXON_XOFF, fcRTS_CTS, fcDSR_DTR);

// Constants for using in the ErrorNoise Property
// I tried to catch Errors, send Warnings or sometimes Messages for Your convinience.
// If You set the ErrorNoise Property to one of the Values this kind of Messages will be reported
// while those with higher Numbers not
const
  enError = 0;   // Errors like unable to Open Port
  enWarning = 1; // Warnings like cant pause Thread
  enMsg = 2;     // Messages like starting with Port opening
  enDebug = 3;   // Debughelpermessage like im am here or there
  enAll = 255;   // Show all

const
// Set some constant defaults.
// These are the equivalent of COM2:9600,N,8,1;
  dflt_CommPort = 'COM2';
  dflt_BaudRate = CBR_9600;
  dflt_ParityType = NOPARITY;
  dflt_ParityErrorChar = #0;
  dflt_ParityErrorReplacement = False;
  dflt_StopBits = ONESTOPBIT;
  dflt_DataBits = 8;
  dflt_XONChar = #$11;  {ASCII 11h}
  dflt_XOFFChar = #$13; {ASCII 13h}
  dflt_XONLimDiv = 33; // Set the XONLimit to dflt_XONLimDiv/100*RxQueueSize
  dflt_XOFFLimDiv = 33; // Set the XONLimit to dflt_XONLimDiv/100*RxQueueSize
  dflt_FlowControl = fcNone;
  dflt_StripNullChars = False;
  dflt_BinaryMode = True;
  dflt_EventChar = #0;
// Timeout defaults, fits only to 9600 Baud!
// Look that CharDelay is in micro, ExtraDely in milli Seconds!
  dflt_RTOCharDelayTime = 1100; // 1100microsec (1100E-06 secs)
  dflt_RTOExtraDelayTime = 250; // 250msec      ( 250E-03 secs)
  dflt_WTOCharDelayTime = 1100; // 1100microsec (1100E-06 secs)
  dflt_WTOExtraDelayTime = 250; // 1000msec     ( 250E-03 secs)
  dflt_XTOAuto = True; // lets the Component adjust CharDelay timing on every Baudrate change
  dflt_ClusterSize = 3072; //Max Clustersize
  dflt_RTSState = True;
  dflt_DTRState = True;
  dflt_ErrorNoise = enMsg;
  dflt_BREAKState = False;
  dflt_RxQueueSize = 4096;
  dflt_TxQueueSize = 4096;


type

// Special Event function for the Error and Warning
  TNotifyErrorEvent = procedure(Sender : TObject;Place, Code: DWord; Msg : String) of object;

// TSerialCluster is a Object for the Receiving Process.
// If You just want to receive some Data, don't care
// Under normal circumstances You have not to deal with this Object

// I decided to realize the receiving Process as follow:
// Between two cycles in the WorkThread may the SerialPort receive more than one Character.
// Basicly those Chars are named "Cluster" (and not "Telegram", as You might expect)
// How many Chars are stored in one TSerialCluster depeds on, User controlled,  Conditions
// 1. the ClusterSize is reched
// 2. the Receivingtime is reached
// 3. an (Line-) Error occoured
// 4. The Program set the "ReadRequest" Property to "True"
// If the condition is met, the received Chars are Stored as a Cluster into the ClusterList

  PSerialCluster = ^TSerialCluster;
  TSerialCluster = class (TObject)
    private
      ClusterData : Pointer; // Pointer to Data
      ClusterSize : Integer; // How many Bytes in Datafield
      ClusterCCError : DWord; // This Value comes from the ClearCommError function and is a Bitfield
//  CE_RXOVER = 1;        { Receive Queue overflow }
//  CE_OVERRUN = 2;       { Receive Overrun Error }
//  CE_RXPARITY = 4;      { Receive Parity Error }
//  CE_FRAME = 8;         { Receive Framing error }
//  CE_BREAK = $10;       { Break Detected }
//  CE_TXFULL = $100;     { TX Queue is full }
//  CE_MODE = $8000;      { Requested mode unsupported }

    public
    constructor Create(Data : Pointer; Size : Integer; CCError : DWord);
    function GetCCError : DWord;
    function GetSize : Integer;
    procedure GetData(Dest : Pointer);
    function GetDataAsString : String;
    function GetDataAsPChar(Dest : PChar) : PChar;
    destructor Destroy; override;
  end;

// TSerialPortNG is the Heart of the Job, everything what has to do with the
// SerialPort should be done with this Component
// The Concept is as follows:
// After instancing the Port is still closed
// You should set the Property "CommPort" to the full Name of the Port e.g. 'COM1'
// After this set the "Active" Property to "True"
// Sending Data ist performed with the SendData or the SendString procedures
// since Sendig is "Overlapped" the procedures returns immidiatly and You can do
// some other Jobs in Your main Programm
// You should not reentry this Procedures until they done there Job (Will give a warning).
// If send is done the component call the "OnWriteDone" Event.
// You also can ask the "WriteInProgress" Property.
// Reading Data is faily simple, just Read the Data with one of the "ReadNextCluster..." functions
// You place the read Access into the "OnRxClusterEvent".
// See sample Programs for more Information
  TSerialPortNG = class(TComponent)
  private
    // Variables holding Values for Properties
    fCommPort : ShortString;
    fBaudRate : DWord;
    fParityType : Byte;
    fParityErrorChar : Char;
    fParityErrorReplacement : Boolean;
    fStopBits : Byte;
    fDataBits : Byte;
    fXONChar : Char;
    fXOFFChar : Char;
    fXONLimDiv : Byte; // 0..100
    fXOFFLimDiv : Byte; // 0..100
    fFlowControl : LongInt;
    fStripNullChars : Boolean;  // Strip null chars?
    fEventChar : Char;
    fErrorNoise : Byte;
    // These fields are set in the EventThread
    fCommStateFlags : TComStateFlags;
    fCommStateInQueue : DWord;
    fCommStateOutQueue : DWord;
    fCommError : DWord;
    fCommEvent : DWord;
    fModemState : DWord;
    // TimeOut definitions
    fRTOCharDelayTime : DWord;     // in 탎 max: 4.294.967.295탎 aprox 1h 20min
    fRTOExtraDelayTime : Word;    // in ms
    fWTOCharDelayTime : DWord;     // in 탎
    fWTOExtraDelayTime : Word;    // in ms
    fXTOAuto : Boolean;
    fActive : Boolean;
    fRTSState : Boolean;
    fDTRState : Boolean;
    fBREAKState : Boolean;
    fCTSState : Boolean;
    fDSRState : Boolean;
    fRLSDState : Boolean;
    fRingState : Boolean;
    fClusterSize : Word;
    fRxQueueSize : Word;
    fTxQueueSize : Word;
    fReadRequest : Boolean; // Force Thread to Read the Queue
    fSendInProgress : Boolean;
    fWrittenBytes : DWord;

    // Eventvariables
    fOnTxQueueEmptyEvent : TNotifyEvent;
    fOnCommEvent : TNotifyEvent;
    fOnCommStat : TNotifyEvent;
    fOnBreakEvent : TNotifyEvent;
    fOnCTSEvent : TNotifyEvent;
    fOnDSREvent : TNotifyEvent;
    fOnLineErrorEvent : TNotifyEvent;
    fOnRingEvent : TNotifyEvent;
    fOnRLSDEvent : TNotifyEvent;
    fOnRxClusterEvent : TNotifyEvent;
    fOnRxCharEvent : TNotifyEvent;
    fOnRxEventCharEvent : TNotifyEvent;
    fOnWriteDone : TNotifyEvent;
    fOnProcessError : TNotifyErrorEvent;

    hCommPort : THandle; // Handle to the port.
    WriteOverlapped : TOverlapped; //Overlapped field for Write
    ReadOverlapped : TOverlapped;  //Overlapped field for Read
    StatusOverlapped : TOverlapped; //Overlapped field for Status
    BytesToWrite : DWord;
    WriteStartTime : DWord;
    WorkThread : TThread;
    WorkThreadIsRunning : Boolean;
    WorkThreadIsTerminated : Boolean;
    ShutdownInProgress : Boolean;
    RxDClusterList : TList;
    LastErr : Integer;
    Platform : Integer; // 0 Win32s on Win3.11, 1 Win 9x, 2 WinNT

    // Procedures for setting the variables, refrenced in the Properties
    procedure SetCommPort(value : ShortString);
    procedure SetBaudRate(value : DWord);
    procedure SetParityType(value : Byte);
    procedure SetParityErrorChar(value : Char);
    procedure SetParityErrorReplacement(value : Boolean);
    procedure SetStopBits(value : Byte);
    procedure SetDataBits(value : Byte);
    procedure SetXONChar(value : Char);
    procedure SetXOFFChar(value : Char);
    procedure SetXONLimDiv(value : Byte);
    procedure SetXOFFLimDiv(value : Byte);
    procedure SetFlowControl(value : LongInt);
    procedure SetStripNullChars(value : Boolean);
    procedure SetEventChar(value : Char);
    procedure SetRTOCharDelayTime(value : DWord);
    procedure SetRTOExtraDelayTime(value : Word);
    procedure SetWTOCharDelayTime(value : DWord);
    procedure SetWTOExtraDelayTime(value : Word);
    procedure SetXTOAuto(value : Boolean);
    procedure SetClusterSize(value : Word);
    procedure SetRxQueueSize(value : Word);
    procedure SetTxQueueSize(value : Word);
    procedure SetErrorNoise(value : Byte);
    procedure SetSignalRTS(State : Boolean);
    procedure SetSignalDTR(State : Boolean);
    procedure SetSignalBREAK(State : Boolean);
    procedure SetReadRequest(value : Boolean);
    procedure SetActive(NewState : Boolean);
    // Rest of Procedures
    procedure InitOverlapped(var Overlapped : TOverlapped; EventName : PChar);
    procedure ResetOverlapped(var Overlapped : TOverlapped);
    procedure SetupDCB;
    procedure PortWork (ReOpen : Boolean); //If ReOpen is True the Port will be (Re-) Opened, otherwise closed. The ActiveFlag will bes Set!
    procedure EnableEvents;
    procedure ProcessError(Place, Code : DWord; Msg : String; Noise : Byte);
    procedure WorkThreadDone(Sender: TObject);
  protected
  public
    // Procedures for external calling
    constructor Create(AOwner : TComponent); override; //Create the Component
    destructor Destroy; override; //Destroy
    procedure SendData (Data : Pointer; Size : DWord); //Send binary Data
    procedure SendString(S : String); //Send String Data
    // Clusterfunctions works on received Datapackages
    function NextClusterSize : Integer;
    function NextClusterCCError : DWord;
    function ReadNextCluster(var ClusterSize : Integer; var CCError : DWord) : Pointer;
    function ReadNextClusterAsString : String;
    function ReadNextClusterAsPChar(Dest : PChar) : PChar;
    // Clears the Queues
    procedure ClearTxDQueue;
    procedure ClearRxDQueue;
    // Sets the Timingfields in depedecy to the Baudrate
    procedure XTODefault;
    // Save and retrieves the Setting to/from the registry
    procedure WriteSettings(Regkey, RegSubKey : String); // e.g. WriteSettings('Software/DomIS','SerialNGAdvDemo') will save to HKEY_CURRENT_USER\Software\DomIS\SerialAdvDemo
    procedure ReadSettings(Regkey, RegSubKey : String);
  published
    //If You set Active to True, the component tries to Open the Port, if Opened the state remains True.
    property Active : Boolean read FActive write SetActive default False;
    property ComHandle : THandle read hCommPort default INVALID_HANDLE_VALUE;
    property CommPort : ShortString read fCommPort write SetCommPort;
    property BaudRate :  DWord read fBaudRate write SetBaudRate default dflt_BaudRate;
    property ParityType : Byte read fParityType write SetParityType default dflt_ParityType;
    property ParityErrorChar : Char read fParityErrorChar write SetParityErrorChar default dflt_ParityErrorChar;
    property ParityErrorReplacement :  Boolean read fParityErrorReplacement  write SetParityErrorReplacement  default dflt_ParityErrorReplacement;
    property StopBits : Byte read fStopBits write SetStopBits default dflt_StopBits;
    property DataBits : Byte read fDataBits write SetDataBits default dflt_DataBits;
    property XONChar : Char read fXONChar  write SetXONChar  default dflt_XONChar;
    property XOFFChar : Char read fXOFFChar write SetXOFFChar  default dflt_XOFFChar;
    property XONLimDiv : Byte read fXONLimDiv  write SetXONLimDiv default dflt_XOnLimDiv;
    property XOFFLimDiv : Byte read fXOFFLimDiv  write SetXOFFLimDiv default dflt_XOffLimDiv;
    property FlowControl : LongInt read fFlowControl write SetFlowControl default dflt_FlowControl;
    property StripNullChars : Boolean read fStripNullChars write SetStripNullChars default dflt_StripNullChars;
    property EventChar : Char read fEventChar write SetEventChar default dflt_EventChar;

// One part of the Clusterdefinition is here, please read carefully
// The "RTOCharDelayTime" is the Time that may delay between two received Chars
// This Time should be Computed depending from the Baudrate e.g. 9600 Baud -> 960 Chars per Second -> Delay 1ms
// You can use the CharDelayDefault Procedure to set RTOCharDelayTime and WTOCharDelayTime depending
// of the selected Baudrate!
    property RTOCharDelayTime : DWord read fRTOCharDelayTime write SetRTOCharDelayTime default dflt_RTOCharDelayTime;
// The "RTOExtraDelayTime" is the Time that may delay addionally once
// So if the (CharCount*RTOCharDelayTime)/1000 + RTOExtraDelayTime extends the measured Time, a Cluster will be build
    property RTOExtraDelayTime : Word read fRTOExtraDelayTime write SetRTOExtraDelayTime default dflt_RTOExtraDelayTime;
// Clustersize specify how long one Cluster could become max
    property ClusterSize : Word read fClusterSize write SetClusterSize default dflt_ClusterSize;
// RxQueueSize specify the amount of Chars that could be received without reading,
// this should be longer than the Cluster size to prevent overrun errors
    property RxQueueSize : Word read fRxQueueSize write SetRxQueueSize default dflt_RxQueueSize;
    property TxQueueSize : Word read fTxQueueSize write SetTxQueueSize default dflt_TxQueueSize;

    property WTOCharDelayTime : DWord read fWTOCharDelayTime write SetWTOCharDelayTime default dflt_WTOCharDelayTime;
    property WTOExtraDelayTime : Word read fWTOExtraDelayTime write SetWTOExtraDelayTime default dflt_WTOExtraDelayTime;
    property XTOAuto : Boolean read fXTOAuto write SetXTOAuto default dflt_XTOAuto;
    property RTSState : Boolean read fRTSState write SetSignalRTS default dflt_RTSState;
    property DTRState : Boolean read fDTRState write SetSignalDTR default dflt_DTRState;
    property BREAKState : Boolean read fBREAKState write SetSignalBREAK default dflt_BreakState;
    property CTSState : Boolean read fCTSState;
    property DSRState : Boolean read fDSRSTate;
    property RLSDState : Boolean read fRLSDState;
    property RingState : Boolean read fRingState;
    property ErrorNoise : Byte read fErrorNoise write SetErrorNoise default dflt_ErrorNoise;
    property ReadRequest : Boolean read fReadRequest write SetReadRequest default False;
    property SendInProgress : Boolean read fSendInProgress;
    property CommError : DWord read fCommError;
    property CommStateFlags : TComStateFlags read fCommStateFlags;
    property CommStateInQueue: DWord read fCommStateInQueue;
    property CommStateOutQueue : DWord read fCommStateOutQueue;
    property ModemState : DWord read fModemState;
    property CommEvent : DWord read fCommEvent;
    property WrittenBytes : DWord read fWrittenBytes;
    // Event Properties
    property OnCommEvent : TNotifyEvent read fOnCommEvent write fOnCommEvent;
    property OnCommStat : TNotifyEvent read fOnCommStat write fOnCommStat;
    property OnTxQueueEmptyEvent : TNotifyEvent read fOnTxQueueEmptyEvent write fOnTxQueueEmptyEvent;
    property OnWriteDone : TNotifyEvent read fOnWriteDone write fOnWriteDone;
    property OnBreakEvent : TNotifyEvent read fOnBreakEvent write fOnBreakEvent;
    property OnCTSEvent : TNotifyEvent read fOnCTSEvent write fOnCTSEvent;
    property OnDSREvent : TNotifyEvent read fOnDSREvent write fOnDSREvent;
    property OnLineErrorEvent : TNotifyEvent read fOnLineErrorEvent write fOnLineErrorEvent;
    property OnRingEvent : TNotifyEvent read fOnRingEvent write fOnRingEvent;
    property OnRLSDEvent : TNotifyEvent read fOnRLSDEvent write fOnRLSDEvent;
    property OnRxClusterEvent : TNotifyEvent read fOnRxClusterEvent write fOnRxClusterEvent;
    property OnRxCharEvent : TNotifyEvent read fOnRxCharEvent write fOnRxCharEvent;
    property OnRxEventCharEvent : TNotifyEvent read fOnRxEventCharEvent write fOnRxEventCharEvent;
    property OnProcessError : TNotifyErrorEvent read fOnProcessError write fOnProcessError;
  end;

// The TWorkThread class deals with several CommEvents and controll the receiving
// of Clusters and check the Sendprocess
// Under normal cirumstances You don't have to deal with
  TWorkThread = class(TThread)
  private
    Owner : TSerialPortNG;
    Place, Code : DWord;
    Msg : String;
    Noise : Byte;
    Cluster : TSerialCluster;
    procedure SetProcessError(APlace, ACode : DWord; AMsg : String; ANoise : Byte);
    procedure ProcessError;
    procedure RxClusterEvent;
    procedure CommEvent;
    procedure CommStatEvent;
    procedure BreakEvent;
    procedure CTSEvent;
    procedure DSREvent;
    procedure LineErrorEvent;
    procedure RingEvent;
    procedure RLSDEvent;
    procedure RxCharEvent;
    procedure RxEventCharEvent;
    procedure TxQueueEmptyEvent;
    procedure WriteDone;

  protected
  public
    constructor Create(AOwner : TSerialPortNG);
    procedure Execute; override;
  end;

procedure Register;
procedure GetCommNames(CommNames : TStrings);

implementation
uses Registry, SerialNGAdv;

var VersionInfo : TOSVersionInfo;

procedure Register;
begin
  RegisterComponents('Samples', [TSerialPortNG]);
end;

// Help function for OS Detection
function CheckOS(var VersionInfo : TOSVersionInfo) : Integer;
begin
{
    dwOSVersionInfoSize: DWORD;
    dwMajorVersion: DWORD;
    dwMinorVersion: DWORD;
    dwBuildNumber: DWORD;
    dwPlatformId: DWORD;
    szCSDVersion: array[0..127] of AnsiChar; // Maintenance string for PSS usage
}
  VersionInfo.dwOSVersionInfoSize := SizeOf(VersionInfo);
  if GetVersionEx(VersionInfo) then
    CheckOS := VersionInfo.dwPlatformId
  else
    CheckOS := -1;
end;

// Help function to collect CommPortNames
procedure GetCommNames(CommNames : TStrings);
// From:alanglloyd@aol.com (AlanGLLoyd)
// Organization:AOL, http://www.aol.co.uk
// Newsgroups:alt.comp.lang.borland-delphi

{searches the *PNP0501 and SerialComm entries in the registry fo commport
names}
var
  Reg : TRegistry;
  SerPtSL : TStringList;
  i : integer;
  CommStr : string;
const
  CommPNPKey : string = '\Enum\BIOS\*PNP0501';
  HardwareKey : string = 'HARDWARE\DEVICEMAP\SERIALCOMM';
//  HardwareKey : string = '\hardware\serialcomm';
var
  LogStr : String;
  S : String;
begin
  {stringlist to hold key or value names during search}
  SerPtSL := TStringList.Create;
  Reg := TRegistry.Create;
  with Reg do begin
    RootKey := HKEY_LOCAL_MACHINE;
    LogStr := LogStr + '  HKEY_LOCAL_MACHINE' + #13;
    {check PNP entries}
    if OpenKey(CommPNPKey, false) then begin
      LogStr := Format('%s  %s opened%s', [LogStr, CommPNPKey, #13]);
      {get all serial port keys - one key for each interupt used}
      GetKeyNames(SerPtSL);
      {get the Comm names for all the keys - into CommSL}
      for i := 0 to SerPtSL.Count - 1 do begin
        OpenKey(CommPNPKey + '\' + SerPtSL.Strings[i], false);
        if GetDataType('PortName') = rdString then begin
        // Prevent duplicate Entries (ED 18.9.2001
          S := ReadString('PortName');
          if CommNames.IndexOf(S) < 0 then begin
            CommNames.Add(S);
            LogStr := Format('%s    %s%s', [LogStr, CommNames.Strings[i], #13]);
          end;
        end;
      end; {for i := 0 to SerPtSL.Count - 1}
      end {if OpenKey(CommPNP, false) else}
    else
      LogStr := LogStr + '  Unable to open ' + CommPNPKey + #13;
    SerPtSL.Clear; // to use for hardware value names

    {check the hardware entries}

    if OpenKeyReadOnly(HardwareKey) then begin
      LogStr := Format('%s  %s opened%s', [LogStr, HardwareKey, #13]);
      {get the value names for the commports - NT is "Serialn" W95 is "COMn"}
      GetValueNames(SerPtSL);
      {now get the data value for each commport}
      for i := 0 to SerPtSL.Count - 1 do
        if GetDataType(SerPtSL.Strings[i]) = rdString then begin
          CommStr := ReadString(SerPtSL.Strings[i]);
          LogStr := LogStr + '    ' + CommStr;
          {if its not in CommNames already ...}
          if CommNames.IndexOf(CommStr) < 0 then begin
            {... add it}
            CommNames.Add(CommStr);
            LogStr := LogStr + ' added' + #13;
            end
          else
            LogStr := LogStr + ' already in list' + #13;
          end;
        end {if GetDataType(SerPtSL.Strings[i]) = rdString}
      {end; for i := 0 to SerPtSL.Count - 1}
    else
      LogStr := Format('%s  Unable to open %s', [LogStr, HardwareKey, #13]);
    {end; if OpenKey(HardwareKey, false) else}
    Free; // TFegistry
  end;
  SerPtSL.Free;
//if (SerialNGAdvDLG.ManualPort.Text <> '') and (CommNames.IndexOf(SerialNGAdvDLG.ManualPort.Text) < 0) then
//   begin
//   CommNames.Add(SerialNGAdvDLG.ManualPort.Text);
//   end;
end;

//
// TSerialCluster Component
//

constructor TSerialCluster.Create(Data : Pointer; Size : Integer; CCError : DWord);
begin
  inherited Create;
  ClusterData := Data; // Take the Pointer
  ClusterSize := Size; // Size of Data
  ClusterCCError := CCError;
end;

function TSerialCluster.GetCCError : DWord;
begin
  GetCCError := ClusterCCError;
end;

function TSerialCluster.GetSize : Integer;
begin
  GetSize := ClusterSize;
end;

procedure TSerialCluster.GetData(Dest : Pointer);
begin
  if Dest <> Nil then
    Move(ClusterData^, Dest^, ClusterSize);
end;

function TSerialCluster.GetDataAsString : String;
var S : String;
begin
  SetLength(S,ClusterSize);
  Move(ClusterData^, S[1], ClusterSize);
  GetDataAsString := S;
end;

function TSerialCluster.GetDataAsPChar(Dest : PChar) : PChar;
type TMaxSize = array[0..MaxLongInt-1] of Char;
     PMaxSize = ^TMaxSize;
begin
  if Dest <> Nil then
    begin
      Move(ClusterData^, Dest^, ClusterSize);
      PMaxSize(Dest)^[ClusterSize] := #0;
    end;
  GetDataAsPChar := Dest;
end;

destructor TSerialCluster.Destroy;
begin
  Dispose(ClusterData);
  inherited Destroy;
end;


//
// TSerialPortNG Component definition
//

//
// Serveral "Set..." procedure for the Property mapping

procedure TSerialPortNG.SetCommPort(value : ShortString);
begin
  if value <> fCommPort then
    begin
      fCommPort := value;
      PortWork(fActive);
    end;
end;

procedure TSerialPortNG.SetBaudRate(value : DWord);
begin
  if value <> fBaudRate then
    begin
      fBaudRate := value;
      if fXTOAuto then
        XTODefault; // Adjust the CharDelay Timeouts
      if fActive then
        SetupDCB;
    end;
end;

procedure TSerialPortNG.SetParityType(value : Byte);
begin
  if value <> fParityType then
    begin
      fParityType := value;
      if fActive then
        SetupDCB;
    end;
end;

procedure TSerialPortNG.SetParityErrorChar(value : Char);
begin
  if value <> fParityErrorChar then
    begin
      fParityErrorChar := value;
      if fActive then
        SetupDCB;
    end;
end;

procedure TSerialPortNG.SetParityErrorReplacement(value : Boolean);
begin
  if value <> fParityErrorReplacement then
    begin
      fParityErrorReplacement := value;
      if fActive then
        SetupDCB;
    end;
end;

procedure TSerialPortNG.SetStopBits(value : Byte);
begin
  if value <> fStopBits then
    begin
      fStopBits := value;
      if fActive then
        SetupDCB;
    end;
end;

procedure TSerialPortNG.SetDataBits(value : Byte);
begin
  if value <> fDataBits then
    begin
      fDataBits := value;
      if fActive then
        SetupDCB;
    end;
end;

procedure TSerialPortNG.SetXONChar(value : Char);
begin
  if value <> fXONChar then
    begin
      fXONChar := value;
      if fActive then
        SetupDCB;
    end;
end;

procedure TSerialPortNG.SetXOFFChar(value : Char);
begin
  if value <> fXOFFChar then
    begin
      fXOFFChar := value;
      if fActive then
        SetupDCB;
    end;
end;

procedure TSerialPortNG.SetXONLimDiv(value : Byte);
begin
  if value <> fXONLimDiv then
    begin
      if value > 100 then
        begin
          ProcessError(0100,value,'Warning XOnLimDef set to 100',enWarning);
          value := 100;
        end;
      fXONLimDiv := value;
      if fActive then
        SetupDCB;
    end;
end;

procedure TSerialPortNG.SetXOFFLimDiv(value : Byte);
begin
  if value <> fXOFFLimDiv then
    begin
      if value > 100 then
        begin
          ProcessError(0100,value,'Warning XOffLimDef set to 100',enWarning);
          value := 100;
        end;
      fXOFFLimDiv := value;
      if fActive then
        SetupDCB;
    end;
end;

procedure TSerialPortNG.SetFlowControl(value : LongInt);
begin
  if value <> fFlowControl then
    begin
      fFlowControl := value;
      if fActive then
        SetupDCB;
    end;
end;

procedure TSerialPortNG.SetStripNullChars(value : Boolean);
begin
  if value <> fStripNullChars then
    begin
      fStripNullChars := value;
      if fActive then
        SetupDCB;
    end;
end;

procedure TSerialPortNG.SetEventChar(value : Char);
begin
  if value <> fEventChar then
    begin
      fEventChar := value;
      if fActive then
        SetupDCB;
    end;
end;

procedure TSerialPortNG.SetRTOCharDelayTime(value : DWord);
begin
  if value <> fRTOCharDelayTime then
    fRTOCharDelayTime := value;
end;

procedure TSerialPortNG.SetRTOExtraDelayTime(value : Word);
begin
  if value <> fRTOExtraDelayTime then
    fRTOExtraDelayTime := value;
end;

procedure TSerialPortNG.SetWTOCharDelayTime(value : DWord);
begin
  if value <> fWTOCharDelayTime then
    begin
      fWTOCharDelayTime := value;
      if fActive then
        SetupDCB;
    end;
end;

procedure TSerialPortNG.SetWTOExtraDelayTime(value : Word);
begin
  if value <> fWTOExtraDelayTime then
    begin
      fWTOExtraDelayTime := value;
      if fActive then
        SetupDCB;
    end;
end;

procedure TSerialPortNG.SetXTOAuto(value : Boolean);
begin
  if value <> fXTOAuto then
    begin
      fXTOAuto := value;
      if fXTOAuto then
        XTODefault;
    end;
end;

procedure TSerialPortNG.SetClusterSize(value : Word);
begin
  fClusterSize := value;
end;

procedure TSerialPortNG.SetRxQueueSize(value : Word);
begin
  if value <> fRxQueueSize then
    begin
      fRxQueueSize := value;
      if not SetupComm(hCommPort,fRxQueueSize,fTxQueueSize) then
        ProcessError(0101,GetLastError,'Error can not set Quesize',enError);
    end;
end;

procedure TSerialPortNG.SetTxQueueSize(value : Word);
begin
  if value <> fTxQueueSize then
    begin
      fTxQueueSize := value;
      if not SetupComm(hCommPort,fRxQueueSize,fTxQueueSize) then
        ProcessError(0102,GetLastError,'Error can not set Quesize',enError);
    end;
end;

procedure TSerialPortNG.SetErrorNoise(value : Byte);
begin
  fErrorNoise := value;
end;

procedure TSerialPortNG.SetReadRequest(value : Boolean);
begin
  fReadRequest := value;
end;

procedure TSerialPortNG.SetActive(NewState : Boolean);
begin
  // You may expect that this function set only the fActive Value
  // This is done by the PortWork procedure, depending from the successful
  // opened Port
  if NewState <> fActive then
    PortWork(NewState);
end;

//
// Several Methods

procedure TSerialPortNG.ProcessError(Place, Code : DWord; Msg : String; Noise : Byte);
begin
  if ShutdownInProgress then Exit; // No Messages now the Component is in Destroystate
  if Noise <= fErrorNoise then
    if assigned(fOnProcessError) then
         fOnProcessError(Owner,Place,Code,Msg);
end;

//
// Init and Reset of the Overlapped Records
procedure TSerialPortNG.InitOverlapped(var Overlapped : TOverlapped; EventName : PChar);
begin
  Overlapped.Offset := 0;
  Overlapped.OffsetHigh := 0;
  Overlapped.Internal := 0;
  Overlapped.InternalHigh := 0;
  Overlapped.hEvent := CreateEvent(nil,True,False,EventName);
  if Overlapped.hEvent = 0 then
    ProcessError(1001,GetLastError,'Error Creating Overlapped Event',enError);
end;

procedure TSerialPortNG.ResetOverlapped(var Overlapped : TOverlapped);
begin
  Overlapped.Offset := 0;
  Overlapped.OffsetHigh := 0;
  Overlapped.Internal := 0;
  Overlapped.InternalHigh := 0;
  if not ResetEvent(Overlapped.hEvent) then
// EVENT_MODIFY_STATE
    ProcessError(1101,GetLastError,'Error resetting Overlapped Event',enError);
end;

//
// Create method.
constructor TSerialPortNG.Create(AOwner : TComponent);
begin
  inherited Create(AOwner);
  ShutdownInProgress := False;
  hCommPort := INVALID_HANDLE_VALUE;
  Platform := CheckOS(VersionInfo);

  // Set initial settings.  Even though
  // the default parameter was specified
  // in the property, if you were to
  // create a component at runtime, the
  // defaults would not get set.  So it
  // is important to call them again in
  // the create of the component.
  fCommPort := dflt_CommPort;
  fBaudRate := dflt_BaudRate;
  fParityType := dflt_ParityType;
  fStopBits := dflt_StopBits;
  fDataBits := dflt_DataBits;
  fXONChar := dflt_XONChar;
  fXOFFChar := dflt_XOFFChar;
  fXONLimDiv := dflt_XONLimDiv;
  fXOFFLimDiv := dflt_XOFFLimDiv;
  fFlowControl := dflt_FlowControl;
  fRTOCharDelayTime := dflt_RTOCharDelayTime;
  fRTOExtraDelayTime := dflt_RTOExtraDelayTime;
  fWTOCharDelayTime := dflt_WTOCharDelayTime;
  fWTOExtraDelayTime := dflt_WTOExtraDelayTime;
  fXTOAuto := dflt_XTOAuto;
  fClusterSize := dflt_ClusterSize;
  fRxQueueSize := dflt_RxQueueSize;
  fTxQueueSize := dflt_TxQueueSize;
  fErrorNoise := enAll;
  fReadRequest := False;
  fRTSState := dflt_RTSState;
  fDTRState := dflt_DTRState;
  fBREAKState := dflt_BREAKState;
  fOnTxQueueEmptyEvent := Nil;
  fOnBreakEvent := Nil;
  fOnCTSEvent := Nil;
  fOnDSREvent := Nil;
  fOnLineErrorEvent := Nil;
  fOnRingEvent := Nil;
  fOnRLSDEvent := Nil;
  fOnRxCharEvent := Nil;
  fOnRxEventCharEvent := Nil;
  fOnRxClusterEvent := Nil;
  fOnProcessError := Nil;

  LastErr := 0;
  RxDClusterList := TList.Create; // Create the List to store the received Clusters
  InitOverlapped(WriteOverlapped,pChar('SerialWriteEvent'));
  InitOverlapped(ReadOverlapped,pChar('SerialReadEvent'));
  InitOverlapped(StatusOverlapped,pChar('SerialStateEvent'));
  WorkThread := TWorkThread.Create(Self);
  WorkThread.OnTerminate := WorkThreadDone;
end;

// Destroy method.
destructor TSerialPortNG.Destroy;
var DestroyCtr : Integer;
    i : Integer;
begin
  ShutdownInProgress := True;
  PortWork(False);
  WorkThread.Terminate;
  DestroyCtr := 0;
  while (DestroyCtr < 5) and
    (not WorkThreadIsTerminated)do
    begin
      Sleep(250);
      Inc(DestroyCtr);
    end;
  ResetOverlapped(WriteOverlapped);
  CloseHandle(WriteOverlapped.hEvent);
  ResetOverlapped(StatusOverlapped);
  CloseHandle(StatusOverlapped.hEvent);
  ResetOverlapped(ReadOverlapped);
  CloseHandle(ReadOverlapped.hEvent);
  WorkThread.Free;
  for i := 0 to RxDClusterList.Count-1 do
    begin
      if RxDClusterList.Items[i] <> Nil then
        begin
          TSerialCluster(RxDClusterList.Items[i]).Free;
          RxDClusterList.Items[i] := Nil;
        end;
    end;
  RxDClusterList.Free;
  inherited Destroy;
end;

// PortWork Closes or Opens the Port depending of the Parm
// It sets the fActive Variable depending of result of Opening the Port
procedure TSerialPortNG.PortWork(ReOpen : Boolean);
var
  DeactivateCtr : Integer;
  CommPortName : array [0..79] of Char;
begin
  if fActive then // The Port is Open, Close first
    begin
      ProcessError(0100,0,'Msg start deactivating Port',enMsg);
      if not SetCommMask(hCommPort,0) then
        ProcessError(0101,GetLastError,'Error disabling CommEvents',enError);
      fActive := False; // The WorkThread check this Flag
      DeactivateCtr := 0;
      while (DeactivateCtr  < 20) and
         (WorkThreadIsRunning) do
        begin
          Sleep(75);
          Inc(DeactivateCtr );
        end;
      if WorkThreadIsRunning then
        ProcessError(0104,0,'Warning ThreadIsRunning',enWarning);
      if not PurgeComm(hCommPort, PURGE_RXABORT or PURGE_RXCLEAR or PURGE_TXABORT or PURGE_TXCLEAR) then
        ProcessError(0102,GetLastError,'Error clearing Queues',enError);
      SetSignalDTR(False);
      SetSignalRTS(False);
      if not CloseHandle(hCommPort) then
        ProcessError(0103,GetLastError,'Error closing Port',enError);
      hCommPort := INVALID_HANDLE_VALUE;
    end;
// The Port is Closed, the Thread is Idle
  if  ReOpen then
    begin // Reopen the Port with (new) Parms
      ProcessError(0110,0,'Msg start reactivating Port',enMsg);
      if (Length(fCommPort) > 4) and (fCommPort[1] <> '\') then
         fCommPort := '\\.\'+fCommPort;
      hCommPort := CreateFile(StrPCopy(CommPortName,Copy(fCommPort,1,79)),
            GENERIC_READ OR GENERIC_WRITE,
            0,
            nil,
            OPEN_EXISTING,
            FILE_FLAG_OVERLAPPED,0);
      fActive := (hCommPort <> INVALID_HANDLE_VALUE);
      if fActive then
        begin
          if not SetupComm(hCommPort,fRxQueueSize,fTxQueueSize) then
            ProcessError(0111,GetLastError,'Error setup Queuesize',enError);
          SetupDCB;
          SetSignalDTR(dflt_DTRState);
          SetSignalRTS(dflt_RTSState);
          EnableEvents;
        end
      else
        ProcessError(0112,GetLastError,'Error reopening Port',enError);
    end;
end;

// Internal method to enable all Events
procedure TSerialPortNG.EnableEvents;
begin
  if not SetCommMask(hCommPort, EV_BREAK or EV_CTS or EV_DSR or EV_ERR or EV_RING or EV_RLSD or EV_RXCHAR or EV_RXFLAG or EV_TXEMPTY) then
    ProcessError(0201,GetLastError,'Error activating CommEventMask',enError);
end;

// Public method to cancel and  flush the receive buffer.
procedure TSerialPortNG.ClearRxDQueue;
begin
  if fActive then
    if not PurgeComm(hCommPort,  PURGE_RXABORT or PURGE_RXCLEAR) then
      ProcessError(0301,GetLastError,'Error clearing RxD Queue',enError);
end;

// Public method to cancel and flush the transmit buffer.
procedure TSerialPortNG.ClearTxDQueue;
begin
  if fActive then
    if not PurgeComm(hCommPort,  PURGE_TXABORT or PURGE_TXCLEAR) then
      ProcessError(0401,GetLastError,'Error clearing TxD Queue',enError);
end;

// Public method to Play with the RTS Line
// It is an Error to work on this Line while in the Flowmode bmfOutxCtsFlow is set!
procedure TSerialPortNG.SetSignalRTS(State : Boolean);
begin
  if fActive then
    begin
      if State then
        begin
          if not EscapeCommFunction(hCommPort,SETRTS) then
            ProcessError(0501,GetLastError,'Error setting RTS',enError)
        end
      else
        begin
          if not EscapeCommFunction(hCommPort,CLRRTS) then
            ProcessError(0502,GetLastError,'Error clearing RTS',enError)
        end;
      fRTSState := State;
    end;
end;

// Public method to Play with the DTR Line
// It is an Error to work on this Line while in the Flowmode bmfOutxDtrFlow is set!
procedure TSerialPortNG.SetSignalDTR(State : Boolean);
begin
  if fActive then
    begin
      if State then
        begin
          if not EscapeCommFunction(hCommPort,SETDTR) then
            ProcessError(0601,GetLastError,'Error setting DTR',enError)
        end
      else
        begin
          if not EscapeCommFunction(hCommPort,CLRDTR) then
            ProcessError(0602,GetLastError,'Error clearing DTR',enError)
        end;
      fDTRState := State;
    end;
end;

// Public method to set the break State
procedure TSerialPortNG.SetSignalBREAK(State : Boolean);
begin
  if fActive then
    begin
      if State then
        begin
          if not SetCommBreak(hCommPort) then
            ProcessError(0701,GetLastError,'Error setting BREAK State',enError)
        end
      else
        begin
          if not ClearCommBreak(hCommPort) then
            ProcessError(0702,GetLastError,'Error clearing BREAK State',enError)
        end;
      fBREAKState := State;
    end;
end;

// Initialize the device control block.
procedure TSerialPortNG.SetupDCB;
var
  MyDCB : TDCB;
  MyCommTimeouts : TCommTimeouts;
//  SDCB : array[0..79] of Char;
begin
  // The GetCommState function fills in a
  // device-control block (a DCB structure)
  // with the current control settings for
  // a specified communications device.
  // (Win32 Developers Reference)
  // Get a default fill of the DCB.
  if not GetCommState(hCommPort, MyDCB) then
    begin
      ProcessError(0801,GetLastError,'Error getting DCB from CommState',enError);
      Exit;
    end;

  MyDCB.BaudRate := fBaudRate;
  MyDCB.Flags := bmfBinary; //Must be set under Win32
  if fParityType <> NOPARITY then // If a ParityType is selceted, set Paritybit automatic
    MyDCB.Flags := MyDCB.Flags or bmfParity;
  MyDCB.Parity := fParityType;
  if fParityErrorReplacement then
    MyDCB.Flags := MyDCB.Flags or bmfErrorChar;
  MyDCB.Flags := MyDCB.Flags or fFlowControl;
  if fStripNullChars then
    MyDCB.Flags := MyDCB.Flags or bmfNull;
  MyDCB.ErrorChar := fParityErrorChar;
  MyDCB.EvtChar := fEventChar;
  MyDCB.StopBits := fStopBits;
  MyDCB.ByteSize := fDataBits;
  MyDCB.XONChar := fXONChar;
  MyDCB.XOFFChar := fXOFFChar;
  MyDCB.XONLim := fRxQueueSize * fXONLimDiv div 100; // Send XOn if e.g fXONLimDiv = 33 -> 33% full
  MyDCB.XOFFLim := fRxQueueSize * fXOFFLimDiv div 100;  // Send XOff if e.g fXOffLimDiv = 33 -> 100%-33%=67% Percent full
  MyDCB.EOFChar := #0; //Ignored under Win32

  // The SetCommTimeouts function sets
  // the time-out parameters for all
  // read and write operations on a
  // specified communications device.
  // (Win32 Developers Reference)
  // The GetCommTimeouts function retrieves
  // the time-out parameters for all read
  // and write operations on a specified
  // communications device.
  GetCommTimeouts(hCommPort, MyCommTimeouts);
  //Read Timeouts are disabled here, because they realized manually in the WorkThread
  MycommTimeouts.ReadIntervalTimeout := MAXDWORD;
  MycommTimeouts.ReadTotalTimeoutMultiplier := 0;
  MycommTimeouts.ReadTotalTimeoutConstant := 0;
  //Write Timeouts disable here
  MycommTimeouts.WriteTotalTimeoutMultiplier := 0;
  MycommTimeouts.WriteTotalTimeoutConstant := 0;
  if not SetCommTimeouts(hCommPort, MyCommTimeouts) then
      ProcessError(0802,GetLastError,'Error setting CommTimeout',enError);
  if not SetCommState(hCommPort, MyDCB) then
    ProcessError(0802,GetLastError,'Error setting CommState, 87 indicate that Parms are incorrect',enError);
end;

// Public Send data method.
procedure TSerialPortNG.SendData(Data : Pointer; Size : DWord);
var MyCommTimeOuts : TCommTimeOuts;
begin
  if fSendInProgress then
    begin
      ProcessError(0901,0,'Msg, dont enter SendData while SendInProgress is set',enMsg);
      Exit;
    end
  else
    begin
      GetCommTimeouts(hCommPort, MyCommTimeouts);
      //Read Timeouts are disabled
      MycommTimeouts.ReadIntervalTimeout := MAXDWORD;
      MycommTimeouts.ReadTotalTimeoutMultiplier := 0;
      MycommTimeouts.ReadTotalTimeoutConstant := 0;
      //Write Timeouts calculated from the settings
      MycommTimeouts.WriteTotalTimeoutMultiplier := 0;
      MycommTimeouts.WriteTotalTimeoutConstant := ((fWTOCharDelayTime*Size) div 1000) + fWTOExtraDelayTime;
      if not SetCommTimeouts(hCommPort, MyCommTimeouts) then
          ProcessError(0902,GetLastError,'Error setting CommTimeout',enError);
      BytesToWrite := Size;
      if not WriteFile(hCommPort,
                Data^,
                Size,
                fWrittenBytes,
                @WriteOverlapped) then
         begin
           LastErr := GetLastError;
           if LastErr <> ERROR_IO_PENDING then
             begin
               ProcessError(0903,LastErr,'Error writing Data',enError);
               ResetOverlapped(WriteOverlapped);
               fSendInProgress := False;
             end
           else
             begin
               WriteStartTime := GetTickCount;
               fSendInProgress := True;
             end;
         end
       else  // Write was done immidiatly
         begin
           if Assigned(fOnWriteDone) then
             fOnWriteDone(Self);
         end;
     end;
end;

// Public SendString Method
procedure TSerialPortNG.SendString(S : String);
begin
  if Length(S) > 0 then
    SendData(@S[1], Length(S));
end;

// Public NextClusterSize Method
// Return the Number of Databytes
// 0..MAXINT indicates that a Cluster is available, 0 = No Bytes, but an Error code
// -1 not Cluster is available
function TSerialPortNG.NextClusterSize : Integer;
begin
  if RxDClusterList.Count > 0 then
    if RxDClusterList.Items[0] = Nil then
        RxDClusterList.Pack;
  if RxDClusterList.Count > 0 then
    NextClusterSize := TSerialCluster(RxDClusterList.Items[0]).GetSize
  else
    NextClusterSize := -1;
end;

// Public NextClusterCCError Method
// Returns the ErrorCode of the Next Cluster
// Returns MAXDWORD if no Cluster in List
function TSerialPortNG.NextClusterCCError : DWord;
begin
  if RxDClusterList.Count > 0 then
    if RxDClusterList.Items[0] = Nil then
        RxDClusterList.Pack;
  if RxDClusterList.Count > 0 then
    NextClusterCCError := TSerialCluster(RxDClusterList.Items[0]).GetCCError
  else
    NextClusterCCError := MAXDWORD;
end;

// Public Method to read and remove the next Cluster from the List
// If no Cluster is avail the Method retuns NIL
// Else, You have to deal with the Pointer, and Free him self
function TSerialPortNG.ReadNextCluster(var ClusterSize : Integer; var CCError : DWord) : Pointer;
var DataBuffer : Pointer;
begin
  if RxDClusterList.Count > 0 then
    if RxDClusterList.Items[0] = Nil then
        RxDClusterList.Pack;
  if RxDClusterList.Count > 0 then
    begin
      CCError := TSerialCluster(RxDClusterList.Items[0]).GetCCError;
      ClusterSize := TSerialCluster(RxDClusterList.Items[0]).GetSize;
      GetMem(DataBuffer, ClusterSize);
      TSerialCluster(RxDClusterList.Items[0]).GetData(DataBuffer);
      TSerialCluster(RxDClusterList.Items[0]).Free;
      RxDClusterList.Delete(0);
      ReadNextCluster := DataBuffer;
    end
  else
    begin
      ClusterSize := -1;
      CCError := MAXDWORD;
      ReadNextCluster := Nil;
    end;
end;

// Public Method to read and remove the next Cluster from the List
// The Cluster is moved into a String
function TSerialPortNG.ReadNextClusterAsString : String;
begin
  if RxDClusterList.Count > 0 then
    if RxDClusterList.Items[0] = Nil then
        RxDClusterList.Pack;
  if RxDClusterList.Count > 0 then
    begin
      ReadNextClusterAsString := TSerialCluster(RxDClusterList.Items[0]).GetDataAsString;
      TSerialCluster(RxDClusterList.Items[0]).Free;
      RxDClusterList.Delete(0);
    end
  else
    ReadNextClusterAsString := '';
end;

// Public Method to read and remove the next Cluster from the List
// The Cluster is moved into "Dest". "Dest" should Point to enough Space to avoid
// Exception Errors
function TSerialPortNG.ReadNextClusterAsPChar(Dest : PChar) : PChar;
begin
  if Dest <> Nil then
    begin
      if RxDClusterList.Count > 0 then
        if RxDClusterList.Items[0] = Nil then
            RxDClusterList.Pack;
      if RxDClusterList.Count > 0 then
        begin
          ReadNextClusterAsPChar := TSerialCluster(RxDClusterList.Items[0]).GetDataAsPChar(Dest);
          TSerialCluster(RxDClusterList.Items[0]).Free;
          RxDClusterList.Delete(0);
        end
      else
        ReadNextClusterAsPChar := Nil;
    end
  else
    ReadNextClusterAsPChar := Nil;
end;

// Private Method
procedure TSerialPortNG.WorkThreadDone(Sender: TObject);
begin
  WorkThreadIsRunning := False;
end;

// Public Method to fit the TimeOut Values to the current Baudrate
// If the Property XTOAuto is true this method will be called from the SetBaud method
procedure TSerialPortNG.XTODefault;
var i : Integer;
    NewXTO : DWord;
begin
  NewXTO := 1100;
  for i := 0 to BaudRateCount-1 do
    begin
      if fBaudRate <= BaudRates[i] then
        NewXTO := XTOCharDelayDef[i];
    end;
  SetRTOCharDelayTime(NewXTO);
  SetWTOCharDelayTime(NewXTO);
end;

// Saves all Setting into the Registry
// e.g. WriteSettings('Software/DomIS','SerialNGAdvDemo')
// will save to HKEY_CURRENT_USER\Software\DomIS\SerialAdvDemo
procedure TSerialPortNG.WriteSettings(Regkey, RegSubKey : String);

var FIniFile : TIniFile;
begin
  FIniFile := TIniFile.Create( ChangeFileExt(ParamStr(0),'.ini') );
  try
    try
    with FIniFile do
      begin
        WriteString(RegSubKey, 'CommPort', fCommPort);
        WriteString(RegSubKey, 'BaudRate', IntToStr(fBaudRate));
        WriteString(RegSubKey, 'ParityType', IntToStr(fParityType));
        WriteString(RegSubKey, 'ParityErrorChar', fParityErrorChar);
        WriteBool  (RegSubKey, 'ParityErrorReplacement', fParityErrorReplacement);
        WriteString(RegSubKey, 'StopBits', IntToStr(fStopBits));
        WriteString(RegSubKey, 'DataBits', IntToStr(fDataBits));
        WriteString(RegSubKey, 'XONChar', fXONChar);
        WriteString(RegSubKey, 'XOFFChar', fXOFFChar);
        WriteString(RegSubKey, 'XONLimDiv', IntToStr(fXONLimDiv));
        WriteString(RegSubKey, 'XOFFLimDiv', IntToStr(fXOFFLimDiv));
        WriteString(RegSubKey, 'FlowControl', IntToStr(fFlowControl));
        WriteBool  (RegSubKey, 'StripNullChars', fStripNullChars);
        WriteString(RegSubKey, 'EventChar', fEventChar);
        WriteString(RegSubKey, 'RTOCharDelayTime', IntToStr(fRTOCharDelayTime));
        WriteString(RegSubKey, 'RTOExtraDelayTime', IntToStr(fRTOExtraDelayTime));
        WriteString(RegSubKey, 'ClusterSize', IntToStr(fClusterSize));
        WriteString(RegSubKey, 'RxQueueSize', IntToStr(fRxQueueSize));
        WriteString(RegSubKey, 'TxQueueSize', IntToStr(fTxQueueSize));
        WriteString(RegSubKey, 'WTOCharDelayTime', IntToStr(fWTOCharDelayTime));
        WriteString(RegSubKey, 'WTOExtraDelayTime', IntToStr(fWTOExtraDelayTime));
        WriteBool  (RegSubKey, 'XTOAuto', fXTOAuto);
        WriteBool  (RegSubKey, 'RTSState', fRTSState);
        WriteBool  (RegSubKey, 'DTRState', fDTRState);
        WriteBool  (RegSubKey, 'BREAKState', fBREAKState);
        WriteString(RegSubKey, 'ErrorNoise', IntToStr(fErrorNoise));
        WriteBool  (RegSubKey, 'Active', FActive);
        ProcessError(0501,0,'Settings saved',enMsg);
      end;
    except
      ProcessError(0502,0,'Error saving Settings',enError);
    end;
  finally
    FIniFile.Free;
  end;
end;

// Read all Settings from the Registry
// e.g. ReadSettings('Software/DomIS','SerialNGAdvDemo')
// will read from HKEY_CURRENT_USER\Software\DomIS\SerialAdvDemo
procedure TSerialPortNG.ReadSettings(Regkey, RegSubKey : String);
var FIniFile : TIniFile;
    function CharFromStr(S : String):Char;
    begin
      if Length(S) > 0 then
        CharFromStr := S[1]
      else
        CharFromStr := #0;
    end;

begin
  FIniFile := TIniFile.Create( ChangeFileExt(ParamStr(0),'.ini') );
  try
    try
    with FIniFile do
      begin
        fCommPort := ReadString(RegSubKey, 'CommPort', dflt_CommPort);
        fBaudRate := StrToIntDef(ReadString(RegSubKey, 'BaudRate', ''),dflt_BaudRate);
        fParityType := StrToIntDef(ReadString(RegSubKey, 'ParityType', ''), dflt_ParityType);
        ParityErrorChar := CharFromStr(ReadString(RegSubKey, 'ParityErrorChar', dflt_ParityErrorChar));
        fParityErrorReplacement := ReadBool(RegSubKey, 'ParityErrorReplacement', dflt_ParityErrorReplacement);
        fStopBits := StrToIntDef(ReadString(RegSubKey, 'StopBits', ''), dflt_StopBits);
        fDataBits := StrToIntDef(ReadString(RegSubKey, 'DataBits', ''), dflt_DataBits);
        fXONChar := CharFromStr(ReadString(RegSubKey, 'XONChar', dflt_XONChar));
        fXOFFChar := CharFromStr(ReadString(RegSubKey, 'XOFFChar', dflt_XOFFChar));
        fXONLimDiv := StrToIntDef(ReadString(RegSubKey, 'XONLimDiv',''), dflt_XONLimDiv);
        fXOFFLimDiv := StrToIntDef(ReadString(RegSubKey, 'XOFFLimDiv',''), dflt_XOFFLimDiv);
        fFlowControl := StrToIntDef(ReadString(RegSubKey, 'FlowControl',''), dflt_FlowControl);
        fStripNullChars := ReadBool(RegSubKey, 'StripNullChars', dflt_StripNullChars);
        fEventChar := CharFromStr(ReadString(RegSubKey, 'EventChar', dflt_EventChar));
        fRTOCharDelayTime := StrToIntDef(ReadString(RegSubKey, 'RTOCharDelayTime',''), dflt_RTOCharDelayTime);
        fRTOExtraDelayTime := StrToIntDef(ReadString(RegSubKey, 'RTOExtraDelayTime',''), dflt_RTOExtraDelayTime);
        fClusterSize := StrToIntDef(ReadString(RegSubKey, 'ClusterSize',''), dflt_ClusterSize);
        fRxQueueSize := StrToIntDef(ReadString(RegSubKey, 'RxQueueSize',''), dflt_RxQueueSize);
        fTxQueueSize := StrToIntDef(ReadString(RegSubKey, 'TxQueueSize',''), dflt_TxQueueSize);
        fWTOCharDelayTime := StrToIntDef(ReadString(RegSubKey, 'WTOCharDelayTime',''), dflt_WTOCharDelayTime);
        fWTOExtraDelayTime := StrToIntDef(ReadString(RegSubKey, 'WTOExtraDelayTime',''), dflt_WTOExtraDelayTime);
        fXTOAuto := ReadBool(RegSubKey, 'XTOAuto', dflt_XTOAuto);
        fRTSState := ReadBool(RegSubKey, 'RTSState', dflt_RTSState);
        fDTRState := ReadBool(RegSubKey, 'DTRState', dflt_DTRState);
        fBREAKState := ReadBool  (RegSubKey, 'BREAKState', dflt_BREAKState);
        fErrorNoise := StrToIntDef(ReadString(RegSubKey, 'ErrorNoise',''), dflt_ErrorNoise);
        Active := ReadBool(RegSubKey, 'Active', False);
        ProcessError(0401,0,'Settings readed',enMsg);
      end;
    except
      ProcessError(0402,0,'Error reading Settings',enError);
    end;
  finally
    FIniFile.Free;
  end;
end;

//
// WorkThread Definitions
// The Workthread manage all the Work in the Background
// - Checks wether the writing is done
// - Checks if Data are received
// - Checks the Status
// - Calls the Events

// Saves the process error Variables
procedure TWorkThread.SetProcessError(APlace, ACode : DWord; AMsg : String; ANoise : Byte);
begin
  Place := APlace;
  Code := ACode;
  Msg := AMsg;
  Noise := ANoise;
end;

// Calls the ProcessError Eventhandler
procedure TWorkThread.ProcessError;
begin
  Owner.ProcessError(Place,Code,Msg,Noise);
end;

// Create the Thread
constructor TWorkThread.Create(AOwner : TSerialPortNG);
begin
  Owner := AOwner;
  inherited Create(False);
end;

// Events...
procedure TWorkThread.RxClusterEvent;
begin
  Owner.RxDClusterList.Add(Cluster);
  if assigned(Owner.fOnRxClusterEvent) then
    Owner.fOnRxClusterEvent(Owner);
end;
procedure TWorkThread.CommEvent;
begin
  Owner.fOnCommEvent(Owner);
end;
procedure TWorkThread.CommStatEvent;
begin
  Owner.fOnCommStat(Owner);
end;
procedure TWorkThread.BreakEvent;
begin
  Owner.fOnBreakEvent(Owner);
end;
procedure TWorkThread.CTSEvent;
begin
  Owner.fOnCTSEvent(Owner);
end;
procedure TWorkThread.DSREvent;
begin
  Owner.fOnDSREvent(Owner);
end;
procedure TWorkThread.LineErrorEvent;
begin
  Owner.fOnLineErrorEvent(Owner);
end;
procedure TWorkThread.RingEvent;
begin
  Owner.fOnRingEvent(Owner);
end;
procedure TWorkThread.RLSDEvent;
begin
  Owner.fOnRLSDEvent(Owner);
end;
procedure TWorkThread.RxCharEvent;
begin
  Owner.fOnRxCharEvent(Owner);
end;
procedure TWorkThread.RxEventCharEvent;
begin
  Owner.fOnRxEventCharEvent(Owner);
end;
procedure TWorkThread.TxQueueEmptyEvent;
begin
  Owner.fOnTxQueueEmptyEvent(Owner);
end;
procedure TWorkThread.WriteDone;
begin
  if Assigned(Owner.fOnWriteDone) then
    Owner.fOnWriteDone(Owner);
end;

//
// Workthread Maincycle
procedure TWorkThread.Execute;
var
  WrittenBytes : DWORD;
  BytesRead : DWORD;
  CommStatus : TComStat;
  CommErrorCode : DWORD;
  CommEventFlags : DWORD;
  ModemState : DWORD;
  RetCode : DWord;
  StartTime, TickTime : DWord;
  ClusterData : Pointer;
  Buffer : Pointer;
  BufferSize : DWord;
  WaitForReadEvent : Boolean;
  WaitForCommEvent : Boolean;
  HandleEvent : array[0..1] of DWord;
  ActiveMode, TerminateMode : Boolean;
  // The local Procedure evaluates the Events generated by the CommPort
  // and calles the Events of the Mainprogram
  procedure DoCommEvent;
  begin
    if Owner.ShutdownInProgress then Exit;
    Owner.fCommEvent := CommEventFlags;
    if (CommEventFlags and EV_BREAK) <> 0 then
      if assigned(Owner.fOnBreakEvent) then
         Synchronize(BreakEvent);
    if (CommEventFlags and EV_CTS) <> 0 then
      begin
        Owner.fCTSState := (ModemState and MS_CTS_ON) <> 0;
        if assigned(Owner.fOnCTSEvent) then
          Synchronize(CTSEvent);
      end;
    if (CommEventFlags and EV_DSR) <> 0 then
      begin
        Owner.fDSRState := (ModemState and MS_DSR_ON) <> 0;
        if assigned(Owner.fOnDSREvent) then
          Synchronize(DSREvent);
      end;
    if (CommEventFlags and EV_ERR) <> 0 then
      begin
        if assigned(Owner.fOnLineErrorEvent) then
          Synchronize(LineErrorEvent);
      end;
    if (CommEventFlags and EV_RING) <> 0 then
      begin
        Owner.fRingState := (ModemState and MS_RING_ON) <> 0;
        if assigned(Owner.fOnRingEvent) then
          Synchronize(RingEvent);
      end;
    if (CommEventFlags and EV_RLSD) <> 0 then
      begin
        Owner.fRLSDState := (ModemState and MS_RLSD_ON) <> 0;
        if assigned(Owner.fOnRLSDEvent) then
          Synchronize(RLSDEvent);
      end;
    if (CommEventFlags and EV_RXCHAR) <> 0 then
      begin
        if assigned(Owner.fOnRxCharEvent) then
          Synchronize(RxCharEvent);
      end;
    if (CommEventFlags and EV_RXFLAG) <> 0 then
      begin
        if assigned(Owner.fOnRxEventCharEvent) then
          Synchronize(RxEventCharEvent);
      end;
    if (CommEventFlags and EV_TXEMPTY) <> 0 then
      begin
        if assigned(Owner.fOnTxQueueEmptyEvent) then
          Synchronize(TxQueueEmptyEvent);
      end;
    if CommEventFlags <> 0 then
      if assigned(Owner.fOnCommEvent) then
         Synchronize(CommEvent);
  end;

  // This local procedure checks if the Writing is done
  procedure CheckWriter;
  begin
    if Owner.fSendInProgress then
      begin
        if GetOverlappedResult(Owner.hCommPort,Owner.WriteOverlapped,WrittenBytes, FALSE) then
          begin
            Owner.fWrittenBytes := WrittenBytes;
            Owner.fSendInProgress := False;
            if WrittenBytes <> Owner.BytesToWrite then
              begin
                SetProcessError(9701,RetCode,'Error write TimeOut',enError);
                Synchronize(ProcessError);
              end;
            Synchronize(WriteDone);
          end
        else
          begin
            RetCode := GetLastError;
            case RetCode of
              ERROR_IO_INCOMPLETE :;
              ERROR_IO_PENDING :
                begin
                  TickTime := GetTickCount;
                  if ((WrittenBytes*Owner.fWTOCharDelayTime)/1000+Owner.fWTOExtraDelayTime) < (Owner.WriteStartTime - TickTime) then
                    begin
                      Owner.fWrittenBytes := WrittenBytes;
                      Owner.fSendInProgress := False;
                      Owner.ResetOverlapped(Owner.WriteOverlapped);
                      SetProcessError(9701,RetCode,'Error write TimeOut',enError);
                      Synchronize(ProcessError);
                      Synchronize(WriteDone);
                    end;
                end;
            else
              // Its an Error!!!
              Owner.fSendInProgress := False;
              Owner.ResetOverlapped(Owner.WriteOverlapped);
              SetProcessError(9702,RetCode,'Error getting Overlapped Result',enError);
              Synchronize(ProcessError);
              Synchronize(WriteDone);
            end;
          end;
      end;
  end;

  //This procedure stores the received Cluster into the List
  procedure DoRxClusterStore;
  begin
    if not Owner.ShutdownInProgress then
      begin
        if BytesRead > 0 then
          begin
            GetMem(ClusterData,BytesRead);
            Move(Buffer^,ClusterData^,BytesRead);
            Cluster := TSerialCluster.Create(ClusterData,BytesRead,CommErrorCode);
          end
        else
           Cluster := TSerialCluster.Create(Nil,0,CommErrorCode);
        // The Storing of the Cluster into the Queue is done in the Synchronize phase
        Synchronize(RxClusterEvent);
      end;
  end;

  //Checks if Data is wainting in the RxDQueue and reads if Conditions are met
  //is called only if no Overlapp is running
  procedure ReadNoWait;
  begin
    if CommStatus.cbInQue = 0 then // No Char received
      StartTime := GetTickCount // Remember this Time as a Startpoint
    else // at least one Char was received
      begin
      // A Cluster is completed if one of the followoing conditions fit
      // - Owner request reading now
      // - cbInQue is greater than ClusterSize
      // - (cbInQue *  fRTOCharDelayTime)/1000 + fRTOExtraDelayTime is greater than the elapsed Time
      // - a (Line-) Error occoured
        TickTime := GetTickCount;
        if (Owner.fReadRequest) or
           (CommStatus.cbInQue >= Owner.ClusterSize) or
           (((CommStatus.cbInQue *  Owner.fRTOCharDelayTime)/1000 + Owner.fRTOExtraDelayTime) < (TickTime - StartTime)) or
           ((CommErrorCode and (CE_RXOVER or CE_OVERRUN or CE_RXPARITY or CE_FRAME or CE_BREAK)) <> 0) then
          begin
            BufferSize := CommStatus.cbInQue;
            GetMem(Buffer,BufferSize);
            if ReadFile(owner.hCommPort,
                               PChar(Buffer)^,
                               BufferSize,
                               BytesRead,
                               @Owner.ReadOverlapped) then
              begin //We have received something
                Owner.fReadRequest := False; // Reset the Requestflag
                DoRxClusterStore; // Store Data and fire Event...
                FreeMem(Buffer,BufferSize); // Free Buffer
                Buffer := Nil;
                StartTime := GetTickCount // Remember this Time as a Startpoint
              end
            else  // ReadFile was not successful, this may caused by the Overlapped function
              begin
                RetCode := GetLastError;
                if RetCode = ERROR_IO_PENDING then // Yes, Reading is in Progress
                  WaitForReadEvent := True
                else
                  begin // Error while reading
                    Owner.fReadRequest := False;
                    FreeMem(Buffer,BufferSize);
                    Buffer := Nil;
                    SetProcessError(9804,RetCode,'Error reading Data',enError);
                    Synchronize(ProcessError);
                  end;
              end;
          end;
      end;
  end;

  // Checks for new events
  //is called only if no Overlapp is running
  procedure CommEventNoWait;
  begin
    if WaitCommEvent(Owner.hCommPort,CommEventFlags,@Owner.StatusOverlapped) then
      DoCommEvent // Event Occours, fire Events
    else
      begin
        RetCode := GetLastError;
        if RetCode = ERROR_IO_PENDING then
          WaitForCommEvent := True //Check the Overlapped.hEvent
        else
          begin
            SetProcessError(9907,RetCode,'Error calling WaitCommEvent',enError);
            Synchronize(ProcessError);
    {Debug}                   Owner.PortWork(False);
          end;
      end;
  end;

  // Checks for received Data while an Overlapp is running
  procedure ProcessWaitForRead;
  begin
    if GetOverlappedResult(Owner.hCommPort,Owner.ReadOverlapped,BytesRead, False) then
      begin
        RetCode := GetLastError;
        if RetCode = ERROR_OPERATION_ABORTED then
          SetProcessError(9907,RetCode,'Error read aborted',enError)
        else
          SetProcessError(9908,RetCode,'Error getting Overlappedresult',enError);
        Synchronize(ProcessError);
      end
    else  // Successfull Overlapped read
      begin
        DoRxClusterStore; // Store Data and fire Event...
        FreeMem(Buffer,BufferSize); // Free Buffer
        Buffer := Nil;
        StartTime := GetTickCount // Remember this Time as a Startpoint
      end;
    WaitForReadEvent := False;
  end;

  // Checks for new Events while an Overlapp is running
  procedure ProcessWaitForComm;
///  var OvRes : DWord;
  begin

// The code below follows the Description given in the
// http://msdn.microsoft.com/library/default.asp?url=/library/en-us/dnwbgen/html/msdn_serial.asp
// Description about the Serial Communication.
// But I found that this dont work.
{
    if Owner.Platform = VER_PLATFORM_WIN32_NT then
      begin
        if GetOverlappedResult(Owner.hCommPort,Owner.StatusOverlapped, OvRes, True) then
          begin
            RetCode := GetLastError;
            case RetCode of
              ERROR_IO_PENDING :;
              ERROR_OPERATION_ABORTED :
                begin
                  SetProcessError(9909,RetCode,'Error Status aborted',enError);
                  Synchronize(ProcessError);
                  WaitForCommEvent := False;
                end;
            else
              SetProcessError(9910,RetCode,'Error getting Overlappedresult',enError);
              Synchronize(ProcessError);
              WaitForCommEvent := False;
            end;
          end
        else  // Successfull Overlapped read
          begin
            DoCommEvent;
            WaitForCommEvent := False;
          end;
      end
    else // Other Win
      begin
}
        DoCommEvent;
        WaitForCommEvent := False;
//      end;
  end;

  // Fetch the ModemStatus and CommErrorCode and CommStatus and generate
  // a CommStatEvent if something changed
  procedure GetStatus;
  begin
    if GetCommModemStatus(Owner.hCommPort,ModemState) then
      begin
       // There is a Bug in Win9x on signalizing the RING Event
       // We catch this manually here
        if Owner.Platform = VER_PLATFORM_WIN32_WINDOWS then
          begin
            if ((Owner.fModemState xor ModemState) and MS_RING_ON) <> 0 then
              // The RingIndicator Line has changed, generate the Event
              begin
                Owner.fModemState := ModemState;
                CommEventFlags := EV_RING;
                DoCommEvent;
              end;
          end;
        Owner.fModemState := ModemState;
      end
    else
      begin
        SetProcessError(9905,GetLastError,'Error getting ModemStatus',enError);
        Synchronize(ProcessError);
      end;
    if ClearCommError(owner.hCommPort, CommErrorCode, @CommStatus) then
      begin
        if (Owner.fCommError <> CommErrorCode) or
           (Owner.fCommStateFlags <> CommStatus.Flags) or
           (Owner.fCommStateInQueue <> CommStatus.cbInQue) or
           (Owner.fCommStateOutQueue <> CommStatus.cbOutQue) then
          begin
            Owner.fCommError := CommErrorCode;
            Owner.fCommStateFlags := CommStatus.Flags;
            Owner.fCommStateInQueue := CommStatus.cbInQue;
            Owner.fCommStateOutQueue := CommStatus.cbOutQue;
            if Assigned(Owner.fOnCommStat) then
              Synchronize(CommStatEvent);
          end
      end
    else
      begin
        SetProcessError(9803,GetLastError,'Error ClearCommError',enError);
        Synchronize(ProcessError);
      end
  end;

// Main Cycle of the Thread
begin
  WaitForCommEvent := False;
  WaitForReadEvent := False;
  ActiveMode := Owner.fActive;
  TerminateMode := Terminated;
  while not TerminateMode do
    begin
      if ActiveMode then
        begin
          Owner.WorkThreadIsRunning := True;
          GetStatus; // Picup several Information about the actual State of Com
          CheckWriter; // Checks for pending Writeprocess
          if (not WaitForReadEvent) and (Owner.fActive) then // Start new Action only if not deactivating
            ReadNoWait; // Reads if avail, no waiting here
          if not WaitForCommEvent and (Owner.fActive) then   // Start new Action only if not deactivating
            CommEventNoWait; // Check for Events, no waiting here
          // WaitForMultiple Events
          if (WaitForReadEvent and WaitForCommEvent) then
            begin
              HandleEvent[0] := Owner.ReadOverlapped.hEvent;
              HandleEvent[1] := Owner.StatusOverlapped.hEvent;
              RetCode := WaitForMultipleObjects(2,@HandleEvent,False,75);
              GetStatus; // Picup several Information about the actual State of Com
              case RetCode of
              WAIT_OBJECT_0 :
                begin
                  ProcessWaitForRead;
                end;
              WAIT_OBJECT_0 + 1 :
                begin
                  ProcessWaitForComm;
                end;
              WAIT_TIMEOUT :
                begin
                end;
              else
                SetProcessError(9911,RetCode,'Error getting Overlappedresult',enError);
                Synchronize(ProcessError);
                WaitForReadEvent := False;
                WaitForCommEvent := False;
              end;
            end
          else if WaitForReadEvent then
            begin
              RetCode := WaitForSingleObject(Owner.ReadOverlapped.hEvent,75);
              GetStatus; // Picup several Information about the actual State of Com
              case RetCode of
              WAIT_OBJECT_0 :
                begin
                  ProcessWaitForRead;
                end;
              WAIT_TIMEOUT :
                begin
                end;
              else
                SetProcessError(9912,RetCode,'Error getting Overlappedresult',enError);
                Synchronize(ProcessError);
                WaitForReadEvent := False;
              end;
            end
          else if WaitForCommEvent then// WaitForCommEvent
            begin
              RetCode := WaitForSingleObject(Owner.StatusOverlapped.hEvent,75);
              GetStatus; // Picup several Information about the actual State of Com
              case RetCode of
              WAIT_OBJECT_0 :
                begin
                  ProcessWaitForComm;
                end;
              WAIT_TIMEOUT :
                begin
                end;
              else
                SetProcessError(9913,RetCode,'Error getting Overlappedresult',enError);
                Synchronize(ProcessError);
                WaitForCommEvent := False;
              end;
            end;
          if not Owner.fActive then // The owner wants to deactivate the port
            begin
              if (not WaitForCommEvent) and
                 (not WaitForReadEvent) and
                 (not Owner.fSendInProgress) then
                ActiveMode := False; // We do so if everything pending is finished
            end;
        end
      else // not ActiveMode
        begin
          Owner.WorkThreadIsRunning := False;
          ActiveMode := Owner.fActive;
          Sleep(200); //prevent consuming 100% of cpu-time in inactive mode
        end;
      if Terminated and (not ActiveMode) then //No termination before deactivation
        TerminateMode := True;
    end; // while not Terminated
  Owner.WorkThreadIsTerminated := True;
end;

end.
