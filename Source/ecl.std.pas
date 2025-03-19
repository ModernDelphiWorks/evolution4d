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

unit ecl.std;

interface

uses
  Rtti,
  Math,
  Classes,
  Windows,
  TypInfo,
  SysUtils,
  StrUtils,
  DateUtils,
  Generics.Collections,
  Generics.Defaults,
//  ecl.vector,
  ecl.map;

type
  /// <summary>
  ///   Represents a list of strings.
  /// </summary>
  TListString = TList<String>;

  /// <summary>
  ///   Represents a tuple as an array of TValue.
  /// </summary>
  Tuple = array of TValue;

  /// <summary>
  ///   Interface for an observer that can be updated with progress information.
  /// </summary>
  IObserverEx = interface
    ['{5887CDFF-DA23-4466-A5CB-FBA1DFEAF907}']
    /// <summary>
    ///   Updates the observer with the current progress.
    /// </summary>
    /// <param name="Progress">
    ///   The progress value to update the observer with.
    /// </param>
    procedure Update(const Progress: Integer);
  end;

  /// <summary>
  ///   Provides a stream implementation that operates directly on a memory pointer.
  /// </summary>
  TPointerStream = class(TCustomMemoryStream)
  public
    /// <summary>
    ///   Initializes a new instance of the TPointerStream class with a specified memory pointer and size.
    /// </summary>
    /// <param name="P">
    ///   The pointer to the memory block that the stream will operate on.
    /// </param>
    /// <param name="ASize">
    ///   The size of the memory block in bytes.
    /// </param>
    constructor Create(P: Pointer; ASize: Integer);

    /// <summary>
    ///   Writes data from a buffer to the stream.
    /// </summary>
    /// <param name="Buffer">
    ///   The buffer containing the data to write.
    /// </param>
    /// <param name="Count">
    ///   The number of bytes to write from the buffer.
    /// </param>
    /// <returns>
    ///   The number of bytes actually written to the stream.
    /// </returns>
    function Write(const Buffer; Count: Longint): Longint; override;
  end;

  /// <summary>
  ///   Represents a future value that can be either successful or contain an error.
  /// </summary>
  TFuture = record
  private
    FValue: TValue;
    FErr: String;
    FIsOK: Boolean;
    FIsErr: Boolean;
  public
    /// <summary>
    ///   Checks if the future is in a successful state.
    /// </summary>
    /// <returns>
    ///   True if the future is successful, otherwise False.
    /// </returns>
    function IsOk: Boolean;

    /// <summary>
    ///   Checks if the future contains an error.
    /// </summary>
    /// <returns>
    ///   True if the future contains an error, otherwise False.
    /// </returns>
    function IsErr: Boolean;

    /// <summary>
    ///   Retrieves the successful value of the future.
    /// </summary>
    /// <returns>
    ///   The value of type T.
    /// </returns>
    function Ok<T>: T;

    /// <summary>
    ///   Retrieves the error message of the future.
    /// </summary>
    /// <returns>
    ///   The error message.
    /// </returns>
    function Err: String;

    /// <summary>
    ///   Sets the future to a successful state with a value.
    /// </summary>
    /// <param name="AValue">
    ///   The value to set.
    /// </param>
    procedure SetOk(const AValue: TValue);

    /// <summary>
    ///   Sets the future to an error state with an error message.
    /// </summary>
    /// <param name="AErr">
    ///   The error message to set.
    /// </param>
    procedure SetErr(const AErr: String);
  end;

  /// <summary>
  ///   Provides extended functionality for arrays.
  /// </summary>
  TArrayEx = class(TArray)
  public
    /// <summary>
    ///   Merges two arrays into one.
    /// </summary>
    /// <param name="AArray1">
    ///   The first array to merge.
    /// </param>
    /// <param name="AArray2">
    ///   The second array to merge.
    /// </param>
    /// <returns>
    ///   A new array containing elements from both input arrays.
    /// </returns>
    class function Merge<T>(const AArray1: array of T; const AArray2: array of T): TArray<T>; static;

    /// <summary>
    ///   Converts an array to a TList.
    /// </summary>
    /// <param name="AArray">
    ///   The array to convert.
    /// </param>
    /// <returns>
    ///   A TList containing the elements of the array.
    /// </returns>
    class function AsList<T>(const AArray: array of T): TList<T>; static;

    /// <summary>
    ///   Executes a specified action for each element in the array.
    /// </summary>
    /// <param name="AValues">
    ///   The array to iterate over.
    /// </param>
    /// <param name="AAction">
    ///   The action to execute for each element.
    /// </param>
    class procedure ForEach<T>(const AValues: array of T; AAction: TProc<T>); static;

    /// <summary>
    ///   Copies a range of elements from one array to another.
    /// </summary>
    /// <param name="AValues">
    ///   The source array.
    /// </param>
    /// <param name="ASourceIndex">
    ///   The starting index in the source array.
    /// </param>
    /// <param name="ADestIndex">
    ///   The starting index in the destination array.
    /// </param>
    /// <param name="ACount">
    ///   The number of elements to copy.
    /// </param>
    /// <returns>
    ///   A new array containing the copied elements.
    /// </returns>
    class function Copy<T>(const AValues: array of T; const ASourceIndex: Integer;
      const ADestIndex: Integer; const ACount: Integer): TArray<T>; static;

    /// <summary>
    ///   Reduces an array to a single value using a reducer function.
    /// </summary>
    /// <param name="AValues">
    ///   The array to reduce.
    /// </param>
    /// <param name="AReducer">
    ///   The function to apply to reduce the array.
    /// </param>
    /// <returns>
    ///   The reduced value.
    /// </returns>
    class function Reduce<T>(const AValues: array of T; AReducer: TFunc<T, T, T>): T; overload; static;

    /// <summary>
    ///   Reduces an array to a single value using a reducer function and an initial value.
    /// </summary>
    /// <param name="AValues">
    ///   The array to reduce.
    /// </param>
    /// <param name="AReducer">
    ///   The function to apply to reduce the array.
    /// </param>
    /// <param name="AInitial">
    ///   The initial value for the reduction.
    /// </param>
    /// <returns>
    ///   The reduced value.
    /// </returns>
    class function Reduce<T>(const AValues: array of T; AReducer: TFunc<T, T, T>; const AInitial: T): T; overload; static;

    /// <summary>
    ///   Maps an array to a new array using a mapping function.
    /// </summary>
    /// <param name="AValues">
    ///   The array to map.
    /// </param>
    /// <param name="AFunc">
    ///   The function to apply to each element.
    /// </param>
    /// <returns>
    ///   A new array containing the mapped elements.
    /// </returns>
    class function Map<T, TResult>(const AValues: array of T; AFunc: TFunc<T, TResult>): TArray<TResult>; static;

    /// <summary>
    ///   Filters an array based on a predicate function.
    /// </summary>
    /// <param name="AValues">
    ///   The array to filter.
    /// </param>
    /// <param name="APredicate">
    ///   The function to test each element.
    /// </param>
    /// <returns>
    ///   A new array containing only the elements that satisfy the predicate.
    /// </returns>
    class function Filter<T>(const AValues: array of T; APredicate: TFunc<T, Boolean>): TArray<T>; static;

    /// <summary>
    ///   Checks if any element in the array satisfies a predicate.
    /// </summary>
    /// <param name="AValues">
    ///   The array to check.
    /// </param>
    /// <param name="APredicate">
    ///   The function to test each element.
    /// </param>
    /// <returns>
    ///   True if any element satisfies the predicate, otherwise False.
    /// </returns>
    class function Any<T>(const AValues: array of T; APredicate: TFunc<T, Boolean>): Boolean; static;

    /// <summary>
    ///   Checks if all elements in the array satisfy a predicate.
    /// </summary>
    /// <param name="AValues">
    ///   The array to check.
    /// </param>
    /// <param name="APredicate">
    ///   The function to test each element.
    /// </param>
    /// <returns>
    ///   True if all elements satisfy the predicate, otherwise False.
    /// </returns>
    class function All<T>(const AValues: array of T; APredicate: TFunc<T, Boolean>): Boolean; static;

    /// <summary>
    ///   Calculates the total of an array of Single values.
    /// </summary>
    /// <param name="AData">
    ///   The array of Single values.
    /// </param>
    /// <returns>
    ///   The total of the array elements.
    /// </returns>
    class function Total(const AData: array of Single): Single; overload;

    /// <summary>
    ///   Calculates the total of an array of Double values.
    /// </summary>
    /// <param name="AData">
    ///   The array of Double values.
    /// </param>
    /// <returns>
    ///   The total of the array elements.
    /// </returns>
    class function Total(const AData: array of Double): Double; overload;

    /// <summary>
    ///   Calculates the total of an array of Extended values.
    /// </summary>
    /// <param name="AData">
    ///   The array of Extended values.
    /// </param>
    /// <returns>
    ///   The total of the array elements.
    /// </returns>
    class function Total(const AData: array of Extended): Extended; overload;

    /// <summary>
    ///   Calculates the sum of an array of Integer values.
    /// </summary>
    /// <param name="AData">
    ///   The array of Integer values.
    /// </param>
    /// <returns>
    ///   The sum of the array elements.
    /// </returns>
    class function Sum(const AData: array of Integer): Integer; overload;

    /// <summary>
    ///   Calculates the sum of an array of Single values.
    /// </summary>
    /// <param name="AData">
    ///   The array of Single values.
    /// </param>
    /// <returns>
    ///   The sum of the array elements.
    /// </returns>
    class function Sum(const AData: array of Single): Single; overload;

    /// <summary>
    ///   Calculates the sum of an array of Double values.
    /// </summary>
    /// <param name="AData">
    ///   The array of Double values.
    /// </param>
    /// <returns>
    ///   The sum of the array elements.
    /// </returns>
    class function Sum(const AData: array of Double): Double; overload;

    /// <summary>
    ///   Calculates the sum of an array of Extended values.
    /// </summary>
    /// <param name="AData">
    ///   The array of Extended values.
    /// </param>
    /// <returns>
    ///   The sum of the array elements.
    /// </returns>
    class function Sum(const AData: array of Extended): Extended; overload;

    /// <summary>
    ///   Skips the first specified number of elements in an array and returns the remaining elements.
    /// </summary>
    /// <param name="AValues">
    ///   The array of values to skip elements from.
    /// </param>
    /// <param name="ACount">
    ///   The number of elements to skip from the start of the array.
    /// </param>
    /// <returns>
    ///   A new array containing the elements after skipping the specified count.
    /// </returns>
    class function Skip<T>(const AValues: array of T; ACount: Integer): TArray<T>; static;

    /// <summary>
    ///   Takes the first specified number of elements from an array.
    /// </summary>
    /// <param name="AValues">
    ///   The array of values to take elements from.
    /// </param>
    /// <param name="ACount">
    ///   The number of elements to take from the start of the array.
    /// </param>
    /// <returns>
    ///   A new array containing the first specified number of elements.
    /// </returns>
    class function Take<T>(const AValues: array of T; ACount: Integer): TArray<T>; static;

    /// <summary>
    ///   Transforms each element of an array into an array of results and flattens the result into a single array.
    /// </summary>
    /// <param name="AValues">
    ///   The array of values to transform.
    /// </param>
    /// <param name="AFunc">
    ///   The function that transforms each element into an array of results.
    /// </param>
    /// <returns>
    ///   A new array containing the flattened transformed elements.
    /// </returns>
    class function FlatMap<T, TResult>(const AValues: array of T; AFunc: TFunc<T, TArray<TResult>>): TArray<TResult>; static;

    /// <summary>
    ///   Partitions an array into two arrays based on a predicate function.
    /// </summary>
    /// <param name="AValues">
    ///   The array of values to partition.
    /// </param>
    /// <param name="APredicate">
    ///   The function that determines which elements go into the right partition.
    /// </param>
    /// <param name="Left">
    ///   The array containing elements that do not satisfy the predicate.
    /// </param>
    /// <param name="Right">
    ///   The array containing elements that satisfy the predicate.
    /// </param>
    class procedure Partition<T>(const AValues: array of T; APredicate: TFunc<T, Boolean>; out Left, Right: TArray<T>); static;

    /// <summary>
    ///   Groups the elements of an array by a key selected by a function into a dictionary.
    /// </summary>
    /// <param name="AValues">
    ///   The array of values to group.
    /// </param>
    /// <param name="AKeySelector">
    ///   The function that selects the key for each element.
    /// </param>
    /// <returns>
    ///   A dictionary mapping keys to arrays of grouped elements.
    /// </returns>
    class function GroupBy<TKey, T>(const AValues: array of T;
      AKeySelector: TFunc<T, TKey>): TMap<TKey, TArray<T>>; static;

    /// <summary>
    ///   Reverses the order of elements in an array.
    /// </summary>
    /// <param name="AValues">
    ///   The array of values to reverse.
    /// </param>
    /// <returns>
    ///   A new array with the elements in reversed order.
    /// </returns>
    class function Reverse<T>(const AValues: array of T): TArray<T>; static;

    /// <summary>
    ///   Removes duplicate elements from an array, keeping only unique values.
    /// </summary>
    /// <param name="AValues">
    ///   The array of values to process.
    /// </param>
    /// <returns>
    ///   A new array containing only unique elements.
    /// </returns>
    class function Distinct<T>(const AValues: array of T): TArray<T>; static;

    /// <summary>
    ///   Combines two arrays into a single array by applying a combiner function to corresponding elements.
    /// </summary>
    /// <param name="AArray1">
    ///   The first array of values.
    /// </param>
    /// <param name="AArray2">
    ///   The second array of values.
    /// </param>
    /// <param name="ACombiner">
    ///   The function that combines elements from both arrays into a result.
    /// </param>
    /// <returns>
    ///   A new array containing the combined results.
    /// </returns>
    class function Zip<T1, T2, TResult>(const AArray1: array of T1; const AArray2: array of T2; ACombiner: TFunc<T1, T2, TResult>): TArray<TResult>; static;

    /// <summary>
    ///   Converts an array to a TFuture, validating it with a provided function.
    /// </summary>
    /// <param name="AValues">
    ///   The array of values to convert.
    /// </param>
    /// <param name="AValidator">
    ///   The function that validates the array and returns an error message if invalid.
    /// </param>
    /// <returns>
    ///   A TFuture containing the array if valid, or an error message if invalid.
    /// </returns>
    class function ToFuture<T>(const AValues: TArray<T>; AValidator: TFunc<TArray<T>, String>): TFuture; static;

    //// <summary>
    ////   Converts an array to a TVector<T>.
    //// </summary>
    //// <param name="AValues">
    ////   The array of values to convert.
    //// </param>
    //// <returns>
    ////   A TVector<T> containing the array elements.
    //// </returns>
    //class function ToVector<T>(const AValues: array of T): TVector<T>; static;
  end;

  /// <summary>
  ///   Represents a set of unique items.
  /// </summary>
  TSet<T> = class sealed
  strict private
    FItems: TDictionary<T, Boolean>;
    FComparer: IEqualityComparer<T>;
    function _GetCount: Integer;
  public
    /// <summary>
    ///   Initializes a new instance of the TSet class.
    /// </summary>
    constructor Create; overload;

    /// <summary>
    ///   Initializes a new instance of the TSet class with a custom comparer.
    /// </summary>
    /// <param name="Comparer">
    ///   The comparer to use for item equality.
    /// </param>
    constructor Create(const Comparer: IEqualityComparer<T>); overload;

    /// <summary>
    ///   Destroys the TSet instance.
    /// </summary>
    destructor Destroy; override;

    /// <summary>
    ///   Adds an item to the set.
    /// </summary>
    /// <param name="Item">
    ///   The item to add.
    /// </param>
    /// <returns>
    ///   True if the item was added, otherwise False.
    /// </returns>
    function Add(const Item: T): Boolean;

    /// <summary>
    ///   Checks if the set contains a specific item.
    /// </summary>
    /// <param name="Item">
    ///   The item to check.
    /// </param>
    /// <returns>
    ///   True if the set contains the item, otherwise False.
    /// </returns>
    function Contains(const Item: T): Boolean;

    /// <summary>
    ///   Removes an item from the set.
    /// </summary>
    /// <param name="Item">
    ///   The item to remove.
    /// </param>
    /// <returns>
    ///   True if the item was removed, otherwise False.
    /// </returns>
    function Remove(const Item: T): Boolean;

    /// <summary>
    ///   Converts the set to an array.
    /// </summary>
    /// <returns>
    ///   An array containing the items in the set.
    /// </returns>
    function ToArray: TArray<T>;

    /// <summary>
    ///   Creates a union of this set with another set.
    /// </summary>
    /// <param name="Other">
    ///   The other set to union with.
    /// </param>
    /// <returns>
    ///   A new set containing the union of both sets.
    /// </returns>
    function Union(const Other: TSet<T>): TSet<T>;

    /// <summary>
    ///   Clears all items from the set.
    /// </summary>
    procedure Clear;

    /// <summary>
    ///   Gets the number of items in the set.
    /// </summary>
    property Count: Integer read _GetCount;
  end;

  /// <summary>
  ///   Provides utility functions for common operations.
  /// </summary>
  TStd = class
  strict private
    FFormatSettings: TFormatSettings;
  protected
    class var FInstance: TStd;
    class var FSequenceCounter: Int64;
  public
    /// <summary>
    ///   Gets the singleton instance of TStd.
    /// </summary>
    /// <returns>
    ///   The singleton instance of TStd.
    /// </returns>
    class function Get: TStd; static; inline;

    /// <summary>
    ///   Returns one of two values based on a condition.
    /// </summary>
    /// <param name="AValue">
    ///   The condition to evaluate.
    /// </param>
    /// <param name="ATrue">
    ///   The value to return if the condition is True.
    /// </param>
    /// <param name="AFalse">
    ///   The value to return if the condition is False.
    /// </param>
    /// <returns>
    ///   The selected value.
    /// </returns>
    class function IfThen<T>(AValue: Boolean; const ATrue: T; const AFalse: T): T; static; inline;

    /// <summary>
    ///   Joins an array of strings into a single string with a specified separator.
    /// </summary>
    /// <param name="AStrings">
    ///   The array of strings to join.
    /// </param>
    /// <param name="ASeparator">
    ///   The separator to use between strings.
    /// </param>
    /// <returns>
    ///   The joined string.
    /// </returns>
    class function JoinStrings(const AStrings: array of String; const ASeparator: String): String; overload; static;

    /// <summary>
    ///   Joins a list of strings into a single string with a specified separator.
    /// </summary>
    /// <param name="AStrings">
    ///   The list of strings to join.
    /// </param>
    /// <param name="ASeparator">
    ///   The separator to use between strings.
    /// </param>
    /// <returns>
    ///   The joined string.
    /// </returns>
    class function JoinStrings(const AStrings: TListString; const ASeparator: String): String; overload; static; inline;

    /// <summary>
    ///   Removes trailing characters from a string.
    /// </summary>
    /// <param name="AStr">
    ///   The string to process.
    /// </param>
    /// <param name="AChars">
    ///   The set of characters to remove.
    /// </param>
    /// <returns>
    ///   The string with trailing characters removed.
    /// </returns>
    class function RemoveTrailingChars(const AStr: String; const AChars: TSysCharSet): String; static; inline;

    /// <summary>
    ///   Converts an ISO 8601 formatted string to a TDateTime.
    /// </summary>
    /// <param name="AValue">
    ///   The ISO 8601 formatted string.
    /// </param>
    /// <param name="AUseISO8601DateFormat">
    ///   Whether to use ISO 8601 date format.
    /// </param>
    /// <returns>
    ///   The converted TDateTime.
    /// </returns>
    class function Iso8601ToDateTime(const AValue: String; const AUseISO8601DateFormat: Boolean): TDateTime; static; inline;

    /// <summary>
    ///   Converts a TDateTime to an ISO 8601 formatted string.
    /// </summary>
    /// <param name="AValue">
    ///   The TDateTime to convert.
    /// </param>
    /// <param name="AUseISO8601DateFormat">
    ///   Whether to use ISO 8601 date format.
    /// </param>
    /// <returns>
    ///   The ISO 8601 formatted string.
    /// </returns>
    class function DateTimeToIso8601(const AValue: TDateTime; const AUseISO8601DateFormat: Boolean): String; static; inline;

    /// <summary>
    ///   Returns the minimum of two Integer values.
    /// </summary>
    /// <param name="A">
    ///   The first value.
    /// </param>
    /// <param name="B">
    ///   The second value.
    /// </param>
    /// <returns>
    ///   The minimum value.
    /// </returns>
    class function Min(const A, B: Integer): Integer; overload; static; inline;

    /// <summary>
    ///   Returns the minimum of two Double values.
    /// </summary>
    /// <param name="A">
    ///   The first value.
    /// </param>
    /// <param name="B">
    ///   The second value.
    /// </param>
    /// <returns>
    ///   The minimum value.
    /// </returns>
    class function Min(const A, B: Double): Double; overload; static; inline;

    /// <summary>
    ///   Returns the minimum of two Currency values.
    /// </summary>
    /// <param name="A">
    ///   The first value.
    /// </param>
    /// <param name="B">
    ///   The second value.
    /// </param>
    /// <returns>
    ///   The minimum value.
    /// </returns>
    class function Min(const A, B: Currency): Currency; overload; static; inline;

    /// <summary>
    ///   Returns the minimum of two Int64 values.
    /// </summary>
    /// <param name="A">
    ///   The first value.
    /// </param>
    /// <param name="B">
    ///   The second value.
    /// </param>
    /// <returns>
    ///   The minimum value.
    /// </returns>
    class function Min(const A, B: Int64): Int64; overload; static; inline;

    /// <summary>
    ///   Returns the maximum of two Integer values.
    /// </summary>
    /// <param name="A">
    ///   The first value.
    /// </param>
    /// <param name="B">
    ///   The second value.
    /// </param>
    /// <returns>
    ///   The maximum value.
    /// </returns>
    class function Max(const A, B: Integer): Integer; overload; static; inline;

    /// <summary>
    ///   Returns the maximum of two Double values.
    /// </summary>
    /// <param name="A">
    ///   The first value.
    /// </param>
    /// <param name="B">
    ///   The second value.
    /// </param>
    /// <returns>
    ///   The maximum value.
    /// </returns>
    class function Max(const A, B: Double): Double; overload; static; inline;

    /// <summary>
    ///   Returns the maximum of two Currency values.
    /// </summary>
    /// <param name="A">
    ///   The first value.
    /// </param>
    /// <param name="B">
    ///   The second value.
    /// </param>
    /// <returns>
    ///   The maximum value.
    /// </returns>
    class function Max(const A, B: Currency): Currency; overload; static; inline;

    /// <summary>
    ///   Splits a string into an array of strings.
    /// </summary>
    /// <param name="S">
    ///   The string to split.
    /// </param>
    /// <returns>
    ///   An array of strings.
    /// </returns>
    class function Split(const S: String): TArray<String>; static; inline;

    /// <summary>
    ///   Clones a block of memory.
    /// </summary>
    /// <param name="AFirst">
    ///   The starting pointer of the memory block.
    /// </param>
    /// <param name="ASize">
    ///   The size of the memory block.
    /// </param>
    /// <param name="Return">
    ///   The destination pointer.
    /// </param>
    /// <returns>
    ///   The destination pointer.
    /// </returns>
    class function Clone<T>(const AFirst: Pointer; ASize: Cardinal; var Return): Pointer; static; inline;

    /// <summary>
    ///   Converts a string to an array of strings, where each element is a character.
    /// </summary>
    /// <param name="S">
    ///   The string to convert.
    /// </param>
    /// <returns>
    ///   An array of strings.
    /// </returns>
    class function ToCharArray(const S: String): TArray<String>; static; inline;

    /// <summary>
    ///   Fills a block of memory with a specified value.
    /// </summary>
    /// <param name="AFirst">
    ///   The starting pointer of the memory block.
    /// </param>
    /// <param name="ASize">
    ///   The size of the memory block.
    /// </param>
    /// <param name="Value">
    ///   The value to fill the memory block with.
    /// </param>
    class procedure Fill<T>(const AFirst: Pointer; ASize: Cardinal; const Value: T); static; inline;

    /// <summary>
    ///   Generates a sequential number.
    /// </summary>
    /// <returns>
    ///   The generated sequential number.
    /// </returns>
    class function GenerateSequentialNumber: UInt64; static; inline;

    /// <summary>
    ///   Gets or sets the format settings for the TStd instance.
    /// </summary>
    property FormatSettings: TFormatSettings read FFormatSettings write FFormatSettings;
  end;

{$IFDEF DEBUG}
/// <summary>
///   Prints a debug message.
/// </summary>
/// <param name="AMessage">
///   The message to print.
/// </param>
procedure DebugPrint(const AMessage: String);
{$ENDIF}

implementation

uses
  RTLConsts;

{$IFDEF DEBUG}
procedure DebugPrint(const AMessage: String);
begin
  TThread.Queue(nil,
    procedure
    begin
      OutputDebugString(PWideChar('[ECL] - ' + FormatDateTime('mm/dd/yyyy, hh:mm:ss am/pm', Now) + ' LOG ' + AMessage));
    end);
end;
{$ENDIF}

{ TStd }

class function TStd.DateTimeToIso8601(const AValue: TDateTime; const AUseISO8601DateFormat: Boolean): String;
var
  LDatePart: String;
  LTimePart: String;
begin
  Result := '';
  if AValue = 0 then
    Exit;

  if AUseISO8601DateFormat then
    LDatePart := FormatDateTime('yyyy-mm-dd', AValue)
  else
    LDatePart := DateToStr(AValue, TStd.Get.FormatSettings);

  if Frac(AValue) = 0 then
    Result := IfThen<String>(AUseISO8601DateFormat, LDatePart, TimeToStr(AValue, TStd.Get.FormatSettings))
  else
  begin
    LTimePart := FormatDateTime('hh:nn:ss', AValue);
    Result := IfThen<String>(AUseISO8601DateFormat, LDatePart + 'T' + LTimePart, LDatePart + ' ' + LTimePart);
  end;
end;

class function TStd.IfThen<T>(AValue: Boolean; const ATrue, AFalse: T): T;
begin
  Result := AFalse;
  if AValue then
    Result := ATrue;
end;

class function TStd.Iso8601ToDateTime(const AValue: String; const AUseISO8601DateFormat: Boolean): TDateTime;
var
  LYYYY: Integer;
  LMM: Integer;
  LDD: Integer;
  LHH: Integer;
  LMI: Integer;
  LSS: Integer;
  LMS: Integer;
begin
  if not AUseISO8601DateFormat then
  begin
    Result := StrToDateTimeDef(AValue, 0);
    Exit;
  end;
  LYYYY := 0; LMM := 0; LDD := 0; LHH := 0; LMI := 0; LSS := 0; LMS := 0;
  if TryStrToInt(Copy(AValue, 1, 4), LYYYY) and
     TryStrToInt(Copy(AValue, 6, 2), LMM) and
     TryStrToInt(Copy(AValue, 9, 2), LDD) and
     TryStrToInt(Copy(AValue, 12, 2), LHH) and
     TryStrToInt(Copy(AValue, 15, 2), LMI) and
     TryStrToInt(Copy(AValue, 18, 2), LSS) then
  begin
    Result := EncodeDateTime(LYYYY, LMM, LDD, LHH, LMI, LSS, LMS);
  end
  else
    Result := 0;
end;

class function TStd.JoinStrings(const AStrings: TListString; const ASeparator: String): String;
var
  LBuilder: TStringBuilder;
  LFor: Integer;
begin
  LBuilder := TStringBuilder.Create;
  try
    for LFor := 0 to AStrings.Count - 1 do
    begin
      if LFor > 0 then
        LBuilder.Append(ASeparator);
      LBuilder.Append(AStrings[LFor]);
    end;
    Result := LBuilder.ToString;
  finally
    LBuilder.Free;
  end;
end;

class function TStd.Min(const A, B: Integer): Integer;
begin
  Result := Math.Min(A, B);
end;

class function TStd.Min(const A, B: Double): Double;
begin
  Result := Math.Min(A, B);
end;

class function TStd.Max(const A, B: Integer): Integer;
begin
  Result := Math.Max(A, B);
end;

class function TStd.Max(const A, B: Double): Double;
begin
  Result := Math.Max(A, B);
end;

class function TStd.Max(const A, B: Currency): Currency;
begin
  Result := Math.Max(A, B);
end;

class function TStd.ToCharArray(const S: String): TArray<String>;
var
  LFor: Integer;
begin
  SetLength(Result, Length(S));
  for LFor := 1 to Length(S) do
    Result[LFor - 1] := S[LFor];
end;

class function TStd.Min(const A, B: Int64): Int64;
begin
  Result := Math.Min(A, B);
end;

class function TStd.Get: TStd;
begin
  if not Assigned(FInstance) then
    FInstance := TStd.Create;
  Result := FInstance;
end;

class function TStd.Min(const A, B: Currency): Currency;
begin
  Result := Math.Min(A, B);
end;

class function TStd.RemoveTrailingChars(const AStr: String; const AChars: TSysCharSet): String;
var
  LLastCharIndex: Integer;
begin
  LLastCharIndex := Length(AStr);
  while (LLastCharIndex > 0) and CharInSet(AStr[LLastCharIndex], AChars) do
    Dec(LLastCharIndex);
  Result := Copy(AStr, 1, LLastCharIndex);
end;

class function TStd.Split(const S: String): TArray<String>;
var
  LFor: Integer;
begin
  SetLength(Result, Length(S));
  for LFor := 1 to Length(S) do
    Result[LFor - 1] := S[LFor];
end;

class function TStd.JoinStrings(const AStrings: array of String; const ASeparator: String): String;
var
  LBuilder: TStringBuilder;
  LFor: Integer;
begin
  LBuilder := TStringBuilder.Create;
  try
    for LFor := Low(AStrings) to High(AStrings) do
    begin
      if LFor > Low(AStrings) then
        LBuilder.Append(ASeparator);
      LBuilder.Append(AStrings[LFor]);
    end;
    Result := LBuilder.ToString;
  finally
    LBuilder.Free;
  end;
end;

class function TStd.Clone<T>(const AFirst: Pointer; ASize: Cardinal; var Return): Pointer;
var
  LSource: ^T;
  LTarget: ^T;
begin
  if (ASize <= 0) or (AFirst = nil) then
    raise Exception.Create('Invalid parameters in TStd.Clone');

  LSource := AFirst;
  LTarget := @Return;
  while ASize > 0 do
  begin
    LTarget^ := LSource^;
    Inc(PByte(LSource), sizeof(T));
    Inc(PByte(LTarget), sizeof(T));
    Dec(ASize);
  end;
  Result := @Return;
end;

class procedure TStd.Fill<T>(const AFirst: Pointer; ASize: Cardinal; const Value: T);
var
  LPointer: ^T;
begin
  if (ASize <= 0) or (AFirst = nil) then
    raise Exception.Create('Invalid parameters in TStd.Fill');

  LPointer := AFirst;
  repeat
    LPointer^ := Value;
    Inc(PByte(LPointer), sizeof(T));
    Dec(ASize);
  until ASize = 0;
end;

class function TStd.GenerateSequentialNumber: UInt64;
begin
  Result := InterlockedIncrement64(TStd.FSequenceCounter);
end;

{ TPointerStream }

constructor TPointerStream.Create(P: Pointer; ASize: Integer);
begin
  SetPointer(P, ASize);
end;

function TPointerStream.Write(const Buffer; Count: Longint): Longint;
var
  LPos: Longint;
  LEndPos: Longint;
  LSize: Longint;
  LMem: Pointer;
begin
  LPos := Self.Position;
  Result := 0;
  if (LPos < 0) and (Count = 0) then
    Exit;
  LEndPos := LPos + Count;
  LSize := Self.Size;
  if LEndPos > LSize then
    raise EStreamError.Create('Out of memory while expanding memory stream');
  LMem := Self.Memory;
  System.Move(Buffer, Pointer(Longint(LMem) + LPos)^, Count);
  Self.Position := LPos;
  Result := Count;
end;

{ TArrayEx }

class function TArrayEx.Copy<T>(const AValues: array of T; const ASourceIndex: Integer;
  const ADestIndex: Integer; const ACount: Integer): TArray<T>;
var
  LResult: TArray<T>;
begin
  if (ASourceIndex < 0) or (ASourceIndex >= Length(AValues)) then
    raise EArgumentOutOfRangeException.Create('Source index out of range');
  if ACount < 0 then
    raise EArgumentOutOfRangeException.Create('Count cannot be negative');
  if ASourceIndex + ACount > Length(AValues) then
    raise EArgumentOutOfRangeException.Create('Source range exceeds array length');
  if ADestIndex < 0 then
    raise EArgumentOutOfRangeException.Create('Destination index cannot be negative');
  SetLength(LResult, ACount + ADestIndex);
  TArray.Copy<T>(AValues, LResult, ASourceIndex, ADestIndex, ACount);
  Result := LResult;
end;

class function TArrayEx.Filter<T>(const AValues: array of T; APredicate: TFunc<T, Boolean>): TArray<T>;
var
  LList: TList<T>;
  LItem: T;
begin
  LList := TList<T>.Create;
  try
    for LItem in AValues do
      if APredicate(LItem) then
        LList.Add(LItem);
    Result := LList.ToArray;
  finally
    LList.Free;
  end;
end;

class procedure TArrayEx.ForEach<T>(const AValues: array of T; AAction: TProc<T>);
var
  LItem: T;
begin
  for LItem in AValues do
    AAction(LItem);
end;

class function TArrayEx.Any<T>(const AValues: array of T; APredicate: TFunc<T, Boolean>): Boolean;
var
  LItem: T;
begin
  for LItem in AValues do
    if APredicate(LItem) then
      Exit(True);
  Result := False;
end;

class function TArrayEx.Merge<T>(const AArray1, AArray2: array of T): TArray<T>;
var
  LLength1, LLength2: Integer;
begin
  Result := [];
  LLength1 := Length(AArray1);
  LLength2 := Length(AArray2);
  if (LLength1 = 0) and (LLength2 = 0) then
    Exit;
  SetLength(Result, LLength1 + LLength2);
  if LLength1 > 0 then
    Move(AArray1[0], Result[0], LLength1 * SizeOf(T));
  if LLength2 > 0 then
    Move(AArray2[0], Result[LLength1], LLength2 * SizeOf(T));
end;

class function TArrayEx.AsList<T>(const AArray: array of T): TList<T>;
var
  LFor: Integer;
begin
  Result := TList<T>.Create;
  for LFor := 0 to High(AArray) do
    Result.Add(AArray[LFor]);
end;

class function TArrayEx.All<T>(const AValues: array of T; APredicate: TFunc<T, Boolean>): Boolean;
var
  LItem: T;
begin
  for LItem in AValues do
    if not APredicate(LItem) then
      Exit(False);
  Result := True;
end;

class function TArrayEx.Map<T, TResult>(const AValues: array of T; AFunc: TFunc<T, TResult>): TArray<TResult>;
var
  LIndex: Integer;
begin
  SetLength(Result, Length(AValues));
  for LIndex := 0 to High(AValues) do
    Result[LIndex] := AFunc(AValues[LIndex]);
end;

class function TArrayEx.Reduce<T>(const AValues: array of T; AReducer: TFunc<T, T, T>): T;
var
  LValue: T;
  LIndex: Integer;
begin
  if Length(AValues) = 0 then
    raise EArgumentException.Create('Cannot reduce an empty array');
  LValue := AValues[Low(AValues)];
  for LIndex := Low(AValues) + 1 to High(AValues) do
    LValue := AReducer(LValue, AValues[LIndex]);
  Result := LValue;
end;

class function TArrayEx.Reduce<T>(const AValues: array of T; AReducer: TFunc<T, T, T>; const AInitial: T): T;
var
  LValue: T;
  LItem: T;
begin
  if Length(AValues) = 0 then
    Exit(AInitial);
  LValue := AInitial;
  for LItem in AValues do
    LValue := AReducer(LValue, LItem);
  Result := LValue;
end;

class function TArrayEx.Sum(const AData: array of Single): Single;
begin
  Result := Math.Sum(AData);
end;

class function TArrayEx.Sum(const AData: array of Double): Double;
begin
  Result := Math.Sum(AData);
end;

class function TArrayEx.Sum(const AData: array of Extended): Extended;
begin
  Result := Math.Sum(AData);
end;

class function TArrayEx.Sum(const AData: array of Integer): Integer;
begin
  Result := Math.SumInt(AData);
end;

class function TArrayEx.Total(const AData: array of Single): Single;
begin
  Result := Math.TotalVariance(AData);
end;

class function TArrayEx.Total(const AData: array of Double): Double;
begin
  Result := Math.TotalVariance(AData);
end;

class function TArrayEx.Total(const AData: array of Extended): Extended;
begin
  Result := Math.TotalVariance(AData);
end;

class function TArrayEx.Take<T>(const AValues: array of T; ACount: Integer): TArray<T>;
var
  LFor: Integer;
  LLength: Integer;
begin
  LLength := Length(AValues);
  if ACount <= 0 then
  begin
    SetLength(Result, 0);
    Exit;
  end;
  if ACount >= LLength then
    ACount := LLength;
  SetLength(Result, ACount);
  for LFor := 0 to ACount - 1 do
    Result[LFor] := AValues[LFor];
end;

class function TArrayEx.Skip<T>(const AValues: array of T; ACount: Integer): TArray<T>;
var
  LFor: Integer;
  LLength: Integer;
begin
  LLength := Length(AValues);
  if ACount <= 0 then
  begin
    SetLength(Result, LLength);
    for LFor := 0 to LLength - 1 do
      Result[LFor] := AValues[LFor];
    Exit;
  end;
  if ACount >= LLength then
  begin
    SetLength(Result, 0);
    Exit;
  end;
  SetLength(Result, LLength - ACount);
  for LFor := 0 to LLength - ACount - 1 do
    Result[LFor] := AValues[LFor + ACount];
end;

class function TArrayEx.FlatMap<T, TResult>(const AValues: array of T; AFunc: TFunc<T, TArray<TResult>>): TArray<TResult>;
var
  LList: TList<TResult>;
  LItem: T;
  LSubArray: TArray<TResult>;
  LFor: Integer;
begin
  LList := TList<TResult>.Create;
  try
    for LItem in AValues do
    begin
      LSubArray := AFunc(LItem);
      for LFor := 0 to High(LSubArray) do
        LList.Add(LSubArray[LFor]);
    end;
    Result := LList.ToArray;
  finally
    LList.Free;
  end;
end;

class procedure TArrayEx.Partition<T>(const AValues: array of T; APredicate: TFunc<T, Boolean>; out Left, Right: TArray<T>);
var
  LLeft, LRight: TList<T>;
  LItem: T;
begin
  LLeft := TList<T>.Create;
  LRight := TList<T>.Create;
  try
    for LItem in AValues do
      if APredicate(LItem) then
        LRight.Add(LItem)
      else
        LLeft.Add(LItem);
    Left := LLeft.ToArray;
    Right := LRight.ToArray;
  finally
    LLeft.Free;
    LRight.Free;
  end;
end;

class function TArrayEx.GroupBy<TKey, T>(const AValues: array of T; AKeySelector: TFunc<T, TKey>): TMap<TKey, TArray<T>>;
var
  LDict: TMap<TKey, TList<T>>;
  LItem: T;
  LKey: TKey;
  LList: TList<T>;
  LPair: TMapPair<TKey, TList<T>>;
begin
  LDict := TMap<TKey, TList<T>>.Create([]);
  try
    for LItem in AValues do
    begin
      LKey := AKeySelector(LItem);
      if not LDict.TryGetValue(LKey, LList) then
      begin
        LList := TList<T>.Create;
        LDict.Add(LKey, LList);
      end;
      LList.Add(LItem);
    end;
    Result := TMap<TKey, TArray<T>>.Create([]);
    for LPair in LDict do
      Result.Add(LPair.Key, LPair.Value.ToArray);
  finally
    for LPair in LDict do
      LPair.Value.Free;
  end;
end;

class function TArrayEx.Reverse<T>(const AValues: array of T): TArray<T>;
var
  LFor: Integer;
begin
  SetLength(Result, Length(AValues));
  for LFor := 0 to High(AValues) do
    Result[LFor] := AValues[High(AValues) - LFor];
end;

class function TArrayEx.Distinct<T>(const AValues: array of T): TArray<T>;
var
  LSet: TSet<T>;
  LList: TList<T>;
  LItem: T;
  LIndex: Integer;
begin
  LSet := TSet<T>.Create;
  LList := TList<T>.Create;
  try
    for LItem in AValues do
    begin
      if LSet.Add(LItem) then
        LList.Add(LItem);
    end;
    SetLength(Result, LList.Count);
    for LIndex := 0 to LList.Count - 1 do
      Result[LIndex] := LList[LIndex];
  finally
    LSet.Free;
    LList.Free;
  end;
end;

class function TArrayEx.Zip<T1, T2, TResult>(const AArray1: array of T1; const AArray2: array of T2; ACombiner: TFunc<T1, T2, TResult>): TArray<TResult>;
var
  LFor: Integer;
  LMinLength: Integer;
begin
  LMinLength := Min(Length(AArray1), Length(AArray2));
  SetLength(Result, LMinLength);
  for LFor := 0 to LMinLength - 1 do
    Result[LFor] := ACombiner(AArray1[LFor], AArray2[LFor]);
end;

//class function TArrayEx.ToVector<T>(const AValues: array of T): TVector<T>;
//var
//  LFor: Integer;
//begin
//  Result := TVector<T>.Create([]);
//  for LFor := 0 to High(AValues) do
//    Result.Add(AValues[LFor]);
//end;

class function TArrayEx.ToFuture<T>(const AValues: TArray<T>; AValidator: TFunc<TArray<T>, String>): TFuture;
var
  LError: String;
  LFor: Integer;
  LCopy: TArray<T>;
begin
  LError := AValidator(AValues);
  if LError = '' then
  begin
    SetLength(LCopy, Length(AValues));
    for LFor := 0 to Length(AValues) - 1 do
      LCopy[LFor] := AValues[LFor];
    Result.SetOk(TValue.From<TArray<T>>(LCopy));
  end
  else
    Result.SetErr(LError);
end;

{ TFuture }

function TFuture.Err: String;
begin
  Result := FErr;
end;

function TFuture.IsErr: Boolean;
begin
  Result := FIsErr;
end;

function TFuture.IsOk: Boolean;
begin
  Result := FIsOK;
end;

function TFuture.Ok<T>: T;
begin
  if not FIsOK then
    raise Exception.Create('Future is not in a success state');
  Result := FValue.AsType<T>;
end;

procedure TFuture.SetErr(const AErr: String);
begin
  FErr := AErr;
  FIsErr := True;
  FIsOK := False;
end;

procedure TFuture.SetOk(const AValue: TValue);
begin
  FValue := AValue;
  FIsOK := True;
  FIsErr := False;
end;

{ TSet<T> }

constructor TSet<T>.Create;
begin
  FComparer := TEqualityComparer<T>.Default;
  FItems := TDictionary<T, Boolean>.Create(FComparer);
end;

constructor TSet<T>.Create(const Comparer: IEqualityComparer<T>);
begin
  if Comparer = nil then
    FComparer := TEqualityComparer<T>.Default
  else
    FComparer := Comparer;
  FItems := TDictionary<T, Boolean>.Create(FComparer);
end;

destructor TSet<T>.Destroy;
begin
  FItems.Free;
  inherited;
end;

function TSet<T>.Add(const Item: T): Boolean;
begin
  if not FItems.ContainsKey(Item) then
  begin
    FItems.Add(Item, True);
    Result := True;
  end
  else
    Result := False;
end;

function TSet<T>.Contains(const Item: T): Boolean;
begin
  Result := FItems.ContainsKey(Item);
end;

function TSet<T>.Remove(const Item: T): Boolean;
begin
  Result := FItems.ContainsKey(Item);
  if Result then
    FItems.Remove(Item);
end;

procedure TSet<T>.Clear;
begin
  FItems.Clear;
end;

function TSet<T>.ToArray: TArray<T>;
begin
  Result := FItems.Keys.ToArray;
end;

function TSet<T>._GetCount: Integer;
begin
  Result := FItems.Count;
end;

function TSet<T>.Union(const Other: TSet<T>): TSet<T>;
var
  LItem: T;
begin
  Result := TSet<T>.Create(FComparer);
  for LItem in FItems.Keys do
    Result.Add(LItem);
  for LItem in Other.FItems.Keys do
    Result.Add(LItem);
end;

initialization
  TStd.Get.FormatSettings := TFormatSettings.Create('en_US');
  TStd.FSequenceCounter := Trunc((Now - EncodeDate(2022, 1, 1)) * 86400);

finalization
  if Assigned(TStd.FInstance) then
    TStd.FInstance.Free;

end.
