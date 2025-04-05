{
                 ECL - Evolution Core Library for Delphi

                   Copyright (c) 2023, Isaque Pinheiro
                          All rights reserved.

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

unit ecl.tuple;

interface

uses
  Rtti,
  TypInfo,
  SysUtils,
  Generics.Collections,
  Generics.Defaults,
  ecl.std;

type
  Tuple = ecl.std.Tuple;

  /// <summary>
  /// Interface for managing a dictionary of key-value pairs within a tuple.
  /// </summary>
  ITupleDict<K> = interface
    ['{A5F8C7E2-3F8D-4E9A-BC5F-7D8E9C2F4B1D}']
    /// <summary>
    /// Returns the underlying dictionary instance.
    /// </summary>
    /// <returns>The TDictionary<K, TValue> managed by this interface.</returns>
    function GetDict: TDictionary<K, TValue>;

    /// <summary>
    /// Returns the number of key-value pairs in the dictionary.
    /// </summary>
    /// <returns>The count of elements in the dictionary.</returns>
    function Count: Integer;

    /// <summary>
    /// Retrieves the value associated with the specified key.
    /// </summary>
    /// <param name="AKey">The key to look up in the dictionary.</param>
    /// <returns>The TValue associated with the specified key.</returns>
    function GetItem(const AKey: K): TValue;

    /// <summary>
    /// Attempts to retrieve the value associated with the specified key.
    /// </summary>
    /// <param name="AKey">The key to look up in the dictionary.</param>
    /// <param name="AValue">The output parameter to store the retrieved value.</param>
    /// <returns>True if the key exists and the value was retrieved, False otherwise.</returns>
    function TryGetValue(const AKey: K; out AValue: TValue): Boolean;
  end;

  /// <summary>
  /// Internal class implementing ITupleDict<K> to manage a dictionary of key-value pairs.
  /// </summary>
  TTupleDict<K> = class(TInterfacedObject, ITupleDict<K>)
  private
    FTupleDict: TDictionary<K, TValue>;
  public
    /// <summary>
    /// Creates a new instance of TTupleDict with the specified key-value pairs.
    /// </summary>
    /// <param name="ATuples">An array of TPair<K, TValue> to initialize the dictionary.</param>
    constructor Create(const ATuples: TArray<TPair<K, TValue>>);

    /// <summary>
    /// Destroys the instance and frees the internal dictionary.
    /// </summary>
    destructor Destroy; override;

    function GetDict: TDictionary<K, TValue>;
    function Count: Integer;
    function GetItem(const AKey: K): TValue;
    function TryGetValue(const AKey: K; out AValue: TValue): Boolean;
  end;

  /// <summary>
  /// A record representing a tuple with key-value pairs, where keys are of type K and values are TValue.
  /// Provides efficient access to values using a dictionary-based implementation.
  /// </summary>
  TTuple<K> = record
  strict private
    FTupleDict: ITupleDict<K>;
    constructor Create(const ATuples: TArray<TPair<K, TValue>>);
    function GetItem(const AKey: K): TValue;
  public
    /// <summary>
    /// Implicit conversion from TTuple<K> to TArray<TPair<K, TValue>>.
    /// </summary>
    class operator Implicit(const P: TTuple<K>): TArray<TPair<K, TValue>>; inline;

    /// <summary>
    /// Implicit conversion from TArray<TPair<K, TValue>> to TTuple<K>.
    /// </summary>
    class operator Implicit(const P: TArray<TPair<K, TValue>>): TTuple<K>; inline;

    /// <summary>
    /// Checks if two TTuple<K> instances are equal based on their key-value pairs.
    /// </summary>
    class operator Equal(const Left, Right: TTuple<K>): Boolean; inline;

    /// <summary>
    /// Checks if two TTuple<K> instances are not equal based on their key-value pairs.
    /// </summary>
    class operator NotEqual(const Left, Right: TTuple<K>): Boolean; inline;

    /// <summary>
    /// Creates a new TTuple<K> instance with the specified keys and values.
    /// </summary>
    /// <param name="AKeys">An array of keys of type K.</param>
    /// <param name="AValues">An array of values of type TValue to associate with the keys.</param>
    /// <returns>A new TTuple<K> instance.</returns>
    class function New(const AKeys: TArray<K>;
      const AValues: TArray<TValue>): TTuple<K>; static; inline;

    /// <summary>
    /// Retrieves the value associated with the specified key, cast to type T.
    /// </summary>
    /// <param name="AKey">The key to look up.</param>
    /// <returns>The value associated with the key, cast to T.</returns>
    /// <exception cref="Exception">Raised if the key is not found.</exception>
    function Get<T>(const AKey: K): T; inline;

    /// <summary>
    /// Attempts to retrieve the value associated with the specified key, cast to type T.
    /// </summary>
    /// <param name="AKey">The key to look up.</param>
    /// <param name="AValue">The output parameter to store the retrieved value.</param>
    /// <returns>True if the key exists and the value was retrieved, False otherwise.</returns>
    function TryGet<T>(const AKey: K; out AValue: T): Boolean; inline;

    /// <summary>
    /// Returns the number of key-value pairs in the tuple.
    /// </summary>
    /// <returns>The count of elements in the tuple.</returns>
    function Count: Integer; inline;

    /// <summary>
    /// Creates a new TTuple<K> instance with the specified keys and values, replacing the current content.
    /// </summary>
    /// <param name="AKeys">An array of keys of type K.</param>
    /// <param name="AValues">An array of values of type TValue to associate with the keys.</param>
    /// <returns>A new TTuple<K> instance with the updated key-value pairs.</returns>
    function SetTuple(const AKeys: TArray<K>; const AValues: TArray<TValue>): TTuple<K>; inline;

    /// <summary>
    /// Property to access values by key.
    /// </summary>
    /// <param name="Key">The key to look up.</param>
    /// <returns>The TValue associated with the specified key.</returns>
    property Items[const Key: K]: TValue read GetItem; default;
  end;

  TValueArray = array of TValue;

  /// <summary>
  /// A record representing a tuple with a positional array of TValue elements.
  /// Provides access to elements by index.
  /// </summary>
  PTuple = ^TTuple;
  TTuple = record
  strict private
    FTuples: TValueArray;
    constructor Create(const Args: TValueArray);
    function GetItem(const AIndex: Integer): TValue;
  public
    /// <summary>
    /// Implicit conversion from TTuple to TValueArray.
    /// </summary>
    class operator Implicit(const Args: TTuple): TValueArray;

    /// <summary>
    /// Implicit conversion from an array of Variant to TTuple.
    /// </summary>
    class operator Implicit(const Args: array of Variant): TTuple;

    /// <summary>
    /// Implicit conversion from TValueArray to TTuple.
    /// </summary>
    class operator Implicit(const Args: TValueArray): TTuple;

    /// <summary>
    /// Checks if two TTuple instances are equal based on their elements.
    /// </summary>
    class operator Equal(const Left, Right: TTuple): Boolean; inline;

    /// <summary>
    /// Checks if two TTuple instances are not equal based on their elements.
    /// </summary>
    class operator NotEqual(const Left, Right: TTuple): Boolean; inline;

    /// <summary>
    /// Creates a new TTuple instance with the specified values.
    /// </summary>
    /// <param name="AValues">An array of TValue elements to initialize the tuple.</param>
    /// <returns>A new TTuple instance.</returns>
    class function New(const AValues: TValueArray): TTuple; static; inline;

    /// <summary>
    /// Retrieves the value at the specified index, cast to type T.
    /// </summary>
    /// <param name="AIndex">The index of the value to retrieve.</param>
    /// <returns>The value at the specified index, cast to T.</returns>
    function Get<T>(const AIndex: Integer): T; inline;

    /// <summary>
    /// Returns the number of elements in the tuple.
    /// </summary>
    /// <returns>The count of elements in the tuple.</returns>
    function Count: Integer; inline;

    /// <summary>
    /// Destructures the tuple into variables passed as pointers.
    /// </summary>
    /// <param name="AArgs">An open array of pointers to variables that will receive the tuple values.</param>
    /// <exception cref="Exception">Raised if the number of pointers does not match the tuple length.</exception>
    procedure Dest(const AVarRefs: TArray<Pointer>);

    /// <summary>
    /// Property to access values by index.
    /// </summary>
    /// <param name="Key">The index of the value to retrieve.</param>
    /// <returns>The TValue at the specified index.</returns>
    property Items[const Key: Integer]: TValue read GetItem; default;
  end;

implementation

{ TTupleDict<K> }

constructor TTupleDict<K>.Create(const ATuples: TArray<TPair<K, TValue>>);
var
  I: Integer;
begin
  FTupleDict := TDictionary<K, TValue>.Create;
  for I := 0 to High(ATuples) do
    FTupleDict.Add(ATuples[I].Key, ATuples[I].Value);
end;

destructor TTupleDict<K>.Destroy;
begin
  FTupleDict.Free;
  inherited;
end;

function TTupleDict<K>.GetDict: TDictionary<K, TValue>;
begin
  Result := FTupleDict;
end;

function TTupleDict<K>.Count: Integer;
begin
  Result := FTupleDict.Count;
end;

function TTupleDict<K>.GetItem(const AKey: K): TValue;
begin
  Result := FTupleDict[AKey];
end;

function TTupleDict<K>.TryGetValue(const AKey: K; out AValue: TValue): Boolean;
begin
  Result := FTupleDict.TryGetValue(AKey, AValue);
end;

{ TTuple<K> }

function TTuple<K>.Count: Integer;
begin
  Result := FTupleDict.Count;
end;

constructor TTuple<K>.Create(const ATuples: TArray<TPair<K, TValue>>);
begin
  FTupleDict := TTupleDict<K>.Create(ATuples);
end;

class operator TTuple<K>.Equal(const Left, Right: TTuple<K>): Boolean;
var
  LComp1: IEqualityComparer<K>;
  LComp2: IEqualityComparer<TValue>;
  LPair: TPair<K, TValue>;
begin
  Result := False;
  if Left.FTupleDict.Count <> Right.FTupleDict.Count then
    Exit;
  LComp1 := TEqualityComparer<K>.Default;
  LComp2 := TEqualityComparer<TValue>.Default;
  for LPair in Left.FTupleDict.GetDict do
  begin
    if not Right.FTupleDict.GetDict.ContainsKey(LPair.Key) then
      Exit;
    if not LComp2.Equals(LPair.Value, Right.FTupleDict.GetDict[LPair.Key]) then
      Exit;
  end;
  Result := True;
end;

function TTuple<K>.SetTuple(const AKeys: TArray<K>;
  const AValues: TArray<TValue>): TTuple<K>;
begin
  Result := TTuple<K>.New(AKeys, AValues);
end;

function TTuple<K>.Get<T>(const AKey: K): T;
begin
  Result := FTupleDict.GetItem(AKey).AsType<T>;
end;

function TTuple<K>.TryGet<T>(const AKey: K; out AValue: T): Boolean;
var
  LValue: TValue;
begin
  Result := FTupleDict.TryGetValue(AKey, LValue);
  if Result then
    AValue := LValue.AsType<T>
  else
    AValue := Default(T);
end;

function TTuple<K>.GetItem(const AKey: K): TValue;
begin
  Result := FTupleDict.GetItem(AKey);
end;

class operator TTuple<K>.Implicit(const P: TArray<TPair<K, TValue>>): TTuple<K>;
begin
  Result := TTuple<K>.Create(P);
end;

class operator TTuple<K>.Implicit(const P: TTuple<K>): TArray<TPair<K, TValue>>;
var
  LPair: TPair<K, TValue>;
  I: Integer;
begin
  SetLength(Result, P.FTupleDict.Count);
  I := 0;
  for LPair in P.FTupleDict.GetDict do
  begin
    Result[I] := LPair;
    Inc(I);
  end;
end;

class function TTuple<K>.New(const AKeys: TArray<K>;
  const AValues: TArray<TValue>): TTuple<K>;
var
  LPairs: TArray<TPair<K, TValue>>;
  I: Integer;
begin
  if Length(AKeys) <> Length(AValues) then
    raise Exception.Create('Number of keys and values must match');

  SetLength(LPairs, Length(AKeys));
  for I := 0 to High(AKeys) do
    LPairs[I] := TPair<K, TValue>.Create(AKeys[I], AValues[I]);
  Result := TTuple<K>.Create(LPairs);
end;

class operator TTuple<K>.NotEqual(const Left, Right: TTuple<K>): Boolean;
begin
  Result := not (Left = Right);
end;

{ TTuple }

function TTuple.Count: Integer;
begin
  Result := Length(FTuples);
end;

constructor TTuple.Create(const Args: TValueArray);
var
  LFor: Integer;
begin
  SetLength(FTuples, Length(Args));
  for LFor := Low(Args) to High(Args) do
    FTuples[LFor] := Args[LFor];
end;

class operator TTuple.Equal(const Left, Right: TTuple): Boolean;
var
  LFor: Integer;
begin
  Result := False;
  if Length(Left.FTuples) <> Length(Right.FTuples) then
    Exit;
  for LFor := 0 to High(Left.FTuples) do
  begin
    if Left.FTuples[LFor].Kind <> Right.FTuples[LFor].Kind then
      Exit;
    if Left.FTuples[LFor].ToString <> Right.FTuples[LFor].ToString then
      Exit;
  end;
  Result := True;
end;

function TTuple.Get<T>(const AIndex: Integer): T;
begin
  Result := FTuples[AIndex].AsType<T>;
end;

function TTuple.GetItem(const AIndex: Integer): TValue;
begin
  Result := FTuples[AIndex];
end;

procedure TTuple.Dest(const AVarRefs: TArray<Pointer>);
var
  LFor: Integer;
  LTypeInfo: PTypeInfo;
begin
  if Length(AVarRefs) <> Length(FTuples) then
    raise Exception.Create('Number of pointers (' + IntToStr(Length(AVarRefs)) +
      ') must match tuple length (' + IntToStr(Length(FTuples)) + ')');

  for LFor := Low(AVarRefs) to High(AVarRefs) do
  begin
    case FTuples[LFor].Kind of
      tkInt64:
        PInt64(AVarRefs[LFor])^ := FTuples[LFor].AsInt64;
      tkInteger, tkSet:
        PInteger(AVarRefs[LFor])^ := FTuples[LFor].AsInteger;
      tkFloat:
        PDouble(AVarRefs[LFor])^ := FTuples[LFor].AsExtended;
      tkUString, tkLString, tkWString, tkString, tkChar, tkWChar:
        PUnicodeString(AVarRefs[LFor])^ := FTuples[LFor].AsString;
      tkClass:
        PObject(AVarRefs[LFor])^ := FTuples[LFor].AsObject;
      tkEnumeration:
        PBoolean(AVarRefs[LFor])^ := FTuples[LFor].AsBoolean;
      tkRecord, tkVariant:
        PVariant(AVarRefs[LFor])^ := FTuples[LFor].AsVariant;
      tkArray, tkDynArray:
      begin
        LTypeInfo := FTuples[LFor].TypeInfo;
        case GetTypeData(LTypeInfo).elType2^.Kind of
          tkInt64:
            TArray<Int64>(AVarRefs[LFor]) := FTuples[LFor].AsType<TArray<Int64>>;
          tkInteger, tkSet:
            TArray<Integer>(AVarRefs[LFor]) := FTuples[LFor].AsType<TArray<Integer>>;
          tkFloat:
            TArray<Extended>(AVarRefs[LFor]) := FTuples[LFor].AsType<TArray<Extended>>;
          tkUString, tkLString, tkWString, tkString, tkChar, tkWChar:
            TArray<String>(AVarRefs[LFor]) := FTuples[LFor].AsType<TArray<String>>;
          tkClass:
            TArray<TObject>(AVarRefs[LFor]) := FTuples[LFor].AsType<TArray<TObject>>;
          tkEnumeration:
            TArray<Boolean>(AVarRefs[LFor]) := FTuples[LFor].AsType<TArray<Boolean>>;
          tkRecord, tkVariant:
            TArray<Variant>(AVarRefs[LFor]) := FTuples[LFor].AsType<TArray<Variant>>;
          else
            raise Exception.Create('Unsupported array element type at index ' + IntToStr(LFor));
        end;
      end;
      else
        raise Exception.Create('Unsupported type at index ' + IntToStr(LFor));
    end;
  end;
end;

class operator TTuple.Implicit(const Args: TTuple): TValueArray;
begin
  Result := Args.FTuples;
end;

class operator TTuple.Implicit(const Args: array of Variant): TTuple;
var
  LFor: Integer;
begin
  SetLength(Result.FTuples, Length(Args));
  for LFor := Low(Args) to High(Args) do
    Result.FTuples[LFor] := TValue.FromVariant(Args[LFor]);
end;

class operator TTuple.Implicit(const Args: TValueArray): TTuple;
begin
  Result := TTuple.Create(Args);
end;

class function TTuple.New(const AValues: TValueArray): TTuple;
begin
  Result := TTuple.Create(AValues);
end;

class operator TTuple.NotEqual(const Left, Right: TTuple): Boolean;
begin
  Result := not (Left = Right);
end;

end.

