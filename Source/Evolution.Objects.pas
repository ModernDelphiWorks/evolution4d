{
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

unit Evolution.Objects;

{$I .\evolution4d.inc}

interface

uses
  Rtti,
  TypInfo,
  SysUtils,
  Classes,
  Variants,
  SyncObjs,
  Generics.Collections;

type
  TArrayValue = array of TValue;

  /// <summary>
  /// Interface for a factory that creates objects dynamically using RTTI.
  /// </summary>
  IEvolutoinObject = interface
    ['{486D1BA3-6AEE-46A6-A845-D5154BEBE31C}']
    /// <summary>
    /// Creates an instance of a class using its default constructor.
    /// </summary>
    /// <param name="AClass">The class type to instantiate.</param>
    /// <returns>The created object instance.</returns>
    function Factory(const AClass: TClass): TObject; overload;

    /// <summary>
    /// Creates an instance of a class using a specific constructor with arguments.
    /// </summary>
    /// <param name="AClass">The class type to instantiate.</param>
    /// <param name="AArgs">Array of arguments to pass to the constructor.</param>
    /// <param name="AMethodName">The name of the constructor method to invoke.</param>
    /// <returns>The created object instance.</returns>
    function Factory(const AClass: TClass; const AArgs: TArrayValue;
      const AMethodName: String): TObject; overload;
  end;

  /// <summary>
  /// Sealed class implementing IObject, providing RTTI-based object creation.
  /// Uses a singleton TRttiContext for efficiency.
  /// </summary>
  TEvolutionObject = class sealed(TInterfacedObject, IEvolutoinObject)
  strict private
    /// <summary>
    /// Singleton RTTI context used for reflection operations.
    /// </summary>
    class var FContext: TRttiContext;

    /// <summary>
    /// Global critical section to ensure thread-safe initialization of AutoRef locks.
    /// </summary>
    class var FAutoRefLock: TCriticalSection;
  protected
    /// <summary>
    /// Provides access to the global critical section for AutoRef initialization.
    /// </summary>
    /// <returns>The global TCriticalSection instance.</returns>
    class function AutoRefLock: TCriticalSection; static;

    /// <summary>
    /// Initializes the RTTI context and global lock.
    /// Called during unit initialization.
    /// </summary>
    class procedure InitializeContext; static;

    /// <summary>
    /// Finalizes the RTTI context and global lock.
    /// Called during unit finalization.
    /// </summary>
    class procedure FinalizeContext; static;

    class function Context: TRttiContext; static;
  public
    /// <summary>
    /// Default constructor for TObjectEx.
    /// </summary>
    constructor Create;

    /// <summary>
    /// Destructor for TObjectEx, ensures proper cleanup.
    /// </summary>
    destructor Destroy; override;

    /// <summary>
    /// Creates a new instance of TObjectEx as an IObject interface.
    /// </summary>
    /// <returns>An IObject instance.</returns>
    class function New: IEvolutoinObject;

    /// <summary>
    /// Creates an instance of a class using its default constructor.
    /// </summary>
    /// <param name="AClass">The class type to instantiate.</param>
    /// <returns>The created object instance.</returns>
    function Factory(const AClass: TClass): TObject; overload;

    /// <summary>
    /// Creates an instance of a class using a specific constructor with arguments.
    /// </summary>
    /// <param name="AClass">The class type to instantiate.</param>
    /// <param name="AArgs">Array of arguments to pass to the constructor.</param>
    /// <param name="AMethodName">The name of the constructor method to invoke.</param>
    /// <returns>The created object instance.</returns>
    function Factory(const AClass: TClass; const AArgs: TArrayValue;
      const AMethodName: String): TObject; overload;

    /// <summary>
    /// Creates an instance of an interface type using its default constructor.
    /// </summary>
    /// <returns>The created interface instance.</returns>
    function Factory<T: IInterface>: T; overload;
  end;

  /// <summary>
  /// Interface for a smart pointer that manages object lifetime and state.
  /// </summary>
  ISmartPtr<T> = interface
    ['{57FF7863-CE3E-4FE6-89BE-99539495CDB7}']
    /// <summary>
    /// Checks if the managed object is null.
    /// </summary>
    /// <returns>True if the object is null, False otherwise.</returns>
    function IsNull: Boolean;

    /// <summary>
    /// Checks if the managed object is loaded and valid.
    /// </summary>
    /// <returns>True if the object is loaded, False otherwise.</returns>
    function IsLoaded: Boolean;
  end;

  /// <summary>
  /// Interface for a lock mechanism used in AutoRef to ensure thread safety.
  /// </summary>
  IAutoRefLock = interface
    ['{4D666831-0735-4EF7-9977-06CF47C33ED6}']
    /// <summary>
    /// Acquires the lock for thread-safe operations.
    /// </summary>
    procedure Acquire;

    /// <summary>
    /// Releases the lock after thread-safe operations.
    /// </summary>
    procedure Release;
  end;

  /// <summary>
  /// Class implementing IAutoRefLock, providing a thread-safe critical section.
  /// </summary>
  TAutoRefLock = class(TInterfacedObject, IAutoRefLock)
  private
    FAutoRefLock: TCriticalSection;
  public
    /// <summary>
    /// Creates a new TAutoRefLock instance with an internal critical section.
    /// </summary>
    constructor Create;

    /// <summary>
    /// Destroys the TAutoRefLock instance, freeing the critical section.
    /// </summary>
    destructor Destroy; override;

    /// <summary>
    /// Acquires the critical section lock.
    /// </summary>
    procedure Acquire;

    /// <summary>
    /// Releases the critical section lock.
    /// </summary>
    procedure Release;
  end;

  /// <summary>
  /// A record-based smart pointer that manages object lifetime with lazy loading
  /// and thread-safe initialization. Provides modern features like pattern matching
  /// and scoped execution.
  /// </summary>
  TSmartPtr<T: class, constructor> = record
  strict private
    /// <summary>
    /// The managed object instance, created lazily on first access.
    /// </summary>
    FValue: T;

    /// <summary>
    /// Internal smart pointer managing the object's lifetime.
    /// </summary>
    FSmartPtr: ISmartPtr<T>;

    /// <summary>
    /// Thread-safe lock for managing object initialization.
    /// </summary>
    FAutoRefLock: IAutoRefLock;

    /// <summary>
    /// RTTI-based factory for creating object instances.
    /// </summary>
    FObjectEx: IEvolutoinObject;

    /// <summary>
    /// Internal method to retrieve the managed object, initializing it if necessary.
    /// </summary>
    /// <returns>The managed object instance.</returns>
    function _GetAsRef: T;
  strict private
    type
      /// <summary>
      /// Internal class implementing ISmartPtr for object lifetime management.
      /// </summary>
      TSmartPtr = class(TInterfacedObject, ISmartPtr<T>)
      private
        FValue: TObject;
        FIsLoaded: Boolean;
      public
        constructor Create(const AObjectRef: TObject);
        destructor Destroy; override;
        function IsNull: Boolean;
        function IsLoaded: Boolean;
      end;
  public
    /// <summary>
    /// Creates an AutoRef instance with an optional initial object.
    /// </summary>
    /// <param name="AObjectRef">The object to manage, or nil for lazy initialization.</param>
    constructor Create(const AObjectRef: T);

    /// <summary>
    /// Implicit conversion from an object to an AutoRef instance.
    /// </summary>
    class operator Implicit(const AObjectRef: T): TSmartPtr<T>;

    /// <summary>
    /// Implicit conversion from an AutoRef instance to its managed object.
    /// </summary>
    class operator Implicit(const AAutoRef: TSmartPtr<T>): T;

    /// <summary>
    /// Checks if the managed object is null.
    /// </summary>
    /// <returns>True if null, False otherwise.</returns>
    function IsNull: Boolean;

    /// <summary>
    /// Checks if the managed object is loaded and valid.
    /// </summary>
    /// <returns>True if loaded, False otherwise.</returns>
    function IsLoaded: Boolean;

    /// <summary>
    /// Performs pattern matching on the managed object, executing a function based on its state.
    /// </summary>
    /// <param name="ANullFunc">Function to execute if the object is null.</param>
    /// <param name="AValidFunc">Function to execute if the object is valid.</param>
    /// <returns>The result of the executed function.</returns>
    function Match<R>(const ANullFunc: TFunc<R>; const AValidFunc: TFunc<T, R>): R;

    /// <summary>
    /// Executes an action with the managed object, ensuring it is released afterward.
    /// </summary>
    /// <param name="AAction">The action to perform with the object.</param>
    procedure Scoped(const AAction: TProc<T>);

    /// <summary>
    /// Property to access the managed object, initializing it lazily if needed.
    /// </summary>
    property AsRef: T read _GetAsRef;
  end;

//  TImmutableHook = class
//  private
//    FInstance: TObject;
//    FOriginalSetters: TDictionary<string, Pointer>;
//    FContext: TRttiContext;
//    procedure _HookAllSetters;
//    procedure _RestoreAllSetters;
//  public
//    constructor Create(AInstance: TObject);
//    destructor Destroy; override;
//    function GetProperty(const APropertyName: string): TValue;
//  end;

  TMutableRef<T> = record
  strict private
    FValue: TValue;
    FSmartPtr: ISmartPtr<T>;
    FAutoRefLock: IAutoRefLock;
    FObjectEx: IEvolutoinObject;
    FIsMutable: Boolean;
    function _GetAsRef: T;
  strict private
    type
      TSmartPtr = class(TInterfacedObject, ISmartPtr<T>)
      private
        FValue: TValue;
        FIsLoaded: Boolean;
//        FImmutableHook: TImmutableHook;
      public
        constructor Create(const AValue: TValue);
        destructor Destroy; override;
        function IsNull: Boolean;
        function IsLoaded: Boolean;
      end;
  public
    constructor Create(const AValueRef: T; const AMutable: Boolean = False); overload;
    class operator Implicit(const AValueRef: T): TMutableRef<T>;
    class operator Implicit(const AAutoRef: TMutableRef<T>): T;
    function IsNull: Boolean;
    function IsLoaded: Boolean;
    function IsMutable: Boolean;
    function Match<R>(const ANullFunc: TFunc<R>; const AValidFunc: TFunc<T, R>): R;
    procedure Scoped(const AAction: TFunc<T, TValue>);
    property AsRef: T read _GetAsRef;
  end;

procedure BlockedSetter(const Value: Variant);

implementation

uses
  Windows;

procedure BlockedSetter(const Value: Variant);
begin
  raise Exception.Create('Property is immutable');
end;


{ TObjectEx }

class function TEvolutionObject.AutoRefLock: TCriticalSection;
begin
  Result := FAutoRefLock;
end;

class function TEvolutionObject.Context: TRttiContext;
begin
  Result := FContext;
end;

constructor TEvolutionObject.Create;
begin

end;

destructor TEvolutionObject.Destroy;
begin
  inherited;
end;

class procedure TEvolutionObject.InitializeContext;
begin
  FContext := TRttiContext.Create;
  FAutoRefLock := TCriticalSection.Create;
end;

class procedure TEvolutionObject.FinalizeContext;
begin
  FAutoRefLock.Free;
  FContext.Free;
end;

class function TEvolutionObject.New: IEvolutoinObject;
begin
  Result := TEvolutionObject.Create;
end;

function TEvolutionObject.Factory(const AClass: TClass): TObject;
begin
  Result := Factory(AClass, [], 'Create');
end;

function TEvolutionObject.Factory(const AClass: TClass; const AArgs: TArrayValue;
  const AMethodName: String): TObject;
var
  LConstructor: TRttiMethod;
  LInstance: TValue;
  LType: TRttiType;
begin
  LType := FContext.GetType(AClass);
  LConstructor := LType.GetMethod(AMethodName);
  if LConstructor = nil then
    raise Exception.CreateFmt('Constructor "%s" not found in class %s', [AMethodName, AClass.ClassName]);
  try
    LInstance := LConstructor.Invoke(LType.AsInstance.MetaClassType, AArgs);
    Result := LInstance.AsObject;
  except
    on E: Exception do
      raise Exception.CreateFmt('Failed to invoke constructor "%s" in class %s: %s', [AMethodName, AClass.ClassName, E.Message]);
  end;
end;

function TEvolutionObject.Factory<T>: T;
var
  LType: TRttiType;
  LInstance: TValue;
begin
  LType := FContext.GetType(TypeInfo(T));
  LInstance := LType.GetMethod('Create').Invoke(LType.AsInstance.MetaClassType, []);
  Result := LInstance.AsType<T>;
end;

{ AutoRef<T>.TSmartPtr }

constructor TSmartPtr<T>.TSmartPtr.Create(const AObjectRef: TObject);
begin
  FValue := AObjectRef;
  FIsLoaded := Assigned(FValue);
end;

destructor TSmartPtr<T>.TSmartPtr.Destroy;
begin
  if Assigned(FValue) then
    FValue.Free;
  inherited;
end;

function TSmartPtr<T>.TSmartPtr.IsNull: Boolean;
begin
  Result := FValue = nil;
end;

function TSmartPtr<T>.TSmartPtr.IsLoaded: Boolean;
begin
  Result := FIsLoaded;
end;

{ AutoRef<T> }

constructor TSmartPtr<T>.Create(const AObjectRef: T);
begin
  FValue := AObjectRef;
  if Assigned(FValue) then
    FSmartPtr := TSmartPtr.Create(FValue);
  FObjectEx := TEvolutionObject.New;
  FAutoRefLock := TAutoRefLock.Create;
end;

function TSmartPtr<T>._GetAsRef: T;
begin
  if not Assigned(FAutoRefLock) then
  begin
    TEvolutionObject.AutoRefLock.Acquire;
    try
      if not Assigned(FAutoRefLock) then
        FAutoRefLock := TAutoRefLock.Create;
    finally
      TEvolutionObject.AutoRefLock.Release;
    end;
  end;

  FAutoRefLock.Acquire;
  try
    if (FSmartPtr = nil) or FSmartPtr.IsNull then
    begin
      if FObjectEx = nil then
        FObjectEx := TEvolutionObject.New;
      FValue := FObjectEx.Factory(T) as T;
      FSmartPtr := TSmartPtr.Create(FValue);
    end;
    Result := FValue;
  finally
    FAutoRefLock.Release;
  end;
end;

class operator TSmartPtr<T>.Implicit(const AObjectRef: T): TSmartPtr<T>;
begin
  Result := TSmartPtr<T>.Create(AObjectRef);
end;

class operator TSmartPtr<T>.Implicit(const AAutoRef: TSmartPtr<T>): T;
begin
  Result := AAutoRef.AsRef;
end;

function TSmartPtr<T>.IsNull: Boolean;
begin
  Result := True;
  if FSmartPtr = nil then
    Exit;
  Result := FSmartPtr.IsNull;
end;

function TSmartPtr<T>.IsLoaded: Boolean;
begin
  Result := (FSmartPtr <> nil) and FSmartPtr.IsLoaded;
end;

function TSmartPtr<T>.Match<R>(const ANullFunc: TFunc<R>; const AValidFunc: TFunc<T, R>): R;
begin
  if IsNull then
    Result := ANullFunc()
  else
    Result := AValidFunc(AsRef);
end;

procedure TSmartPtr<T>.Scoped(const AAction: TProc<T>);
begin
  try
    AAction(AsRef);
  finally
    FSmartPtr := nil;
  end;
end;

{ TAutoRefLock }

procedure TAutoRefLock.Acquire;
begin
  FAutoRefLock.Acquire;
end;

constructor TAutoRefLock.Create;
begin
  FAutoRefLock := TCriticalSection.Create;
end;

destructor TAutoRefLock.Destroy;
begin
  FAutoRefLock.Free;
  inherited;
end;

procedure TAutoRefLock.Release;
begin
  FAutoRefLock.Release;
end;

{ MutableRef<T> }

constructor TMutableRef<T>.Create(const AValueRef: T; const AMutable: Boolean);
begin
  FIsMutable := AMutable;
  FValue := TValue.From<T>(AValueRef);
  FSmartPtr := TSmartPtr.Create(FValue);
  FObjectEx := TEvolutionObject.New;
  FAutoRefLock := TAutoRefLock.Create;
end;

class operator TMutableRef<T>.Implicit(const AValueRef: T): TMutableRef<T>;
begin
  if Result.IsLoaded then
    if not Result.IsMutable then
      raise Exception.Create('Attempt to modify an immutable value.');
  Result := TMutableRef<T>.Create(AValueRef);
end;

class operator TMutableRef<T>.Implicit(const AAutoRef: TMutableRef<T>): T;
begin
  if AAutoRef.IsLoaded then
    if not AAutoRef.IsMutable then
      raise Exception.Create('Attempt to modify an immutable value.');
  Result := AAutoRef.AsRef;
end;

function TMutableRef<T>.IsLoaded: Boolean;
begin
  Result := (FSmartPtr <> nil) and FSmartPtr.IsLoaded;
end;

function TMutableRef<T>.IsMutable: Boolean;
begin
  Result := FIsMutable;
end;

function TMutableRef<T>.IsNull: Boolean;
begin
  Result := True;
  if FSmartPtr = nil then
    Exit;
  Result := FSmartPtr.IsNull;
end;

function TMutableRef<T>.Match<R>(const ANullFunc: TFunc<R>; const AValidFunc: TFunc<T, R>): R;
begin
  if IsNull then
    Result := ANullFunc()
  else
    Result := AValidFunc(AsRef);
end;

procedure TMutableRef<T>.Scoped(const AAction: TFunc<T, TValue>);
begin
  if IsNull then
    Exit;
  if not FIsMutable then
    raise Exception.Create('Attempt to modify an immutable value.');
  FValue := AAction(FValue.AsType<T>);
end;

function TMutableRef<T>._GetAsRef: T;
var
  LType: TRttiType;
begin
  if not Assigned(FAutoRefLock) then
  begin
    TEvolutionObject.AutoRefLock.Acquire;
    try
      if not Assigned(FAutoRefLock) then
        FAutoRefLock := TAutoRefLock.Create;
    finally
      TEvolutionObject.AutoRefLock.Release;
    end;
  end;

  FAutoRefLock.Acquire;
  try
    if (FSmartPtr = nil) or FSmartPtr.IsNull then
    begin
      if FValue.IsEmpty then
      begin
        if FObjectEx = nil then
          FObjectEx := TEvolutionObject.New;
        LType := TEvolutionObject.Context.GetType(TypeInfo(T));
        if LType.IsInstance then
        begin
          FValue := FObjectEx.Factory(LType.AsInstance.MetaclassType);
          FIsMutable := False;
        end
        else
          raise Exception.Create('MutableRef<T> can only create instances of class types');
      end;
      FSmartPtr := TSmartPtr.Create(FValue);
    end;
    Result := FValue.AsType<T>;
  finally
    FAutoRefLock.Release;
  end;
end;

{ MutableRef<T>.TSmartPtr }

constructor TMutableRef<T>.TSmartPtr.Create(const AValue: TValue);
begin
  FValue := AValue;
  FIsLoaded := not FValue.IsEmpty;
//  if PTypeInfo(TypeInfo(T))^.Kind = tkClass then
//    FImmutableHook := TImmutableHook.Create(AValue.AsObject);
end;

destructor TMutableRef<T>.TSmartPtr.Destroy;
begin
  if PTypeInfo(TypeInfo(T))^.Kind = tkClass then
  begin
    if not FValue.IsEmpty then
      TObject(FValue.AsObject).Free;
  end;
//  if Assigned(FImmutableHook) then
//    FImmutableHook.Free;
  inherited;
end;

function TMutableRef<T>.TSmartPtr.IsLoaded: Boolean;
begin
  Result := FIsLoaded;
end;

function TMutableRef<T>.TSmartPtr.IsNull: Boolean;
begin
  Result := FValue.IsEmpty;
end;

{ TImmutableHook }

//constructor TImmutableHook.Create(AInstance: TObject);
//begin
//  FInstance := AInstance;
//  FContext := TRttiContext.Create;
//  FOriginalSetters := TDictionary<string, Pointer>.Create;
//  _HookAllSetters;
//end;
//
//destructor TImmutableHook.Destroy;
//begin
//  _RestoreAllSetters;
//  FOriginalSetters.Free;
//  FContext.Free;
//  inherited;
//end;
//
//function TImmutableHook.GetProperty(const APropertyName: string): TValue;
//var
//  RttiType: TRttiType;
//  Prop: TRttiProperty;
//begin
//  RttiType := FContext.GetType(FInstance.ClassType);
//  Prop := RttiType.GetProperty(APropertyName);
//  if Assigned(Prop) then
//    Result := Prop.GetValue(FInstance)
//  else
//    raise Exception.CreateFmt('Propriedade "%s" não encontrada', [APropertyName]);
//end;
//
//procedure TImmutableHook._HookAllSetters;
//var
//  RttiType: TRttiType;
//  Prop: TRttiProperty;
//  Method: TRttiMethod;
//  MethodAddress: Pointer;
//  NewMethod: Pointer;
//  OldProtect: DWORD;
//  SetterName: string;
//begin
//  RttiType := FContext.GetType(FInstance.ClassType);
//  for Prop in RttiType.GetProperties do
//  begin
//    if Prop.IsWritable then
//    begin
//      SetterName := '_Set' + Prop.Name;
//      Method := RttiType.GetMethod(SetterName);
//      if Assigned(Method) then
//      begin
//        MethodAddress := Method.CodeAddress;
//        FOriginalSetters.Add(SetterName, MethodAddress);
//        NewMethod := @BlockedSetter;
//
//        if VirtualProtect(MethodAddress, SizeOf(Pointer), PAGE_EXECUTE_READWRITE, OldProtect) then
//        try
//          PPointer(MethodAddress)^ := NewMethod;
//        finally
//          VirtualProtect(MethodAddress, SizeOf(Pointer), OldProtect, OldProtect);
//        end
//        else
//          raise Exception.Create('Failed to hook setter for ' + Prop.Name);
//      end
//      else
//        raise Exception.Create('Setter ' + SetterName + ' not found for property ' + Prop.Name);
//    end;
//  end;
//end;
//
//procedure TImmutableHook._RestoreAllSetters;
//var
//  RttiType: TRttiType;
//  Method: TRttiMethod;
//  MethodAddress: Pointer;
//  OldProtect: DWORD;
//  SetterPair: TPair<string, Pointer>;
//begin
//  RttiType := FContext.GetType(FInstance.ClassType);
//  for SetterPair in FOriginalSetters do
//  begin
//    Method := RttiType.GetMethod(SetterPair.Key);
//    if Assigned(Method) then
//    begin
//      MethodAddress := Method.CodeAddress;
//      if VirtualProtect(MethodAddress, SizeOf(Pointer), PAGE_EXECUTE_READWRITE, OldProtect) then
//      try
//        PPointer(MethodAddress)^ := SetterPair.Value;
//      finally
//        VirtualProtect(MethodAddress, SizeOf(Pointer), OldProtect, OldProtect);
//      end;
//    end;
//  end;
//end;

initialization
  TEvolutionObject.InitializeContext;

finalization
  TEvolutionObject.FinalizeContext;

end.
