﻿{
             Evolution4D: Modern Delphi Development Library

                          Apache License
                      Version 2.0, January 2004
                   http://www.apache.org/licenses/

       Licensed under the Apache License, Version 2.0 (the "License");
       you may not use this file except in compliance with the License.
       You may obtain a copy of the License at

             http://www.apache.org/licenses/LICENSE-2.0

       Unless required by applicable law or agreed to in writing, software
       distributed under the License is distributed on an "AS IS" BASIS,
       WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
       See the License for the specific language governing permissions and
       limitations under the License.
}

{
  @abstract(Evolution4D Library)
  @created(03 Abr 2025)
  @author(Isaque Pinheiro <isaquepsp@gmail.com>)
  @Discord(https://discord.gg/T2zJC8zX)
}

unit Evolution.Std;

interface

uses
  Math,
  Classes,
  Windows,
  SysUtils,
  DateUtils,
  Generics.Collections,
  Generics.Defaults,
  Evolution.System;

type
  TPointerStream = class(TCustomMemoryStream)
  public
    constructor Create(P: Pointer; ASize: Integer);
    function Write(const Buffer; Count: Longint): Longint; override;
  end;

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

initialization
  TStd.Get.FormatSettings := TFormatSettings.Create('en_US');
  TStd.FSequenceCounter := Trunc((Now - EncodeDate(2022, 1, 1)) * 86400);

finalization
  if Assigned(TStd.FInstance) then
    TStd.FInstance.Free;

end.
