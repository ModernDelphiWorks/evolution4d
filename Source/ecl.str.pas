{
               ECL - Evolution Core Library for Delphi

                   Copyright (c) 2023, Isaque Pinheiro
                          All rights reserved.

                    GNU Lesser General Public License
                      Versão 3, 29 de junho de 2007

       Copyright (C) 2007 Free Software Foundation, Inc. <http://fsf.org/>
       A todos é permitido copiar e distribuir cópias deste documento de
       licença, mas mudá-lo não é permitido.
}

{
  @abstract(ECL Library - Functional Extensions for Basic Types)
  @created(19 Mar 2025)
  @author(Isaque Pinheiro <isaquepsp@gmail.com>)
  @Discord(https://discord.gg/T2zJC8zX)
}

unit ecl.str;

interface

uses
  SysUtils,
  Generics.Collections,
  ecl.vector,
  DateUtils;

type
  TCharHelperEx = record helper for Char
  public
    /// <summary>
    /// Converts the character to uppercase.
    /// </summary>
    /// <returns>The uppercase character.</returns>
    function ToUpper: Char;
    /// <summary>
    /// Converts the character to lowercase.
    /// </summary>
    /// <returns>The lowercase character.</returns>
    function ToLower: Char;
    /// <summary>
    /// Checks if the character is a letter (a-z or A-Z).
    /// </summary>
    /// <returns>True if the character is a letter, False otherwise.</returns>
    function IsLetter: Boolean;
    /// <summary>
    /// Checks if the character is a digit (0-9).
    /// </summary>
    /// <returns>True if the character is a digit, False otherwise.</returns>
    function IsDigit: Boolean;
  end;

  TStringHelperEx = record helper for String
  public
    /// <summary>
    /// Filters characters based on a predicate.
    /// </summary>
    /// <param name="APredicate">The condition to filter characters.</param>
    /// <returns>A new string with filtered characters.</returns>
    function Filter(const APredicate: TFunc<Char, Boolean>): String;
    /// <summary>
    /// Collects each character into a TVector<String>.
    /// </summary>
    /// <returns>A vector containing each character as a string.</returns>
    function Collect: TVector<String>;
    /// <summary>
    /// Transforms each character using a transformation function.
    /// </summary>
    /// <param name="ATransform">The transformation function.</param>
    /// <returns>A new string with transformed characters.</returns>
    function Map(const ATransform: TFunc<Char, Char>): String;
    /// <summary>
    /// Transforms each character into a string and concatenates the results.
    /// </summary>
    /// <param name="ATransform">The transformation function producing a string.</param>
    /// <returns>A new concatenated string.</returns>
    function FlatMap(const ATransform: TFunc<Char, String>): String;
    /// <summary>
    /// Sums the numeric values of characters (assumes digits).
    /// </summary>
    /// <returns>The sum of numeric values.</returns>
    function Sum: Integer;
    /// <summary>
    /// Returns the first character of the string.
    /// </summary>
    /// <returns>The first character.</returns>
    function First: Char;
    /// <summary>
    /// Returns the last character of the string.
    /// </summary>
    /// <returns>The last character.</returns>
    function Last: Char;
    /// <summary>
    /// Reduces the string to a single value using an accumulator.
    /// </summary>
    /// <typeparam name="T">The type of the accumulated value.</typeparam>
    /// <param name="AInitialValue">The initial value for reduction.</param>
    /// <param name="AAccumulator">The accumulation function.</param>
    /// <returns>The reduced value.</returns>
    function Reduce<T>(const AInitialValue: T; const AAccumulator: TFunc<T, Char, T>): T;
    /// <summary>
    /// Checks if any character satisfies a predicate.
    /// </summary>
    /// <param name="APredicate">The condition to check.</param>
    /// <returns>True if any character satisfies, False otherwise.</returns>
    function Exists(const APredicate: TFunc<Char, Boolean>): Boolean;
    /// <summary>
    /// Checks if all characters satisfy a predicate.
    /// </summary>
    /// <param name="APredicate">The condition to check.</param>
    /// <returns>True if all characters satisfy, False otherwise.</returns>
    function All(const APredicate: TFunc<Char, Boolean>): Boolean;
    /// <summary>
    /// Checks if at least one character satisfies a predicate.
    /// </summary>
    /// <param name="APredicate">The condition to check.</param>
    /// <returns>True if at least one satisfies, False otherwise.</returns>
    function Any(const APredicate: TFunc<Char, Boolean>): Boolean;
    /// <summary>
    /// Sorts the characters in the string alphabetically.
    /// </summary>
    /// <returns>A new sorted string.</returns>
    function Sort: String;
    /// <summary>
    /// Partitions the string into two based on a predicate.
    /// </summary>
    /// <param name="APredicate">The condition to partition.</param>
    /// <param name="Left">Characters that don't satisfy the predicate.</param>
    /// <param name="Right">Characters that satisfy the predicate.</param>
    procedure Partition(APredicate: TFunc<Char, Boolean>; out Left, Right: String);
    /// <summary>
    /// Takes the first N characters of the string.
    /// </summary>
    /// <param name="ACount">Number of characters to take.</param>
    /// <returns>A new string with the first N characters.</returns>
    function Take(ACount: Integer): String;
    /// <summary>
    /// Skips the first N characters of the string.
    /// </summary>
    /// <param name="ACount">Number of characters to skip.</param>
    /// <returns>A new string without the first N characters.</returns>
    function Skip(ACount: Integer): String;
    /// <summary>
    /// Groups characters by a key selector into a dictionary.
    /// </summary>
    /// <param name="AKeySelector">Function to determine the group key.</param>
    /// <returns>A dictionary mapping keys to grouped strings.</returns>
    function GroupBy(const AKeySelector: TFunc<Char, String>): TDictionary<String, String>;
    /// <summary>
    /// Reverses the order of characters in the string.
    /// </summary>
    /// <returns>A new reversed string.</returns>
    function Reverse: String;
    /// <summary>
    /// Counts occurrences of characters satisfying a predicate.
    /// </summary>
    /// <param name="APredicate">The condition to count.</param>
    /// <returns>The number of characters that satisfy the predicate.</returns>
    function CountWhere(const APredicate: TFunc<Char, Boolean>): Integer;
  end;

  TIntegerHelperEx = record helper for Integer
  public
    /// <summary>
    /// Transforms the integer using a transformation function.
    /// </summary>
    /// <param name="ATransform">The transformation function.</param>
    /// <returns>The transformed integer.</returns>
    function Map(const ATransform: TFunc<Integer, Integer>): Integer;
    /// <summary>
    /// Checks if the integer is even.
    /// </summary>
    /// <returns>True if even, False otherwise.</returns>
    function IsEven: Boolean;
    /// <summary>
    /// Checks if the integer is odd.
    /// </summary>
    /// <returns>True if odd, False otherwise.</returns>
    function IsOdd: Boolean;
    /// <summary>
    /// Applies a function a specified number of times.
    /// </summary>
    /// <param name="ATransform">The function to apply.</param>
    /// <returns>The result after applying the function Self times.</returns>
    function Times(const ATransform: TFunc<Integer, Integer>): Integer;
  end;

  TBooleanHelperEx = record helper for Boolean
  public
    /// <summary>
    /// Maps the boolean to a value based on its state.
    /// </summary>
    /// <param name="ATrueValue">Value if True.</param>
    /// <param name="AFalseValue">Value if False.</param>
    /// <returns>The mapped value.</returns>
    function Map<T>(const ATrueValue, AFalseValue: T): T;
    /// <summary>
    /// Executes an action if the boolean is True.
    /// </summary>
    /// <param name="AAction">The action to execute.</param>
    procedure IfTrue(const AAction: TProc);
    /// <summary>
    /// Executes an action if the boolean is False.
    /// </summary>
    /// <param name="AAction">The action to execute.</param>
    procedure IfFalse(const AAction: TProc);
  end;

  TFloatHelperEx = record helper for Double
  public
    /// <summary>
    /// Transforms the float using a transformation function.
    /// </summary>
    /// <param name="ATransform">The transformation function.</param>
    /// <returns>The transformed float.</returns>
    function Map(const ATransform: TFunc<Double, Double>): Double;
    /// <summary>
    /// Rounds the float to the nearest integer.
    /// </summary>
    /// <returns>The rounded integer.</returns>
    function Round: Integer;
    /// <summary>
    /// Checks if the float is approximately equal to another within a tolerance.
    /// </summary>
    /// <param name="AValue">The value to compare.</param>
    /// <param name="ATolerance">The tolerance for comparison.</param>
    /// <returns>True if approximately equal, False otherwise.</returns>
    function ApproxEqual(const AValue: Double; const ATolerance: Double = 0.0001): Boolean;
  end;

  TDateTimeHelperEx = record helper for TDateTime
  public
    /// <summary>
    /// Transforms the datetime using a transformation function.
    /// </summary>
    /// <param name="ATransform">The transformation function.</param>
    /// <returns>The transformed datetime.</returns>
    function Map(const ATransform: TFunc<TDateTime, TDateTime>): TDateTime;
    /// <summary>
    /// Adds a specified number of days to the datetime.
    /// </summary>
    /// <param name="ADays">Number of days to add.</param>
    /// <returns>The new datetime.</returns>
    function AddDays(ADays: Integer): TDateTime;
    /// <summary>
    /// Checks if the datetime is in the past relative to now.
    /// </summary>
    /// <returns>True if in the past, False otherwise.</returns>
    function IsPast: Boolean;
    /// <summary>
    /// Formats the datetime using a specified format string.
    /// </summary>
    /// <param name="AFormat">The format string.</param>
    /// <returns>The formatted string.</returns>
    function ToFormat(const AFormat: String): String;
  end;

implementation

uses
  ecl.std;

{ TCharHelperEx }

function TCharHelperEx.ToUpper: Char;
begin
  if CharInSet(Self, ['a'..'z']) then
    Result := Chr(Ord(Self) - 32)
  else
    Result := Self;
end;

function TCharHelperEx.ToLower: Char;
begin
  if CharInSet(Self, ['A'..'Z']) then
    Result := Chr(Ord(Self) + 32)
  else
    Result := Self;
end;

function TCharHelperEx.IsLetter: Boolean;
begin
  Result := CharInSet(Self, ['a'..'z', 'A'..'Z']);
end;

function TCharHelperEx.IsDigit: Boolean;
begin
  Result := CharInSet(Self, ['0'..'9']);
end;

{ TStringHelperEx }

function TStringHelperEx.Filter(const APredicate: TFunc<Char, Boolean>): String;
var
  LChar: Char;
begin
  if not Assigned(APredicate) then
    raise Exception.Create('Invalid predicate function in TStringHelperEx.Filter');
  Result := '';
  for LChar in Self do
    if APredicate(LChar) then
      Result := Result + LChar;
end;

function TStringHelperEx.Collect: TVector<String>;
var
  LChar: Char;
begin
  Result := TVector<String>.Create([]);
  for LChar in Self do
    Result.Add(LChar);
end;

function TStringHelperEx.Map(const ATransform: TFunc<Char, Char>): String;
var
  LChar: Char;
begin
  if not Assigned(ATransform) then
    raise Exception.Create('Invalid transform function in TStringHelperEx.Map');
  Result := '';
  for LChar in Self do
    Result := Result + ATransform(LChar);
end;

function TStringHelperEx.FlatMap(const ATransform: TFunc<Char, String>): String;
var
  LChar: Char;
begin
  if not Assigned(ATransform) then
    raise Exception.Create('Invalid transform function in TStringHelperEx.FlatMap');
  Result := '';
  for LChar in Self do
    Result := Result + ATransform(LChar);
end;

function TStringHelperEx.Sum: Integer;
var
  LChar: Char;
begin
  Result := 0;
  for LChar in Self do
    Result := Result + StrToIntDef(LChar, 0);
end;

function TStringHelperEx.First: Char;
begin
  if Length(Self) > 0 then
    Result := Self[1]
  else
    raise Exception.Create('String is empty');
end;

function TStringHelperEx.Last: Char;
begin
  if Length(Self) > 0 then
    Result := Self[Length(Self)]
  else
    raise Exception.Create('String is empty');
end;

function TStringHelperEx.Reduce<T>(const AInitialValue: T; const AAccumulator: TFunc<T, Char, T>): T;
var
  LChar: Char;
begin
  if not Assigned(AAccumulator) then
    raise Exception.Create('Invalid accumulator function in TStringHelperEx.Reduce<T>');
  Result := AInitialValue;
  for LChar in Self do
    Result := AAccumulator(Result, LChar);
end;

function TStringHelperEx.Exists(const APredicate: TFunc<Char, Boolean>): Boolean;
var
  LChar: Char;
begin
  if not Assigned(APredicate) then
    raise Exception.Create('Invalid predicate function in TStringHelperEx.Exists');
  for LChar in Self do
    if APredicate(LChar) then
      Exit(True);
  Result := False;
end;

function TStringHelperEx.All(const APredicate: TFunc<Char, Boolean>): Boolean;
var
  LChar: Char;
begin
  if not Assigned(APredicate) then
    raise Exception.Create('Invalid predicate function in TStringHelperEx.All');
  for LChar in Self do
    if not APredicate(LChar) then
      Exit(False);
  Result := True;
end;

function TStringHelperEx.Any(const APredicate: TFunc<Char, Boolean>): Boolean;
var
  LChar: Char;
begin
  if not Assigned(APredicate) then
    raise Exception.Create('Invalid predicate function in TStringHelperEx.Any');
  for LChar in Self do
    if APredicate(LChar) then
      Exit(True);
  Result := False;
end;

function TStringHelperEx.Sort: String;
var
  LArray: TArray<Char>;
  LChar: Char;
  LIndex: Integer;
begin
  SetLength(LArray, Length(Self));
  for LIndex := 1 to Length(Self) do
    LArray[LIndex - 1] := Self[LIndex];
  TArray.Sort<Char>(LArray);
  Result := '';
  for LChar in LArray do
    Result := Result + LChar;
end;

procedure TStringHelperEx.Partition(APredicate: TFunc<Char, Boolean>; out Left, Right: String);
var
  LIndex: Integer;
begin
  if not Assigned(APredicate) then
    raise Exception.Create('Invalid predicate function in TStringHelperEx.Partition');
  Left := '';
  Right := '';
  for LIndex := 1 to Length(Self) do
  begin
    if APredicate(Self[LIndex]) then
      Right := Right + Self[LIndex]
    else
      Left := Left + Self[LIndex];
  end;
end;

function TStringHelperEx.Take(ACount: Integer): String;
begin
  if ACount >= Length(Self) then
    Result := Self
  else if ACount <= 0 then
    Result := ''
  else
    Result := Copy(Self, 1, ACount);
end;

function TStringHelperEx.Skip(ACount: Integer): String;
begin
  if ACount >= Length(Self) then
    Result := ''
  else if ACount <= 0 then
    Result := Self
  else
    Result := Copy(Self, ACount + 1, Length(Self));
end;

function TStringHelperEx.GroupBy(const AKeySelector: TFunc<Char, String>): TDictionary<String, String>;
var
  LChar: Char;
  LKey, LValue: String;
begin
  if not Assigned(AKeySelector) then
    raise Exception.Create('Invalid key selector function in TStringHelperEx.GroupBy');
  Result := TDictionary<String, String>.Create;
  for LChar in Self do
  begin
    LKey := AKeySelector(LChar);
    if Result.TryGetValue(LKey, LValue) then
      Result[LKey] := LValue + LChar
    else
      Result.Add(LKey, LChar);
  end;
end;

function TStringHelperEx.Reverse: String;
var
  LIndex: Integer;
begin
  SetLength(Result, Length(Self));
  for LIndex := 1 to Length(Self) do
    Result[LIndex] := Self[Length(Self) - LIndex + 1];
end;

function TStringHelperEx.CountWhere(const APredicate: TFunc<Char, Boolean>): Integer;
var
  LChar: Char;
begin
  if not Assigned(APredicate) then
    raise Exception.Create('Invalid predicate function in TStringHelperEx.CountWhere');
  Result := 0;
  for LChar in Self do
    if APredicate(LChar) then
      Inc(Result);
end;

{ TIntegerHelperEx }

function TIntegerHelperEx.Map(const ATransform: TFunc<Integer, Integer>): Integer;
begin
  if not Assigned(ATransform) then
    raise Exception.Create('Invalid transform function in TIntegerHelperEx.Map');
  Result := ATransform(Self);
end;

function TIntegerHelperEx.IsEven: Boolean;
begin
  Result := Self mod 2 = 0;
end;

function TIntegerHelperEx.IsOdd: Boolean;
begin
  Result := Self mod 2 <> 0;
end;

function TIntegerHelperEx.Times(const ATransform: TFunc<Integer, Integer>): Integer;
var
  LFor: Integer;
begin
  if not Assigned(ATransform) then
    raise Exception.Create('Invalid transform function in TIntegerHelperEx.Times');
  Result := 0;  // Começa de 0 pra alinhar com o teste
  for LFor := 1 to Abs(Self) do
    Result := ATransform(Result);
end;

{ TBooleanHelperEx }

function TBooleanHelperEx.Map<T>(const ATrueValue, AFalseValue: T): T;
begin
  if Self then
    Result := ATrueValue
  else
    Result := AFalseValue;
end;

procedure TBooleanHelperEx.IfTrue(const AAction: TProc);
begin
  if not Assigned(AAction) then
    raise Exception.Create('Invalid action in TBooleanHelperEx.IfTrue');
  if Self then
    AAction();
end;

procedure TBooleanHelperEx.IfFalse(const AAction: TProc);
begin
  if not Assigned(AAction) then
    raise Exception.Create('Invalid action in TBooleanHelperEx.IfFalse');
  if not Self then
    AAction();
end;

{ TFloatHelperEx }

function TFloatHelperEx.Map(const ATransform: TFunc<Double, Double>): Double;
begin
  if not Assigned(ATransform) then
    raise Exception.Create('Invalid transform function in TFloatHelperEx.Map');
  Result := ATransform(Self);
end;

function TFloatHelperEx.Round: Integer;
begin
  Result := System.Round(Self);
end;

function TFloatHelperEx.ApproxEqual(const AValue: Double; const ATolerance: Double): Boolean;
begin
  Result := Abs(Self - AValue) < ATolerance;
end;

{ TDateTimeHelperEx }

function TDateTimeHelperEx.Map(const ATransform: TFunc<TDateTime, TDateTime>): TDateTime;
begin
  if not Assigned(ATransform) then
    raise Exception.Create('Invalid transform function in TDateTimeHelperEx.Map');
  Result := ATransform(Self);
end;

function TDateTimeHelperEx.AddDays(ADays: Integer): TDateTime;
begin
  Result := IncDay(Self, ADays);
end;

function TDateTimeHelperEx.IsPast: Boolean;
begin
  Result := Self < Now;
end;

function TDateTimeHelperEx.ToFormat(const AFormat: String): String;
begin
  Result := FormatDateTime(AFormat, Self);
end;

end.
