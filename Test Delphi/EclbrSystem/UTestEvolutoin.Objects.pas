unit UTestEvolutoin.Objects;

interface

uses
  DUnitX.TestFramework,
  System.Evolution.Objects;

type
  TMyClass = class
  public
    destructor Destroy; override;
    class function New: TMyClass;
    function GetMessage: String;
  end;

  [TestFixture]
  TTestObectLib = class
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;
    [Test]
    procedure TestSmartPtr_Create;
    [Test]
    procedure TestSmartPtr_New;
    [Test]
    procedure TestSmartPtr_LazyLoad;
    [Test]
    procedure TestSmartPtrRecord;
    [Test]
    procedure TestSmartPtr_Match;
    [Test]
    procedure TestSmartPtr_Scoped;
    [Test]
    procedure TestSmartPtr_IsLoaded;
  end;

implementation

uses
  SysUtils;

procedure TTestObectLib.Setup;
begin
end;

procedure TTestObectLib.TearDown;
begin
end;

procedure TTestObectLib.TestSmartPtr_Create;
var
  LOption: TSmartPtr<TMyClass>;
begin
  LOption := TSmartPtr<TMyClass>.Create(TMyClass.Create);

  Assert.IsNotNull(LOption.AsRef);
  Assert.AreEqual('Hello word', LOption.AsRef.GetMessage);
end;

procedure TTestObectLib.TestSmartPtr_New;
var
  LOption: TSmartPtr<TMyClass>;
begin
  LOption := TMyClass.New; // Convers�o impl�cita de TMyClass para TSmartPtr<TMyClass>

  Assert.IsNotNull(LOption.AsRef);
  Assert.AreEqual('Hello word', LOption.AsRef.GetMessage);
end;

procedure TTestObectLib.TestSmartPtr_LazyLoad;
var
  LOption: TSmartPtr<TMyClass>;
begin
  // Lazy loading impl�cito: LOption come�a com FValue = nil e cria sob demanda
  Assert.IsTrue(LOption.IsNull); // Ainda nulo antes do primeiro acesso
  Assert.IsNotNull(LOption.AsRef);  // Cria o objeto aqui
  Assert.IsFalse(LOption.IsNull); // N�o nulo mais
  Assert.AreEqual('Hello word', LOption.AsRef.GetMessage);
end;

procedure TTestObectLib.TestSmartPtrRecord;
var
  LObject1: TSmartPtr<TMyClass>;
  LStringBuilder: TSmartPtr<TStringBuilder>;
  LMessage: string;
begin
  // Inicializa��o expl�cita para LStringBuilder
  LStringBuilder := TStringBuilder.Create(10);
  LStringBuilder.AsRef.Append('Test');

  Assert.IsTrue(LObject1.IsNull); // Ainda n�o criado
  Assert.IsFalse(LStringBuilder.IsNull); // J� criado

  // Acesso cria LObject1
  Assert.IsNotNull(LObject1.AsRef);
  Assert.IsNotNull(LStringBuilder.AsRef);

  Assert.IsFalse(LObject1.IsNull);
  Assert.IsFalse(LStringBuilder.IsNull);

  // Armazena o resultado antes de liberar
  LMessage := LStringBuilder.AsRef.ToString;
  Assert.AreEqual('Test', LMessage);

  // Limpa o StringBuilder (n�o precisa de try-finally, pois SmartPtr gerencia)
  LStringBuilder.AsRef.Clear;
end;

procedure TTestObectLib.TestSmartPtr_Match;
var
  LOption: TSmartPtr<TMyClass>;
  LResult: string;
begin
  // Testa Match com LOption nulo
  LResult := LOption.Match<string>(
    function: string
    begin
      Result := 'Nulo';
    end,
    function(Value: TMyClass): string
    begin
      Result := Value.GetMessage;
    end);

  Assert.AreEqual('Nulo', LResult);

  // Testa Match com LOption inicializado
  LOption := TMyClass.New;
  LResult := LOption.Match<string>(
    function: string
    begin
      Result := 'Nulo';
    end,
    function(Value: TMyClass): string
    begin
      Result := Value.GetMessage;
    end);
  Assert.AreEqual('Hello word', LResult);
end;

procedure TTestObectLib.TestSmartPtr_Scoped;
var
  LOption: TSmartPtr<TMyClass>;
begin
  LOption := TMyClass.New;

  // Usa Scoped para executar uma a��o e liberar automaticamente
  LOption.Scoped(
    procedure(Value: TMyClass)
    begin
      Assert.AreEqual('Hello word', Value.GetMessage);
    end);

  // Ap�s Scoped, FSmartPtr � nil, e o objeto foi liberado
  Assert.IsTrue(LOption.IsNull);
  Assert.IsFalse(LOption.IsLoaded);
end;

procedure TTestObectLib.TestSmartPtr_IsLoaded;
var
  LOption: TSmartPtr<TMyClass>;
begin
  // Estado inicial: n�o carregado
  Assert.IsFalse(LOption.IsLoaded);
  Assert.IsTrue(LOption.IsNull);

  // Ap�s primeiro acesso, carregado
  Assert.IsNotNull(LOption.AsRef);

  Assert.IsTrue(LOption.IsLoaded);
  Assert.IsFalse(LOption.IsNull);

  // Ap�s Scoped, volta a n�o carregado
  LOption.Scoped(
    procedure(Value: TMyClass)
    begin
      // Apenas usa o valor
    end);
  Assert.IsFalse(LOption.IsLoaded);
  Assert.IsTrue(LOption.IsNull);
end;

{ TMyClass }

destructor TMyClass.Destroy;
begin
  // Debugar aqui para verificar se est� sendo liberado
  inherited;
end;

function TMyClass.GetMessage: String;
begin
  Result := 'Hello word';
end;

class function TMyClass.New: TMyClass;
begin
  Result := TMyClass.Create;
end;

initialization
  TDUnitX.RegisterTestFixture(TTestObectLib);

end.
