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

{$T+}

unit ecl.map;

interface

uses
  Rtti,
  Math,
  Classes,
  SysUtils,
  StrUtils,
  TypInfo,
  Generics.Defaults,
  Generics.Collections;

type
  TMapPair<K, V> = record
    Key: K;
    Value: V;
    constructor Create(const AKey: K; const AValue: V);
  end;

  IMapEnumerator<K, V> = interface
    ['{5BC9B8F2-7503-4896-82C6-E8EFA27E9555}']
    function _GetCurrent: TMapPair<K, V>;
    function MoveNext: Boolean;
    property Current: TMapPair<K, V> read _GetCurrent;
  end;

  TDefaultCapacity = record
  public
    class var DefaultCapacity: Integer;
  end;

  TMap<K, V> = record
  strict private
    type
      PItemPair = ^TItemPair;
      TItemPair = record
        HashCode: Integer;
        Key: K;
        Value: V;
        constructor Create(const AKey: K; const AValue: V; const AHashCode: Integer = -1);
      end;
      TArrayPair = TArray<TItemPair>;
      PArrayPair = ^TArrayPair;

      TMapEnumerator = class(TEnumerator<TMapPair<K,V>>)
      private
        FItems: PArrayPair;
        FIndex: Integer;
        function _GetCurrent: TMapPair<K, V>;
      protected
        function DoGetCurrent: TMapPair<K,V>; override;
        function DoMoveNext: Boolean; override;
        function _IsEquals<T>(const ALeft: T; ARight: T): Boolean;
      public
        constructor Create(const AItems: PArrayPair);
        destructor Destroy; override;
        function MoveNext: Boolean;
        property Current: TMapPair<K, V> read _GetCurrent;
      end;
  strict private
    FMapItems: TArrayPair;
    FDefaultCapacity: TDefaultCapacity;
    FCapacity: Integer;

    /// <summary>
    ///   Calculates the bucket index for a given key using its hash code.
    /// </summary>
    /// <remarks>
    ///   Uses linear probing to resolve collisions. Returns the index of an empty slot or the existing key if found.
    ///   Returns -1 if no suitable slot is available after probing the entire table.
    /// </remarks>
    /// <param name="AKey">The key to find or insert.</param>
    /// <param name="AHashCode">Optional precomputed hash code. If -1, computes the hash internally.</param>
    function _GetBucketIndex(const AKey: K; const AHashCode: Integer = -1): Integer;

    /// <summary>
    ///   Counts the number of occupied slots in the map.
    /// </summary>
    /// <returns>The number of key-value pairs currently stored.</returns>
    function _GetCount: Integer;

    /// <summary>
    ///   Computes a hash code for a given key.
    /// </summary>
    /// <param name="Key">The key to hash.</param>
    /// <returns>A positive integer hash code.</returns>
    function _Hash(const Key: K): Integer;

    /// <summary>
    ///   Compares two values for equality using the default equality comparer.
    /// </summary>
    /// <param name="ALeft">The first value to compare.</param>
    /// <param name="ARight">The second value to compare.</param>
    /// <returns>True if the values are equal, False otherwise.</returns>
    function _IsEquals<T>(const ALeft: T; ARight: T): Boolean;

    /// <summary>
    ///   Adds a key-value pair to the map.
    /// </summary>
    /// <remarks>
    ///   Handles capacity growth if the load factor exceeds 50%. In debug mode, raises an exception if no valid slot is found.
    /// </remarks>
    /// <param name="AKey">The key to add.</param>
    /// <param name="AValue">The value associated with the key.</param>
    /// <param name="AIndex">Unused parameter (reserved for compatibility).</param>
    procedure _DoAdd(const AKey: K; const AValue: V; const AIndex: Integer);

    /// <summary>
    ///   Resizes the map to a new capacity and rehashes existing items.
    /// </summary>
    /// <remarks>
    ///   Ensures the new capacity is at least as large as the current count. Reindexes all items using their hash codes.
    /// </remarks>
    /// <param name="NewCapacity">The new capacity to set.</param>
    procedure _Rehash(const ANewCapacity: Integer); inline;
  public
    /// <summary>
    ///   Implicitly converts a TMap to its internal TArrayPair representation.
    /// </summary>
    class operator Implicit(const V: TMap<K, V>): TArrayPair;

    /// <summary>
    ///   Implicitly converts a TArrayPair to a TMap.
    /// </summary>
    class operator Implicit(const V: TArrayPair): TMap<K, V>;

    /// <summary>
    ///   Creates an empty TMap with the default capacity.
    /// </summary>
    /// <returns>A new empty TMap instance.</returns>
    class function Empty: TMap<K, V>; static; inline;

    /// <summary>
    ///   Creates a TMap from an existing array of key-value pairs.
    /// </summary>
    /// <param name="AValue">The array of key-value pairs to initialize the map.</param>
    constructor Create(const AValue: TArrayPair); overload;

    /// <summary>
    ///   Creates a TMap with a single key-value pair.
    /// </summary>
    /// <param name="AKey">The initial key.</param>
    /// <param name="AValue">The initial value.</param>
    constructor Create(const AKey: K; AValue: V); overload;

    /// <summary>
    ///   Executes an action for each key-value pair in the map.
    /// </summary>
    /// <param name="AAction">The action to perform on each pair.</param>
    procedure ForEach(const AAction: TProc<K, V>); inline;

    /// <summary>
    ///   Adds all key-value pairs from another TMap to this map.
    /// </summary>
    /// <param name="ACollection">The TMap containing pairs to add.</param>
    procedure AddRange(const ACollection: TMap<K, V>); inline;

    /// <summary>
    ///   Sets the capacity of the map, resizing if necessary.
    /// </summary>
    /// <param name="ACapacity">The new capacity to set.</param>
    procedure SetCapacity(const ACapacity: Integer); inline;

    /// <summary>
    ///   Sets the default initial capacity for new TMap instances.
    /// </summary>
    /// <param name="ADefault">The default capacity value.</param>
    procedure SetDefaultCapacity(const ADefault: Integer); inline;

    /// <summary>
    ///   Inserts a key-value pair at a specific index.
    /// </summary>
    /// <remarks>
    ///   Resizes the map if the index exceeds the current capacity. Shifts existing items as needed.
    /// </remarks>
    /// <param name="AIndex">The index at which to insert the pair.</param>
    /// <param name="AItem">The key-value pair to insert.</param>
    procedure Insert(const AIndex: Integer; const AItem: TItemPair); inline;

    /// <summary>
    ///   Deletes the key-value pair at the specified index.
    /// </summary>
    /// <remarks>
    ///   Marks the slot as empty without resizing the array.
    /// </remarks>
    /// <param name="AIndex">The index of the pair to delete.</param>
    procedure Delete(const AIndex: Integer); inline;

    /// <summary>
    ///   Frees the internal array. Must be called manually to avoid memory leaks.
    /// </summary>
    procedure Clear; inline;

    /// <summary>
    ///   Returns an enumerator for iterating over the map's key-value pairs.
    /// </summary>
    /// <returns>An enumerator instance.</returns>
    function GetEnumerator: TEnumerator<TMapPair<K,V>>; inline;

    /// <summary>
    ///   Retrieves the value associated with a key.
    /// </summary>
    /// <param name="AKey">The key to look up.</param>
    /// <returns>The value if found, otherwise the default value for V.</returns>
    function GetValue(const AKey: K): V; inline;

    /// <summary>
    ///   Attempts to retrieve the value associated with a key.
    /// </summary>
    /// <param name="AKey">The key to look up.</param>
    /// <param name="AValue">The variable to store the retrieved value.</param>
    /// <returns>True if the key exists, False otherwise.</returns>
    function TryGetValue(const AKey: K; var AValue: V): Boolean; inline;

    /// <summary>
    ///   Retrieves the internal key-value pair for a given key.
    /// </summary>
    /// <param name="AKey">The key to look up.</param>
    /// <returns>The TItemPair if found, otherwise a default pair.</returns>
    function GetPair(const AKey: K): TItemPair; inline;

    /// <summary>
    ///   Adds a key-value pair to the map.
    /// </summary>
    /// <param name="APair">The key-value pair to add.</param>
    /// <returns>The index where the pair was added.</returns>
    function Add(const APair: TMapPair<K, V>): Integer; overload; inline;

    /// <summary>
    ///   Adds a key-value pair to the map using separate key and value parameters.
    /// </summary>
    /// <param name="AKey">The key to add.</param>
    /// <param name="AValue">The value associated with the key.</param>
    /// <returns>The index where the pair was added.</returns>
    function Add(const AKey: K; const AValue: V): Integer; overload; inline;

    /// <summary>
    ///   Adds or updates a key-value pair in the map.
    /// </summary>
    /// <param name="AKey">The key to add or update.</param>
    /// <param name="AValue">The value to associate with the key.</param>
    procedure AddOrUpdate(const AKey: K; const AValue: V); inline;

    /// <summary>
    ///   Checks if a key exists in the map.
    /// </summary>
    /// <param name="AKey">The key to check.</param>
    /// <returns>True if the key exists, False otherwise.</returns>
    function Contains(const AKey: K): Boolean; inline;

    /// <summary>
    ///   Merges an array of key-value pairs into the map, adding only new keys.
    /// </summary>
    /// <param name="ASourceArray">The array of pairs to merge.</param>
    /// <returns>The updated TMap instance.</returns>
    function Merge(const ASourceArray: TArray<TMapPair<K, V>>): TMap<K, V>; inline;

    /// <summary>
    ///   Filters the map based on a predicate, returning a new TMap.
    /// </summary>
    /// <param name="APredicate">The function to evaluate each key-value pair.</param>
    /// <returns>A new TMap containing only pairs that satisfy the predicate.</returns>
    function Filter(const APredicate: TFunc<K, V, Boolean>): TMap<K, V>; inline;

    /// <summary>
    ///   Maps values to a new TMap using a transformation function.
    /// </summary>
    /// <param name="AMappingFunc">The function to transform each value.</param>
    /// <returns>A new TMap with transformed values.</returns>
    function Map(const AMappingFunc: TFunc<V, V>): TMap<K, V>; overload; inline;

    /// <summary>
    ///   Maps values to a new TMap with a different value type using a transformation function.
    /// </summary>
    /// <param name="AMappingFunc">The function to transform each value.</param>
    /// <returns>A new TMap with transformed values of type R.</returns>
    function Map<R>(const AMappingFunc: TFunc<V, R>): TMap<K, R>; overload; inline;

    /// <summary>
    ///   Maps key-value pairs to a new TMap using a transformation function.
    /// </summary>
    /// <param name="AMappingFunc">The function to transform each key-value pair.</param>
    /// <returns>A new TMap with transformed values.</returns>
    function Map(const AMappingFunc: TFunc<K, V, V>): TMap<K, V>; overload; inline;

    /// <summary>
    ///   Maps key-value pairs to a new TMap with a different value type using a transformation function.
    /// </summary>
    /// <param name="AMappingFunc">The function to transform each key-value pair.</param>
    /// <returns>A new TMap with transformed values of type R.</returns>
    function Map<R>(const AMappingFunc: TFunc<K, V, R>): TMap<K, R>; overload; inline;

    /// <summary>
    ///   Removes a key-value pair from the map.
    /// </summary>
    /// <param name="AKey">The key to remove.</param>
    /// <returns>True if the key was removed, False if it was not found.</returns>
    function Remove(const AKey: K): Boolean; //inline;

    /// <summary>
    ///   Returns the first occupied key-value pair in the map.
    /// </summary>
    /// <returns>The first TItemPair, or default if the map is empty.</returns>
    function First: TItemPair; inline;

    /// <summary>
    ///   Returns the last key-value pair based on key order.
    /// </summary>
    /// <remarks>
    ///   Uses sorting internally, which may impact performance for large maps.
    /// </remarks>
    /// <returns>The last TMapPair based on key comparison.</returns>
    function Last: TMapPair<K, V>; inline;

    /// <summary>
    ///   Returns a JSON representation of the map with sorted keys.
    /// </summary>
    /// <remarks>
    ///   Uses sorting internally, which may impact performance for large maps. See ToJsonRaw for a faster alternative.
    /// </remarks>
    /// <returns>A JSON string representing the map.</returns>
    function ToJson: String; inline;

    /// <summary>
    ///   Returns a string representation of the map with sorted keys.
    /// </summary>
    /// <remarks>
    ///   Uses sorting internally, which may impact performance for large maps. See ToStringRaw for a faster alternative.
    /// </remarks>
    /// <returns>A string representing the map.</returns>
    function ToString: String; inline;

    /// <summary>
    ///   Returns the current capacity of the map.
    /// </summary>
    /// <returns>The number of slots in the internal array.</returns>
    function Capacity: Integer; inline;

    /// <summary>
    ///   Returns the number of key-value pairs in the map.
    /// </summary>
    /// <returns>The count of occupied slots.</returns>
    function Count: Integer; inline;

    /// <summary>
    ///   Converts the map to an array of key-value pairs.
    /// </summary>
    /// <returns>An array of TItemPair containing all occupied slots.</returns>
    function ToArray: TArray<TItemPair>; inline;

    /// <summary>
    ///   Returns the number of items displaced from their ideal hash slots due to collisions.
    /// </summary>
    /// <remarks>
    ///   Useful for monitoring hash distribution quality in high-load scenarios. O(n) complexity, use sparingly.
    /// </remarks>
    /// <returns>The number of collisions in the map.</returns>
    function GetCollisions: Integer; inline;

    /// <summary>
    ///   Returns a JSON representation without sorting, optimized for high-performance scenarios.
    /// </summary>
    /// <returns>A JSON string with unsorted key-value pairs.</returns>
    function ToJsonRaw: String; inline;

    /// <summary>
    ///   Returns a string representation without sorting, optimized for high-performance scenarios.
    /// </summary>
    /// <returns>A string with unsorted key-value pairs.</returns>
    function ToStringRaw: String; inline;

    property Items[const AKey: K]: V read GetValue write AddOrUpdate; default;
  end;

implementation

{ TMap<K, V> }

function TMap<K, V>._GetCount: Integer;
var
  LFor: Integer;
begin
  Result := 0;
  for LFor := 0 to High(FMapItems) do
    if FMapItems[LFor].HashCode <> -1 then
      Inc(Result);
end;

function TMap<K, V>._GetBucketIndex(const AKey: K; const AHashCode: Integer): Integer;
var
  LHashCode: Integer;
  LCapacity: Integer;
  LIndex: Integer;
  LStartIndex: Integer;
begin
  LCapacity := Length(FMapItems);
  if LCapacity = 0 then
    Exit(-1);

  LHashCode := IfThen(AHashCode = -1, _Hash(AKey), AHashCode);
  LIndex := LHashCode and (LCapacity - 1);
  LStartIndex := LIndex;

  repeat
    if FMapItems[LIndex].HashCode = -1 then
      Exit(LIndex);
    if _IsEquals<K>(FMapItems[LIndex].Key, AKey) then
      Exit(LIndex);

    Inc(LIndex);
    if LIndex >= LCapacity then
      LIndex := 0;
  until LIndex = LStartIndex;

  Result := -1;
end;

procedure TMap<K, V>.SetCapacity(const ACapacity: Integer);
begin
  if ACapacity > FCapacity then
    _Rehash(ACapacity);
end;

procedure TMap<K, V>._Rehash(const ANewCapacity: Integer);
var
  LOldItems: TArrayPair;
  LFor, LIndex: Integer;
begin
  if ANewCapacity < _GetCount then
    raise Exception.Create('New capacity cannot be less than current count');

  LOldItems := FMapItems;
  FCapacity := ANewCapacity;
  SetLength(FMapItems, FCapacity);

  for LFor := 0 to FCapacity - 1 do
    FMapItems[LFor].HashCode := -1;

  for LFor := 0 to Length(LOldItems) - 1 do
  begin
    if LOldItems[LFor].HashCode <> -1 then
    begin
      LIndex := _GetBucketIndex(LOldItems[LFor].Key, LOldItems[LFor].HashCode);
      FMapItems[LIndex] := LOldItems[LFor];
    end;
  end;
end;

procedure TMap<K, V>.SetDefaultCapacity(const ADefault: Integer);
begin
  FDefaultCapacity.DefaultCapacity := ADefault;
end;

procedure TMap<K, V>.AddRange(const ACollection: TMap<K, V>);
var
  LPair: TItemPair;
begin
  for LPair in ACollection.FMapItems do
  begin
    if LPair.HashCode <> -1 then
      Add(LPair.Key, LPair.Value);
  end;
end;

function TMap<K, V>.GetValue(const AKey: K): V;
var
  LPair: TItemPair;
begin
  LPair := GetPair(AKey);
  if _IsEquals<K>(LPair.Key, AKey) then
    Result := LPair.Value
  else
    Result := Default(V);
end;

class operator TMap<K, V>.Implicit(const V: TMap<K, V>): TArrayPair;
begin
  Result := V.FMapItems;
end;

class operator TMap<K, V>.Implicit(const V: TArrayPair): TMap<K, V>;
begin
  Result.FMapItems := V;
end;

procedure TMap<K, V>.Insert(const AIndex: Integer; const AItem: TItemPair);
var
  LFor: Integer;
  LLength: Integer;
begin
  LLength := FCapacity;
  if LLength = 0 then
  begin
    SetCapacity(FDefaultCapacity.DefaultCapacity);
    LLength := FCapacity;
  end
  else if LLength <= AIndex then
  begin
    LLength := AIndex + FDefaultCapacity.DefaultCapacity;
    SetCapacity(LLength);
  end;
  for LFor := LLength - 1 downto AIndex + 1 do
    FMapItems[LFor] := FMapItems[LFor - 1];
  FMapItems[AIndex] := AItem;
end;

function TMap<K, V>.GetCollisions: Integer;
var
  LFor: Integer;
  LExpectedIndex: Integer;
begin
  Result := 0;
  for LFor := 0 to High(FMapItems) do
  begin
    if FMapItems[LFor].HashCode <> -1 then
      Continue;
    LExpectedIndex := FMapItems[LFor].HashCode and (Length(FMapItems) - 1);
    if LExpectedIndex <> LFor then
      Inc(Result);
  end;
end;

function TMap<K, V>.GetEnumerator: TEnumerator<TMapPair<K,V>>;
begin
  Result := TMapEnumerator.Create(@FMapItems);
end;

function TMap<K, V>.GetPair(const AKey: K): TItemPair;
var
  LIndex: Integer;
begin
  LIndex := _GetBucketIndex(AKey);
  if LIndex <> -1 then
    Result := FMapItems[LIndex]
  else
    Result := TItemPair.Create(Default(K), Default(V));
end;

function TMap<K, V>.Add(const APair: TMapPair<K, V>): Integer;
var
  LIndex: Integer;
begin
  LIndex := _GetBucketIndex(APair.Key);
  if LIndex = -1 then
  begin
    _DoAdd(APair.Key, APair.Value, LIndex);
    Result := _GetBucketIndex(APair.Key);
  end
  else
  begin
    FMapItems[LIndex] := TItemPair.Create(APair.Key, APair.Value, _Hash(APair.Key));
    Result := LIndex;
  end;
end;

function TMap<K, V>.Add(const AKey: K; const AValue: V): Integer;
begin
  Result := Add(TMapPair<K, V>.Create(AKey, AValue));
end;

procedure TMap<K, V>.AddOrUpdate(const AKey: K; const AValue: V);
var
  LIndex: Integer;
begin
  LIndex := _GetBucketIndex(AKey);
  if LIndex > -1 then
    FMapItems[LIndex] := TItemPair.Create(AKey, AValue, _Hash(AKey))
  else
    Add(TMapPair<K, V>.Create(AKey, AValue));
end;

procedure TMap<K, V>._DoAdd(const AKey: K; const AValue: V; const AIndex: Integer);
var
  LIndex: Integer;
  LCount: Integer;
begin
  LCount := _GetCount;
  if Length(FMapItems) = 0 then
  begin
    FCapacity := TDefaultCapacity.DefaultCapacity;
    SetLength(FMapItems, FCapacity);
    for LIndex := 0 to FCapacity - 1 do
      FMapItems[LIndex].HashCode := -1;
  end;

  if LCount >= (FCapacity div 2) then
    SetCapacity(FCapacity * 2);

  LIndex := _GetBucketIndex(AKey);
  {$IFDEF DEBUG}
  if (LIndex < 0) or (LIndex >= Length(FMapItems)) then
    raise Exception.Create('Invalid bucket index: ' + LIndex.ToString);
  {$ENDIF}
  FMapItems[LIndex] := TItemPair.Create(AKey, AValue, _Hash(AKey));
end;

function TMap<K, V>.Capacity: Integer;
begin
  Result := FCapacity;
end;

procedure TMap<K, V>.Clear;
begin
  FMapItems := nil;
  FCapacity := 0;
end;

function TMap<K, V>.Contains(const AKey: K): Boolean;
var
  LIndex: Integer;
begin
  LIndex := _GetBucketIndex(AKey);
  Result := (LIndex >= 0) and (FMapItems[LIndex].HashCode <> -1) and _IsEquals<K>(FMapItems[LIndex].Key, AKey);
end;

constructor TMap<K, V>.Create(const AValue: TArrayPair);
var
  LFor: Integer;
begin
  FMapItems := AValue;
  FCapacity := Length(FMapItems);
  if FCapacity = 0 then
  begin
    FCapacity := TDefaultCapacity.DefaultCapacity;
    SetLength(FMapItems, FCapacity);
    for LFor := 0 to FCapacity - 1 do
      FMapItems[LFor].HashCode := -1;
  end;
end;

constructor TMap<K, V>.Create(const AKey: K; AValue: V);
var
  LFor: Integer;
begin
  FCapacity := TDefaultCapacity.DefaultCapacity;
  SetLength(FMapItems, FCapacity);
  for LFor := 0 to FCapacity - 1 do
    FMapItems[LFor].HashCode := -1;
  Add(AKey, AValue);
end;

procedure TMap<K, V>.Delete(const AIndex: Integer);
begin
  if (AIndex >= 0) and (AIndex < Length(FMapItems)) then
  begin
    FMapItems[AIndex].HashCode := -1;
    FMapItems[AIndex].Key := Default(K);
    FMapItems[AIndex].Value := Default(V);
  end;
end;

class function TMap<K, V>.Empty: TMap<K, V>;
var
  LFor: Integer;
begin
  Result.FCapacity := TDefaultCapacity.DefaultCapacity;
  SetLength(Result.FMapItems, Result.FCapacity);
  for LFor := 0 to Result.FCapacity - 1 do
    Result.FMapItems[LFor].HashCode := -1;
end;

function TMap<K, V>.Remove(const AKey: K): Boolean;
var
  LIndex: Integer;
begin
  Result := False;
  LIndex := _GetBucketIndex(AKey);
  if LIndex = -1 then
    Exit;
  Result := (FMapItems[LIndex].HashCode <> -1);
  if Result then
    Delete(LIndex);
end;

function TMap<K, V>.Last: TMapPair<K, V>;
var
  LPair: TItemPair;
  LList: TList<TItemPair>;
  LLastIndex: Integer;
begin
  LList := TList<TItemPair>.Create;
  try
    for LPair in FMapItems do
      if LPair.HashCode <> -1 then
        LList.Add(LPair);

    if LList.Count = 0 then
      raise Exception.Create('No non-empty elements found');

    LList.Sort(TComparer<TItemPair>.Construct(
      function(const Left, Right: TItemPair): Integer
      begin
        Result := TComparer<K>.Default.Compare(Left.Key, Right.Key);
      end));

    LLastIndex := LList.Count - 1;
    Result.Key := LList[LLastIndex].Key;
    Result.Value := LList[LLastIndex].Value;
  finally
    LList.Free;
  end;
end;

function TMap<K, V>.Count: Integer;
begin
  Result := _GetCount;
end;

function TMap<K, V>.Map(const AMappingFunc: TFunc<V, V>): TMap<K, V>;
var
  LPair: TMapPair<K, V>;
begin
  Result := TMap<K, V>.Empty;
  for LPair in Self do
    Result.Add(LPair.Key, AMappingFunc(LPair.Value));
end;

function TMap<K, V>.Map(const AMappingFunc: TFunc<K, V, V>): TMap<K, V>;
var
  LPair: TMapPair<K, V>;
begin
  Result := TMap<K, V>.Empty;
  for LPair in Self do
    Result.Add(LPair.Key, AMappingFunc(LPair.Key, LPair.Value));
end;

function TMap<K, V>.Map<R>(const AMappingFunc: TFunc<K, V, R>): TMap<K, R>;
var
  LPair: TMapPair<K, V>;
begin
  Result := TMap<K, R>.Empty;
  for LPair in Self do
    Result.Add(LPair.Key, AMappingFunc(LPair.Key, LPair.Value));
end;

function TMap<K, V>.Map<R>(const AMappingFunc: TFunc<V, R>): TMap<K, R>;
var
  LPair: TMapPair<K, V>;
begin
  Result := TMap<K, R>.Empty;
  for LPair in Self do
    Result.Add(LPair.Key, AMappingFunc(LPair.Value));
end;

function TMap<K, V>.Merge(const ASourceArray: TArray<TMapPair<K, V>>): TMap<K, V>;
var
  LItem: TMapPair<K, V>;
begin
  for LItem in ASourceArray do
    if not Contains(LItem.Key) then
      Add(LItem.Key, LItem.Value);
  Result := Self;
end;

function TMap<K, V>.Filter(const APredicate: TFunc<K, V, Boolean>): TMap<K, V>;
var
  LItem: TItemPair;
begin
  Result := TMap<K, V>.Empty;
  for LItem in FMapItems do
    if (LItem.HashCode <> -1) and APredicate(LItem.Key, LItem.Value) then
      Result.Add(LItem.Key, LItem.Value);
end;

function TMap<K, V>.First: TItemPair;
var
  LFor: Integer;
begin
  Result := Default(TItemPair);
  if Length(FMapItems) = 0 then
    Exit;
  for LFor := 0 to High(FMapItems) do
    if FMapItems[LFor].HashCode <> -1 then
      Exit(FMapItems[LFor]);
end;

procedure TMap<K, V>.ForEach(const AAction: TProc<K, V>);
var
  LPair: TItemPair;
begin
  for LPair in FMapItems do
    if LPair.HashCode <> -1 then
      AAction(LPair.Key, LPair.Value);
end;

function TMap<K, V>.ToString: String;
var
  LPair: TItemPair;
  LBuilder: TStringBuilder;
  LKey: TValue;
  LValue: TValue;
  LList: TList<TItemPair>;
  LFor: Integer;
begin
  LList := TList<TItemPair>.Create;
  try
    for LPair in FMapItems do
      if LPair.HashCode <> -1 then
        LList.Add(LPair);

    LList.Sort(TComparer<TItemPair>.Construct(
      function(const Left, Right: TItemPair): Integer
      begin
        Result := TComparer<K>.Default.Compare(Left.Key, Right.Key);
      end));

    LBuilder := TStringBuilder.Create;
    try
      for LFor := 0 to LList.Count - 1 do
      begin
        LPair := LList[LFor];
        LKey := TValue.From<K>(LPair.Key);
        LValue := TValue.From<V>(LPair.Value);
        if LKey.IsObject then
          LBuilder.Append(Format('%s=%s ', [LKey.AsObject.ToString, LValue.ToString]))
        else
          LBuilder.Append(Format('%s=%s ', [LKey.ToString, LValue.ToString]));
      end;
      Result := TrimRight(LBuilder.ToString);
    finally
      LBuilder.Free;
    end;
  finally
    LList.Free;
  end;
end;

function TMap<K, V>.TryGetValue(const AKey: K; var AValue: V): Boolean;
var
  LIndex: Integer;
begin
  LIndex := _GetBucketIndex(AKey);
  Result := LIndex >= 0;
  if Result then
  begin
    AValue := FMapItems[LIndex].Value;
    Result := FMapItems[LIndex].HashCode <> -1;
  end
  else
    AValue := Default(V);
end;

function TMap<K, V>.ToArray: TArray<TItemPair>;
var
  LPair: TItemPair;
begin
  SetLength(Result, 0);
  for LPair in FMapItems do
  begin
    if LPair.HashCode = -1 then
      Continue;
    SetLength(Result, Length(Result) + 1);
    Result[Length(Result) - 1] := LPair;
  end;
end;

function TMap<K, V>.ToJson: String;
var
  LPair: TItemPair;
  LJsonPairs: TStringBuilder;
  LKey: TValue;
  LValue: TValue;
  LFirstPair: Boolean;
  LList: TList<TItemPair>;
  LFor: Integer;
begin
  LList := TList<TItemPair>.Create;
  try
    for LPair in FMapItems do
      if LPair.HashCode <> -1 then
        LList.Add(LPair);

    LList.Sort(TComparer<TItemPair>.Construct(
      function(const Left, Right: TItemPair): Integer
      begin
        Result := TComparer<K>.Default.Compare(Left.Key, Right.Key);
      end));

    LJsonPairs := TStringBuilder.Create;
    LFirstPair := True;
    try
      for LFor := 0 to LList.Count - 1 do
      begin
        LPair := LList[LFor];
        LKey := TValue.From<K>(LPair.Key);
        LValue := TValue.From<V>(LPair.Value);
        if not LFirstPair then
          LJsonPairs.Append(', ');
        LJsonPairs.Append(Format('"%s": "%s"', [LKey.ToString, LValue.ToString]));
        LFirstPair := False;
      end;
      Result := '{' + LJsonPairs.ToString + '}';
    finally
      LJsonPairs.Free;
    end;
  finally
    LList.Free;
  end;
end;

function TMap<K, V>._Hash(const Key: K): Integer;
const
  POSITIVEMASK = not Integer($80000000);
begin
  Result := POSITIVEMASK and ((POSITIVEMASK and TEqualityComparer<K>.Default.GetHashCode(Key)) + 1);
end;

function TMap<K, V>._IsEquals<T>(const ALeft: T; ARight: T): Boolean;
begin
  Result := TEqualityComparer<T>.Default.Equals(ALeft, ARight);
end;


function TMap<K, V>.ToStringRaw: String;
var
  LPair: TItemPair;
  LBuilder: TStringBuilder;
  LKey: TValue;
  LValue: TValue;
begin
  LBuilder := TStringBuilder.Create;
  try
    for LPair in FMapItems do
      if LPair.HashCode <> -1 then
      begin
        LKey := TValue.From<K>(LPair.Key);
        LValue := TValue.From<V>(LPair.Value);
        LBuilder.Append(Format('%s=%s ', [LKey.ToString, LValue.ToString]));
      end;
    Result := TrimRight(LBuilder.ToString);
  finally
    LBuilder.Free;
  end;
end;

function TMap<K, V>.ToJsonRaw: String;
var
  LPair: TItemPair;
  LJsonPairs: TStringBuilder;
  LKey: TValue;
  LValue: TValue;
  LFirstPair: Boolean;
begin
  LJsonPairs := TStringBuilder.Create;
  LFirstPair := True;
  try
    for LPair in FMapItems do
      if LPair.HashCode <> -1 then
      begin
        LKey := TValue.From<K>(LPair.Key);
        LValue := TValue.From<V>(LPair.Value);
        if not LFirstPair then
          LJsonPairs.Append(', ');
        LJsonPairs.Append(Format('"%s": "%s"', [LKey.ToString, LValue.ToString]));
        LFirstPair := False;
      end;
    Result := '{' + LJsonPairs.ToString + '}';
  finally
    LJsonPairs.Free;
  end;
end;

{ TMap<K, V>.TMapEnumerator }

constructor TMap<K, V>.TMapEnumerator.Create(const AItems: PArrayPair);
begin
  FItems := AItems;
  FIndex := -1;
end;

destructor TMap<K, V>.TMapEnumerator.Destroy;
begin
  FItems := nil;
  inherited;
end;

function TMap<K, V>.TMapEnumerator.DoGetCurrent: TMapPair<K, V>;
begin
  Result := _GetCurrent;
end;

function TMap<K, V>.TMapEnumerator.DoMoveNext: Boolean;
begin
  Result := MoveNext;
end;

function TMap<K, V>.TMapEnumerator._GetCurrent: TMapPair<K, V>;
begin
  Result.Key := FItems^[FIndex].Key;
  Result.Value := FItems^[FIndex].Value;
end;

function TMap<K, V>.TMapEnumerator._IsEquals<T>(const ALeft: T; ARight: T): Boolean;
begin
  Result := TEqualityComparer<T>.Default.Equals(ALeft, ARight);
end;

function TMap<K, V>.TMapEnumerator.MoveNext: Boolean;
begin
  repeat
    Inc(FIndex);
    if FIndex >= Length(FItems^) then
      Exit(False);
  until FItems^[FIndex].HashCode <> -1;
  Result := True;
end;

{ TMap<K, V>.TItemPair }

constructor TMap<K, V>.TItemPair.Create(const AKey: K; const AValue: V; const AHashCode: Integer);
begin
  Key := AKey;
  Value := AValue;
  HashCode := AHashCode;
end;

{ TMapPair<K, V> }

constructor TMapPair<K, V>.Create(const AKey: K; const AValue: V);
begin
  Key := AKey;
  Value := AValue;
end;

initialization
  TDefaultCapacity.DefaultCapacity := 4;

end.


