unit UTestEcl.Str;

interface

uses
  DUnitX.TestFramework,
  SysUtils,
  StrUtils,
  DateUtils,
  Classes,
  Generics.Collections;

type
  [TestFixture]
  TTestStd = class
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;
    [Test]
    procedure TestFilter;
    [Test]
    procedure TestCollect;
    [Test]
    procedure TestMap;
    [Test]
    procedure TestSum;
    [Test]
    procedure TestFirst;
    [Test]
    procedure TestLast;
    [Test]
    procedure TestReduce;
    [Test]
    procedure TestExists;
    [Test]
    procedure TestAll;
    [Test]
    procedure TestAny;
    [Test]
    procedure TestSort;
    [Test]
    procedure TestPartition;
    [Test]
    procedure TestTake;
    [Test]
    procedure TestSkip;
    [Test]
    procedure TestFlatMap;
    [Test]
    procedure TestGroupBy;
    [Test]
    procedure TestReverse;
    [Test]
    procedure TestCountWhere;
    [Test]
    procedure TestCharHelpers;
    [Test]
    procedure TestIntegerHelpers;
    [Test]
    procedure TestBooleanHelpers;
    [Test]
    procedure TestFloatHelpers;
    [Test]
    procedure TestDateTimeHelpers;
  end;

implementation

uses
  ecl.str,
  ecl.vector;

procedure TTestStd.Setup;
begin
  Writeln('Setup: Initializing test environment');
end;

procedure TTestStd.TearDown;
begin
  Writeln('TearDown: Cleaning up test environment');
end;

procedure TTestStd.TestFilter;
var
  LStr: String;
  LFilteredStr: String;
begin
  Writeln('TestFilter: Starting filter tests');
  // Caso 1: Filtrar vogais
  LStr := 'Hello World';
  Writeln('TestFilter: Input string = ' + LStr);
  LFilteredStr := LStr.Filter(function(C: Char): Boolean begin Result := CharInSet(C, ['A', 'E', 'I', 'O', 'U', 'a', 'e', 'i', 'o', 'u']) end);
  Assert.AreEqual('eoo', LFilteredStr, 'Caso 1: Filtrar vogais');
  Writeln('TestFilter: Caso 1 - Filtered vowels = ' + LFilteredStr);

  // Caso 2: Filtrar maiúsculas
  LStr := 'Hello World';
  Writeln('TestFilter: Input string = ' + LStr);
  LFilteredStr := LStr.Filter(function(C: Char): Boolean begin Result := CharInSet(C, ['A'..'Z']) end);
  Assert.AreEqual('HW', LFilteredStr, 'Caso 2: Filtrar maiúsculas');
  Writeln('TestFilter: Caso 2 - Filtered uppercase = ' + LFilteredStr);

  // Caso 3: Filtrar minúsculas
  LStr := 'Hello World';
  Writeln('TestFilter: Input string = ' + LStr);
  LFilteredStr := LStr.Filter(function(C: Char): Boolean begin Result := CharInSet(C, ['a'..'z']) end);
  Assert.AreEqual('elloorld', LFilteredStr, 'Caso 3: Filtrar minúsculas');
  Writeln('TestFilter: Caso 3 - Filtered lowercase = ' + LFilteredStr);

  // Caso 4: Filtrar vazio
  LStr := '';
  Writeln('TestFilter: Input string = empty');
  LFilteredStr := LStr.Filter(function(C: Char): Boolean begin Result := True end);
  Assert.AreEqual('', LFilteredStr, 'Caso 4: Filtrar string vazia');
  Writeln('TestFilter: Caso 4 - Filtered empty string = ' + LFilteredStr);
end;

procedure TTestStd.TestCollect;
var
  LStr: String;
  LCollected: TVector<String>;
begin
  Writeln('TestCollect: Starting collect test');
  LStr := 'Hello World';
  Writeln('TestCollect: Input string = ' + LStr);
  LCollected := LStr.Collect;

  Assert.AreEqual(11, LCollected.Count, 'Length should be 11');
  Assert.AreEqual('H', LCollected[0], 'First char should be H');
  Assert.AreEqual('d', LCollected[10], 'Last char should be d');
  Writeln('TestCollect: Collected into vector, Count = ' + IntToStr(LCollected.Count));
  Writeln('TestCollect: First char = ' + LCollected[0] + ', Last char = ' + LCollected[10]);
end;

procedure TTestStd.TestMap;
var
  LStr: String;
  LMappedStr: String;
begin
  Writeln('TestMap: Starting map tests');
  // Caso 1: Maiúsculas
  LStr := 'Hello World';
  Writeln('TestMap: Input string = ' + LStr);
  LMappedStr := LStr.Map(function(C: Char): Char begin Result := C.ToUpper end);
  Assert.AreEqual('HELLO WORLD', LMappedStr, 'Caso 1: Map to uppercase');
  Writeln('TestMap: Caso 1 - Mapped to uppercase = ' + LMappedStr);

  // Caso 2: Minúsculas
  LStr := 'HELLO WORLD';
  Writeln('TestMap: Input string = ' + LStr);
  LMappedStr := LStr.Map(function(C: Char): Char begin Result := C.ToLower end);
  Assert.AreEqual('hello world', LMappedStr, 'Caso 2: Map to lowercase');
  Writeln('TestMap: Caso 2 - Mapped to lowercase = ' + LMappedStr);

  // Caso 3: Asteriscos
  LStr := 'Hello World';
  Writeln('TestMap: Input string = ' + LStr);
  LMappedStr := LStr.Map(function(C: Char): Char begin Result := '*' end);
  Assert.AreEqual('***********', LMappedStr, 'Caso 3: Map to asterisks');
  Writeln('TestMap: Caso 3 - Mapped to asterisks = ' + LMappedStr);

  // Caso 4: Vazio
  LStr := '';
  Writeln('TestMap: Input string = empty');
  LMappedStr := LStr.Map(function(C: Char): Char begin Result := '*' end);
  Assert.AreEqual('', LMappedStr, 'Caso 4: Map empty string');
  Writeln('TestMap: Caso 4 - Mapped empty string = ' + LMappedStr);
end;

procedure TTestStd.TestSum;
var
  LStr: String;
  LSumResult: Integer;
begin
  Writeln('TestSum: Starting sum test');
  LStr := '12345';
  Writeln('TestSum: Input string = ' + LStr);
  LSumResult := LStr.Sum;
  Assert.AreEqual(15, LSumResult, 'Sum of "12345" should be 15');
  Writeln('TestSum: Sum of "12345" = ' + IntToStr(LSumResult));

  LStr := 'abc';
  Writeln('TestSum: Input string = ' + LStr);
  LSumResult := LStr.Sum;
  Assert.AreEqual(0, LSumResult, 'Sum of "abc" should be 0');
  Writeln('TestSum: Sum of "abc" = ' + IntToStr(LSumResult));
end;

procedure TTestStd.TestFirst;
var
  LStr: String;
  LFirstChar: Char;
begin
  Writeln('TestFirst: Starting first test');
  LStr := 'Hello World';
  Writeln('TestFirst: Input string = ' + LStr);
  LFirstChar := LStr.First;
  Assert.AreEqual('H', LFirstChar, 'First char should be H');
  Writeln('TestFirst: First char of "Hello World" = ' + LFirstChar);

  LStr := 'a';
  Writeln('TestFirst: Input string = ' + LStr);
  LFirstChar := LStr.First;
  Assert.AreEqual('a', LFirstChar, 'First char of "a" should be a');
  Writeln('TestFirst: First char of "a" = ' + LFirstChar);
end;

procedure TTestStd.TestLast;
var
  LStr: String;
  LLastChar: Char;
begin
  Writeln('TestLast: Starting last test');
  LStr := 'Hello World';
  Writeln('TestLast: Input string = ' + LStr);
  LLastChar := LStr.Last;
  Assert.AreEqual('d', LLastChar, 'Last char should be d');
  Writeln('TestLast: Last char of "Hello World" = ' + LLastChar);

  LStr := 'a';
  Writeln('TestLast: Input string = ' + LStr);
  LLastChar := LStr.Last;
  Assert.AreEqual('a', LLastChar, 'Last char of "a" should be a');
  Writeln('TestLast: Last char of "a" = ' + LLastChar);
end;

procedure TTestStd.TestReduce;
var
  LStr: String;
  LReducedResult: String;
begin
  Writeln('TestReduce: Starting reduce test');
  LStr := 'Hello';
  Writeln('TestReduce: Input string = ' + LStr);
  LReducedResult := LStr.Reduce<String>('',
    function(Accumulator: String; CharToAdd: Char): String begin Result := Accumulator + CharToAdd end);
  Assert.AreEqual('Hello', LReducedResult, 'Reduced "Hello" should be Hello');
  Writeln('TestReduce: Reduced "Hello" = ' + LReducedResult);

  LStr := '';
  Writeln('TestReduce: Input string = empty');
  LReducedResult := LStr.Reduce<String>('init',
    function(Accumulator: String; CharToAdd: Char): String begin Result := Accumulator + CharToAdd end);
  Assert.AreEqual('init', LReducedResult, 'Reduced empty string should be init');
  Writeln('TestReduce: Reduced empty string = ' + LReducedResult);
end;

procedure TTestStd.TestExists;
var
  LStr: String;
  LResultExists: Boolean;
begin
  Writeln('TestExists: Starting exists test');
  LStr := 'Hello World';
  Writeln('TestExists: Input string = ' + LStr);
  LResultExists := LStr.Exists(function(C: Char): Boolean begin Result := C = 'o' end);
  Assert.IsTrue(LResultExists, 'Should find "o" in "Hello World"');
  Writeln('TestExists: Exists "o" in "Hello World" = ' + IfThen(LResultExists, 'True', 'False'));

  LStr := 'xyz';
  Writeln('TestExists: Input string = ' + LStr);
  LResultExists := LStr.Exists(function(C: Char): Boolean begin Result := C = 'a' end);
  Assert.IsFalse(LResultExists, 'Should not find "a" in "xyz"');
  Writeln('TestExists: Exists "a" in "xyz" = ' + IfThen(LResultExists, 'True', 'False'));
end;

procedure TTestStd.TestAll;
var
  LStr: String;
  LResultAll: Boolean;
begin
  Writeln('TestAll: Starting all tests');
  LStr := 'helloworld';
  Writeln('TestAll: Input string = ' + LStr);
  LResultAll := LStr.All(function(C: Char): Boolean begin Result := CharInSet(C, ['a'..'z']) end);
  Assert.IsTrue(LResultAll, 'Caso 1: All lowercase');
  Writeln('TestAll: Caso 1 - All lowercase in "helloworld" = ' + IfThen(LResultAll, 'True', 'False'));

  LStr := 'HELLOWORLD';
  Writeln('TestAll: Input string = ' + LStr);
  LResultAll := LStr.All(function(C: Char): Boolean begin Result := CharInSet(C, ['A'..'Z']) end);
  Assert.IsTrue(LResultAll, 'Caso 2: All uppercase');
  Writeln('TestAll: Caso 2 - All uppercase in "HELLOWORLD" = ' + IfThen(LResultAll, 'True', 'False'));

  LStr := '1234567890';
  Writeln('TestAll: Input string = ' + LStr);
  LResultAll := LStr.All(function(C: Char): Boolean begin Result := CharInSet(C, ['0'..'9']) end);
  Assert.IsTrue(LResultAll, 'Caso 3: All digits');
  Writeln('TestAll: Caso 3 - All digits in "1234567890" = ' + IfThen(LResultAll, 'True', 'False'));

  LStr := 'Hello World';
  Writeln('TestAll: Input string = ' + LStr);
  LResultAll := LStr.All(function(C: Char): Boolean begin Result := C.IsLetter end);
  Assert.IsFalse(LResultAll, 'Caso 4: Not all letters');
  Writeln('TestAll: Caso 4 - All letters in "Hello World" = ' + IfThen(LResultAll, 'True', 'False'));
end;

procedure TTestStd.TestAny;
var
  LStr: String;
  LResultAny: Boolean;
begin
  Writeln('TestAny: Starting any tests');
  LStr := 'Hello World';
  Writeln('TestAny: Input string = ' + LStr);
  LResultAny := LStr.Any(function(C: Char): Boolean begin Result := C = 'o' end);
  Assert.IsTrue(LResultAny, 'Caso 1: Should find "o"');
  Writeln('TestAny: Caso 1 - Any "o" in "Hello World" = ' + IfThen(LResultAny, 'True', 'False'));

  LStr := 'Hello World';
  Writeln('TestAny: Input string = ' + LStr);
  LResultAny := LStr.Any(function(C: Char): Boolean begin Result := CharInSet(C, ['0'..'9']) end);
  Assert.IsFalse(LResultAny, 'Caso 2: Should not find digits');
  Writeln('TestAny: Caso 2 - Any digit in "Hello World" = ' + IfThen(LResultAny, 'True', 'False'));

  LStr := '';
  Writeln('TestAny: Input string = empty');
  LResultAny := LStr.Any(function(C: Char): Boolean begin Result := True end);
  Assert.IsFalse(LResultAny, 'Caso 3: Empty string should return False');
  Writeln('TestAny: Caso 3 - Any in empty string = ' + IfThen(LResultAny, 'True', 'False'));
end;

procedure TTestStd.TestSort;
var
  LStr: String;
  LSortedStr: String;
begin
  Writeln('TestSort: Starting sort test');
  LStr := 'Hello World';
  Writeln('TestSort: Input string = ' + LStr);
  LSortedStr := LStr.Sort;
  Assert.AreEqual(' HWdellloor', LSortedStr, 'Sorted "Hello World" should be " HWdellloor"');
  Writeln('TestSort: Sorted "Hello World" = ' + LSortedStr);

  LStr := 'cba';
  Writeln('TestSort: Input string = ' + LStr);
  LSortedStr := LStr.Sort;
  Assert.AreEqual('abc', LSortedStr, 'Sorted "cba" should be "abc"');
  Writeln('TestSort: Sorted "cba" = ' + LSortedStr);
end;

procedure TTestStd.TestPartition;
var
  LStr, LLeft, LRight: String;
begin
  Writeln('TestPartition: Starting partition test');
  LStr := 'Hello123World';
  Writeln('TestPartition: Input string = ' + LStr);
  LStr.Partition(function(C: Char): Boolean begin Result := CharInSet(C, ['0'..'9']) end, LLeft, LRight);
  Assert.AreEqual('HelloWorld', LLeft, 'Left partition should be "HelloWorld"');
  Assert.AreEqual('123', LRight, 'Right partition should be "123"');
  Writeln('TestPartition: Partitioned "Hello123World" - Left = ' + LLeft + ', Right = ' + LRight);

  LStr := 'abc';
  Writeln('TestPartition: Input string = ' + LStr);
  LStr.Partition(function(C: Char): Boolean begin Result := C = 'b' end, LLeft, LRight);
  Assert.AreEqual('ac', LLeft, 'Left partition should be "ac"');
  Assert.AreEqual('b', LRight, 'Right partition should be "b"');
  Writeln('TestPartition: Partitioned "abc" - Left = ' + LLeft + ', Right = ' + LRight);
end;

procedure TTestStd.TestTake;
var
  LStr: String;
begin
  Writeln('TestTake: Starting take test');
  LStr := 'Hello World';
  Writeln('TestTake: Input string = ' + LStr);
  Assert.AreEqual('Hel', LStr.Take(3), 'Take 3 should be "Hel"');
  Writeln('TestTake: Took 3 from "Hello World" = ' + LStr.Take(3));
  Assert.AreEqual('', LStr.Take(0), 'Take 0 should be empty');
  Writeln('TestTake: Took 0 from "Hello World" = ' + LStr.Take(0));
  Assert.AreEqual('Hello World', LStr.Take(20), 'Take more than length should be full string');
  Writeln('TestTake: Took 20 from "Hello World" = ' + LStr.Take(20));
end;

procedure TTestStd.TestSkip;
var
  LStr: String;
begin
  Writeln('TestSkip: Starting skip test');
  LStr := 'Hello World';
  Writeln('TestSkip: Input string = ' + LStr);
  Assert.AreEqual('lo World', LStr.Skip(3), 'Skip 3 should be "lo World"');
  Writeln('TestSkip: Skipped 3 from "Hello World" = ' + LStr.Skip(3));
  Assert.AreEqual('Hello World', LStr.Skip(0), 'Skip 0 should be full string');
  Writeln('TestSkip: Skipped 0 from "Hello World" = ' + LStr.Skip(0));
  Assert.AreEqual('', LStr.Skip(20), 'Skip more than length should be empty');
  Writeln('TestSkip: Skipped 20 from "Hello World" = ' + LStr.Skip(20));
end;

procedure TTestStd.TestFlatMap;
var
  LStr: String;
begin
  Writeln('TestFlatMap: Starting flatmap test');
  LStr := 'abc';
  Writeln('TestFlatMap: Input string = ' + LStr);
  Assert.AreEqual('aabbcc', LStr.FlatMap(function(C: Char): String begin Result := C + C end), 'FlatMap should double each char');
  Writeln('TestFlatMap: FlatMapped "abc" to doubled chars = ' + LStr.FlatMap(function(C: Char): String begin Result := C + C end));

  LStr := 'x';
  Writeln('TestFlatMap: Input string = ' + LStr);
  Assert.AreEqual('xx', LStr.FlatMap(function(C: Char): String begin Result := C + C end), 'FlatMap single char should double');
  Writeln('TestFlatMap: FlatMapped "x" to doubled char = ' + LStr.FlatMap(function(C: Char): String begin Result := C + C end));
end;

procedure TTestStd.TestGroupBy;
var
  LStr: String;
  LDict: TDictionary<String, String>;
begin
  Writeln('TestGroupBy: Starting groupby test');
  LStr := 'a1b2c3';
  Writeln('TestGroupBy: Input string = ' + LStr);
  LDict := LStr.GroupBy(function(C: Char): String begin Result := IfThen(C.IsLetter, 'letter', 'number') end);
  Assert.AreEqual('abc', LDict['letter'], 'Letters should be "abc"');
  Assert.AreEqual('123', LDict['number'], 'Numbers should be "123"');
  Writeln('TestGroupBy: Grouped "a1b2c3" - Letters = ' + LDict['letter'] + ', Numbers = ' + LDict['number']);
  LDict.Free;

  LStr := 'aaa';
  Writeln('TestGroupBy: Input string = ' + LStr);
  LDict := LStr.GroupBy(function(C: Char): String begin Result := 'same' end);
  Assert.AreEqual('aaa', LDict['same'], 'All same should be "aaa"');
  Writeln('TestGroupBy: Grouped "aaa" - Same = ' + LDict['same']);
  LDict.Free;
end;

procedure TTestStd.TestReverse;
var
  LStr: String;
begin
  Writeln('TestReverse: Starting reverse test');
  LStr := 'Hello World';
  Writeln('TestReverse: Input string = ' + LStr);
  Assert.AreEqual('dlroW olleH', LStr.Reverse, 'Reverse should be "dlroW olleH"');
  Writeln('TestReverse: Reversed "Hello World" = ' + LStr.Reverse);

  LStr := 'abc';
  Writeln('TestReverse: Input string = ' + LStr);
  Assert.AreEqual('cba', LStr.Reverse, 'Reverse "abc" should be "cba"');
  Writeln('TestReverse: Reversed "abc" = ' + LStr.Reverse);
end;

procedure TTestStd.TestCountWhere;
var
  LStr: String;
begin
  Writeln('TestCountWhere: Starting countwhere test');
  LStr := 'Hello123';
  Writeln('TestCountWhere: Input string = ' + LStr);
  Assert.AreEqual(3, LStr.CountWhere(function(C: Char): Boolean begin Result := C.IsDigit end), 'Should count 3 digits');
  Writeln('TestCountWhere: Counted digits in "Hello123" = ' + IntToStr(LStr.CountWhere(function(C: Char): Boolean begin Result := C.IsDigit end)));

  LStr := 'abc';
  Writeln('TestCountWhere: Input string = ' + LStr);
  Assert.AreEqual(0, LStr.CountWhere(function(C: Char): Boolean begin Result := C.IsDigit end), 'Should count 0 digits');
  Writeln('TestCountWhere: Counted digits in "abc" = ' + IntToStr(LStr.CountWhere(function(C: Char): Boolean begin Result := C.IsDigit end)));
end;

procedure TTestStd.TestCharHelpers;
var
  LChar: Char;
begin
  Writeln('TestCharHelpers: Starting char helpers test');
  LChar := 'a';
  Writeln('TestCharHelpers: Input char = ' + LChar);
  Assert.AreEqual('A', LChar.ToUpper, 'ToUpper "a" should be "A"');
  Writeln('TestCharHelpers: "a".ToUpper = ' + LChar.ToUpper);
  Assert.IsTrue(LChar.IsLetter, '"a" should be a letter');
  Writeln('TestCharHelpers: "a".IsLetter = ' + IfThen(LChar.IsLetter, 'True', 'False'));

  LChar := '5';
  Writeln('TestCharHelpers: Input char = ' + LChar);
  Assert.IsTrue(LChar.IsDigit, '"5" should be a digit');
  Writeln('TestCharHelpers: "5".IsDigit = ' + IfThen(LChar.IsDigit, 'True', 'False'));
  Assert.AreEqual('5', LChar.ToLower, 'ToLower "5" should be "5"');
  Writeln('TestCharHelpers: "5".ToLower = ' + LChar.ToLower);
end;

procedure TTestStd.TestIntegerHelpers;
var
  LInt: Integer;
begin
  Writeln('TestIntegerHelpers: Starting integer helpers test');
  LInt := 5;
  Writeln('TestIntegerHelpers: Input integer = ' + IntToStr(LInt));
  Assert.AreEqual(10, LInt.Map(function(x: Integer): Integer begin Result := x * 2 end), 'Map 5 * 2 should be 10');
  Writeln('TestIntegerHelpers: 5.Map(*2) = ' + IntToStr(LInt.Map(function(x: Integer): Integer begin Result := x * 2 end)));
  Assert.IsFalse(LInt.IsEven, '5 should not be even');
  Writeln('TestIntegerHelpers: 5.IsEven = ' + IfThen(LInt.IsEven, 'True', 'False'));
  Assert.AreEqual(5, LInt.Times(function(x: Integer): Integer begin Result := x + 1 end), '5.Times(+1) should be 5');
  Writeln('TestIntegerHelpers: 5.Times(+1) = ' + IntToStr(LInt.Times(function(x: Integer): Integer begin Result := x + 1 end)));

  LInt := 0;
  Writeln('TestIntegerHelpers: Input integer = ' + IntToStr(LInt));
  Assert.AreEqual(0, LInt.Times(function(x: Integer): Integer begin Result := x + 1 end), '0.Times(+1) should be 0');
  Writeln('TestIntegerHelpers: 0.Times(+1) = ' + IntToStr(LInt.Times(function(x: Integer): Integer begin Result := x + 1 end)));
end;

procedure TTestStd.TestBooleanHelpers;
var
  LBool: Boolean;
begin
  Writeln('TestBooleanHelpers: Starting boolean helpers test');
  LBool := True;
  Writeln('TestBooleanHelpers: Input boolean = True');
  Assert.AreEqual('yes', LBool.Map<String>('yes', 'no'), 'True should map to "yes"');
  Writeln('TestBooleanHelpers: True.Map("yes", "no") = ' + LBool.Map<String>('yes', 'no'));
  LBool.IfTrue(procedure begin Writeln('TestBooleanHelpers: True condition triggered') end);

  LBool := False;
  Writeln('TestBooleanHelpers: Input boolean = False');
  Assert.AreEqual('no', LBool.Map<String>('yes', 'no'), 'False should map to "no"');
  Writeln('TestBooleanHelpers: False.Map("yes", "no") = ' + LBool.Map<String>('yes', 'no'));
  LBool.IfFalse(procedure begin Writeln('TestBooleanHelpers: False condition triggered') end);
end;

procedure TTestStd.TestFloatHelpers;
var
  LFloat: Double;
begin
  Writeln('TestFloatHelpers: Starting float helpers test');
  LFloat := 3.14;
  Writeln('TestFloatHelpers: Input float = ' + FloatToStr(LFloat));
  Assert.AreEqual(6.28, LFloat.Map(function(x: Double): Double begin Result := x * 2 end), 0.001, '3.14 * 2 should be 6.28');
  Writeln('TestFloatHelpers: 3.14.Map(*2) = ' + FloatToStr(LFloat.Map(function(x: Double): Double begin Result := x * 2 end)));
  Assert.AreEqual(3, LFloat.Round, '3.14 should round to 3');
  Writeln('TestFloatHelpers: 3.14.Round = ' + IntToStr(LFloat.Round));
  Assert.IsTrue(LFloat.ApproxEqual(3.14, 0.001), '3.14 should be approx equal to 3.14');
  Writeln('TestFloatHelpers: 3.14.ApproxEqual(3.14) = ' + IfThen(LFloat.ApproxEqual(3.14, 0.001), 'True', 'False'));

  LFloat := 0.0;
  Writeln('TestFloatHelpers: Input float = ' + FloatToStr(LFloat));
  Assert.AreEqual(0, LFloat.Round, '0.0 should round to 0');
  Writeln('TestFloatHelpers: 0.0.Round = ' + IntToStr(LFloat.Round));
end;

procedure TTestStd.TestDateTimeHelpers;
var
  LDate: TDateTime;
begin
  Writeln('TestDateTimeHelpers: Starting datetime helpers test');
  LDate := Now;
  Writeln('TestDateTimeHelpers: Input datetime = ' + DateTimeToStr(LDate));
  Assert.IsTrue(LDate.Map(function(d: TDateTime): TDateTime begin Result := IncDay(d, 1) end).IsPast = LDate.IsPast, 'Mapping should preserve past state');
  Writeln('TestDateTimeHelpers: Now.AddDays(1).IsPast = ' + IfThen(LDate.AddDays(1).IsPast, 'True', 'False'));
  Writeln('TestDateTimeHelpers: Now.ToFormat("yyyy-mm-dd") = ' + LDate.ToFormat('yyyy-mm-dd'));

  LDate := EncodeDate(2020, 1, 1);
  Writeln('TestDateTimeHelpers: Input datetime = ' + DateTimeToStr(LDate));
  Assert.IsTrue(LDate.IsPast, '2020-01-01 should be past');
  Writeln('TestDateTimeHelpers: 2020-01-01.IsPast = ' + IfThen(LDate.IsPast, 'True', 'False'));
end;

initialization
  TDUnitX.RegisterTestFixture(TTestStd);

end.
