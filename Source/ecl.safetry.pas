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

unit ecl.safetry;

interface

uses
  SysUtils,
  Rtti;

type
  TSafeResult = record
  private
    FIsOk: Boolean;
    FValue: TValue;
    FException: String;

    /// <summary>
    ///   Sets the success state and value for the TSafeResult.
    /// </summary>
    /// <remarks>
    ///   Use this procedure to mark the TSafeResult as successful and assign a value to it.
    ///   This method clears any previous error state and exception message.
    /// </remarks>
    /// <param name="AValue">
    ///   The value of type TValue to set as the successful result.
    /// </param>
    procedure _Ok(const AValue: TValue);

    /// <summary>
    ///   Sets the error state and exception message for the TSafeResult.
    /// </summary>
    /// <remarks>
    ///   Use this procedure to mark the TSafeResult as an error and assign an exception message.
    ///   This method clears any previous success value and sets the result to an error state.
    /// </remarks>
    /// <param name="AException">
    ///   The exception message as a string to set for the error state.
    /// </param>
    procedure _Err(const AException: String);

    /// <summary>
    ///   Creates a TSafeResult instance with a success state and value.
    /// </summary>
    /// <remarks>
    ///   This static method initializes a TSafeResult with a successful state and the specified value.
    ///   It is typically used internally by TSafeTry to return a successful execution result.
    /// </remarks>
    /// <param name="AValue">
    ///   The value of type TValue to set as the successful result.
    /// </param>
    class function _CreateOk(const AValue: TValue): TSafeResult; static;

    /// <summary>
    ///   Creates a TSafeResult instance with an error state and exception message.
    /// </summary>
    /// <remarks>
    ///   This static method initializes a TSafeResult with an error state and the specified exception message.
    ///   It is typically used internally by TSafeTry to return an error result from an exception.
    /// </remarks>
    /// <param name="AException">
    ///   The exception message as a string to set for the error state.
    /// </param>
    class function _CreateErr(const AException: String): TSafeResult; static;
  public
    /// <summary>
    ///   Determines if the TSafeResult represents a successful state.
    /// </summary>
    /// <remarks>
    ///   This function returns True if the TSafeResult is in a success state (no error occurred),
    ///   and False otherwise. Use this to check the outcome of a TSafeTry execution.
    /// </remarks>
    function IsOk: Boolean;

    /// <summary>
    ///   Determines if the TSafeResult represents an error state.
    /// </summary>
    /// <remarks>
    ///   This function returns True if the TSafeResult is in an error state (an exception occurred),
    ///   and False otherwise. Use this to check if an error was encountered during TSafeTry execution.
    /// </remarks>
    function IsErr: Boolean;

    /// <summary>
    ///   Retrieves the value from the TSafeResult if successful.
    /// </summary>
    /// <remarks>
    ///   This function returns the stored TValue if the TSafeResult is in a success state (IsOk = True).
    ///   If the result is in an error state, it raises an exception.
    /// </remarks>
    function GetValue: TValue;

    /// <summary>
    ///   Attempts to retrieve the value from the TSafeResult without raising an exception.
    /// </summary>
    /// <remarks>
    ///   This function tries to retrieves the stored TValue from the TSafeResult. It returns True and sets
    ///   the AValue parameter if the result is successful (IsOk = True), or False and sets AValue to
    ///   TValue.Empty if the result is an error (IsErr = True).
    /// </remarks>
    /// <param name="AValue">
    ///   The TValue variable to receive the stored value if successful.
    /// </param>
    function TryGetValue(out AValue: TValue): Boolean;

    /// <summary>
    ///   Retrieves the exception message from the TSafeResult if an error occurred.
    /// </summary>
    /// <remarks>
    ///   This function returns the exception message as a string if the TSafeResult is in an error state
    ///   (IsErr = True). If no error occurred (IsOk = True), it returns an empty string.
    /// </remarks>
    function ExceptionMessage: String;

    /// <summary>
    ///   Converts the stored value in the TSafeResult to a specified type.
    /// </summary>
    /// <remarks>
    ///   This function converts the TValue stored in the TSafeResult to the type T specified by the generic
    ///   parameter. It raises an exception if the result is in an error state or if the conversion fails.
    /// </remarks>
    function AsType<T>: T;

    /// <summary>
    ///   Checks if the stored value in the TSafeResult can be converted to a specified type.
    /// </summary>
    /// <remarks>
    ///   This function returns True if the TSafeResult is in a success state (IsOk = True) and the stored
    ///   TValue can be converted to the type T specified by the generic parameter, False otherwise.
    /// </remarks>
    function IsType<T>: Boolean;
  end;

  TSafeTry = record
  private
    FTryFunc: TFunc<TValue>;
    FTryProc: TProc;
    FExcept: TProc<Exception>;
    FFinally: TProc;
    /// <summary>
    ///   Executes the try block and handles exceptions and finalization internally.
    /// </summary>
    /// <remarks>
    ///   This internal function executes the try block defined by FTryFunc or FTryProc, handles any
    ///   exceptions using FExcept, and ensures FFinally is called. It returns a TValue representing
    ///   the result of the execution, or raises an exception if an error occurs.
    /// </remarks>
    function _EndExecute: TValue;
  public
    /// <summary>
    ///   Initializes a TSafeTry instance with a function to execute.
    /// </summary>
    /// <remarks>
    ///   This static method creates a TSafeTry instance configured to execute the specified function
    ///   (AFunc) in a try-except-finally block. The function should return a TValue as the result.
    /// </remarks>
    /// <param name="AFunc">
    ///   The function of type TFunc<TValue> to execute in the try block.
    /// </param>
    class function &Try(const AFunc: TFunc<TValue>): TSafeTry; overload; static;
    /// <summary>
    ///   Initializes a TSafeTry instance with a procedure to execute.
    /// </summary>
    /// <remarks>
    ///   This static method creates a TSafeTry instance configured to execute the specified procedure
    ///   (AProc) in a try-except-finally block. If AProc is nil, an empty try block is assumed,
    ///   returning a default success value (True).
    /// </remarks>
    /// <param name="AProc">
    ///   The procedure of type TProc to execute in the try block (optional, defaults to nil).
    /// </param>
    class function &Try(const AProc: TProc = nil): TSafeTry; overload; static;
    /// <summary>
    ///   Configures an exception handler for the TSafeTry instance.
    /// </summary>
    /// <remarks>
    ///   This method sets the exception handler procedure (AProc) that will be called if an exception
    ///   occurs during the try block execution. The handler receives the Exception object and can
    ///   process it as needed.
    /// </remarks>
    /// <param name="AProc">
    ///   The exception handler procedure of type TProc<Exception> to execute when an exception occurs.
    /// </param>
    function &Except(const AProc: TProc<Exception>): TSafeTry;
    /// <summary>
    ///   Configures a finalization handler for the TSafeTry instance.
    /// </summary>
    /// <remarks>
    ///   This method sets the finalization procedure (AProc) that will be called after the try block
    ///   and any exception handling, regardless of success or failure. It ensures cleanup or final steps
    ///   are executed.
    /// </remarks>
    /// <param name="AProc">
    ///   The finalization procedure of type TProc to execute after the try and except blocks.
    /// </param>
    function &Finally(const AProc: TProc): TSafeTry;
    /// <summary>
    ///   Executes the configured try-except-finally block and returns the result.
    /// </summary>
    /// <remarks>
    ///   This method executes the try block (defined by &Try), handles any exceptions using the configured
    ///   &Except handler, and ensures the &Finally handler is called. It returns a TSafeResult containing
    ///   either the success value or the error state.
    /// </remarks>
    function &End: TSafeResult;
  end;

/// <summary>
///   Creates a TSafeTry instance with a function to execute.
/// </summary>
/// <remarks>
///   This global function is a shorthand for TSafeTry.&Try, initializing a TSafeTry instance with
///   the specified function (AFunc) to be executed in a try-except-finally block. The function returns
///   a TValue as the result.
/// </remarks>
/// <param name="AFunc">
///   The function of type TFunc<TValue> to execute in the try block.
/// </param>
function &Try(const AFunc: TFunc<TValue>): TSafeTry; overload;

/// <summary>
///   Creates a TSafeTry instance with a procedure to execute.
/// </summary>
/// <remarks>
///   This global function is a shorthand for TSafeTry.&Try, initializing a TSafeTry instance with
///   the specified procedure (AProc) to be executed in a try-except-finally block.
/// </remarks>
/// <param name="AProc">
///   The procedure of type TProc to execute in the try block.
/// </param>
function &Try(const AProc: TProc): TSafeTry; overload;

/// <summary>
///   Creates a TSafeTry instance with an empty try block.
/// </summary>
/// <remarks>
///   This global function is a shorthand for TSafeTry.&Try with no procedure or function, initializing
///   a TSafeTry instance with an empty try block that returns a default success value (True).
/// </remarks>
function &Try: TSafeTry; overload;

implementation

{ TSafeResult }

procedure TSafeResult._Ok(const AValue: TValue);
begin
  FIsOk := True;
  FValue := AValue;
  FException := '';
end;

procedure TSafeResult._Err(const AException: String);
begin
  FIsOk := False;
  FValue := TValue.Empty;
  FException := AException;
end;

function TSafeResult.IsOk: Boolean;
begin
  Result := FIsOk;
end;

function TSafeResult.IsErr: Boolean;
begin
  Result := not FIsOk;
end;

function TSafeResult.GetValue: TValue;
begin
  if not FIsOk then
    raise Exception.Create('Cannot get value when result is an error.');
  Result := FValue;
end;

function TSafeResult.TryGetValue(out AValue: TValue): Boolean;
begin
  Result := FIsOk;
  if Result then
    AValue := FValue
  else
    AValue := TValue.Empty;
end;

function TSafeResult.ExceptionMessage: String;
begin
  Result := FException;
end;

function TSafeResult.AsType<T>: T;
begin
  Result := GetValue.AsType<T>;
end;

function TSafeResult.IsType<T>: Boolean;
begin
  Result := FIsOk and FValue.IsType(TypeInfo(T));
end;

class function TSafeResult._CreateOk(const AValue: TValue): TSafeResult;
begin
  Result._Ok(AValue);
end;

class function TSafeResult._CreateErr(const AException: String): TSafeResult;
begin
  Result._Err(AException);
end;

{ TSafeTry }

class function TSafeTry.&Try(const AFunc: TFunc<TValue>): TSafeTry;
begin
  Result.FTryFunc := AFunc;
  Result.FTryProc := nil;
  Result.FExcept := nil;
  Result.FFinally := nil;
end;

class function TSafeTry.&Try(const AProc: TProc): TSafeTry;
begin
  Result.FTryProc := AProc;
  Result.FTryFunc := nil;
  Result.FExcept := nil;
  Result.FFinally := nil;
end;

function TSafeTry.&Except(const AProc: TProc<Exception>): TSafeTry;
begin
  FExcept := AProc;
  Result := Self;
end;

function TSafeTry.&Finally(const AProc: TProc): TSafeTry;
begin
  FFinally := AProc;
  Result := Self;
end;

function TSafeTry._EndExecute: TValue;
var
  LExceptMessage: String;
begin
  try
    try
      if Assigned(FTryFunc) then
      begin
        Result := FTryFunc();
        if Result.IsEmpty then
          Result := TValue.From(True);
      end
      else if Assigned(FTryProc) then
      begin
        FTryProc();
        Result := TValue.From(True);
      end
      else
        Result := TValue.From(True);
    except
      on E: Exception do
      begin
        LExceptMessage := E.Message;
        if Assigned(FExcept) then
        begin
          try
            FExcept(E);
          except
            on EInner: Exception do
              LExceptMessage := E.Message + ' (Except handler failed: ' + EInner.Message + ')';
          end;
        end;
        raise Exception.Create(LExceptMessage);
      end;
    end;
  finally
    if Assigned(FFinally) then
    begin
      try
        FFinally();
      except
        on E: Exception do
          // Ignora exceções em Finally silenciosamente
          // Futuro: Poderia logar se houver um mecanismo global
      end;
    end;
  end;
end;

function TSafeTry.&End: TSafeResult;
var
  LValue: TValue;
begin
  try
    LValue := _EndExecute;
    Result := TSafeResult._CreateOk(LValue);
  except
    on E: Exception do
      Result := TSafeResult._CreateErr(E.Message);
  end;
end;

{ Função Auxiliar }

function &Try(const AFunc: TFunc<TValue>): TSafeTry;
begin
  Result := TSafeTry.&Try(AFunc);
end;

function &Try(const AProc: TProc): TSafeTry;
begin
  Result := TSafeTry.&Try(AProc);
end;

function &Try: TSafeTry;
begin
  Result := TSafeTry.&Try;
end;

end.


