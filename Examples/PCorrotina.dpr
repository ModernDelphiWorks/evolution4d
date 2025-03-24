program PCorrotina;

uses
  FastMM4,
  Vcl.Forms,
  UCorrotina in 'UCorrotina.pas' {Form2},
  ecl.coroutine in '..\Source\ecl.coroutine.pas',
  ecl.std in '..\Source\ecl.std.pas',
  ecl.threading in '..\Source\ecl.threading.pas',
  ecl.map in '..\Source\ecl.map.pas';

{$R *.res}

begin
  ReportMemoryLeaksOnShutdown := True;

  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm2, Form2);
  Application.Run;
end.
