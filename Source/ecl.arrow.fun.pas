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

unit ecl.arrow.fun;

interface

uses
  Rtti,
  SysUtils,
  TypInfo,
  Generics.Collections,
  ecl.std;

type
  EArrowException = Exception;

  /// <summary>
  ///   A utility record providing functional programming constructs for managing and manipulating values and variables.
  /// </summary>
  /// <remarks>
  ///   TArrow offers methods to create procedures and functions that operate on TValue instances, enabling side effects on variables
  ///   or returning computed results. It supports both single-value and multi-value operations through arrays and tuples, with automatic
  ///   type conversion and error handling.
  /// </remarks>
  TArrow = record
  strict private
    class var FValue: TValue; // Internal storage for the last processed value

    /// <summary>
    ///   Frees the internally stored TValue when the class is destroyed.
    /// </summary>
    class destructor Destroy;

  public
    /// <summary>
    ///   Creates a procedure that sets an internal value without affecting external variables.
    /// </summary>
    /// <param name="AValue">The value to store internally.</param>
    /// <returns>A procedure that assigns AValue to the internal FValue when executed.</returns>
    class function Fn(const AValue: TValue): TProc; overload; static;

    /// <summary>
    ///   Creates a procedure that assigns multiple values to referenced variables based on a tuple.
    /// </summary>
    /// <remarks>
    ///   Uses an array of pointers to variables and a Tuple to update multiple variables with type-safe conversions.
    ///   Throws an exception if the array lengths do not match or if types are unsupported.
    /// </remarks>
    /// <param name="AVarRefs">An array of pointers to variables to be updated.</param>
    /// <param name="AValues">A Tuple containing the values to assign to the variables.</param>
    /// <returns>A procedure that updates the variables with values from AValues when executed with a TValue.</returns>
    class function Fn(const AVarRefs: TArray<Pointer>; const AValues: Tuple): TProc<TValue>; overload; static;

    /// <summary>
    ///   Creates a procedure that assigns a value to a typed variable.
    /// </summary>
    /// <remarks>
    ///   Provides a type-safe way to update a single variable with a specified value when the procedure is executed.
    /// </remarks>
    /// <param name="AVar">The variable to update, passed by reference.</param>
    /// <param name="AValue">The value to assign to AVar.</param>
    /// <returns>A procedure that updates AVar with AValue when executed with a TValue.</returns>
    class function Fn<T>(var AVar: T; const AValue: T): TProc<TValue>; overload; inline; static;

    /// <summary>
    ///   Creates a function that sets an internal value and returns it.
    /// </summary>
    /// <param name="AValue">The value to store and return.</param>
    /// <returns>A function that assigns AValue to FValue and returns it when executed.</returns>
    class function Result(const AValue: TValue): TFunc<TValue>; static;

    /// <summary>
    ///   Retrieves the last stored value as a specified type.
    /// </summary>
    /// <remarks>
    ///   Attempts to cast the internal FValue to type T. Raises EArrowException if the cast fails.
    /// </remarks>
    /// <returns>The internal FValue cast to type T.</returns>
    class function Value<T>: T; static;
  end;

implementation

{ TArrow }

class function TArrow.Fn(const AValue: TValue): TProc;
begin
  Result := procedure
            begin
              FValue := AValue;
            end;
end;

class function TArrow.Result(const AValue: TValue): TFunc<TValue>;
begin
  Result := function: TValue
            begin
              FValue := AValue;
              Result := AValue;
            end;
end;

class function TArrow.Fn<T>(var AVar: T; const AValue: T): TProc<TValue>;
var
  LVar: ^T;
  LValue: T;
begin
  LVar := @AVar;
  LValue := AValue;
  Result := procedure(AValue: TValue)
            begin
              try
                FValue := nil;
                FValue := AValue;
                LVar^ := LValue;
              except
                on E: Exception do
                  raise EArrowException.Create('Error in TArrow.Fn: ' + E.Message);
              end;
            end;
end;

class function TArrow.Value<T>: T;
begin
  try
    Result := FValue.AsType<T>;
  except
    on E: Exception do
      raise EArrowException.Create('Error in TArrow.Value: Cannot cast value to specified type. ' + E.Message);
  end;
end;

class destructor TArrow.Destroy;
begin
  FValue := nil;
end;

class function TArrow.Fn(const AVarRefs: TArray<Pointer>; const AValues: Tuple): TProc<TValue>;
var
  LVarRefs: TArray<Pointer>;
begin
  if Length(AVarRefs) <> Length(AValues) then
    raise Exception.Create('Different-sized arrays in TArrow.Fn.');

  LVarRefs := AVarRefs;
  Result := procedure(AValue: TValue)
            var
              LFor: Integer;
              LTypeInfo: PTypeInfo;
            begin
              try
                FValue := AValue;
                for LFor := 0 to High(LVarRefs) do
                begin
                  case AValues[LFor].Kind of
                    tkInt64:
                      PInt64(LVarRefs[LFor])^ := AValues[LFor].AsInt64;
                    tkInteger, tkSet:
                      PInteger(LVarRefs[LFor])^ := AValues[LFor].AsInteger;
                    tkFloat:
                      PDouble(LVarRefs[LFor])^ := AValues[LFor].AsExtended;
                    tkUString, tkLString, tkWString, tkString, tkChar, tkWChar:
                      PUnicodeString(LVarRefs[LFor])^ := AValues[LFor].AsString;
                    tkClass:
                      PObject(LVarRefs[LFor])^ := AValues[LFor].AsObject;
                    tkEnumeration:
                      PBoolean(LVarRefs[LFor])^ := AValues[LFor].AsBoolean;
                    tkRecord, tkVariant:
                      PVariant(LVarRefs[LFor])^ := AValues[LFor].AsVariant;
                    tkArray, tkDynArray:
                    begin
                      LTypeInfo := AValues[LFor].TypeInfo;
                      case GetTypeData(LTypeInfo).elType2^.Kind of
                        tkInt64:
                          TArray<Int64>(LVarRefs[LFor]) := AValues[LFor].AsType<TArray<Int64>>;
                        tkInteger, tkSet:
                          TArray<Integer>(LVarRefs[LFor]) := AValues[LFor].AsType<TArray<Integer>>;
                        tkFloat:
                          TArray<Extended>(LVarRefs[LFor]) := AValues[LFor].AsType<TArray<Extended>>;
                        tkUString, tkLString, tkWString, tkString, tkChar, tkWChar:
                          TArray<String>(LVarRefs[LFor]) := AValues[LFor].AsType<TArray<String>>;
                        tkClass:
                          TArray<TObject>(LVarRefs[LFor]) := AValues[LFor].AsType<TArray<TObject>>;
                        tkEnumeration:
                          TArray<Boolean>(LVarRefs[LFor]) := AValues[LFor].AsType<TArray<Boolean>>;
                        tkRecord, tkVariant:
                          TArray<Variant>(LVarRefs[LFor]) := AValues[LFor].AsType<TArray<Variant>>;
                      else
                        raise EArrowException.Create('Unsupported array element type at index ' + IntToStr(LFor));
                      end;
                    end;
                  else
                    raise EArrowException.Create('Unsupported type at index ' + IntToStr(LFor));
                  end;
                end;
              except
                on E: Exception do
                  raise EArrowException.Create('Error in TArrow.Fn (array): ' + E.Message);
              end;
            end;
end;

end.
