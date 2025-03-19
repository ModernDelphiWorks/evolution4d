unit UTestEcl.Std;

interface

uses
  DUnitX.TestFramework,
  SysUtils,
  DateUtils,
  StrUtils,
  Classes,
  Generics.Collections,
  ecl.objects,
  ecl.std,
  ecl.crypt;

type
  [TestFixture]
  TTestStd = class
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;
    [Test]
    procedure TestArrayMerge_IntegerArrays;
    [Test]
    procedure TestArrayMerge_StringArrays;
    [Test]
    procedure TestArrayCopy_StringArrays;
    [Test]
    procedure TestAsList_IntegerArray;
    [Test]
    procedure TestJoinStrings_StringArray;
    [Test]
    procedure TestJoinStrings_StringList;
    [Test]
    procedure TestRemoveTrailingChars;
    [Test]
    procedure TestIso8601ToDateTime;
    [Test]
    procedure TestDateTimeToIso8601;
    [Test]
    procedure TestDecodeBase64;
    [Test]
    procedure TestEncodeBase64;
    [Test]
    procedure TestEncodeString;
    [Test]
    procedure TestDecodeString;
    [Test]
    procedure TestMinInteger;
    [Test]
    procedure TestMinDouble;
    [Test]
    procedure TestMinCurrency;
    [Test]
    procedure TestSplit;
    [Test]
    procedure TestArrayReduce;
    [Test]
    procedure TestArrayMap;
    [Test]
    procedure TestArrayFilter;
    [Test]
    procedure TestForEach;
    [Test]
    procedure TestAny;
    [Test]
    procedure TestAll;
    [Test]
    procedure TestArrayTake;
    [Test]
    procedure TestArraySkip;
    [Test]
    procedure TestArrayFlatMap;
    [Test]
    procedure TestArrayPartition;
    [Test]
    procedure TestArrayGroupBy;
    [Test]
    procedure TestArrayReverse;
    [Test]
    procedure TestArrayDistinct;
    [Test]
    procedure TestArrayZip;
    [Test]
    procedure TestArrayToFuture;
  end;

implementation

uses
  ecl.map;

procedure TTestStd.Setup;
begin
  Writeln('Setup: Initializing test environment');
end;

procedure TTestStd.TearDown;
begin
  Writeln('TearDown: Cleaning up test environment');
end;

procedure TTestStd.TestArrayMerge_IntegerArrays;
var
  LArray1, LArray2, LMergedArray: TArray<Integer>;
  LFor: Integer;
const
  LExpectedArray: TArray<Integer> = [1, 2, 3, 4, 5, 6];
begin
  Writeln('TestArrayMerge_IntegerArrays: Starting merge test');
  SetLength(LArray1, 3);
  LArray1[0] := 1; LArray1[1] := 2; LArray1[2] := 3;
  Writeln('TestArrayMerge_IntegerArrays: Input array1 = [1, 2, 3]');
  SetLength(LArray2, 3);
  LArray2[0] := 4; LArray2[1] := 5; LArray2[2] := 6;
  Writeln('TestArrayMerge_IntegerArrays: Input array2 = [4, 5, 6]');
  LMergedArray := TArrayEx.Merge<Integer>(LArray1, LArray2);
  Writeln('TestArrayMerge_IntegerArrays: Merged array length = ' + IntToStr(Length(LMergedArray)));
  Assert.AreEqual(Length(LExpectedArray), Length(LMergedArray), 'Merged array length should be 6');
  for LFor := Low(LExpectedArray) to High(LExpectedArray) do
  begin
    Assert.AreEqual(LExpectedArray[LFor], LMergedArray[LFor], 'Element at index ' + IntToStr(LFor) + ' should match');
    Writeln('TestArrayMerge_IntegerArrays: Element[' + IntToStr(LFor) + '] = ' + IntToStr(LMergedArray[LFor]));
  end;
end;

procedure TTestStd.TestArrayMerge_StringArrays;
var
  LArray1, LArray2, LMergedArray: TArray<String>;
  LFor: Integer;
const
  LExpectedArray: TArray<String> = ['Hello', 'World', 'DUnitX', 'Testing'];
begin
  Writeln('TestArrayMerge_StringArrays: Starting merge test');
  SetLength(LArray1, 2);
  LArray1[0] := 'Hello'; LArray1[1] := 'World';
  Writeln('TestArrayMerge_StringArrays: Input array1 = [Hello, World]');
  SetLength(LArray2, 2);
  LArray2[0] := 'DUnitX'; LArray2[1] := 'Testing';
  Writeln('TestArrayMerge_StringArrays: Input array2 = [DUnitX, Testing]');
  LMergedArray := TArrayEx.Merge<String>(LArray1, LArray2);
  Writeln('TestArrayMerge_StringArrays: Merged array length = ' + IntToStr(Length(LMergedArray)));
  Assert.AreEqual(Length(LExpectedArray), Length(LMergedArray), 'Merged array length should be 4');
  for LFor := Low(LExpectedArray) to High(LExpectedArray) do
  begin
    Assert.AreEqual(LExpectedArray[LFor], LMergedArray[LFor], 'Element at index ' + IntToStr(LFor) + ' should match');
    Writeln('TestArrayMerge_StringArrays: Element[' + IntToStr(LFor) + '] = ' + LMergedArray[LFor]);
  end;
end;

procedure TTestStd.TestArrayCopy_StringArrays;
var
  LSourceArray, LCopiedArray: TArray<String>;
  LIndex: Integer;
const
  LExpectedArray: TArray<String> = ['Item1', 'Item2', 'Item3'];
begin
  Writeln('TestArrayCopy_StringArrays: Starting copy test');
  LSourceArray := TArray<String>.Create('Item0', 'Item1', 'Item2', 'Item3', 'Item4');
  Writeln('TestArrayCopy_StringArrays: Input array = [Item0, Item1, Item2, Item3, Item4]');
  LCopiedArray := TArrayEx.Copy<String>(LSourceArray, 1, 0, 3);
  Writeln('TestArrayCopy_StringArrays: Copied array length = ' + IntToStr(Length(LCopiedArray)));
  Assert.AreEqual(Length(LExpectedArray), Length(LCopiedArray), 'Copied array length should be 3');
  for LIndex := Low(LExpectedArray) to High(LExpectedArray) do
  begin
    Assert.AreEqual(LExpectedArray[LIndex], LCopiedArray[LIndex], 'Element at index ' + IntToStr(LIndex) + ' should match');
    Writeln('TestArrayCopy_StringArrays: Element[' + IntToStr(LIndex) + '] = ' + LCopiedArray[LIndex]);
  end;
end;

procedure TTestStd.TestAsList_IntegerArray;
var
  LInputArray: TArray<Integer>;
  LList: TList<Integer>;
  LLength, LFor: Integer;
begin
  Writeln('TestAsList_IntegerArray: Starting aslist test');
  LInputArray := TArray<Integer>.Create(1, 2, 3, 4, 5);
  Writeln('TestAsList_IntegerArray: Input array = [1, 2, 3, 4, 5]');
  LList := TArrayEx.AsList<Integer>(LInputArray);
  try
    LLength := Length(LInputArray);
    Assert.AreEqual(LLength, Integer(LList.Count), 'List count should be 5');
    Writeln('TestAsList_IntegerArray: List count = ' + IntToStr(LList.Count));
    for LFor := 0 to High(LInputArray) do
    begin
      Assert.AreEqual(LInputArray[LFor], LList[LFor], 'Element at index ' + IntToStr(LFor) + ' should match');
      Writeln('TestAsList_IntegerArray: Element[' + IntToStr(LFor) + '] = ' + IntToStr(LList[LFor]));
    end;
  finally
    LList.Free;
  end;
end;

procedure TTestStd.TestJoinStrings_StringArray;
var
  LStrings: TArray<String>;
  LSeparator, LResultString: String;
begin
  Writeln('TestJoinStrings_StringArray: Starting join test');
  LStrings := TArray<String>.Create('Hello', 'World', 'DUnitX', 'Testing');
  Writeln('TestJoinStrings_StringArray: Input array = [Hello, World, DUnitX, Testing]');
  LSeparator := ', ';
  LResultString := TStd.JoinStrings(LStrings, LSeparator);
  Assert.AreEqual('Hello, World, DUnitX, Testing', LResultString, 'Joined string should match');
  Writeln('TestJoinStrings_StringArray: Joined string = ' + LResultString);
end;

procedure TTestStd.TestJoinStrings_StringList;
var
  LSeparator, LResultString: String;
  LIAutoRef: TSmartPtr<TListString>;
begin
  Writeln('TestJoinStrings_StringList: Starting join test');
  LIAutoRef := TListString.Create;
  LIAutoRef.AsRef.Add('Hello');
  LIAutoRef.AsRef.Add('World');
  LIAutoRef.AsRef.Add('DUnitX');
  LIAutoRef.AsRef.Add('Testing');
  Writeln('TestJoinStrings_StringList: Input list = [Hello, World, DUnitX, Testing]');
  LSeparator := ', ';
  LResultString := TStd.JoinStrings(LIAutoRef.AsRef, LSeparator);
  Assert.AreEqual('Hello, World, DUnitX, Testing', LResultString, 'Joined string should match');
  Writeln('TestJoinStrings_StringList: Joined string = ' + LResultString);
end;

procedure TTestStd.TestRemoveTrailingChars;
var
  LInputString, LResultString: String;
  LTrailingChars: TSysCharSet;
begin
  Writeln('TestRemoveTrailingChars: Starting remove test');
  LInputString := 'Hello, World!!!';
  Writeln('TestRemoveTrailingChars: Input string = ' + LInputString);
  LTrailingChars := ['!', ','];
  LResultString := TStd.RemoveTrailingChars(LInputString, LTrailingChars);
  Assert.AreEqual('Hello, World', LResultString, 'String should have trailing chars removed');
  Writeln('TestRemoveTrailingChars: Result string = ' + LResultString);
end;

procedure TTestStd.TestIso8601ToDateTime;
var
  LIso8601DateString: String;
  LResultDateTime: TDateTime;
begin
  Writeln('TestIso8601ToDateTime: Starting ISO conversion test');
  LIso8601DateString := '2023-09-26T14:30:00';
  Writeln('TestIso8601ToDateTime: Input ISO string = ' + LIso8601DateString);
  LResultDateTime := TStd.Iso8601ToDateTime(LIso8601DateString, True);
  Assert.AreEqual(2023, YearOf(LResultDateTime), 'Year should be 2023');
  Assert.AreEqual(9, MonthOf(LResultDateTime), 'Month should be 9');
  Assert.AreEqual(26, DayOf(LResultDateTime), 'Day should be 26');
  Assert.AreEqual(14, HourOf(LResultDateTime), 'Hour should be 14');
  Assert.AreEqual(30, MinuteOf(LResultDateTime), 'Minute should be 30');
  Assert.AreEqual(0, SecondOf(LResultDateTime), 'Second should be 0');
  Writeln('TestIso8601ToDateTime: Converted datetime = ' + DateTimeToStr(LResultDateTime));
end;

procedure TTestStd.TestDateTimeToIso8601;
var
  LInputDateTime: TDateTime;
  LResultString: String;
begin
  Writeln('TestDateTimeToIso8601: Starting ISO conversion test');
  LInputDateTime := EncodeDateTime(2023, 9, 26, 14, 30, 0, 0);
  Writeln('TestDateTimeToIso8601: Input datetime = ' + DateTimeToStr(LInputDateTime));
  LResultString := TStd.DateTimeToIso8601(LInputDateTime, True);
  Assert.AreEqual('2023-09-26T14:30:00', LResultString, 'ISO string should match');
  Writeln('TestDateTimeToIso8601: Result ISO string = ' + LResultString);
end;

procedure TTestStd.TestDecodeBase64;
var
  LInputBase64: String;
  LResultBytes: TBytes;
  LDecodedString: String;
begin
  Writeln('TestDecodeBase64: Starting decode test');
  LInputBase64 := 'SGVsbG8sIFdvcmxkIQ==';
  Writeln('TestDecodeBase64: Input base64 = ' + LInputBase64);
  LResultBytes := TCrypt.DecodeBase64(LInputBase64);
  LDecodedString := StringOf(LResultBytes);
  Assert.AreEqual('Hello, World!', LDecodedString, 'Decoded string should match');
  Writeln('TestDecodeBase64: Decoded string = ' + LDecodedString);
end;

procedure TTestStd.TestEncodeBase64;
var
  LInputData: TBytes;
  LResultString: String;
begin
  Writeln('TestEncodeBase64: Starting encode test');
  SetLength(LInputData, 13);
  LInputData[0] := Ord('H'); LInputData[1] := Ord('e'); LInputData[2] := Ord('l');
  LInputData[3] := Ord('l'); LInputData[4] := Ord('o'); LInputData[5] := Ord(',');
  LInputData[6] := Ord(' '); LInputData[7] := Ord('W'); LInputData[8] := Ord('o');
  LInputData[9] := Ord('r'); LInputData[10] := Ord('l'); LInputData[11] := Ord('d');
  LInputData[12] := Ord('!');
  Writeln('TestEncodeBase64: Input string = Hello, World!');
  LResultString := TCrypt.EncodeBase64(@LInputData[0], Length(LInputData));
  Assert.AreEqual('SGVsbG8sIFdvcmxkIQ==', LResultString, 'Encoded base64 should match');
  Writeln('TestEncodeBase64: Encoded base64 = ' + LResultString);
end;

procedure TTestStd.TestEncodeString;
var
  LInputString, LResultString: String;
begin
  Writeln('TestEncodeString: Starting encode test');
  LInputString := 'Hello, World!';
  Writeln('TestEncodeString: Input string = ' + LInputString);
  LResultString := TCrypt.EncodeString(LInputString);
  Assert.AreEqual('SGVsbG8sIFdvcmxkIQ==', LResultString, 'Encoded base64 should match');
  Writeln('TestEncodeString: Encoded base64 = ' + LResultString);
end;

procedure TTestStd.TestDecodeString;
var
  LInputString, LResultString: String;
begin
  Writeln('TestDecodeString: Starting decode test');
  LInputString := 'SGVsbG8sIFdvcmxkIQ==';
  Writeln('TestDecodeString: Input base64 = ' + LInputString);
  LResultString := TCrypt.DecodeString(LInputString);
  Assert.AreEqual('Hello, World!', LResultString, 'Decoded string should match');
  Writeln('TestDecodeString: Decoded string = ' + LResultString);
end;

procedure TTestStd.TestMinInteger;
var
  LA, LB, LResultValue: Integer;
begin
  Writeln('TestMinInteger: Starting min test');
  LA := 5; LB := 10;
  Writeln('TestMinInteger: Input A = ' + IntToStr(LA) + ', B = ' + IntToStr(LB));
  LResultValue := TStd.Min(LA, LB);
  Assert.AreEqual(5, LResultValue, 'Min(A, B) should return 5');
  Writeln('TestMinInteger: Min result = ' + IntToStr(LResultValue));
end;

procedure TTestStd.TestMinDouble;
var
  LA, LB, LResultValue: Double;
begin
  Writeln('TestMinDouble: Starting min test');
  LA := 3.14; LB := 2.71;
  Writeln('TestMinDouble: Input A = ' + FloatToStr(LA) + ', B = ' + FloatToStr(LB));
  LResultValue := TStd.Min(LA, LB);
  Assert.AreEqual(2.71, LResultValue, 0.001, 'Min(A, B) should return 2.71');
  Writeln('TestMinDouble: Min result = ' + FloatToStr(LResultValue));
end;

procedure TTestStd.TestMinCurrency;
var
  LA, LB, LResultValue: Currency;
begin
  Writeln('TestMinCurrency: Starting min test');
  LA := 100.50; LB := 99.99;
  Writeln('TestMinCurrency: Input A = ' + CurrToStr(LA) + ', B = ' + CurrToStr(LB));
  LResultValue := TStd.Min(LA, LB);
  Assert.AreEqual(Currency(99.99), LResultValue, 'Min(A, B) should return 99.99');
  Writeln('TestMinCurrency: Min result = ' + CurrToStr(LResultValue));
end;

procedure TTestStd.TestSplit;
var
  LS: String;
  LResultArray: TArray<String>;
  LFor: Integer;
begin
  Writeln('TestSplit: Starting split test');
  LS := 'Hello,World';
  Writeln('TestSplit: Input string = ' + LS);
  LResultArray := TStd.Split(LS);
  Assert.AreEqual(11, Length(LResultArray), 'Split should return 11 elements');
  Writeln('TestSplit: Split array length = ' + IntToStr(Length(LResultArray)));
  Assert.AreEqual('H', LResultArray[0], 'Element[0] should be "H"');
  Assert.AreEqual('e', LResultArray[1], 'Element[1] should be "e"');
  Assert.AreEqual('l', LResultArray[2], 'Element[2] should be "l"');
  Assert.AreEqual('l', LResultArray[3], 'Element[3] should be "l"');
  Assert.AreEqual('o', LResultArray[4], 'Element[4] should be "o"');
  Assert.AreEqual(',', LResultArray[5], 'Element[5] should be ","');
  Assert.AreEqual('W', LResultArray[6], 'Element[6] should be "W"');
  Assert.AreEqual('o', LResultArray[7], 'Element[7] should be "o"');
  Assert.AreEqual('r', LResultArray[8], 'Element[8] should be "r"');
  Assert.AreEqual('l', LResultArray[9], 'Element[9] should be "l"');
  Assert.AreEqual('d', LResultArray[10], 'Element[10] should be "d"');
  for LFor := 0 to High(LResultArray) do
    Writeln('TestSplit: Element[' + IntToStr(LFor) + '] = ' + LResultArray[LFor]);
end;

procedure TTestStd.TestArrayReduce;
var
  LSum: Integer;
begin
  Writeln('TestArrayReduce: Starting reduce test');
  Writeln('TestArrayReduce: Input array = [1, 2, 3, 4, 5]');
  LSum := TArrayEx.Reduce<Integer>([1, 2, 3, 4, 5],
    function(accumulated, current: Integer): Integer begin Result := accumulated + current end);
  Assert.AreEqual(15, LSum, 'Reduced sum should be 15');
  Writeln('TestArrayReduce: Reduced sum = ' + IntToStr(LSum));
end;

procedure TTestStd.TestArrayMap;
var
  LDoubledArray: TArray<Integer>;
  LFor: Integer;
begin
  Writeln('TestArrayMap: Starting map test');
  Writeln('TestArrayMap: Input array = [1, 2, 3, 4, 5]');
  LDoubledArray := TArrayEx.Map<Integer, Integer>([1, 2, 3, 4, 5],
    function(AValue: Integer): Integer begin Result := AValue * 2 end);
  Assert.AreEqual(5, Length(LDoubledArray), 'Mapped array length should be 5');
  Writeln('TestArrayMap: Mapped array length = ' + IntToStr(Length(LDoubledArray)));
  Assert.AreEqual(2, LDoubledArray[0], 'Element[0] should be 2');
  Assert.AreEqual(4, LDoubledArray[1], 'Element[1] should be 4');
  Assert.AreEqual(6, LDoubledArray[2], 'Element[2] should be 6');
  Assert.AreEqual(8, LDoubledArray[3], 'Element[3] should be 8');
  Assert.AreEqual(10, LDoubledArray[4], 'Element[4] should be 10');
  for LFor := 0 to High(LDoubledArray) do
    Writeln('TestArrayMap: Element[' + IntToStr(LFor) + '] = ' + IntToStr(LDoubledArray[LFor]));
end;

procedure TTestStd.TestArrayFilter;
var
  LEvenNumbers: TArray<Integer>;
  LFor: Integer;
begin
  Writeln('TestArrayFilter: Starting filter test');
  Writeln('TestArrayFilter: Input array = [1, 2, 3, 4, 5]');
  LEvenNumbers := TArrayEx.Filter<Integer>([1, 2, 3, 4, 5],
    function(AValue: Integer): Boolean begin Result := AValue mod 2 = 0 end);
  Assert.AreEqual(2, Length(LEvenNumbers), 'Filtered array length should be 2');
  Writeln('TestArrayFilter: Filtered array length = ' + IntToStr(Length(LEvenNumbers)));
  Assert.AreEqual(2, LEvenNumbers[0], 'Element[0] should be 2');
  Assert.AreEqual(4, LEvenNumbers[1], 'Element[1] should be 4');
  for LFor := 0 to High(LEvenNumbers) do
    Writeln('TestArrayFilter: Element[' + IntToStr(LFor) + '] = ' + IntToStr(LEvenNumbers[LFor]));
end;

procedure TTestStd.TestForEach;
var
  LSum: Integer;
begin
  Writeln('TestForEach: Starting foreach test');
  Writeln('TestForEach: Input array = [1, 2, 3, 4, 5]');
  LSum := 0;
  TArrayEx.ForEach<Integer>([1, 2, 3, 4, 5],
    procedure(AValue: Integer) begin LSum := LSum + AValue end);
  Assert.AreEqual(15, LSum, 'Sum should be 15');
  Writeln('TestForEach: Sum after foreach = ' + IntToStr(LSum));
end;

procedure TTestStd.TestAny;
var
  LResult: Boolean;
begin
  Writeln('TestAny: Starting any test');
  Writeln('TestAny: Input array = [1, 2, 3, 4, 5]');
  LResult := TArrayEx.Any<Integer>([1, 2, 3, 4, 5],
    function(AValue: Integer): Boolean begin Result := AValue > 3 end);
  Assert.IsTrue(LResult, 'Should find value > 3');
  Writeln('TestAny: Any > 3 = ' + IfThen(LResult, 'True', 'False'));

  LResult := TArrayEx.Any<Integer>([1, 2, 3, 4, 5],
    function(AValue: Integer): Boolean begin Result := AValue > 5 end);
  Assert.IsFalse(LResult, 'Should not find value > 5');
  Writeln('TestAny: Any > 5 = ' + IfThen(LResult, 'True', 'False'));
end;

procedure TTestStd.TestAll;
var
  LResult: Boolean;
begin
  Writeln('TestAll: Starting all test');
  Writeln('TestAll: Input array = [1, 2, 3, 4, 5]');
  LResult := TArrayEx.All<Integer>([1, 2, 3, 4, 5],
    function(AValue: Integer): Boolean begin Result := AValue < 6 end);
  Assert.IsTrue(LResult, 'All should be < 6');
  Writeln('TestAll: All < 6 = ' + IfThen(LResult, 'True', 'False'));

  LResult := TArrayEx.All<Integer>([1, 2, 3, 4, 5],
    function(AValue: Integer): Boolean begin Result := AValue < 4 end);
  Assert.IsFalse(LResult, 'Not all are < 4');
  Writeln('TestAll: All < 4 = ' + IfThen(LResult, 'True', 'False'));
end;

procedure TTestStd.TestArrayTake;
var
  LArray: TArray<Integer>;
  LResult: TArray<Integer>;
  LFor: Integer;
begin
  Writeln('TestArrayTake: Starting take test');
  LArray := [1, 2, 3, 4, 5];
  Writeln('TestArrayTake: Input array = [1, 2, 3, 4, 5]');
  LResult := TArrayEx.Take<Integer>(LArray, 3);
  Assert.AreEqual(3, Length(LResult), 'Take 3 should have length 3');
  Writeln('TestArrayTake: Took 3, length = ' + IntToStr(Length(LResult)));
  Assert.AreEqual(1, LResult[0], 'Element[0] should be 1');
  Assert.AreEqual(2, LResult[1], 'Element[1] should be 2');
  Assert.AreEqual(3, LResult[2], 'Element[2] should be 3');
  for LFor := 0 to High(LResult) do
    Writeln('TestArrayTake: Element[' + IntToStr(LFor) + '] = ' + IntToStr(LResult[LFor]));
end;

procedure TTestStd.TestArraySkip;
var
  LArray: TArray<Integer>;
  LResult: TArray<Integer>;
  LFor: Integer;
begin
  Writeln('TestArraySkip: Starting skip test');
  LArray := [1, 2, 3, 4, 5];
  Writeln('TestArraySkip: Input array = [1, 2, 3, 4, 5]');
  LResult := TArrayEx.Skip<Integer>(LArray, 2);
  Assert.AreEqual(3, Length(LResult), 'Skip 2 should have length 3');
  Writeln('TestArraySkip: Skipped 2, length = ' + IntToStr(Length(LResult)));
  Assert.AreEqual(3, LResult[0], 'Element[0] should be 3');
  Assert.AreEqual(4, LResult[1], 'Element[1] should be 4');
  Assert.AreEqual(5, LResult[2], 'Element[2] should be 5');
  for LFor := 0 to High(LResult) do
    Writeln('TestArraySkip: Element[' + IntToStr(LFor) + '] = ' + IntToStr(LResult[LFor]));
end;

procedure TTestStd.TestArrayFlatMap;
var
  LArray: TArray<Integer>;
  LResult: TArray<String>;
  LFor: Integer;
begin
  Writeln('TestArrayFlatMap: Starting flatmap test');
  LArray := [1, 2, 3];
  Writeln('TestArrayFlatMap: Input array = [1, 2, 3]');
  LResult := TArrayEx.FlatMap<Integer, String>(LArray,
    function(AValue: Integer): TArray<String> begin Result := [AValue.ToString, AValue.ToString] end);
  Assert.AreEqual(6, Length(LResult), 'FlatMap should have length 6');
  Writeln('TestArrayFlatMap: FlatMapped length = ' + IntToStr(Length(LResult)));
  Assert.AreEqual('1', LResult[0], 'Element[0] should be "1"');
  Assert.AreEqual('1', LResult[1], 'Element[1] should be "1"');
  Assert.AreEqual('2', LResult[2], 'Element[2] should be "2"');
  for LFor := 0 to High(LResult) do
    Writeln('TestArrayFlatMap: Element[' + IntToStr(LFor) + '] = ' + LResult[LFor]);
end;

procedure TTestStd.TestArrayPartition;
var
  LArray, LLeft, LRight: TArray<Integer>;
  LFor: Integer;
begin
  Writeln('TestArrayPartition: Starting partition test');
  LArray := [1, 2, 3, 4, 5];
  Writeln('TestArrayPartition: Input array = [1, 2, 3, 4, 5]');
  TArrayEx.Partition<Integer>(LArray,
    function(AValue: Integer): Boolean begin Result := AValue > 3 end, LLeft, LRight);
  Assert.AreEqual(3, Length(LLeft), 'Left partition length should be 3');
  Assert.AreEqual(2, Length(LRight), 'Right partition length should be 2');
  Writeln('TestArrayPartition: Left length = ' + IntToStr(Length(LLeft)) + ', Right length = ' + IntToStr(Length(LRight)));
  for LFor := 0 to High(LLeft) do
    Writeln('TestArrayPartition: Left[' + IntToStr(LFor) + '] = ' + IntToStr(LLeft[LFor]));
  for LFor := 0 to High(LRight) do
    Writeln('TestArrayPartition: Right[' + IntToStr(LFor) + '] = ' + IntToStr(LRight[LFor]));
end;

procedure TTestStd.TestArrayGroupBy;
var
  LArray: TArray<Integer>;
  LDict: TMap<Boolean, TArray<Integer>>;
  LFor: Integer;
begin
  Writeln('TestArrayGroupBy: Starting groupby test');
  LArray := [1, 2, 3, 4, 5];
  Writeln('TestArrayGroupBy: Input array = [1, 2, 3, 4, 5]');
  LDict := TArrayEx.GroupBy<Boolean, Integer>(LArray,
    function(AValue: Integer): Boolean begin Result := AValue mod 2 = 0 end);
  Assert.AreEqual(3, Length(LDict[False]), 'Odd numbers length should be 3');
  Assert.AreEqual(2, Length(LDict[True]), 'Even numbers length should be 2');
  Writeln('TestArrayGroupBy: Odd length = ' + IntToStr(Length(LDict[False])) + ', Even length = ' + IntToStr(Length(LDict[True])));
  for LFor := 0 to High(LDict[False]) do
    Writeln('TestArrayGroupBy: Odd[' + IntToStr(LFor) + '] = ' + IntToStr(LDict[False][LFor]));
  for LFor := 0 to High(LDict[True]) do
    Writeln('TestArrayGroupBy: Even[' + IntToStr(LFor) + '] = ' + IntToStr(LDict[True][LFor]));
end;

procedure TTestStd.TestArrayReverse;
var
  LArray, LResult: TArray<Integer>;
  LFor: Integer;
begin
  Writeln('TestArrayReverse: Starting reverse test');
  LArray := [1, 2, 3, 4, 5];
  Writeln('TestArrayReverse: Input array = [1, 2, 3, 4, 5]');
  LResult := TArrayEx.Reverse<Integer>(LArray);
  Assert.AreEqual(5, Length(LResult), 'Reversed array length should be 5');
  Writeln('TestArrayReverse: Reversed length = ' + IntToStr(Length(LResult)));
  Assert.AreEqual(5, LResult[0], 'Element[0] should be 5');
  Assert.AreEqual(1, LResult[4], 'Element[4] should be 1');
  for LFor := 0 to High(LResult) do
    Writeln('TestArrayReverse: Element[' + IntToStr(LFor) + '] = ' + IntToStr(LResult[LFor]));
end;

procedure TTestStd.TestArrayDistinct;
var
  LArray, LResult: TArray<Integer>;
  LFor: Integer;
begin
  Writeln('TestArrayDistinct: Starting distinct test');
  LArray := [1, 2, 2, 3, 3, 4];
  Writeln('TestArrayDistinct: Input array = [1, 2, 2, 3, 3, 4]');
  LResult := TArrayEx.Distinct<Integer>(LArray);
  Assert.AreEqual(4, Length(LResult), 'Distinct array length should be 4');
  Writeln('TestArrayDistinct: Distinct length = ' + IntToStr(Length(LResult)));
  Assert.AreEqual(1, LResult[0], 'Element[0] should be 1');
  Assert.AreEqual(4, LResult[3], 'Element[3] should be 4');
  for LFor := 0 to High(LResult) do
    Writeln('TestArrayDistinct: Element[' + IntToStr(LFor) + '] = ' + IntToStr(LResult[LFor]));
end;

procedure TTestStd.TestArrayZip;
var
  LArray1: TArray<Integer>;
  LArray2: TArray<String>;
  LResult: TArray<String>;
  LFor: Integer;
begin
  Writeln('TestArrayZip: Starting zip test');
  LArray1 := [1, 2, 3];
  LArray2 := ['a', 'b', 'c'];
  Writeln('TestArrayZip: Input array1 = [1, 2, 3], array2 = [a, b, c]');
  LResult := TArrayEx.Zip<Integer, String, String>(LArray1, LArray2,
    function(A: Integer; B: String): String begin Result := A.ToString + B end);
  Assert.AreEqual(3, Length(LResult), 'Zipped array length should be 3');
  Writeln('TestArrayZip: Zipped length = ' + IntToStr(Length(LResult)));
  Assert.AreEqual('1a', LResult[0], 'Element[0] should be "1a"');
  Assert.AreEqual('2b', LResult[1], 'Element[1] should be "2b"');
  Assert.AreEqual('3c', LResult[2], 'Element[2] should be "3c"');
  for LFor := 0 to High(LResult) do
    Writeln('TestArrayZip: Element[' + IntToStr(LFor) + '] = ' + LResult[LFor]);
end;

procedure TTestStd.TestArrayToFuture;
var
  LArray: TArray<Integer>;
  LFuture: TFuture;
begin
  Writeln('TestArrayToFuture: Starting tofuture test');
  LArray := [1, 2, 3];
  Writeln('TestArrayToFuture: Input array = [1, 2, 3]');
  LFuture := TArrayEx.ToFuture<Integer>(LArray,
    function(A: TArray<Integer>): String begin if Length(A) > 0 then Result := '' else Result := 'Empty array' end);
  Assert.IsTrue(LFuture.IsOk, 'Future should be OK');
  Assert.AreEqual(3, Length(LFuture.Ok<TArray<Integer>>), 'Array length should be 3');
  Writeln('TestArrayToFuture: Future OK = ' + IfThen(LFuture.IsOk, 'True', 'False') + ', Length = ' + IntToStr(Length(LFuture.Ok<TArray<Integer>>)));

  LArray := [];
  Writeln('TestArrayToFuture: Input array = empty');
  LFuture := TArrayEx.ToFuture<Integer>(LArray,
    function(A: TArray<Integer>): String begin if Length(A) > 0 then Result := '' else Result := 'Empty array' end);
  Assert.IsTrue(LFuture.IsErr, 'Future should be error');
  Writeln('TestArrayToFuture: Future Error = ' + LFuture.Err);
end;

initialization
  TDUnitX.RegisterTestFixture(TTestStd);

end.
