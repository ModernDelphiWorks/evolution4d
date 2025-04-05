unit UTestEcl.Dictionary;

interface

uses
  DUnitX.TestFramework,
  Rtti,
  SysUtils,
  Generics.Collections,
  Fluent.Core,
  Fluent.Collections;

type
  TDictionaryHelperTest = class
  private
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;
    [Test]
    procedure TestForEach;
    [Test]
    procedure TestMap;
    [Test]
    procedure TestFilter;
    [Test]
    procedure TestReduce;
    [Test]
    procedure TestTake;
    [Test]
    procedure TestAny;
    [Test]
    procedure TestSkip;
    [Test]
    procedure TestZip;
  end;

implementation

{ TDictionaryHelperTest }

procedure TDictionaryHelperTest.Setup;
begin
end;

procedure TDictionaryHelperTest.TearDown;
begin
end;

procedure TDictionaryHelperTest.TestForEach;
var
  LDictionary: TFluentDictionary<Integer, String>;
  LCollectedValues: TList<String>;
begin
  LDictionary := TFluentDictionary<Integer, String>.Create;
  LCollectedValues := TList<String>.Create;
  try
    LDictionary.Add(1, 'One');
    LDictionary.Add(2, 'Two');
    LDictionary.Add(3, 'Three');

    LDictionary.AsEnumerable.ForEach(
      procedure(const Pair: TPair<Integer, String>)
      begin
        LCollectedValues.Add(Pair.Value);
      end);

    Assert.AreEqual(3, LCollectedValues.Count, 'Deveria ter coletado 3 valores');
    Assert.IsTrue(LCollectedValues.Contains('One'), 'Deveria conter "One"');
    Assert.IsTrue(LCollectedValues.Contains('Two'), 'Deveria conter "Two"');
    Assert.IsTrue(LCollectedValues.Contains('Three'), 'Deveria conter "Three"');
  finally
    LDictionary.Free;
    LCollectedValues.Free;
  end;
end;

procedure TDictionaryHelperTest.TestMap;
var
  LDictionary: IFluentDictionary<Integer, String>;
  LMapped: IFluentEnumerable<TPair<Integer, String>>;
  LResult: TDictionary<Integer, String>;
begin
  LDictionary := TFluentDictionary<Integer, String>.Create;
  try
    LDictionary.Add(1, 'One');
    LDictionary.Add(2, 'Two');
    LDictionary.Add(3, 'Three');

    LMapped := LDictionary.AsEnumerable.Map<TPair<Integer, String>>(
      function(Pair: TPair<Integer, String>): TPair<Integer, String>
      begin
        Result.Key := Pair.Key;
        Result.Value := Pair.Value + 'Mapped';
      end);

    LResult := LMapped.ToDictionary<Integer, String>(
      function(Pair: TPair<Integer, String>): Integer
      begin
        Result := Pair.Key;
      end,
      function(Pair: TPair<Integer, String>): String
      begin
        Result := Pair.Value;
      end);

    Assert.AreEqual(3, LResult.Count, 'Deveria ter 3 elementos após o Map');
    Assert.AreEqual('OneMapped', LResult[1], 'Deveria ter mapeado "One" para "OneMapped"');
    Assert.AreEqual('TwoMapped', LResult[2], 'Deveria ter mapeado "Two" para "TwoMapped"');
    Assert.AreEqual('ThreeMapped', LResult[3], 'Deveria ter mapeado "Three" para "ThreeMapped"');
  finally
    LResult.Free;
  end;
end;

procedure TDictionaryHelperTest.TestFilter;
var
  LDictionary: TFluentDictionary<Integer, String>;
  LFiltered: IFluentEnumerable<TPair<Integer, String>>;
  LResult: TDictionary<Integer, String>;
begin
  LDictionary := TFluentDictionary<Integer, String>.Create;
  try
    LDictionary.Add(1, 'One');
    LDictionary.Add(2, 'Two');
    LDictionary.Add(3, 'Three');
    LDictionary.Add(4, 'Four');

    LFiltered := LDictionary.AsEnumerable.Filter(
      function(Pair: TPair<Integer, String>): Boolean
      begin
        Result := Length(Pair.Value) = 3;
      end);

    LResult := LFiltered.ToDictionary<Integer, String>(
      function(Pair: TPair<Integer, String>): Integer
      begin
        Result := Pair.Key;
      end,
      function(Pair: TPair<Integer, String>): String
      begin
        Result := Pair.Value;
      end);

    Assert.AreEqual(2, LResult.Count, 'Deveria ter 2 elementos após o Filter');
    Assert.IsTrue(LResult.ContainsKey(1), 'Deveria conter a chave 1 (One)');
    Assert.IsTrue(LResult.ContainsKey(2), 'Deveria conter a chave 2 (Two)');
    Assert.IsFalse(LResult.ContainsKey(3), 'Não deveria conter a chave 3 (Three)');
    Assert.IsFalse(LResult.ContainsKey(4), 'Não deveria conter a chave 4 (Four)');
  finally
    LDictionary.Free;
    LResult.Free;
  end;
end;

procedure TDictionaryHelperTest.TestReduce;
var
  LDictionary: TFluentDictionary<String, Integer>;
  LResult: TPair<String, Integer>;
begin
  LDictionary := TFluentDictionary<String, Integer>.Create;
  try
    LDictionary.Add('One', 1);
    LDictionary.Add('Two', 2);
    LDictionary.Add('Three', 3);
    LDictionary.Add('Four', 4);

    LResult := LDictionary.AsEnumerable.Reduce(
      function(Acc, Current: TPair<String, Integer>): TPair<String, Integer>
      begin
        Result.Key := Acc.Key + '+' + Current.Key;
        Result.Value := Acc.Value + Current.Value;
      end,
      TPair<String, Integer>.Create('', 0));

    Assert.IsTrue(LResult.Key.Contains('One'), 'Deveria conter "One" nas chaves');
    Assert.IsTrue(LResult.Key.Contains('Two'), 'Deveria conter "Two" nas chaves');
    Assert.IsTrue(LResult.Key.Contains('Three'), 'Deveria conter "Three" nas chaves');
    Assert.IsTrue(LResult.Key.Contains('Four'), 'Deveria conter "Four" nas chaves');
    Assert.AreEqual(10, LResult.Value, 'Deveria somar os valores (1 + 2 + 3 + 4 = 10)');
  finally
    LDictionary.Free;
  end;
end;

procedure TDictionaryHelperTest.TestTake;
var
  LDictionary: TFluentDictionary<Integer, String>;
  LTaken: IFluentEnumerable<TPair<Integer, String>>;
  LResult: TDictionary<Integer, String>;
begin
  LDictionary := TFluentDictionary<Integer, String>.Create;
  try
    LDictionary.Add(1, 'One');
    LDictionary.Add(2, 'Two');
    LDictionary.Add(3, 'Three');
    LDictionary.Add(4, 'Four');

    LTaken := LDictionary.AsEnumerable.OrderBy(
      function(A, B: TPair<Integer, String>): Integer
      begin
        Result := A.Key - B.Key; // Ordena por chave (Integer) em ordem crescente
      end).Take(2);

    LResult := LTaken.ToDictionary<Integer, String>(
      function(Pair: TPair<Integer, String>): Integer
      begin
        Result := Pair.Key;
      end,
      function(Pair: TPair<Integer, String>): String
      begin
        Result := Pair.Value;
      end);

    Assert.AreEqual(2, LResult.Count, 'Deveria ter 2 elementos após o Take');
    Assert.IsTrue(LResult.ContainsKey(1), 'Deveria conter a chave 1 (One)');
    Assert.IsTrue(LResult.ContainsKey(2), 'Deveria conter a chave 2 (Two)');
    Assert.IsFalse(LResult.ContainsKey(3), 'Não deveria conter a chave 3');
    Assert.IsFalse(LResult.ContainsKey(4), 'Não deveria conter a chave 4');
  finally
    LDictionary.Free;
    LResult.Free;
  end;
end;

procedure TDictionaryHelperTest.TestSkip;
var
  LDictionary: TFluentDictionary<Integer, String>;
  LSkipped: IFluentEnumerable<TPair<Integer, String>>;
  LResult: TDictionary<Integer, String>;
begin
  LDictionary := TFluentDictionary<Integer, String>.Create;
  try
    LDictionary.Add(1, 'One');
    LDictionary.Add(2, 'Two');
    LDictionary.Add(3, 'Three');
    LDictionary.Add(4, 'Four');

    LSkipped := LDictionary.AsEnumerable.OrderBy(
      function(A, B: TPair<Integer, String>): Integer
      begin
        Result := A.Key - B.Key;
      end).Skip(2);

    LResult := LSkipped.ToDictionary<Integer, String>(
      function(Pair: TPair<Integer, String>): Integer
      begin
        Result := Pair.Key;
      end,
      function(Pair: TPair<Integer, String>): String
      begin
        Result := Pair.Value;
      end);

    Assert.AreEqual(2, LResult.Count, 'Deveria ter 2 elementos após o Skip');
    Assert.IsFalse(LResult.ContainsKey(1), 'Não deveria conter a chave 1');
    Assert.IsFalse(LResult.ContainsKey(2), 'Não deveria conter a chave 2');
    Assert.IsTrue(LResult.ContainsKey(3), 'Deveria conter a chave 3 (Three)');
    Assert.IsTrue(LResult.ContainsKey(4), 'Deveria conter a chave 4 (Four)');
  finally
    LDictionary.Free;
    LResult.Free;
  end;
end;

procedure TDictionaryHelperTest.TestAny;
var
  LDictionary: TFluentDictionary<Integer, String>;
  LHasLongValue: Boolean;
begin
  LDictionary := TFluentDictionary<Integer, String>.Create;
  try
    LDictionary.Add(1, 'One');
    LDictionary.Add(2, 'Two');
    LDictionary.Add(3, 'Three'); // 'Three' tem 5 caracteres

    // Verifica se existe um valor com comprimento maior que 4 (deve ser True)
    LHasLongValue := LDictionary.AsEnumerable.Any(
      function(Pair: TPair<Integer, String>): Boolean
      begin
        Result := Length(Pair.Value) > 4;
      end);

    Assert.IsTrue(LHasLongValue, 'Deveria ter valores com comprimento maior que 4');

    // Verifica se existe um valor com comprimento igual a 3 (deve ser True)
    LHasLongValue := LDictionary.AsEnumerable.Any(
      function(Pair: TPair<Integer, String>): Boolean
      begin
        Result := Length(Pair.Value) = 3;
      end);

    Assert.IsTrue(LHasLongValue, 'Deveria ter valores com comprimento igual a 3');
  finally
    LDictionary.Free;
  end;
end;

procedure TDictionaryHelperTest.TestZip;
var
  LDictionary1, LDictionary2: IFluentDictionary<Integer, String>;
  LZipped: IFluentEnumerable<TPair<Integer, String>>;
  LResult: TDictionary<Integer, String>;
begin
  LDictionary1 := TFluentDictionary<Integer, String>.Create;
  LDictionary2 := TFluentDictionary<Integer, String>.Create;
  try
    LDictionary1.Add(1, 'One');
    LDictionary1.Add(2, 'Two');
    LDictionary1.Add(3, 'Three');

    LDictionary2.Add(1, 'Uno');
    LDictionary2.Add(2, 'Dos');
    LDictionary2.Add(3, 'Tres');

    LZipped := LDictionary1.AsEnumerable.Zip<TPair<Integer, String>, TPair<Integer, String>>(
      LDictionary2.AsEnumerable,
      function(Pair1, Pair2: TPair<Integer, String>): TPair<Integer, String>
      begin
        Result.Key := Pair1.Key;
        Result.Value := Pair1.Value + ' | ' + Pair2.Value;
      end);

    LResult := LZipped.ToDictionary<Integer, String>(
      function(Pair: TPair<Integer, String>): Integer
      begin
        Result := Pair.Key;
      end,
      function(Pair: TPair<Integer, String>): String
      begin
        Result := Pair.Value;
      end);

    Assert.AreEqual(3, LResult.Count, 'Deveria ter 3 elementos após o Zip');
    Assert.AreEqual('One | Uno', LResult[1], 'Deveria combinar "One | Uno"');
    Assert.AreEqual('Two | Dos', LResult[2], 'Deveria combinar "Two | Dos"');
    Assert.AreEqual('Three | Tres', LResult[3], 'Deveria combinar "Three | Tres"');
  finally
    LResult.Free;
  end;
end;

initialization
  TDUnitX.RegisterTestFixture(TDictionaryHelperTest);

end.
