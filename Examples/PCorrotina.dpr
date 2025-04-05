program PCorrotina;

uses
  FastMM4,
  Vcl.Forms,
  UCorrotina in 'UCorrotina.pas' {Form2},
  Evolution.Coroutine in '..\Source\Evolution.Coroutine.pas',
  Evolution.Std in '..\Source\Evolution.Std.pas',
  Evolution.Threading in '..\Source\Evolution.Threading.pas',
  Evolution.System in '..\Source\Evolution.System.pas';

{$R *.res}

begin
  ReportMemoryLeaksOnShutdown := True;

  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm2, Form2);
  Application.Run;
end.
