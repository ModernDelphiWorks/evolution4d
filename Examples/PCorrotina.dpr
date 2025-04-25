program PCorrotina;

uses
  FastMM4,
  Vcl.Forms,
  UCorrotina in 'UCorrotina.pas' {Form2},
  System.Evolution.Coroutine in '..\Source\System.Evolution.Coroutine.pas',
  System.Evolution.Std in '..\Source\System.Evolution.Std.pas',
  System.Evolution.System in '..\Source\System.Evolution.System.pas',
  System.Evolution.Threading in '..\Source\System.Evolution.Threading.pas';

{$R *.res}

begin
  ReportMemoryLeaksOnShutdown := True;

  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm2, Form2);
  Application.Run;
end.
