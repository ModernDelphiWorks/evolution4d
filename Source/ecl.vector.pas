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

unit ecl.vector;

interface

uses
  Rtti,
  SysUtils,
  StrUtils,
  TypInfo,
  Generics.Defaults,
  Generics.Collections,
  ecl.std;

type
  Tuple = ecl.std.Tuple;

  /// <summary>
  ///   Defines an enumerator interface for iterating over elements of type T in a TVector.
  /// </summary>
  IVectorEnumerator<T> = interface
    ['{1E9F92D8-4EF1-4D15-9160-9B00013BA97D}']
    /// <summary>
    ///   Retrieves the current element in the enumeration.
    /// </summary>
    /// <returns>
    ///   The current element of type T.
    /// </returns>
    function GetCurrent: T;
    /// <summary>
    ///   Advances the enumerator to the next element.
    /// </summary>
    /// <returns>
    ///   True if there is a next element; False if the end is reached.
    /// </returns>
    function MoveNext: Boolean;
    /// <summary>
    ///   Gets the current element in the enumeration.
    /// </summary>
    property Current: T read GetCurrent;
  end;

  /// <summary>
  ///   A generic dynamic array structure that provides flexible manipulation of elements.
  /// </summary>
  TVector<T> = record
  strict private
    type
      PArrayType = ^TArrayType;
      TArrayType = TArray<T>;
      /// <summary>
      ///   Helper record for managing the internal array operations of TVector.
      /// </summary>
      TArrayManager = record
      strict private
        const GROWTH_FACTOR = 2;
        const SHRINK_THRESHOLD = 0.25;
        const INITIAL_CAPACITY = 8;
        class function _IsEquals<I>(const ALeft: I; ARight: I): Boolean; static; inline;
        class procedure _EnsureCapacity(var AArray: TArrayType; var ACapacity: Integer; const AMinCapacity: Integer); static;
      public
        class procedure Add(var AArray: TArrayType; var ACount: Integer; var ACapacity: Integer; const AItem: T); static; inline;
        class procedure Insert(var AArray: TArrayType; var ACount: Integer; var ACapacity: Integer; const AIndex: Integer; const AItem: T); static; inline;
        class procedure Delete(var AArray: TArrayType; var ACount: Integer; var ACapacity: Integer; const AIndex: Integer); static; inline;
        class procedure Remove(var AArray: TArrayType; var ACount: Integer; var ACapacity: Integer; const AItem: T); static; inline;
        class procedure SetLength(var AArray: TArrayType; var ACount: Integer; var ACapacity: Integer; ALength: Integer); static; inline;
        class procedure SetCapacity(var AArray: TArrayType; var ACapacity: Integer; const ACapacityValue: Integer); static; inline;
        class function GetEnumerator(var AArray: TArrayType; ACount: Integer): IVectorEnumerator<T>; static; inline;
        class function Contains(const AArray: TArrayType; ACount: Integer; const AItem: T): Boolean; static; inline;
        class function IndexOf(const AArray: TArrayType; ACount: Integer; const AItem: T): Integer; static; inline;
      end;

      /// <summary>
      ///   Enumerator class for iterating over TVector elements.
      /// </summary>
      TVectorEnumerator = class(TInterfacedObject, IVectorEnumerator<T>)
      strict private
        FItems: PArrayType;
        FIndex: Integer;
        FCount: Integer;
      protected
        function GetCurrent: T;
        function MoveNext: Boolean;
      public
        constructor Create(const AArray: PArrayType; ACount: Integer);
        destructor Destroy; override;
      end;
  strict private
    FItems: TArrayType;
    FCount: Integer;
    FCapacity: Integer;
    /// <summary>
    ///   Initializes the internal state of the vector if it is not already initialized.
    /// </summary>
    /// <remarks>
    ///   Ensures that FCount and FCapacity are set to 0 if FItems is nil or empty.
    ///   This method is called internally by most operations to maintain consistency.
    /// </remarks>
    procedure _StartVariables;
    /// <summary>
    ///   Sets an item at the specified index in the vector.
    /// </summary>
    /// <param name="LIndex">
    ///   The zero-based index at which to set the item.
    /// </param>
    /// <param name="V">
    ///   The value of type T to set at the specified index.
    /// </param>
    procedure _SetItem(LIndex: Integer; const V: T);
    /// <summary>
    ///   Retrieves an item from the specified index in the vector.
    /// </summary>
    /// <param name="LIndex">
    ///   The zero-based index from which to retrieve the item.
    /// </param>
    /// <returns>
    ///   The item of type T at the specified index.
    /// </returns>
    function _GetItem(LIndex: Integer): T;
    /// <summary>
    ///   Compares two values of a generic type for equality.
    /// </summary>
    /// <param name="ALeft">
    ///   The first value to compare.
    /// </param>
    /// <param name="ARight">
    ///   The second value to compare.
    /// </param>
    /// <returns>
    ///   True if the values are equal; False otherwise.
    /// </returns>
    function _IsEquals<I>(const ALeft: I; ARight: I): Boolean;
  public
    /// <summary>
    ///   Implicitly converts a TVector to a TArray.
    /// </summary>
    /// <param name="V">
    ///   The TVector instance to convert.
    /// </param>
    /// <returns>
    ///   A TArray containing the elements of the vector.
    /// </returns>
    class operator Implicit(const V: TVector<T>): TArrayType; inline;
    /// <summary>
    ///   Implicitly converts a TArray to a TVector.
    /// </summary>
    /// <param name="V">
    ///   The TArray to convert into a TVector.
    /// </param>
    /// <returns>
    ///   A TVector initialized with the elements of the array.
    /// </returns>
    class operator Implicit(const V: TArrayType): TVector<T>; inline;
    /// <summary>
    ///   Compares two TVector instances for equality.
    /// </summary>
    /// <param name="Left">
    ///   The first TVector to compare.
    /// </param>
    /// <param name="Right">
    ///   The second TVector to compare.
    /// </param>
    /// <returns>
    ///   True if the vectors are equal; False otherwise.
    /// </returns>
    class operator Equal(const Left, Right: TVector<T>): Boolean; inline;
    /// <summary>
    ///   Compares two TVector instances for inequality.
    /// </summary>
    /// <param name="Left">
    ///   The first TVector to compare.
    /// </param>
    /// <param name="Right">
    ///   The second TVector to compare.
    /// </param>
    /// <returns>
    ///   True if the vectors are not equal; False otherwise.
    /// </returns>
    class operator NotEqual(const Left, Right: TVector<T>): Boolean; inline;
    /// <summary>
    ///   Concatenates two TVector instances.
    /// </summary>
    /// <param name="Left">
    ///   The first TVector to concatenate.
    /// </param>
    /// <param name="Right">
    ///   The second TVector to concatenate.
    /// </param>
    /// <returns>
    ///   A new TVector containing all elements from both vectors.
    /// </returns>
    class operator Add(const Left, Right: TVector<T>): TVector<T>; inline;
    /// <summary>
    ///   Concatenates a TVector with a TArray.
    /// </summary>
    /// <param name="Left">
    ///   The TVector to concatenate.
    /// </param>
    /// <param name="Right">
    ///   The TArray to concatenate.
    /// </param>
    /// <returns>
    ///   A new TVector containing all elements from the vector and array.
    /// </returns>
    class operator Add(const Left: TVector<T>; const Right: TArrayType): TVector<T>; inline;
    /// <summary>
    ///   Concatenates a TArray with a TVector.
    /// </summary>
    /// <param name="Left">
    ///   The TArray to concatenate.
    /// </param>
    /// <param name="Right">
    ///   The TVector to concatenate.
    /// </param>
    /// <returns>
    ///   A new TVector containing all elements from the array and vector.
    /// </returns>
    class operator Add(const Left: TArrayType; const Right: TVector<T>): TVector<T>; inline;
    /// <summary>
    ///   Appends a single element to a TVector.
    /// </summary>
    /// <param name="Left">
    ///   The TVector to append to.
    /// </param>
    /// <param name="Right">
    ///   The element of type T to append.
    /// </param>
    /// <returns>
    ///   A new TVector with the element appended.
    /// </returns>
    class operator Add(const Left: TVector<T>; const Right: T): TVector<T>; inline;
    /// <summary>
    ///   Prepends a single element to a TVector.
    /// </summary>
    /// <param name="Left">
    ///   The element of type T to prepend.
    /// </param>
    /// <param name="Right">
    ///   The TVector to prepend to.
    /// </param>
    /// <returns>
    ///   A new TVector with the element prepended.
    /// </returns>
    class operator Add(const Left: T; const Right: TVector<T>): TVector<T>; inline;
    /// <summary>
    ///   Removes elements from one TVector that are present in another.
    /// </summary>
    /// <param name="Left">
    ///   The TVector to remove elements from.
    /// </param>
    /// <param name="Right">
    ///   The TVector containing elements to remove.
    /// </param>
    /// <returns>
    ///   A new TVector with the specified elements removed.
    /// </returns>
    class operator Subtract(const Left, Right: TVector<T>): TVector<T>; inline;
    /// <summary>
    ///   Removes a single element from a TVector.
    /// </summary>
    /// <param name="Left">
    ///   The TVector to remove the element from.
    /// </param>
    /// <param name="Right">
    ///   The element of type T to remove.
    /// </param>
    /// <returns>
    ///   A new TVector with the element removed.
    /// </returns>
    class operator Subtract(const Left: TVector<T>; const Right: T): TVector<T>; inline;
    /// <summary>
    ///   Checks if an element is contained within a TVector.
    /// </summary>
    /// <param name="Left">
    ///   The element of type T to check.
    /// </param>
    /// <param name="Right">
    ///   The TVector to search in.
    /// </param>
    /// <returns>
    ///   True if the element is found; False otherwise.
    /// </returns>
    class operator In(const Left: T; const Right: TVector<T>): Boolean; inline;
    /// <summary>
    ///   Checks if all elements of one TVector are contained within another.
    /// </summary>
    /// <param name="Left">
    ///   The TVector containing elements to check.
    /// </param>
    /// <param name="Right">
    ///   The TVector to search in.
    /// </param>
    /// <returns>
    ///   True if all elements are found; False otherwise.
    /// </returns>
    class operator In(const Left, Right: TVector<T>): Boolean; inline;
    /// <summary>
    ///   Checks if all elements of a TArray are contained within a TVector.
    /// </summary>
    /// <param name="Left">
    ///   The TArray containing elements to check.
    /// </param>
    /// <param name="Right">
    ///   The TVector to search in.
    /// </param>
    /// <returns>
    ///   True if all elements are found; False otherwise.
    /// </returns>
    class operator In(const Left: TArrayType; const Right: TVector<T>): Boolean; inline;
    /// <summary>
    ///   Creates an empty TVector instance.
    /// </summary>
    /// <returns>
    ///   A new TVector with no elements.
    /// </returns>
    class function Empty: TVector<T>; static; inline;
    /// <summary>
    ///   Initializes a TVector with an array of elements.
    /// </summary>
    /// <param name="Value">
    ///   The TArray of type T to initialize the vector with.
    /// </param>
    constructor Create(const Value: TArrayType);
    /// <summary>
    ///   Adds an element to the end of the vector.
    /// </summary>
    /// <param name="AValue">
    ///   The element of type T to add.
    /// </param>
    procedure Add(const AValue: T); inline;
    /// <summary>
    ///   Inserts an element at the specified index in the vector.
    /// </summary>
    /// <param name="LIndex">
    ///   The zero-based index at which to insert the element.
    /// </param>
    /// <param name="LItem">
    ///   The element of type T to insert.
    /// </param>
    procedure Insert(const LIndex: Integer; const LItem: T); inline;
    /// <summary>
    ///   Deletes an element at the specified index from the vector.
    /// </summary>
    /// <param name="LIndex">
    ///   The zero-based index of the element to delete.
    /// </param>
    procedure Delete(const LIndex: Integer); inline;
    /// <summary>
    ///   Removes the first occurrence of a specified element from the vector.
    /// </summary>
    /// <param name="LItem">
    ///   The element of type T to remove.
    /// </param>
    procedure Remove(const LItem: T); overload; inline;
    /// <summary>
    ///   Removes all occurrences of elements from a specified array from the vector.
    /// </summary>
    /// <param name="LItems">
    ///   The TArray of elements to remove.
    /// </param>
    procedure Remove(const LItems: TArray<T>); overload; inline;
    /// <summary>
    ///   Executes an action for each element in the vector.
    /// </summary>
    /// <param name="LAction">
    ///   The procedure to execute for each element of type T.
    /// </param>
    procedure ForEach(const LAction: TProc<T>); overload; inline;
    /// <summary>
    ///   Sets the length of the vector, adjusting its capacity if necessary.
    /// </summary>
    /// <param name="LLength">
    ///   The new length of the vector.
    /// </param>
    procedure SetLength(const LLength: Integer); inline;
    /// <summary>
    ///   Sets the capacity of the vector.
    /// </summary>
    /// <param name="LCapacity">
    ///   The new capacity of the vector.
    /// </param>
    procedure SetCapacity(const LCapacity: Integer); inline;
    /// <summary>
    ///   Adds a range of elements from a TArray to the vector.
    /// </summary>
    /// <param name="LCollection">
    ///   The TArray of elements to add.
    /// </param>
    procedure AddRange(const LCollection: TArrayType); inline;
    /// <summary>
    ///   Populates the vector by splitting a string into elements using a separator.
    /// </summary>
    /// <param name="LValue">
    ///   The string to split and convert into elements.
    /// </param>
    /// <param name="LSeparator">
    ///   The separator used to split the string.
    /// </param>
    procedure JoinStrings(const LValue: String; const LSeparator: String); inline;
    /// <summary>
    ///   Removes all elements from the vector and resets its capacity.
    /// </summary>
    procedure Clear; inline;
    /// <summary>
    ///   Assigns a new set of elements to the vector from an open array.
    /// </summary>
    /// <param name="LItems">
    ///   The open array of elements to assign.
    /// </param>
    procedure Assign(const LItems: array of T);
    /// <summary>
    ///   Sorts the vector using the default comparer.
    /// </summary>
    procedure Sort; overload; inline;
    /// <summary>
    ///   Sorts the vector using a specified comparer.
    /// </summary>
    /// <param name="LComparer">
    ///   The IComparer to use for sorting.
    /// </param>
    procedure Sort(const LComparer: IComparer<T>); overload; inline;
    /// <summary>
    ///   Reverses the order of elements in the vector.
    /// </summary>
    procedure Reverse;
    /// <summary>
    ///   Removes duplicate elements from the vector, keeping only unique values.
    /// </summary>
    procedure Unique;
    /// <summary>
    ///   Merges elements from a TArray into the vector, adding only unique values.
    /// </summary>
    /// <param name="LSourceArray">
    ///   The TArray of elements to merge.
    /// </param>
    procedure Merge(const LSourceArray: TArrayType); inline;
    /// <summary>
    ///   Returns an enumerator for iterating over the vector's elements.
    /// </summary>
    /// <returns>
    ///   An IVectorEnumerator for the vector.
    /// </returns>
    function GetEnumerator: IVectorEnumerator<T>; inline;
    /// <summary>
    ///   Checks if a specific element is contained in the vector.
    /// </summary>
    /// <param name="LItem">
    ///   The element of type T to check for.
    /// </param>
    /// <returns>
    ///   True if the element is found; False otherwise.
    /// </returns>
    function Contains(const LItem: T): Boolean; overload; inline;
    /// <summary>
    ///   Checks if all elements from a TArray are contained in the vector.
    /// </summary>
    /// <param name="LItems">
    ///   The TArray of elements to check for.
    /// </param>
    /// <returns>
    ///   True if all elements are found; False otherwise.
    /// </returns>
    function Contains(const LItems: TArrayType): Boolean; overload;
    /// <summary>
    ///   Finds the index of the first occurrence of an element in the vector.
    /// </summary>
    /// <param name="LItem">
    ///   The element of type T to find.
    /// </param>
    /// <returns>
    ///   The zero-based index of the element, or -1 if not found.
    /// </returns>
    function IndexOf(const LItem: T): Integer; inline;
    /// <summary>
    ///   Filters the vector using a predicate, returning a new vector with matching elements.
    /// </summary>
    /// <param name="LPredicate">
    ///   The predicate function to filter elements.
    /// </param>
    /// <returns>
    ///   A new TVector containing elements that satisfy the predicate.
    /// </returns>
    function Filter(const LPredicate: TPredicate<T>): TVector<T>; overload; inline;
    /// <summary>
    ///   Filters the vector using a predicate with index, returning a new vector with matching elements.
    /// </summary>
    /// <param name="LPredicate">
    ///   The predicate function that takes an element and its index to filter elements.
    /// </param>
    /// <returns>
    ///   A new TVector containing elements that satisfy the predicate.
    /// </returns>
    function Filter(const LPredicate: TFunc<T, Integer, Boolean>): TVector<T>; overload; inline;
    /// <summary>
    ///   Maps each element in the vector to a new type using a mapping function.
    /// </summary>
    /// <param name="LMappingFunc">
    ///   The function to transform each element into a new type R.
    /// </param>
    /// <returns>
    ///   A new TVector of type R with transformed elements.
    /// </returns>
    function Map<R>(const LMappingFunc: TFunc<T, R>): TVector<R>; inline;
    /// <summary>
    ///   Reduces the vector to a single value using an accumulator function.
    /// </summary>
    /// <param name="LAccumulator">
    ///   The function to combine elements into a single value of type T.
    /// </param>
    /// <returns>
    ///   The reduced value of type T.
    /// </returns>
    function Reduce(const LAccumulator: TFunc<T, T, T>): T; overload; inline;
    /// <summary>
    ///   Reduces the vector to a single value using an accumulator function and an initial value.
    /// </summary>
    /// <param name="LAccumulator">
    ///   The function to combine elements into a single value of type T.
    /// </param>
    /// <param name="LInitial">
    ///   The initial value of type T to start the reduction.
    /// </param>
    /// <returns>
    ///   The reduced value of type T.
    /// </returns>
    function Reduce(const LAccumulator: TFunc<T, T, T>; const LInitial: T): T; overload; inline;
    /// <summary>
    ///   Reduces the vector to a Tuple using an accumulator function and an initial Tuple.
    /// </summary>
    /// <param name="LAccumulator">
    ///   The function to combine elements with a Tuple into a new Tuple.
    /// </param>
    /// <param name="LTuple">
    ///   The initial Tuple to start the reduction.
    /// </param>
    /// <returns>
    ///   The reduced Tuple.
    /// </returns>
    function Reduce(const LAccumulator: TFunc<T, Tuple, Tuple>; const LTuple: Tuple): Tuple; overload; inline;
    /// <summary>
    /// Transforms elements with an optional filter, simulating a list comprehension.
    /// </summary>
    /// <typeparam name="R">Type of the resulting vector elements.</typeparam>
    /// <param name="ATransform">Function to transform each element from T to R.</param>
    /// <param name="APredicate">Optional filter; nil includes all elements (default: nil).</param>
    /// <returns>New TVector<R> with transformed, optionally filtered elements.</returns>
    function Comprehend<R>(const ATransform: TFunc<T, R>; const APredicate: TPredicate<T> = nil): TVector<R>; inline;
    /// <summary>
    ///   Retrieves the first element of the vector.
    /// </summary>
    /// <returns>
    ///   The first element of type T, or Default(T) if the vector is empty.
    /// </returns>
    function First: T; inline;
    /// <summary>
    ///   Retrieves the last element of the vector.
    /// </summary>
    /// <returns>
    ///   The last element of type T, or Default(T) if the vector is empty.
    /// </returns>
    function Last: T; inline;
    /// <summary>
    ///   Checks if the vector is empty.
    /// </summary>
    /// <returns>
    ///   True if the vector contains no elements; False otherwise.
    /// </returns>
    function IsEmpty: Boolean; inline;
    /// <summary>
    ///   Returns the type information for the generic type T.
    /// </summary>
    /// <returns>
    ///   A pointer to the type information of T.
    /// </returns>
    function AsType: PTypeInfo;
    /// <summary>
    ///   Returns a pointer to the internal array of the vector.
    /// </summary>
    /// <returns>
    ///   A pointer to the TArrayType representing the vector's elements.
    /// </returns>
    function AsPointer: PArrayType;
    /// <summary>
    ///   Converts the vector to a TList.
    /// </summary>
    /// <returns>
    ///   A TList containing all elements of the vector.
    /// </returns>
    function AsList: TList<T>;
    /// <summary>
    ///   Converts the vector to a TArray.
    /// </summary>
    /// <returns>
    ///   A TArray containing all elements of the vector.
    /// </returns>
    function ToArray: TArray<T>; inline;
    /// <summary>
    ///   Converts the vector to a string representation.
    /// </summary>
    /// <returns>
    ///   A string representing the vector's elements in a comma-separated list enclosed in brackets.
    /// </returns>
    function ToString: String; inline;
    /// <summary>
    ///   Gets the number of elements in the vector.
    /// </summary>
    /// <returns>
    ///   The number of elements currently in the vector.
    /// </returns>
    function Length: Integer; inline;
    /// <summary>
    ///   Gets the number of elements in the vector (alias for Length).
    /// </summary>
    /// <returns>
    ///   The number of elements currently in the vector.
    /// </returns>
    function Count: Integer; inline;
    /// <summary>
    ///   Gets the current capacity of the vector.
    /// </summary>
    /// <returns>
    ///   The number of elements the vector can hold without resizing.
    /// </returns>
    function Capacity: Integer; inline;
    /// <summary>
    ///   Provides indexed access to the elements of the vector.
    /// </summary>
    /// <param name="LIndex">
    ///   The zero-based index of the element to access.
    /// </param>
    /// <returns>
    ///   The element at the specified index.
    /// </returns>
    property Items[LIndex: Integer]: T read _GetItem write _SetItem; default;
  end;

implementation

{ TVector<T> }

procedure TVector<T>._StartVariables;
begin
  if (FItems = nil) or (System.Length(FItems) = 0) then
  begin
    FCount := 0;
    FCapacity := 0;
  end;
end;

function TVector<T>._GetItem(LIndex: Integer): T;
begin
  if (LIndex < 0) or (LIndex >= FCount) or (IsEmpty) then
    raise ERangeError.Create('Index out of range');
  Result := FItems[LIndex];
end;

function TVector<T>._IsEquals<I>(const ALeft: I; ARight: I): Boolean;
begin
  Result := TEqualityComparer<I>.Default.Equals(ALeft, ARight);
end;

procedure TVector<T>._SetItem(LIndex: Integer; const V: T);
begin
  if (LIndex < 0) or (LIndex >= FCount) or (IsEmpty) then
    raise ERangeError.Create('Index out of range');
  FItems[LIndex] := V;
end;

procedure TVector<T>.Add(const AValue: T);
begin
  _StartVariables;
  TArrayManager.Add(FItems, FCount, FCapacity, AValue);
end;

procedure TVector<T>.Insert(const LIndex: Integer; const LItem: T);
begin
  _StartVariables;
  TArrayManager.Insert(FItems, FCount, FCapacity, LIndex, LItem);
end;

procedure TVector<T>.Delete(const LIndex: Integer);
begin
  if IsEmpty then
    raise Exception.Create('Vector is empty, cannot delete.');
  TArrayManager.Delete(FItems, FCount, FCapacity, LIndex);
end;

procedure TVector<T>.Remove(const LItem: T);
begin
  if IsEmpty then
    raise Exception.Create('Vector is empty, cannot remove.');
  TArrayManager.Remove(FItems, FCount, FCapacity, LItem);
end;

procedure TVector<T>.Remove(const LItems: TArray<T>);
var
  LFor: Integer;
begin
  if IsEmpty then
    raise Exception.Create('Vector is empty, cannot remove.');
  for LFor := 0 to System.Length(LItems) - 1 do
    Remove(LItems[LFor]);
end;

procedure TVector<T>.ForEach(const LAction: TProc<T>);
var
  LFor: Integer;
begin
  if IsEmpty then
    raise Exception.Create('Vector is empty, cannot foreach.');
  for LFor := 0 to FCount - 1 do
    LAction(FItems[LFor]);
end;

procedure TVector<T>.SetLength(const LLength: Integer);
begin
  _StartVariables;
  TArrayManager.SetLength(FItems, FCount, FCapacity, LLength);
end;

procedure TVector<T>.SetCapacity(const LCapacity: Integer);
begin
  _StartVariables;
  TArrayManager.SetCapacity(FItems, FCapacity, LCapacity);
end;

procedure TVector<T>.AddRange(const LCollection: TArrayType);
var
  LItem: T;
begin
  for LItem in LCollection do
    Add(LItem);
end;

procedure TVector<T>.JoinStrings(const LValue: String; const LSeparator: String);
var
  LArray: TArray<String>;
  LItem: String;
  LConvertedValue: T;
begin
  FItems := nil;
  FCount := 0;
  FCapacity := 0;
  LArray := SplitString(LValue, LSeparator);
  for LItem in LArray do
  begin
    LConvertedValue := TValue.From<Variant>(LItem).AsType<T>;
    Add(LConvertedValue);
  end;
end;

procedure TVector<T>.Clear;
begin
  FCount := 0;
  TArrayManager.SetCapacity(FItems, FCapacity, 0);
end;

procedure TVector<T>.Assign(const LItems: array of T);
begin
  if IsEmpty then
    raise Exception.Create('Vector is empty, cannot assign.');
  FItems := TArrayEx.Copy<T>(LItems, 0, 0, System.Length(LItems));
  FCount := System.Length(FItems);
  FCapacity := System.Length(FItems);
end;

procedure TVector<T>.Sort;
begin
  if IsEmpty then
    raise Exception.Create('Vector is empty, cannot sort.');
  if FCount > 1 then
    TArray.Sort<T>(FItems, TComparer<T>.Default, 0, FCount);
end;

procedure TVector<T>.Sort(const LComparer: IComparer<T>);
begin
  if IsEmpty then
    raise Exception.Create('Vector is empty, cannot sort.');
  if FCount > 1 then
    TArray.Sort<T>(FItems, LComparer, 0, FCount);
end;

procedure TVector<T>.Reverse;
var
  LTemp: T;
  LStart, LEnd: Integer;
begin
  if IsEmpty then
    raise Exception.Create('Vector is empty, cannot reverse.');
  LStart := 0;
  LEnd := FCount - 1;
  while LStart < LEnd do
  begin
    LTemp := FItems[LStart];
    FItems[LStart] := FItems[LEnd];
    FItems[LEnd] := LTemp;
    Inc(LStart);
    Dec(LEnd);
  end;
end;

procedure TVector<T>.Unique;
var
  LUnique: TVector<T>;
  LFor: Integer;
  LItem: T;
begin
  if IsEmpty then
    raise Exception.Create('Vector is empty, cannot unique.');
  LUnique := TVector<T>.Empty;
  for LFor := 0 to FCount - 1 do
  begin
    LItem := FItems[LFor];
    if LUnique.IndexOf(LItem) = -1 then
      LUnique.Add(LItem);
  end;
  FItems := LUnique.FItems;
  FCount := LUnique.FCount;
  FCapacity := LUnique.FCapacity;
end;

procedure TVector<T>.Merge(const LSourceArray: TArrayType);
var
  LItem: T;
begin
  if IsEmpty then
    raise Exception.Create('Vector is empty, cannot marge.');
  for LItem in LSourceArray do
    if not Contains(LItem) then
      Add(LItem);
end;

function TVector<T>.GetEnumerator: IVectorEnumerator<T>;
begin

  Result := TArrayManager.GetEnumerator(FItems, FCount);
end;

function TVector<T>.Contains(const LItem: T): Boolean;
begin
  if IsEmpty then
    raise Exception.Create('Vector is empty, cannot contains.');
  Result := TArrayManager.Contains(FItems, FCount, LItem);
end;

function TVector<T>.Contains(const LItems: TArrayType): Boolean;
var
  LFor: Integer;
begin
  if IsEmpty then
    raise Exception.Create('Vector is empty, cannot contains.');
  for LFor := 0 to System.Length(LItems) - 1 do
    if not Contains(LItems[LFor]) then
      Exit(False);
  Result := True;
end;

function TVector<T>.IndexOf(const LItem: T): Integer;
begin
  _StartVariables;
  Result := TArrayManager.IndexOf(FItems, FCount, LItem);
end;

function TVector<T>.Filter(const LPredicate: TPredicate<T>): TVector<T>;
var
  LFor: Integer;
  LItem: T;
begin
  if IsEmpty then
    raise Exception.Create('Vector is empty, cannot filter.');
  Result := TVector<T>.Empty;
  for LFor := 0 to FCount - 1 do
  begin
    LItem := FItems[LFor];
    if LPredicate(LItem) then
      Result.Add(LItem);
  end;
end;

function TVector<T>.Filter(const LPredicate: TFunc<T, Integer, Boolean>): TVector<T>;
var
  LFor: Integer;
  LItem: T;
begin
  if IsEmpty then
    raise Exception.Create('Vector is empty, cannot filter.');
  Result := TVector<T>.Empty;
  for LFor := 0 to FCount - 1 do
  begin
    LItem := FItems[LFor];
    if LPredicate(LItem, LFor) then
      Result.Add(LItem);
  end;
end;

function TVector<T>.Map<R>(const LMappingFunc: TFunc<T, R>): TVector<R>;
var
  LFor: Integer;
  LItem: T;
begin
  if IsEmpty then
    raise Exception.Create('Vector is empty, cannot map.');
  Result := TVector<R>.Empty;
  for LFor := 0 to FCount - 1 do
  begin
    LItem := FItems[LFor];
    Result.Add(LMappingFunc(LItem));
  end;
end;

function TVector<T>.Reduce(const LAccumulator: TFunc<T, T, T>): T;
var
  LFor: Integer;
begin
  if IsEmpty then
    raise Exception.Create('Vector is empty, cannot reduce.');
  Result := FItems[0];
  for LFor := 1 to FCount - 1 do
    Result := LAccumulator(Result, FItems[LFor]);
end;

function TVector<T>.Reduce(const LAccumulator: TFunc<T, T, T>; const LInitial: T): T;
var
  LFor: Integer;
  LItem: T;
begin
  if IsEmpty then
    raise Exception.Create('Vector is empty, cannot reduce.');
  Result := LInitial;
  for LFor := 0 to FCount - 1 do
  begin
    LItem := FItems[LFor];
    Result := LAccumulator(Result, LItem);
  end;
end;

function TVector<T>.Reduce(const LAccumulator: TFunc<T, Tuple, Tuple>; const LTuple: Tuple): Tuple;
var
  LFor: Integer;
  LItem: T;
begin
  if IsEmpty then
    raise Exception.Create('Vector is empty, cannot reduce.');
  Result := LTuple;
  for LFor := 0 to FCount - 1 do
  begin
    LItem := FItems[LFor];
    Result := LAccumulator(LItem, Result);
  end;
end;

function TVector<T>.First: T;
begin
  if IsEmpty then
    raise Exception.Create('Cannot retrieve first element: Vector contains no data.');
  if FCount = 0 then
    Result := Default(T)
  else
    Result := FItems[0];
end;

function TVector<T>.Last: T;
begin
  if IsEmpty then
    raise Exception.Create('Cannot retrieve last element: Vector contains no data.');
  if FCount = 0 then
    Result := Default(T)
  else
    Result := FItems[FCount - 1];
end;

function TVector<T>.IsEmpty: Boolean;
begin
  Result := (FItems = nil) or (System.Length(FItems) = 0) or (FCount = 0);
end;

function TVector<T>.AsType: PTypeInfo;
begin
  Result := TypeInfo(T);
end;

function TVector<T>.AsPointer: PArrayType;
begin
  Result := @FItems;
end;

function TVector<T>.AsList: TList<T>;
var
  LFor: Integer;
begin
  if IsEmpty then
    raise Exception.Create('Cannot convert to list: Vector contains no data.');
  Result := TList<T>.Create;
  for LFor := 0 to FCount - 1 do
    Result.Add(FItems[LFor]);
end;

function TVector<T>.ToArray: TArray<T>;
begin
  if IsEmpty then
    raise Exception.Create('Cannot convert to array: Vector contains no data.');
  Result := Copy(FItems, 0, FCount);
end;

function TVector<T>.ToString: String;
var
  LFor: Integer;
  LValue: TValue;
begin
  if IsEmpty then
    raise Exception.Create('Cannot convert to string: Vector contains no data.');
  Result := '[';
  for LFor := 0 to FCount - 1 do
  begin
    if LFor > 0 then
      Result := Result + ', ';
    LValue := TValue.From<T>(FItems[LFor]);
    Result := Result + LValue.ToString;
  end;
  Result := Result + ']';
end;

function TVector<T>.Length: Integer;
begin
  _StartVariables;
  Result := FCount;
end;

function TVector<T>.Count: Integer;
begin
  _StartVariables;
  Result := FCount;
end;

function TVector<T>.Capacity: Integer;
begin
  _StartVariables;
  Result := FCapacity;
end;

constructor TVector<T>.Create(const Value: TArrayType);
begin
  FItems := Value;
  FCount := System.Length(Value);
  FCapacity := System.Length(Value);
end;

class function TVector<T>.Empty: TVector<T>;
begin
  Result.FItems := nil;
  Result.FCount := 0;
  Result.FCapacity := 0;
end;

class operator TVector<T>.Implicit(const V: TVector<T>): TArrayType;
begin
  Result := V.ToArray;
end;

class operator TVector<T>.Implicit(const V: TArrayType): TVector<T>;
begin
  Result := TVector<T>.Create(V);
end;

class operator TVector<T>.Equal(const Left, Right: TVector<T>): Boolean;
var
  LComparer: IEqualityComparer<T>;
  LFor: Integer;
begin
  if Left.FCount <> Right.FCount then
    Exit(False);
  LComparer := TEqualityComparer<T>.Default;
  for LFor := 0 to Left.FCount - 1 do
    if not LComparer.Equals(Left.FItems[LFor], Right.FItems[LFor]) then
      Exit(False);
  Result := True;
end;

class operator TVector<T>.NotEqual(const Left, Right: TVector<T>): Boolean;
begin
  Result := not (Left = Right);
end;

class operator TVector<T>.Add(const Left, Right: TVector<T>): TVector<T>;
begin
  Result := Left;
  Result.AddRange(Right.FItems);
end;

class operator TVector<T>.Add(const Left: TVector<T>; const Right: TArrayType): TVector<T>;
begin
  Result := Left;
  Result.AddRange(Right);
end;

class operator TVector<T>.Add(const Left: TArrayType; const Right: TVector<T>): TVector<T>;
begin
  Result := TVector<T>.Create(Left);
  Result.AddRange(Right.FItems);
end;

class operator TVector<T>.Add(const Left: TVector<T>; const Right: T): TVector<T>;
begin
  Result := Left;
  Result.Add(Right);
end;

class operator TVector<T>.Add(const Left: T; const Right: TVector<T>): TVector<T>;
begin
  Result := TVector<T>.Empty;
  Result.Add(Left);
  Result.AddRange(Right.FItems);
end;

class operator TVector<T>.Subtract(const Left, Right: TVector<T>): TVector<T>;
begin
  Result := Left;
  Result.Remove(Right.FItems);
end;

class operator TVector<T>.Subtract(const Left: TVector<T>; const Right: T): TVector<T>;
begin
  Result := Left;
  Result.Remove(Right);
end;

class operator TVector<T>.In(const Left: T; const Right: TVector<T>): Boolean;
begin
  Result := Right.Contains(Left);
end;

class operator TVector<T>.In(const Left, Right: TVector<T>): Boolean;
begin
  Result := Right.Contains(Left.FItems);
end;

class operator TVector<T>.In(const Left: TArrayType; const Right: TVector<T>): Boolean;
begin
  Result := Right.Contains(Left);
end;

{ TVector<T>.TArrayManager }

class function TVector<T>.TArrayManager._IsEquals<I>(const ALeft: I; ARight: I): Boolean;
begin
  Result := TEqualityComparer<I>.Default.Equals(ALeft, ARight);
end;

class procedure TVector<T>.TArrayManager._EnsureCapacity(var AArray: TArrayType; var ACapacity: Integer; const AMinCapacity: Integer);
var
  LCapacity: Integer;
begin
  if AMinCapacity <= ACapacity then
    Exit;

  LCapacity := ACapacity * GROWTH_FACTOR;
  if LCapacity < AMinCapacity then
    LCapacity := AMinCapacity;
  if LCapacity < INITIAL_CAPACITY then
    LCapacity := INITIAL_CAPACITY;

  SetCapacity(AArray, ACapacity, LCapacity);
end;

class procedure TVector<T>.TArrayManager.SetCapacity(var AArray: TArrayType; var ACapacity: Integer; const ACapacityValue: Integer);
begin
  ACapacity := ACapacityValue;
  System.SetLength(AArray, ACapacity);
end;

class procedure TVector<T>.TArrayManager.Add(var AArray: TArrayType; var ACount: Integer; var ACapacity: Integer; const AItem: T);
begin
  if (AArray = nil) or (System.Length(AArray) = 0) then
  begin
    ACount := 0;
    ACapacity := 0;
    _EnsureCapacity(AArray, ACapacity, INITIAL_CAPACITY);
  end;

  if ACount >= ACapacity then
    _EnsureCapacity(AArray, ACapacity, ACount + 1);
  AArray[ACount] := AItem;
  Inc(ACount);
end;

class procedure TVector<T>.TArrayManager.Insert(var AArray: TArrayType; var ACount: Integer; var ACapacity: Integer; const AIndex: Integer; const AItem: T);
var
  LFor: Integer;
begin
  if (AArray = nil) or (System.Length(AArray) = 0) then
  begin
    ACount := 0;
    ACapacity := 0;
    _EnsureCapacity(AArray, ACapacity, INITIAL_CAPACITY);
  end;

  if (AIndex < 0) or (AIndex > ACount) then
    raise EArgumentOutOfRangeException.Create('Index out of range');
  if ACount >= ACapacity then
    _EnsureCapacity(AArray, ACapacity, ACount + 1);
  for LFor := ACount - 1 downto AIndex do
    AArray[LFor + 1] := AArray[LFor];
  AArray[AIndex] := AItem;
  Inc(ACount);
end;

class procedure TVector<T>.TArrayManager.Delete(var AArray: TArrayType; var ACount: Integer; var ACapacity: Integer; const AIndex: Integer);
var
  LFor: Integer;
  LCapacity: Integer;
begin
  if (AIndex < 0) or (AIndex >= ACount) then
    raise EArgumentOutOfRangeException.Create('Index out of range');
  for LFor := AIndex + 1 to ACount - 1 do
    AArray[LFor - 1] := AArray[LFor];
  Dec(ACount);
  if ACount > 0 then
    AArray[ACount] := Default(T);

  if (ACapacity > INITIAL_CAPACITY) and (ACount < Round(ACapacity * SHRINK_THRESHOLD)) then
  begin
    LCapacity := ACapacity div 2;
    if LCapacity < ACount then
      LCapacity := ACount;
    if LCapacity < INITIAL_CAPACITY then
      LCapacity := INITIAL_CAPACITY;
    SetCapacity(AArray, ACapacity, LCapacity);
  end;
end;

class procedure TVector<T>.TArrayManager.Remove(var AArray: TArrayType; var ACount: Integer; var ACapacity: Integer; const AItem: T);
var
  LIndex: Integer;
begin
  LIndex := IndexOf(AArray, ACount, AItem);
  if LIndex >= 0 then
    Delete(AArray, ACount, ACapacity, LIndex);
end;

class procedure TVector<T>.TArrayManager.SetLength(var AArray: TArrayType; var ACount: Integer; var ACapacity: Integer; ALength: Integer);
begin
  if ALength < 0 then
    raise EArgumentOutOfRangeException.Create('Length cannot be negative');
  if ALength > ACapacity then
    _EnsureCapacity(AArray, ACapacity, ALength);
  if ALength < ACount then
    ACount := ALength;
end;

class function TVector<T>.TArrayManager.GetEnumerator(var AArray: TArrayType; ACount: Integer): IVectorEnumerator<T>;
begin
  Result := TVectorEnumerator.Create(@AArray, ACount);
end;

class function TVector<T>.TArrayManager.Contains(const AArray: TArrayType; ACount: Integer; const AItem: T): Boolean;
var
  LFor: Integer;
begin
  for LFor := 0 to ACount - 1 do
    if _IsEquals<T>(AArray[LFor], AItem) then
      Exit(True);
  Result := False;
end;

class function TVector<T>.TArrayManager.IndexOf(const AArray: TArrayType; ACount: Integer; const AItem: T): Integer;
var
  LFor: Integer;
begin
  for LFor := 0 to ACount - 1 do
    if _IsEquals<T>(AArray[LFor], AItem) then
      Exit(LFor);
  Result := -1;
end;

{ TVector<T>.TVectorEnumerator }

constructor TVector<T>.TVectorEnumerator.Create(const AArray: PArrayType; ACount: Integer);
begin
  FItems := AArray;
  FIndex := -1;
  FCount := ACount;
end;

destructor TVector<T>.TVectorEnumerator.Destroy;
begin
  FItems := nil;
  inherited;
end;

function TVector<T>.TVectorEnumerator.GetCurrent: T;
begin
  if (FIndex < 0) or (FIndex >= FCount) then
    raise ERangeError.Create('Enumerator index out of range');
  Result := FItems^[FIndex];
end;

function TVector<T>.TVectorEnumerator.MoveNext: Boolean;
begin
  Inc(FIndex);
  Result := FIndex < FCount;
end;

function TVector<T>.Comprehend<R>(const ATransform: TFunc<T, R>; const APredicate: TPredicate<T> = nil): TVector<R>;
var
  LItem: T;
  LFor: Integer;
begin
  Result := TVector<R>.Empty;
  for LFor := 0 to FCount - 1 do
  begin
    LItem := FItems[LFor];
    if not Assigned(APredicate) or APredicate(LItem) then
      Result.Add(ATransform(LItem));
  end;
end;

end.


