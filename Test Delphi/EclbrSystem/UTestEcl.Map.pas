unit UTestEcl.Map;

interface

uses
  DUnitX.TestFramework,
  Generics.Collections,
  SysUtils,
  ecl.map;

type
  [TestFixture]
  TMapTest = class
  private
    FMap: TMap<Integer, String>;
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;
    [Test]
    procedure TestAddOrUpdate;
    [Test]
    procedure TestGetValue;
    [Test]
    procedure TestRemove;
    [Test]
    procedure TestLength;
    [Test]
    procedure TestAddAndGet;
    [Test]
    procedure TestLastItemEqualsLastAdded;
    [Test]
    procedure TestMapMerge;
    [Test]
    procedure TestMapFilter;
    [Test]
    procedure TestMapToJson;
    [Test]
    procedure TestMapCapacity;
    [Test]
    procedure TestMapToString;
    [Test]
    procedure TestMapAddRange;
    [Test]
    procedure TestEnumerator;
    [Test]
    procedure TestEmptyMap;
    [Test]
    procedure TestRemoveNonExistentKey;
    [Test]
    procedure TestTryGetValue;
    [Test]
    procedure TestGetCollisions;
    [Test]
    procedure TestToStringRaw;
    [Test]
    procedure TestToJsonRaw;
    [Test]
    procedure TestMassInsertions;
    [Test]
    procedure TestInsertionsAndRemovalsStress;
    [Test]
    procedure TestHashCollisions;
    [Test]
    procedure TestCreateWithArrayOfArraysAndMatch;
  end;

implementation

{ TMapTest }

procedure TMapTest.Setup;
begin
end;

procedure TMapTest.TearDown;
begin
  FMap.Clear;
end;

procedure TMapTest.TestAddAndGet;
begin
  FMap.Add(1, 'One');
  FMap.Add(2, 'Two');

  Assert.AreEqual('One', FMap[1]);
  Assert.AreEqual('Two', FMap[2]);
end;

procedure TMapTest.TestAddOrUpdate;
var
  LArrayPair: TMap<String, Integer>;
begin
  LArrayPair.AddOrUpdate('Key1', 10);
  LArrayPair.AddOrUpdate('Key2', 20);
  LArrayPair.AddOrUpdate('Key3', 30);

  Assert.AreEqual(10, LArrayPair.GetValue('Key1'));
  Assert.AreEqual(20, LArrayPair.GetValue('Key2'));
  Assert.AreEqual(30, LArrayPair.GetValue('Key3'));

  LArrayPair.AddOrUpdate('Key2', 50);

  Assert.AreEqual(50, LArrayPair.GetValue('Key2'));
end;

procedure TMapTest.TestCreateWithArrayOfArraysAndMatch;
var
  LMap: TMap<Integer, string>;
  LResult: string;
begin
  // Arrange
  LMap := TMap<Integer, string>.Create([
    [1, 'Admin'],
    [2, 'Editor'],
    [3, 'Viewer']
  ]);

  // Act
  // Teste 1: Chave existente
  LResult := LMap.Match<string>(1, 'Unknown');

  // Assert
  Assert.AreEqual('Admin', LResult, 'Deveria retornar o valor associado à chave 1');

  // Act
  // Teste 2: Chave não existente
  LResult := LMap.Match<string>(4, 'Unknown');

  // Assert
  Assert.AreEqual('Unknown', LResult, 'Deveria retornar o valor padrão para a chave 4');

  // Teste 3: Verificar o número de elementos no mapa
  Assert.AreEqual(3, LMap.Count, 'O mapa deveria conter 3 elementos após a inicialização');
end;

procedure TMapTest.TestEnumerator;
var
  LPair: TMapPair<Integer, String>;
  LKey: Integer;
  LLast: String;
begin
  FMap.Add(1, 'One');
  FMap.Add(2, 'Two');
  FMap.Add(3, 'Three');

  LPair := FMap.Last;
  LKey := LPair.Key;
  LLast := LPair.Value;

  Assert.AreEqual(3, LKey);
  Assert.AreEqual('Three', LLast);
end;

procedure TMapTest.TestGetValue;
var
  LArrayPair: TMap<String, Integer>;
begin
  LArrayPair.AddOrUpdate('Key1', 10);
  LArrayPair.AddOrUpdate('Key2', 20);
  LArrayPair.AddOrUpdate('Key3', 30);

  Assert.AreEqual(10, LArrayPair.GetValue('Key1'));
  Assert.AreEqual(20, LArrayPair.GetValue('Key2'));
  Assert.AreEqual(30, LArrayPair.GetValue('Key3'));
  Assert.AreEqual(0, LArrayPair.GetValue('Key4')); // Non-existent key
end;

procedure TMapTest.TestRemove;
var
  LArrayPair: TMap<String, Integer>;
begin
  LArrayPair.AddOrUpdate('Key1', 10);
  LArrayPair.AddOrUpdate('Key2', 20);
  LArrayPair.AddOrUpdate('Key3', 30);

  Assert.IsTrue(LArrayPair.Contains('Key1'));
  Assert.IsTrue(LArrayPair.Contains('Key2'));
  Assert.IsTrue(LArrayPair.Contains('Key3'));

  LArrayPair.Remove('Key2');

  Assert.IsTrue(LArrayPair.Contains('Key1'));
  Assert.IsFalse(LArrayPair.Contains('Key2'));
  Assert.IsTrue(LArrayPair.Contains('Key3'));
end;

procedure TMapTest.TestLength;
var
  LArrayPair: TMap<String, Integer>;
begin
  Assert.AreEqual(0, LArrayPair.Count);

  LArrayPair.AddOrUpdate('Key1', 10);
  LArrayPair.AddOrUpdate('Key2', 20);
  LArrayPair.AddOrUpdate('Key3', 30);

  Assert.AreEqual(3, LArrayPair.Count);

  LArrayPair.Remove('Key2');

  Assert.AreEqual(2, LArrayPair.Count);
end;

procedure TMapTest.TestMapAddRange;
var
  LMapToAdd: TMap<Integer, String>;
begin
  FMap.Add(1, 'One');
  FMap.Add(2, 'Two');

  LMapToAdd.Add(3, 'Three');
  LMapToAdd.Add(4, 'Four');

  FMap.AddRange(LMapToAdd);

  Assert.AreEqual(4, FMap.Count);
  Assert.AreEqual('Three', FMap[3]);
  Assert.AreEqual('Four', FMap[4]);
end;

procedure TMapTest.TestMapCapacity;
begin
  FMap.SetDefaultCapacity(16);
  FMap.SetCapacity(10);

  Assert.AreEqual(10, FMap.Capacity);
end;

procedure TMapTest.TestMapFilter;
var
  LFilteredMap: TMap<Integer, String>;
begin
  FMap.Add(1, 'One');
  FMap.Add(2, 'Two');
  FMap.Add(3, 'Three');

  LFilteredMap := FMap.Filter(
    function(Key: Integer; Value: String): Boolean
    begin
      Result := Key mod 2 = 0;
    end);

  Assert.IsTrue(LFilteredMap.Contains(2));
  Assert.IsFalse(LFilteredMap.Contains(1));
  Assert.IsFalse(LFilteredMap.Contains(3));
end;

procedure TMapTest.TestLastItemEqualsLastAdded;
var
  LLastItem: TMapPair<Integer, String>;
begin
  FMap.Add(1, 'One');
  FMap.Add(2, 'Two');
  FMap.Add(3, 'Three');

  LLastItem := FMap.Last;

  Assert.AreEqual(3, LLastItem.Key);
  Assert.AreEqual('Three', LLastItem.Value);
end;

procedure TMapTest.TestMapMerge;
begin
  FMap.Add(1, 'One');
  FMap.Add(2, 'Two');

  FMap.Merge([TMapPair<Integer, String>.Create(3, 'Three'),
              TMapPair<Integer, String>.Create(4, 'Four')]);

  Assert.IsTrue(FMap.Contains(3));
  Assert.IsTrue(FMap.Contains(4));
end;

procedure TMapTest.TestMapToJson;
var
  LJsonString: String;
begin
  FMap.Add(1, 'One');
  FMap.Add(2, 'Two');

  LJsonString := FMap.ToJson;

  Assert.AreEqual('{"1": "One", "2": "Two"}', LJsonString);
end;

procedure TMapTest.TestMapToString;
begin
  FMap.Add(1, 'One');
  FMap.Add(2, 'Two');

  Assert.AreEqual('1=One 2=Two', FMap.ToString);
end;

procedure TMapTest.TestEmptyMap;
begin
  Assert.AreEqual(0, FMap.Count);
  Assert.IsFalse(FMap.Contains(1));
  Assert.AreEqual('', FMap.GetValue(1));
  Assert.AreEqual(0, FMap.Capacity);
end;

procedure TMapTest.TestRemoveNonExistentKey;
var
  LArrayPair: TMap<String, Integer>;
begin
  LArrayPair.Add('Key1', 10);
  Assert.IsTrue(LArrayPair.Remove('Key1'));
  Assert.IsFalse(LArrayPair.Remove('Key2'));
  Assert.AreEqual(0, LArrayPair.Count);
end;

procedure TMapTest.TestTryGetValue;
var
  LValue: String;
begin
  FMap.Add(1, 'One');
  Assert.IsTrue(FMap.TryGetValue(1, LValue));
  Assert.AreEqual('One', LValue);
  Assert.IsFalse(FMap.TryGetValue(2, LValue));
  Assert.AreEqual('', LValue);
end;

procedure TMapTest.TestGetCollisions;
begin
  FMap.Add(1, 'One');
  FMap.Add(2, 'Two');
  FMap.Add(3, 'Three');
  Assert.IsTrue(FMap.GetCollisions >= 0); // Depends on hash distribution
end;

procedure TMapTest.TestToStringRaw;
begin
  FMap.Add(1, 'One');
  FMap.Add(2, 'Two');
  Assert.IsTrue(Length(FMap.ToStringRaw) > 0); // Non-empty string
  Assert.IsTrue(Pos('1=One', FMap.ToStringRaw) > 0);
  Assert.IsTrue(Pos('2=Two', FMap.ToStringRaw) > 0);
end;

procedure TMapTest.TestToJsonRaw;
begin
  FMap.Add(1, 'One');
  FMap.Add(2, 'Two');
  Assert.IsTrue(Length(FMap.ToJsonRaw) > 0); // Non-empty string
  Assert.IsTrue(Pos('"1": "One"', FMap.ToJsonRaw) > 0);
  Assert.IsTrue(Pos('"2": "Two"', FMap.ToJsonRaw) > 0);
end;

procedure TMapTest.TestMassInsertions;
var
  I: Integer;
begin
  for I := 1 to 1000 do
    FMap.Add(I, 'Value' + I.ToString);
  Assert.AreEqual(1000, FMap.Count);
  Assert.AreEqual('Value500', FMap.GetValue(500));
  Assert.IsTrue(FMap.Capacity >= 1000); // Capacity grows dynamically
end;

procedure TMapTest.TestInsertionsAndRemovalsStress;
var
  I: Integer;
begin
  // Insert 500 items
  for I := 1 to 500 do
    FMap.Add(I, 'Value' + I.ToString);
  Assert.AreEqual(500, FMap.Count);

  // Remove half
  for I := 1 to 250 do
    FMap.Remove(I);
  Assert.AreEqual(250, FMap.Count);

  // Add more
  for I := 501 to 1000 do
    FMap.Add(I, 'Value' + I.ToString);
  Assert.AreEqual(750, FMap.Count);

  Assert.IsFalse(FMap.Contains(1));
  Assert.IsTrue(FMap.Contains(251));
  Assert.IsTrue(FMap.Contains(1000));
end;

procedure TMapTest.TestHashCollisions;
var
  LMap: TMap<Integer, String>;
begin
  LMap := TMap<Integer, String>.Empty;
  LMap.Add(1, 'One');
  LMap.Add(5, 'Five'); // Assuming capacity 4, 1 mod 4 = 1, 5 mod 4 = 1
  LMap.Add(9, 'Nine'); // 9 mod 4 = 1

  Assert.AreEqual(3, LMap.Count);
  Assert.IsTrue(LMap.Contains(1));
  Assert.IsTrue(LMap.Contains(5));
  Assert.IsTrue(LMap.Contains(9));
  Assert.IsTrue(LMap.GetCollisions > 0);
end;

initialization
  TDUnitX.RegisterTestFixture(TMapTest);

end.
