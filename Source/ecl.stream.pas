﻿{
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

unit ecl.stream;

interface

uses
  Classes,
  SysUtils,
  Generics.Collections,
  ecl.map,
  ecl.objects,
  ecl.vector,
  ecl.threading,
  ecl.std;

type
  TStreamReader = Classes.TStreamReader;
  TStringStream = Classes.TStringStream;

  TStreamReaderListenerEvent = procedure(const Line: String; const Operation: String) of object;

  /// <summary>
  ///   An enhanced stream reader class providing functional programming capabilities and event listening for stream operations.
  /// </summary>
  /// <remarks>
  ///   This class extends the standard TStreamReader with methods inspired by modern programming paradigms, such as mapping, filtering,
  ///   and reducing stream content. It also supports asynchronous operations and listener notifications for real-time monitoring.
  ///   Uses AutoRef for automatic resource management of internal streams.
  /// </remarks>
  TStreamReaderEx = class
  strict private
    FDataInternal: TSmartPtr<TStreamReader>;
    FDataString: TSmartPtr<TStringStream>;
    FDataReader: TSmartPtr<TStreamReader>;
    FListeners: TList<TStreamReaderListenerEvent>;

    /// <summary>
    ///   Notifies all registered listeners about a stream operation.
    /// </summary>
    /// <param name="LLine">The line being processed.</param>
    /// <param name="LOperation">The operation being performed (e.g., 'Map', 'Filter'). Defaults to an empty string.</param>
    procedure _NotifyListeners(const LLine: String; const LOperation: String = '');

    /// <summary>
    ///   Processes the stream with a custom action and updates internal state.
    /// </summary>
    /// <remarks>
    ///   Used internally by transformation methods like Map, Filter, and Distinct to process stream lines and update FDataString and FDataReader.
    /// </remarks>
    /// <param name="LOperation">The name of the operation being performed.</param>
    /// <param name="LProcessor">A procedure that processes the stream lines using a TStringBuilder.</param>
    /// <returns>The current instance for method chaining.</returns>
    function _ProcessStream(const LOperation: String; const LProcessor: TProc<TStringBuilder>): TStreamReaderEx;

    /// <summary>
    ///   Initializes or updates the internal string stream and reader from the current internal stream.
    /// </summary>
    /// <remarks>
    ///   Reads all lines from FDataInternal, trims them, and constructs a new FDataString and FDataReader. Used to prepare streams for reading.
    /// </remarks>
    procedure _SetDataInternal;

  public
    /// <summary>
    ///   Creates a new instance with default settings.
    /// </summary>
    constructor Create; overload;

    /// <summary>
    ///   Creates a new instance from a TStream.
    /// </summary>
    /// <param name="Stream">The source stream to read from.</param>
    constructor Create(const Stream: TStream); reintroduce; overload;

    /// <summary>
    ///   Creates a new instance from a TStream with BOM detection option.
    /// </summary>
    /// <param name="Stream">The source stream to read from.</param>
    /// <param name="DetectBOM">If true, detects the byte order mark to determine encoding.</param>
    constructor Create(const Stream: TStream; const DetectBOM: Boolean); reintroduce; overload;

    /// <summary>
    ///   Creates a new instance from a TStream with specified encoding and options.
    /// </summary>
    /// <param name="Stream">The source stream to read from.</param>
    /// <param name="Encoding">The encoding to use for reading the stream.</param>
    /// <param name="DetectBOM">If true, detects BOM to override encoding if present. Defaults to False.</param>
    /// <param name="BufferSize">The buffer size for reading operations. Defaults to 4096 bytes.</param>
    constructor Create(const Stream: TStream; const Encoding: TEncoding;
      const DetectBOM: Boolean = False; const BufferSize: Integer = 4096); reintroduce; overload;

    /// <summary>
    ///   Creates a new instance from a file.
    /// </summary>
    /// <param name="Filename">The path to the file to read from.</param>
    constructor Create(const Filename: String); reintroduce; overload;

    /// <summary>
    ///   Creates a new instance from a file with BOM detection option.
    /// </summary>
    /// <param name="Filename">The path to the file to read from.</param>
    /// <param name="DetectBOM">If true, detects BOM to determine encoding.</param>
    constructor Create(const Filename: String; const DetectBOM: Boolean); reintroduce; overload;

    /// <summary>
    ///   Creates a new instance from a file with specified encoding and options.
    /// </summary>
    /// <param name="Filename">The path to the file to read from.</param>
    /// <param name="Encoding">The encoding to use for reading the file.</param>
    /// <param name="DetectBOM">If true, detects BOM to override encoding if present. Defaults to False.</param>
    /// <param name="BufferSize">The buffer size for reading operations. Defaults to 4096 bytes.</param>
    constructor Create(const Filename: String; const Encoding: TEncoding;
      const DetectBOM: Boolean = False; const BufferSize: Integer = 4096); reintroduce; overload;

    /// <summary>
    ///   Destroys the instance and frees associated resources.
    /// </summary>
    destructor Destroy; override;

    /// <summary>
    ///   Creates a new TStreamReaderEx instance from a TStream.
    /// </summary>
    /// <param name="Stream">The source stream to read from.</param>
    /// <returns>A new TStreamReaderEx instance.</returns>
    class function New(const Stream: TStream): TStreamReaderEx; overload;

    /// <summary>
    ///   Creates a new TStreamReaderEx instance from a file.
    /// </summary>
    /// <param name="Filename">The path to the file to read from.</param>
    /// <returns>A new TStreamReaderEx instance.</returns>
    class function New(const Filename: String): TStreamReaderEx; overload;

    /// <summary>
    ///   Gets the underlying base stream.
    /// </summary>
    /// <returns>The TStream instance being read.</returns>
    function BaseStream: TStream;

    /// <summary>
    ///   Gets the current encoding used by the reader.
    /// </summary>
    /// <returns>The TEncoding instance in use.</returns>
    function CurrentEncoding: TEncoding;

    /// <summary>
    ///   Transforms each line in the stream using a provided function.
    /// </summary>
    /// <remarks>
    ///   Applies the transformation to all lines and updates the stream content for subsequent operations.
    /// </remarks>
    /// <param name="AFunc">A function that takes a string and returns a transformed string.</param>
    /// <returns>The current instance with transformed content.</returns>
    function Map(const AFunc: TFunc<String, String>): TStreamReaderEx; overload;

    /// <summary>
    ///   Maps each line in the stream to a result of type TResult.
    /// </summary>
    /// <remarks>
    ///   Returns a TVector containing the results of applying the mapping function to each line.
    /// </remarks>
    /// <param name="AMappingFunc">A function that transforms a string into a TResult.</param>
    /// <returns>A TVector containing the mapped results.</returns>
    function Map<TResult>(const AMappingFunc: TFunc<String, TResult>): TVector<TResult>; overload;

    /// <summary>
    ///   Filters the stream lines based on a predicate.
    /// </summary>
    /// <param name="APredicate">A function that returns true for lines to keep.</param>
    /// <returns>The current instance with filtered content.</returns>
    function Filter(const APredicate: TPredicate<String>): TStreamReaderEx;

    /// <summary>
    ///   Reduces the stream lines to a single integer value.
    /// </summary>
    /// <remarks>
    ///   Applies an accumulator function iteratively over each line, starting with an initial value.
    /// </remarks>
    /// <param name="AFunc">A function that takes an accumulator and a line, returning a new accumulator value.</param>
    /// <param name="AInitialValue">The initial value for the reduction.</param>
    /// <returns>The final reduced integer value.</returns>
    function Reduce(const AFunc: TFunc<Integer, String, Integer>; const AInitialValue: Integer): Integer;

    /// <summary>
    ///   Executes an action for each line in the stream.
    /// </summary>
    /// <param name="AAction">A procedure to execute for each line.</param>
    /// <returns>The current instance for method chaining.</returns>
    function ForEach(const AAction: TProc<String>): TStreamReaderEx;

    /// <summary>
    ///   Groups stream lines by a key selector function.
    /// </summary>
    /// <remarks>
    ///   Returns a TMap where each key is generated by the selector, and the value is a TVector of lines with that key.
    /// </remarks>
    /// <param name="AKeySelector">A function that generates a key for each line.</param>
    /// <returns>A TMap of grouped lines.</returns>
    function GroupBy(const AKeySelector: TFunc<String, String>): TMap<String, TVector<String>>;

    /// <summary>
    ///   Removes duplicate lines from the stream.
    /// </summary>
    /// <returns>The current instance with unique lines.</returns>
    function Distinct: TStreamReaderEx;

    /// <summary>
    ///   Skips a specified number of lines from the start of the stream.
    /// </summary>
    /// <param name="ACount">The number of lines to skip.</param>
    /// <returns>The current instance with remaining lines.</returns>
    function Skip(const ACount: Integer): TStreamReaderEx;

    /// <summary>
    ///   Sorts the stream lines alphabetically.
    /// </summary>
    /// <returns>The current instance with sorted lines.</returns>
    function Sort: TStreamReaderEx;

    /// <summary>
    ///   Takes a specified number of lines from the start of the stream.
    /// </summary>
    /// <param name="ACount">The number of lines to take.</param>
    /// <returns>The current instance with selected lines.</returns>
    function Take(const ACount: Integer): TStreamReaderEx;

    /// <summary>
    ///   Concatenates the current stream with another TStreamReaderEx instance.
    /// </summary>
    /// <param name="AStreamReader">The TStreamReaderEx to concatenate with.</param>
    /// <returns>The current instance with combined content.</returns>
    function Concat(const AStreamReader: TStreamReaderEx): TStreamReaderEx;

    /// <summary>
    ///   Partitions the stream into two based on a predicate.
    /// </summary>
    /// <remarks>
    ///   Returns a TPair with two TStreamReaderEx instances: one for lines matching the predicate, and one for those that don’t.
    /// </remarks>
    /// <param name="APredicate">A function that returns true for lines to include in the left partition.</param>
    /// <returns>A TPair containing the two partitioned TStreamReaderEx instances.</returns>
    function Partition(const APredicate: TPredicate<String>): TPair<TStreamReaderEx, TStreamReaderEx>;

    /// <summary>
    ///   Joins all stream lines into a single string with a separator.
    /// </summary>
    /// <param name="ASeparator">The separator to use between lines.</param>
    /// <returns>The concatenated string.</returns>
    function Join(const ASeparator: String): String;

    /// <summary>
    ///   Reads the next line from the stream.
    /// </summary>
    /// <returns>The next line, or an empty string if at the end of the stream.</returns>
    function AsLine: String;

    /// <summary>
    ///   Gets the entire stream content as a string.
    /// </summary>
    /// <returns>The full content of the stream.</returns>
    function AsString: String;

    /// <summary>
    ///   Checks if any line in the stream satisfies a predicate.
    /// </summary>
    /// <param name="APredicate">A function that returns true for matching lines.</param>
    /// <returns>True if any line matches, False otherwise.</returns>
    function Any(const APredicate: TPredicate<String>): Boolean;

    /// <summary>
    ///   Checks if all lines in the stream satisfy a predicate.
    /// </summary>
    /// <param name="APredicate">A function that returns true for matching lines.</param>
    /// <returns>True if all lines match, False otherwise.</returns>
    function All(const APredicate: TPredicate<String>): Boolean;

    /// <summary>
    ///   Combines filtering and transformation into a single operation.
    /// </summary>
    /// <param name="ACondition">A predicate to filter lines.</param>
    /// <param name="ATransform">A function to transform matching lines.</param>
    /// <returns>The current instance with filtered and transformed content.</returns>
    function Comprehend(const ACondition: TPredicate<String>; const ATransform: TFunc<String, String>): TStreamReaderEx;

    /// <summary>
    ///   Adds a listener to receive notifications about stream operations.
    /// </summary>
    /// <param name="Listener">The listener procedure to add.</param>
    procedure AddListener(const Listener: TStreamReaderListenerEvent);

    /// <summary>
    ///   Removes a listener from the notification list.
    /// </summary>
    /// <param name="Listener">The listener procedure to remove.</param>
    procedure RemoveListener(const Listener: TStreamReaderListenerEvent);
  end;

implementation

{ TStreamReaderEx }

constructor TStreamReaderEx.Create;
begin
  inherited Create;
end;

constructor TStreamReaderEx.Create(const Stream: TStream);
begin
  Create;
  FDataInternal := TStreamReader.Create(Stream);
end;

constructor TStreamReaderEx.Create(const Stream: TStream; const DetectBOM: Boolean);
begin
  Create;
  FDataInternal := TStreamReader.Create(Stream, DetectBOM);
end;

constructor TStreamReaderEx.Create(const Stream: TStream; const Encoding: TEncoding;
  const DetectBOM: Boolean; const BufferSize: Integer);
begin
  Create;
  FDataInternal := TStreamReader.Create(Stream, Encoding, DetectBOM, BufferSize);
end;

constructor TStreamReaderEx.Create(const Filename: String);
begin
  Create;
  FDataInternal := TStreamReader.Create(Filename);
end;

constructor TStreamReaderEx.Create(const Filename: String; const DetectBOM: Boolean);
begin
  Create;
  FDataInternal := TStreamReader.Create(Filename, DetectBOM);
end;

constructor TStreamReaderEx.Create(const Filename: String; const Encoding: TEncoding;
  const DetectBOM: Boolean; const BufferSize: Integer);
begin
  Create;
  FDataInternal := TStreamReader.Create(Filename, Encoding, DetectBOM, BufferSize);
end;

destructor TStreamReaderEx.Destroy;
begin
  FListeners.Free;
  inherited;
end;

class function TStreamReaderEx.New(const Stream: TStream): TStreamReaderEx;
begin
  Result := TStreamReaderEx.Create(Stream);
end;

class function TStreamReaderEx.New(const Filename: String): TStreamReaderEx;
begin
  Result := TStreamReaderEx.Create(Filename);
end;

function TStreamReaderEx.BaseStream: TStream;
begin
  Result := FDataReader.AsRef.BaseStream;
end;

function TStreamReaderEx.CurrentEncoding: TEncoding;
begin
  Result := FDataReader.AsRef.CurrentEncoding;
end;

procedure TStreamReaderEx._SetDataInternal;
var
  LResultBuilder: TSmartPtr<TStringBuilder>;
  LLine: String;
begin
  LResultBuilder := TStringBuilder.Create;
  try
    FDataInternal.AsRef.BaseStream.Seek(0, soBeginning);
    while not FDataInternal.AsRef.EndOfStream do
    begin
      LLine := TrimRight(FDataInternal.AsRef.ReadLine);
      LResultBuilder.AsRef.AppendLine(LLine);
    end;
    FDataString := nil;
    FDataReader := nil;
    FDataString := TStringStream.Create(LResultBuilder.AsRef.ToString, TEncoding.UTF8);
    FDataReader := TStreamReader.Create(FDataString.AsRef);
  finally
    FDataInternal.AsRef.Close;
  end;
end;

function TStreamReaderEx._ProcessStream(const LOperation: String; const LProcessor: TProc<TStringBuilder>): TStreamReaderEx;
var
  LBuilder: TSmartPtr<TStringBuilder>;
begin
  LBuilder := TStringBuilder.Create;
  FDataInternal.AsRef.BaseStream.Seek(0, soBeginning);
  LProcessor(LBuilder.AsRef);
  FDataString := TStringStream.Create(LBuilder.AsRef.ToString, TEncoding.UTF8);
  FDataReader := TStreamReader.Create(FDataString.AsRef);
  Result := Self;
end;

function TStreamReaderEx.Map(const AFunc: TFunc<String, String>): TStreamReaderEx;
begin
  Result := _ProcessStream('Map', procedure(LBuilder: TStringBuilder)
    var
      LLine: String;
    begin
      while not FDataInternal.AsRef.EndOfStream do
      begin
        LLine := FDataInternal.AsRef.ReadLine;
        LBuilder.AppendLine(AFunc(LLine));
        _NotifyListeners(LLine, 'Map');
      end;
    end);
end;

function TStreamReaderEx.Map<TResult>(const AMappingFunc: TFunc<String, TResult>): TVector<TResult>;
var
  LLine: String;
begin
  Result := TVector<TResult>.Empty;
  FDataInternal.AsRef.BaseStream.Seek(0, soBeginning);
  while not FDataInternal.AsRef.EndOfStream do
  begin
    LLine := FDataInternal.AsRef.ReadLine;
    Result.Add(AMappingFunc(LLine));
  end;
end;

function TStreamReaderEx.Filter(const APredicate: TPredicate<String>): TStreamReaderEx;
begin
  Result := _ProcessStream('Filter', procedure(LBuilder: TStringBuilder)
    var
      LLine: String;
    begin
      while not FDataInternal.AsRef.EndOfStream do
      begin
        LLine := FDataInternal.AsRef.ReadLine;
        if APredicate(LLine) then
        begin
          LBuilder.AppendLine(LLine);
          _NotifyListeners(LLine, 'Filter');
        end;
      end;
    end);
end;

function TStreamReaderEx.Reduce(const AFunc: TFunc<Integer, String, Integer>;
  const AInitialValue: Integer): Integer;
var
  LLine: String;
begin
  Result := AInitialValue;
  FDataInternal.AsRef.BaseStream.Seek(0, soBeginning);
  while not FDataInternal.AsRef.EndOfStream do
  begin
    LLine := FDataInternal.AsRef.ReadLine;
    Result := AFunc(Result, LLine);
    _NotifyListeners(LLine, 'Reduce');
  end;
end;

function TStreamReaderEx.ForEach(const AAction: TProc<String>): TStreamReaderEx;
var
  LLine: String;
begin
  FDataInternal.AsRef.BaseStream.Seek(0, soBeginning);
  while not FDataInternal.AsRef.EndOfStream do
  begin
    LLine := FDataInternal.AsRef.ReadLine;
    AAction(LLine);
    _NotifyListeners(LLine, 'ForEach');
  end;
  Result := Self;
end;

function TStreamReaderEx.GroupBy(const AKeySelector: TFunc<String, String>): TMap<String, TVector<String>>;
var
  LList: TVector<String>;
  LLine, LKey: String;
begin
  Result := [];
  FDataInternal.AsRef.BaseStream.Seek(0, soBeginning);
  while not FDataInternal.AsRef.EndOfStream do
  begin
    LLine := FDataInternal.AsRef.ReadLine;
    LKey := AKeySelector(LLine);
    if not Result.TryGetValue(LKey, LList) then
    begin
      LList := TVector<String>.Create([]);
      Result.Add(LKey, LList);
    end;
    LList.Add(LLine);
    Result[LKey] := LList;
    _NotifyListeners(LLine, 'GroupBy');
  end;
end;

function TStreamReaderEx.Distinct: TStreamReaderEx;
begin
  Result := _ProcessStream('Distinct', procedure(LBuilder: TStringBuilder)
    var
      LSeen: TSet<String>;
      LLine: String;
    begin
      LSeen := TSet<String>.Create;
      try
        while not FDataInternal.AsRef.EndOfStream do
        begin
          LLine := FDataInternal.AsRef.ReadLine;
          if LSeen.Add(LLine) then
          begin
            LBuilder.AppendLine(LLine);
            _NotifyListeners(LLine, 'Distinct');
          end;
        end;
      finally
        LSeen.Free;
      end;
    end);
end;

function TStreamReaderEx.Skip(const ACount: Integer): TStreamReaderEx;
begin
  Result := _ProcessStream('Skip', procedure(LBuilder: TStringBuilder)
    var
      LLine: String;
      LSkipped: Integer;
    begin
      LSkipped := 0;
      while not FDataInternal.AsRef.EndOfStream do
      begin
        LLine := FDataInternal.AsRef.ReadLine;
        if LSkipped >= ACount then
        begin
          LBuilder.AppendLine(LLine);
          _NotifyListeners(LLine, 'Skip');
        end;
        Inc(LSkipped);
      end;
    end);
end;

function TStreamReaderEx.Sort: TStreamReaderEx;
begin
  Result := _ProcessStream('Sort', procedure(LBuilder: TStringBuilder)
    var
      LLines: TSmartPtr<TStringList>;
      LI: Integer;
    begin
      LLines := TStringList.Create;
      while not FDataInternal.AsRef.EndOfStream do
        LLines.AsRef.Add(FDataInternal.AsRef.ReadLine);
      LLines.AsRef.Sort;
      for LI := 0 to LLines.AsRef.Count - 1 do
      begin
        LBuilder.AppendLine(LLines.AsRef[LI]);
        _NotifyListeners(LLines.AsRef[LI], 'Sort');
      end;
    end);
end;

function TStreamReaderEx.Take(const ACount: Integer): TStreamReaderEx;
begin
  Result := _ProcessStream('Take', procedure(LBuilder: TStringBuilder)
    var
      LLine: String;
      LTaken: Integer;
    begin
      LTaken := 0;
      while (not FDataInternal.AsRef.EndOfStream) and (LTaken < ACount) do
      begin
        LLine := FDataInternal.AsRef.ReadLine;
        LBuilder.AppendLine(LLine);
        _NotifyListeners(LLine, 'Take');
        Inc(LTaken);
      end;
    end);
end;

function TStreamReaderEx.Concat(const AStreamReader: TStreamReaderEx): TStreamReaderEx;
begin
  Result := _ProcessStream('Concat', procedure(LBuilder: TStringBuilder)
    var
      LLine: String;
    begin
      while not FDataInternal.AsRef.EndOfStream do
      begin
        LLine := FDataInternal.AsRef.ReadLine;
        LBuilder.AppendLine(LLine);
        _NotifyListeners(LLine, 'Concat');
      end;
      AStreamReader.FDataInternal.AsRef.BaseStream.Seek(0, soBeginning);
      while not AStreamReader.FDataInternal.AsRef.EndOfStream do
      begin
        LLine := AStreamReader.FDataInternal.AsRef.ReadLine;
        LBuilder.AppendLine(LLine);
        _NotifyListeners(LLine, 'Concat');
      end;
    end);
end;

function TStreamReaderEx.Partition(const APredicate: TPredicate<String>): TPair<TStreamReaderEx, TStreamReaderEx>;
var
  LLeftStream, LRightStream: TSmartPtr<TStringStream>;
  LLeftReader, LRightReader: TStreamReaderEx;
  LLine: String;
begin
  LLeftStream := TStringStream.Create('', TEncoding.UTF8);
  LRightStream := TStringStream.Create('', TEncoding.UTF8);
  LLeftReader := nil;
  LRightReader := nil;
  try
    FDataInternal.AsRef.BaseStream.Seek(0, soBeginning);
    while not FDataInternal.AsRef.EndOfStream do
    begin
      LLine := FDataInternal.AsRef.ReadLine;
      if APredicate(LLine) then
        LLeftStream.AsRef.WriteString(LLine + sLineBreak)
      else
        LRightStream.AsRef.WriteString(LLine + sLineBreak);
      _NotifyListeners(LLine, 'Partition');
    end;
    LLeftStream.AsRef.DataString;
    LLeftReader := TStreamReaderEx.New(LLeftStream.AsRef);
    LLeftReader._SetDataInternal;

    LRightStream.AsRef.DataString;
    LRightReader := TStreamReaderEx.New(LRightStream.AsRef);
    LRightReader._SetDataInternal;
  except
    if Assigned(LLeftReader) then
      LLeftReader.Free;
    if Assigned(LRightReader) then
      LRightReader.Free;
    raise;
  end;
  Result.Create(LLeftReader, LRightReader);
end;

function TStreamReaderEx.Join(const ASeparator: String): String;
var
  LBuilder: TSmartPtr<TStringBuilder>;
  LLine: String;
begin
  LBuilder := TStringBuilder.Create;
  FDataInternal.AsRef.BaseStream.Seek(0, soBeginning);
  while not FDataInternal.AsRef.EndOfStream do
  begin
    LLine := FDataInternal.AsRef.ReadLine;
    LBuilder.AsRef.Append(LLine);
    if not FDataInternal.AsRef.EndOfStream then
      LBuilder.AsRef.Append(ASeparator);
    _NotifyListeners(LLine, 'Join');
  end;
  Result := LBuilder.AsRef.ToString;
end;

function TStreamReaderEx.AsLine: String;
begin
  if FDataReader.AsRef.EndOfStream then
    Result := ''
  else
    Result := FDataReader.AsRef.ReadLine;
end;

function TStreamReaderEx.AsString: String;
begin
  Result := FDataString.AsRef.DataString;
end;

procedure TStreamReaderEx._NotifyListeners(const LLine: String; const LOperation: String);
var
  LListener: TStreamReaderListenerEvent;
begin
  if Assigned(FListeners) then
    for LListener in FListeners do
      LListener(LLine, LOperation);
end;

procedure TStreamReaderEx.AddListener(const Listener: TStreamReaderListenerEvent);
begin
  if not Assigned(FListeners) then
    FListeners := TList<TStreamReaderListenerEvent>.Create;
  FListeners.Add(Listener);
end;

procedure TStreamReaderEx.RemoveListener(const Listener: TStreamReaderListenerEvent);
begin
  if Assigned(FListeners) then
    FListeners.Remove(Listener);
end;

function TStreamReaderEx.Any(const APredicate: TPredicate<String>): Boolean;
var
  LLine: String;
begin
  FDataInternal.AsRef.BaseStream.Seek(0, soBeginning);
  while not FDataInternal.AsRef.EndOfStream do
  begin
    LLine := FDataInternal.AsRef.ReadLine;
    if APredicate(LLine) then
      Exit(True);
    _NotifyListeners(LLine, 'Any');
  end;
  Result := False;
end;

function TStreamReaderEx.All(const APredicate: TPredicate<String>): Boolean;
var
  LLine: String;
begin
  FDataInternal.AsRef.BaseStream.Seek(0, soBeginning);
  while not FDataInternal.AsRef.EndOfStream do
  begin
    LLine := FDataInternal.AsRef.ReadLine;
    if not APredicate(LLine) then
      Exit(False);
    _NotifyListeners(LLine, 'All');
  end;
  Result := True;
end;

function TStreamReaderEx.Comprehend(const ACondition: TPredicate<String>;
  const ATransform: TFunc<String, String>): TStreamReaderEx;
begin
  Result := _ProcessStream('Comprehend', procedure(LBuilder: TStringBuilder)
    var
      LLine: String;
    begin
      while not FDataInternal.AsRef.EndOfStream do
      begin
        LLine := FDataInternal.AsRef.ReadLine;
        if ACondition(LLine) then
        begin
          LBuilder.AppendLine(ATransform(LLine));
          _NotifyListeners(LLine, 'Comprehend');
        end;
      end;
    end);
end;

end.
