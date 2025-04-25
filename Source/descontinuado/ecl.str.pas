{
               Evolution4D: Modern Delphi Development Library for Delphi

                    GNU Lesser General Public License
                      Versão 3, 29 de junho de 2007

       Copyright (C) 2007 Free Software Foundation, Inc. <http://fsf.org/>
       A todos é permitido copiar e distribuir cópias deste documento de
       licença, mas mudá-lo não é permitido.

       Esta versão da GNU Lesser General Public License incorpora
       os termos e condições da versão 3 da GNU General Public License
       Licença, complementado pelas permissões adicionais listadas no
       arquivo LICENSE na pasta principal.
}

{
  @abstract(ECL Library)
  @created(23 Abr 2023)
  @author(Isaque Pinheiro <isaquepsp@gmail.com>)
  @Discord(https://discord.gg/T2zJC8zX)
}

unit ecl.str;

interface

uses
  Classes,
  SysUtils,
  Generics.Collections,
  DateUtils,
  ecl.collections,
  ecl.iterator;

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
    procedure Partition(APredicate: TFunc<Char, Boolean>; out Left, Right: String);
    function Filter(const APredicate: TFunc<Char, Boolean>): IListEnumerable<Char>;
    function Collect: IListEnumerable<String>;
    function Map(const ATransform: TFunc<Char, Char>): IListEnumerable<Char>;
    function FlatMap(const ATransform: TFunc<Char, String>): IListEnumerable<Char>;
    function Sum: Integer;
    function First: Char;
    function Last: Char;
    function Reduce<T>(const AInitialValue: T; const AAccumulator: TFunc<T, Char, T>): T;
    function Exists(const APredicate: TFunc<Char, Boolean>): Boolean;
    function All(const APredicate: TFunc<Char, Boolean>): Boolean;
    function Any(const APredicate: TFunc<Char, Boolean>): Boolean;
    function Sort: IListEnumerable<Char>;
    function Take(ACount: Integer): IListEnumerable<Char>;
    function Skip(ACount: Integer): IListEnumerable<Char>;
    function GroupBy(const AKeySelector: TFunc<Char, String>): TDictionary<String, String>;
    function Reverse: IListEnumerable<Char>;
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
  Result := 0;
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

{ TStringHelperEx }

function TStringHelperEx.Filter(const APredicate: TFunc<Char, Boolean>): IListEnumerable<Char>;
var
  LArray: TArray<Char>;
  LIndex: Integer;
begin
  if not Assigned(APredicate) then
    raise EArgumentNilException.Create('Predicate function cannot be nil in Filter');
  SetLength(LArray, Length(Self));
  for LIndex := 1 to Length(Self) do
    LArray[LIndex - 1] := Self[LIndex];
  Result := TListLazyFilter<Char>.Create(
    TListLazyToList<Char>.Create(TArrayEnumerator<Char>.Create(LArray)),
    APredicate);
end;

function TStringHelperEx.Collect: IListEnumerable<String>;
var
  LArray: TArray<Char>;
  LIndex: Integer;
begin
  SetLength(LArray, Length(Self));
  for LIndex := 1 to Length(Self) do
    LArray[LIndex - 1] := Self[LIndex];
  Result := TListLazyMapEnumerable<Char, String>.Create(
    TListLazyMapEnumerator<Char, String>.Create(
      TArrayEnumerator<Char>.Create(LArray),
      function(x: Char): String begin Result := x; end));
end;

function TStringHelperEx.Map(const ATransform: TFunc<Char, Char>): IListEnumerable<Char>;
var
  LArray: TArray<Char>;
  LIndex: Integer;
begin
  if not Assigned(ATransform) then
    raise EArgumentNilException.Create('Transform function cannot be nil in Map');
  SetLength(LArray, Length(Self));
  for LIndex := 1 to Length(Self) do
    LArray[LIndex - 1] := Self[LIndex];
  Result := TListLazyMapEnumerable<Char, Char>.Create(
    TListLazyMapEnumerator<Char, Char>.Create(
      TArrayEnumerator<Char>.Create(LArray),
      ATransform));
end;

function TStringHelperEx.FlatMap(const ATransform: TFunc<Char, String>): IListEnumerable<Char>;
var
  LArray: TArray<Char>;
  LIndex: Integer;
begin
  if not Assigned(ATransform) then
    raise EArgumentNilException.Create('Transform function cannot be nil in FlatMap');
  SetLength(LArray, Length(Self));
  for LIndex := 1 to Length(Self) do
    LArray[LIndex - 1] := Self[LIndex];
  Result := TListLazyFlatMapEnumerable<Char, Char>.Create(
    TListLazyFlatMapEnumerator<Char, Char>.Create(
      TArrayEnumerator<Char>.Create(LArray),
      function(x: Char): TArray<Char>
      var
        LString: String;
        LCharIndex: Integer;
      begin
        LString := ATransform(x);
        SetLength(Result, Length(LString));
        for LCharIndex := 1 to Length(LString) do
          Result[LCharIndex - 1] := LString[LCharIndex];
      end));
end;

function TStringHelperEx.Sum: Integer;
var
  LChar: Char;
begin
  Result := 0;
  for LChar in Self do
    Result := Result + Ord(LChar); // Usa o valor ASCII do caractere
end;

function TStringHelperEx.First: Char;
begin
  if Length(Self) > 0 then
    Result := Self[1]
  else
    raise EInvalidOperation.Create('String is empty in First');
end;

function TStringHelperEx.Last: Char;
begin
  if Length(Self) > 0 then
    Result := Self[Length(Self)]
  else
    raise EInvalidOperation.Create('String is empty in Last');
end;

function TStringHelperEx.Reduce<T>(const AInitialValue: T; const AAccumulator: TFunc<T, Char, T>): T;
var
  LChar: Char;
begin
  if not Assigned(AAccumulator) then
    raise EArgumentNilException.Create('Accumulator function cannot be nil in Reduce');
  Result := AInitialValue;
  for LChar in Self do
    Result := AAccumulator(Result, LChar);
end;

function TStringHelperEx.Exists(const APredicate: TFunc<Char, Boolean>): Boolean;
begin
  Result := Any(APredicate); // Reusa Any pra consistência
end;

function TStringHelperEx.All(const APredicate: TFunc<Char, Boolean>): Boolean;
var
  LChar: Char;
begin
  if not Assigned(APredicate) then
    raise EArgumentNilException.Create('Predicate function cannot be nil in All');
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
    raise EArgumentNilException.Create('Predicate function cannot be nil in Any');
  for LChar in Self do
    if APredicate(LChar) then
      Exit(True);
  Result := False;
end;

function TStringHelperEx.Sort: IListEnumerable<Char>;
var
  LArray: TArray<Char>;
  LIndex: Integer;
begin
  SetLength(LArray, Length(Self));
  for LIndex := 1 to Length(Self) do
    LArray[LIndex - 1] := Self[LIndex];
  TArray.Sort<Char>(LArray);
  Result := TListLazyToList<Char>.Create(TArrayEnumerator<Char>.Create(LArray));
end;

procedure TStringHelperEx.Partition(APredicate: TFunc<Char, Boolean>; out Left, Right: String);
var
  LIndex: Integer;
begin
  if not Assigned(APredicate) then
    raise EArgumentNilException.Create('Predicate function cannot be nil in Partition');
  Left := '';
  Right := '';
  for LIndex := 1 to Length(Self) do
    if APredicate(Self[LIndex]) then
      Right := Right + Self[LIndex]
    else
      Left := Left + Self[LIndex];
end;

function TStringHelperEx.Take(ACount: Integer): IListEnumerable<Char>;
var
  LArray: TArray<Char>;
  LIndex: Integer;
begin
  SetLength(LArray, Length(Self));
  for LIndex := 1 to Length(Self) do
    LArray[LIndex - 1] := Self[LIndex];
  Result := TListLazyTake<Char>.Create(
    TListLazyToList<Char>.Create(TArrayEnumerator<Char>.Create(LArray)),
    ACount);
end;

function TStringHelperEx.Skip(ACount: Integer): IListEnumerable<Char>;
var
  LArray: TArray<Char>;
  LIndex: Integer;
begin
  SetLength(LArray, Length(Self));
  for LIndex := 1 to Length(Self) do
    LArray[LIndex - 1] := Self[LIndex];
  Result := TListLazySkip<Char>.Create(
    TListLazyToList<Char>.Create(TArrayEnumerator<Char>.Create(LArray)),
    ACount);
end;

function TStringHelperEx.GroupBy(const AKeySelector: TFunc<Char, String>): TDictionary<String, String>;
var
  LChar: Char;
  LKey, LValue: String;
begin
  if not Assigned(AKeySelector) then
    raise EArgumentNilException.Create('Key selector function cannot be nil in GroupBy');
  Result := TDictionary<String, String>.Create;
  try
    for LChar in Self do
    begin
      LKey := AKeySelector(LChar);
      if Result.TryGetValue(LKey, LValue) then
        Result[LKey] := LValue + LChar
      else
        Result.Add(LKey, LChar);
    end;
  except
    Result.Free;
    raise;
  end;
end;

function TStringHelperEx.Reverse: IListEnumerable<Char>;
var
  LArray: TArray<Char>;
  LIndex: Integer;
begin
  SetLength(LArray, Length(Self));
  for LIndex := 1 to Length(Self) do
    LArray[LIndex - 1] := Self[Length(Self) - LIndex + 1];
  Result := TListLazyToList<Char>.Create(TArrayEnumerator<Char>.Create(LArray));
end;

function TStringHelperEx.CountWhere(const APredicate: TFunc<Char, Boolean>): Integer;
var
  LChar: Char;
begin
  if not Assigned(APredicate) then
    raise EArgumentNilException.Create('Predicate function cannot be nil in CountWhere');
  Result := 0;
  for LChar in Self do
    if APredicate(LChar) then
      Inc(Result);
end;

end.
