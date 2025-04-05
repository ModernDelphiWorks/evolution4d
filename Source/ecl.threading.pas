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

unit ecl.threading;

interface

uses
  Rtti,
  SysUtils,
  Classes,
  SyncObjs,
  Threading,
  ecl.std;

type
  /// <summary>
  ///   Represents a value that can hold any type.
  /// </summary>
  TValue = Rtti.TValue;

  /// <summary>
  ///   Represents a future value that can be either successful or contain an error.
  /// </summary>
  TFuture = ecl.std.TFuture;

  /// <summary>
  ///   Exception class for asynchronous operations.
  /// </summary>
  EAsyncAwait = Exception;

  /// <summary>
  ///   Interface for automatic locking mechanisms.
  /// </summary>
  IAutoLock = interface
    ['{1857DCF0-4B4C-491B-A546-CB82B199E2E1}']
    /// <summary>
    ///   Acquires the lock.
    /// </summary>
    procedure Acquire;

    /// <summary>
    ///   Releases the lock.
    /// </summary>
    procedure Release;
  end;

  /// <summary>
  ///   Provides automatic locking using a critical section.
  /// </summary>
  TAutoLock = class(TInterfacedObject, IAutoLock)
  private
    FCriticalSection: TCriticalSection;
  public
    /// <summary>
    ///   Initializes a new instance of the TAutoLock class.
    /// </summary>
    constructor Create;

    /// <summary>
    ///   Destroys the TAutoLock instance.
    /// </summary>
    destructor Destroy; override;

    /// <summary>
    ///   Acquires the lock.
    /// </summary>
    procedure Acquire; inline;

    /// <summary>
    ///   Releases the lock.
    /// </summary>
    procedure Release; inline;
  end;

  /// <summary>
  ///   Pointer to a TAsync record.
  /// </summary>
  PAsync = ^TAsync;

  /// <summary>
  ///   Represents an asynchronous operation.
  /// </summary>
  TAsync = record
  strict private
    FTask: ITask;
    FProc: TProc;
    FFunc: TFunc<TValue>;
    FError: TFunc<Exception, TFuture>;
    FLock: IAutoLock;

    function _AwaitProc(const AContinue: TProc; const ATimeout: Cardinal): TFuture; overload;
    function _AwaitFunc(const AContinue: TProc; const ATimeout: Cardinal): TFuture; overload;
    function _AwaitProc(const ATimeout: Cardinal): TFuture; overload;
    function _AwaitFunc(const ATimeout: Cardinal): TFuture; overload;
    function _ExecProc: TFuture;
  private
    /// <summary>
    ///   Initializes a new instance of the TAsync record with a procedure.
    /// </summary>
    /// <param name="AProc">
    ///   The procedure to execute asynchronously.
    /// </param>
    constructor Create(const AProc: TProc); overload;

    /// <summary>
    ///   Initializes a new instance of the TAsync record with a function.
    /// </summary>
    /// <param name="AFunc">
    ///   The function to execute asynchronously.
    /// </param>
    constructor Create(const AFunc: TFunc<TValue>); overload;
  public
    /// <summary>
    ///   Waits for the asynchronous operation to complete and executes a continuation.
    /// </summary>
    /// <param name="AContinue">
    ///   The continuation procedure to execute after the operation completes.
    /// </param>
    /// <param name="ATimeout">
    ///   The maximum time to wait for the operation to complete (in milliseconds).
    /// </param>
    /// <returns>
    ///   A TFuture representing the result of the operation.
    /// </returns>
    function Await(const AContinue: TProc; const ATimeout: Cardinal = INFINITE): TFuture; overload; inline;

    /// <summary>
    ///   Waits for the asynchronous operation to complete.
    /// </summary>
    /// <param name="ATimeout">
    ///   The maximum time to wait for the operation to complete (in milliseconds).
    /// </param>
    /// <returns>
    ///   A TFuture representing the result of the operation.
    /// </returns>
    function Await(const ATimeout: Cardinal = INFINITE): TFuture; overload; inline;

    /// <summary>
    ///   Starts the asynchronous operation.
    /// </summary>
    /// <returns>
    ///   A TFuture representing the result of the operation.
    /// </returns>
    function Run: TFuture; overload;

    /// <summary>
    ///   Starts the asynchronous operation with an error handler.
    /// </summary>
    /// <param name="AError">
    ///   The error handler to execute if an exception occurs.
    /// </param>
    /// <returns>
    ///   A TFuture representing the result of the operation.
    /// </returns>
    function Run(const AError: TFunc<Exception, TFuture>): TFuture; overload; inline;

    /// <summary>
    ///   Starts the asynchronous operation without waiting for completion.
    /// </summary>
    /// <returns>
    ///   A TFuture representing the result of the operation.
    /// </returns>
    function NoAwait: TFuture; overload;

    /// <summary>
    ///   Starts the asynchronous operation without waiting for completion and with an error handler.
    /// </summary>
    /// <param name="AError">
    ///   The error handler to execute if an exception occurs.
    /// </param>
    /// <returns>
    ///   A TFuture representing the result of the operation.
    /// </returns>
    function NoAwait(const AError: TFunc<Exception, TFuture>): TFuture; overload; inline;

    /// <summary>
    ///   Gets the status of the asynchronous operation.
    /// </summary>
    /// <returns>
    ///   The status of the task.
    /// </returns>
    function Status: TTaskStatus; inline;

    /// <summary>
    ///   Gets the ID of the asynchronous task.
    /// </summary>
    /// <returns>
    ///   The ID of the task.
    /// </returns>
    function GetId: Integer; inline;

    /// <summary>
    ///   Cancels the asynchronous operation.
    /// </summary>
    procedure Cancel; inline;

    /// <summary>
    ///   Checks if the asynchronous operation has been canceled.
    /// </summary>
    procedure CheckCanceled; inline;
  end;

/// <summary>
///   Creates a new asynchronous operation with a procedure.
/// </summary>
/// <param name="AProc">
///   The procedure to execute asynchronously.
/// </param>
/// <returns>
///   A TAsync representing the asynchronous operation.
/// </returns>
function Async(const AProc: TProc): TAsync; overload; inline;

/// <summary>
///   Creates a new asynchronous operation with a function.
/// </summary>
/// <param name="AFunc">
///   The function to execute asynchronously.
/// </param>
/// <returns>
///   A TAsync representing the asynchronous operation.
/// </returns>
function Async(const AFunc: TFunc<TValue>): TAsync; overload; inline;

implementation

function Async(const AProc: TProc): TAsync;
var
  LAsync: TAsync;
begin
  LAsync := TAsync.Create(AProc);
  Result := LAsync;
end;

function Async(const AFunc: TFunc<TValue>): TAsync;
begin
  Result := TAsync.Create(AFunc);
end;

function TAsync.Await(const AContinue: TProc; const ATimeout: Cardinal): TFuture;
begin
  if Assigned(FProc) then
    Result := _AwaitProc(AContinue, ATimeout)
  else
  if Assigned(FFunc) then
    Result := _AwaitFunc(AContinue, ATimeout)
end;

constructor TAsync.Create(const AProc: TProc);
begin
  FLock := TAutoLock.Create;
  FTask := nil;
  FProc := AProc;
  FFunc := nil;
end;

function TAsync.Await(const ATimeout: Cardinal): TFuture;
begin
  if Assigned(FProc) then
    Result := _AwaitProc(ATimeout)
  else
  if Assigned(FFunc) then
    Result := _AwaitFunc(ATimeout)
end;

procedure TAsync.Cancel;
begin
  FLock.Acquire;
  try
    if Assigned(FTask) then
      FTask.Cancel;
  finally
    FLock.Release;
  end;
end;

procedure TAsync.CheckCanceled;
begin
  FLock.Acquire;
  try
    if Assigned(FTask) then
      FTask.CheckCanceled;
  finally
    FLock.Release;
  end;
end;

constructor TAsync.Create(const AFunc: TFunc<TValue>);
begin
  FLock := TAutoLock.Create;
  FTask := nil;
  FProc := nil;
  FFunc := AFunc;
end;

function TAsync.Run: TFuture;
begin
  if Assigned(FProc) then
    Result := _ExecProc
  else
  if Assigned(FFunc) then
    Result.SetErr('The "Run" method should not be invoked as a function. Utilize the "Await" method to wait for task completion and access the result, or invoke it as a procedure.');
end;

function TAsync.GetId: Integer;
begin
  FLock.Acquire;
  try
    if Assigned(FTask) then
      Result := FTask.GetId
    else
      Result := -1;
  finally
    FLock.Release;
  end;
end;

function TAsync.NoAwait(const AError: TFunc<Exception, TFuture>): TFuture;
begin
  Result :=  Run(AError);
end;

function TAsync.NoAwait: TFuture;
begin
  Result := Run;
end;

function TAsync.Run(const AError: TFunc<Exception, TFuture>): TFuture;
begin
  FError := AError;
  Result := Self.Run;
end;

function TAsync.Status: TTaskStatus;
begin
  FLock.Acquire;
  try
    if Assigned(FTask) then
      Result := FTask.Status
    else
      Result := TTaskStatus.Created;
  finally
    FLock.Release;
  end;
end;

function TAsync._AwaitProc(const AContinue: TProc; const ATimeout: Cardinal): TFuture;
var
  LSelf: PAsync;
  LMessage: String;
begin
  LSelf := @Self;
  FLock.Acquire;
  try
    try
      FTask := TTask.Run(procedure
                         begin
                           try
                             LSelf^.FProc();
                           except
                             on E: Exception do
                               LMessage := E.Message;
                           end;
                         end);
      FTask.Wait(ATimeout);
      if LMessage <> '' then
        raise EAsyncAwait.Create(LMessage);

      if Assigned(AContinue) then
        TThread.Queue(TThread.CurrentThread,
                      procedure
                      begin
                        try
                          AContinue();
                        except
                          on E: Exception do
                            LMessage := E.Message;
                        end;
                      end);
      if LMessage <> '' then
        raise EAsyncAwait.Create(LMessage);

      Result.SetOk(True);
    except
      on E: Exception do
        Result.SetErr(E.Message);
    end;
  finally
    FLock.Release;
  end;
end;

function TAsync._ExecProc: TFuture;
var
  LProc: TProc;
  LError: TFunc<Exception, TFuture>;
begin
  LProc := FProc;
  LError := FError;
  FLock.Acquire;
  try
    try
      FTask := TTask.Run(procedure
                         var
                           LMessage: String;
                         begin
                           try
                             LProc();
                           except
                             on E: Exception do
                             begin
                               LMessage := E.Message;
                               if Assigned(LError) then
                                 TThread.Queue(TThread.CurrentThread,
                                               procedure
                                               begin
                                                 LError(Exception.Create(LMessage));
                                               end);
                             end;
                           end;
                         end);
      Result.SetOk(True);
    except
      on E: Exception do
        Result.SetErr(E.Message);
    end;
  finally
    FLock.Release;
  end;
end;

function TAsync._AwaitFunc(const AContinue: TProc; const ATimeout: Cardinal): TFuture;
var
  LValue: TValue;
  LSelf: PAsync;
  LMessage: String;
begin
  LSelf := @Self;
  FLock.Acquire;
  try
    try
      FTask := TTask.Run(procedure
                         begin
                           try
                             LValue := LSelf^.FFunc();
                           except
                             on E: Exception do
                               LMessage := E.Message;
                           end;
                         end);
      FTask.Wait(ATimeout);
      if LMessage <> '' then
        raise EAsyncAwait.Create(LMessage);

      if Assigned(AContinue) then
        TThread.Queue(TThread.CurrentThread,
                      procedure
                      begin
                        try
                          AContinue();
                        except
                          on E: Exception do
                            LMessage := E.Message;
                        end;
                      end);
      if LMessage <> '' then
        raise EAsyncAwait.Create(LMessage);

      Result.SetOk(LValue);
    except
      on E: Exception do
        Result.SetErr(E.Message);
    end;
  finally
    FLock.Release;
  end;
end;

function TAsync._AwaitFunc(const ATimeout: Cardinal): TFuture;
var
  LValue: TValue;
  LSelf: PAsync;
  LMessage: String;
begin
  LSelf := @Self;
  FLock.Acquire;
  try
    try
      FTask := TTask.Run(procedure
                         begin
                           try
                             LValue := LSelf^.FFunc();
                           except
                             on E: Exception do
                               LMessage := E.Message;
                           end;
                         end);
      FTask.Wait(ATimeout);
      if LMessage <> '' then
        raise EAsyncAwait.Create(LMessage);

      Result.SetOk(LValue);
    except
      on E: Exception do
        Result.SetErr(E.Message);
    end;
  finally
    FLock.Release;
  end;
end;

function TAsync._AwaitProc(const ATimeout: Cardinal): TFuture;
var
  LSelf: PAsync;
  LMessage: String;
begin
  LSelf := @Self;
  FLock.Acquire;
  try
    try
      FTask := TTask.Run(procedure
                         begin
                           try
                             LSelf^.FProc();
                           except
                             on E: Exception do
                               LMessage := E.Message;
                           end;
                         end);
      FTask.Wait(ATimeout);
      if LMessage <> '' then
        raise EAsyncAwait.Create(LMessage);

      Result.SetOk(True);
    except
      on E: Exception do
        Result.SetErr(E.Message);
    end;
  finally
    FLock.Release;
  end;
end;

{ TCriticalSectionHelper }

procedure TAutoLock.Acquire;
begin
  FCriticalSection.Acquire;
end;

constructor TAutoLock.Create;
begin
  inherited Create;
  FCriticalSection := TCriticalSection.Create;
end;

destructor TAutoLock.Destroy;
begin
  FCriticalSection.Free;
  inherited;
end;

procedure TAutoLock.Release;
begin
  FCriticalSection.Release;
end;

end.
