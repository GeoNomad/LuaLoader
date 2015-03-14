program LuaLoader;

uses
  Forms,
  LuaLoaderMain in 'LuaLoaderMain.pas' {Form1},
  netstat in 'netstat.pas' {net},
  SerialNG in 'SerialNG.pas',
  SerialNGAdv in 'SerialNGAdv.pas' {SerialNGAdvDLG};
{$R *.RES}


begin
  Application.Initialize;
  Application.Title := 'LuaLoader';
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TSerialNGAdvDLG, SerialNGAdvDLG);
  Application.CreateForm(Tnet, net);
  Application.Run;
  net.Free;
  SerialNGAdvDLG.Free;
  Halt;
  Form1.Free;
end.


