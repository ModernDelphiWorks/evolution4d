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

unit ecl.iterator;

interface

uses
  Rtti,
  Classes,
  SysUtils,
  Generics.Collections,
  Generics.Defaults;

type
  TAction<T> = reference to procedure(const AArg: T);
  TConverterFunc<T, TResult> = reference to function(const AItem: T; out AResult: TResult): Boolean;
  IGroupedEnumerator<TKey, T> = interface;

  IEnumEx<T> = interface(IInterface)
    ['{3C56CA46-CE3E-414D-A96E-6CEB933797DA}']
    function GetCurrent: T;
    function MoveNext: Boolean;
    procedure Reset;
    property Current: T read GetCurrent;
  end;

  IArrayEx<T> = interface(IInterface)
    ['{C7D24BE8-B269-432E-A167-2797A708CD18}']
    function GetEnumerator: IEnumEx<T>;
  end;

  IListEx<T> = interface(IInterface)
    ['{B15B8649-8B14-4D3C-9528-DF832A5A9250}']
    function GetEnumerator: IEnumEx<T>;
  end;

  IDictionaryEx<K, V> = interface(IInterface)
    ['{19379211-22BF-42A8-9BD8-E3A826F0C6DF}']
    function GetEnumerator: IEnumEx<TPair<K, V>>;
  end;

  // Interface para auto-gerenciamento de memória das classes "lazy" de listas
  IListLazyEnumerable<T> = interface(IInterface)
    ['{1BDF18BC-35EF-47E6-A28E-7F65B4A81C3F}']
    function GetEnumerator: IEnumEx<T>;
  end;

  // Interface para auto-gerenciamento de memória das classes "lazy" de dicionários
  IDictLazyEnumerable<K, V> = interface(IInterface)
    ['{8E1EAEBB-D1BD-438F-AE7E-818278C8C3DA}']
    function GetEnumerator: IEnumEx<TPair<K, V>>;
  end;

  // Record simulando interface para coleções enumeráveis de listas
  IListEnumerable<T> = record
  private
    FEnumerator: IListLazyEnumerable<T>;
  public
    constructor Create(AEnumerator: IListLazyEnumerable<T>);
    function GetEnumerator: IEnumEx<T>;
    function Map<TResult>(const ASelector: TFunc<T, TResult>): IListEnumerable<TResult>;
    function OfType<TResult>(const AConverter: TConverterFunc<T, TResult>): IListEnumerable<TResult>;
    function GroupBy<TKey>(const AKeySelector: TFunc<T, TKey>): IGroupedEnumerator<TKey, T>;
    function Zip<TSecond, TResult>(const ASecond: IListEnumerable<TSecond>;
      const AResultSelector: TFunc<T, TSecond, TResult>): IListEnumerable<TResult>;
    function Join<TInner, TKey, TResult>(const AInner: IListEnumerable<TInner>;
      const AOuterKeySelector: TFunc<T, TKey>; const AInnerKeySelector: TFunc<TInner, TKey>;
      const AResultSelector: TFunc<T, TInner, TResult>): IListEnumerable<TResult>;
    function MinBy<TKey>(const AKeySelector: TFunc<T, TKey>;
      const AComparer: TFunc<TKey, TKey, Integer>): T;
    function MaxBy<TKey>(const AKeySelector: TFunc<T, TKey>;
      const AComparer: TFunc<TKey, TKey, Integer>): T;
    function Filter(const APredicate: TFunc<T, Boolean>): IListEnumerable<T>;
    function Take(const ACount: Integer): IListEnumerable<T>;
    function Skip(const ACount: Integer): IListEnumerable<T>;
    function Distinct: IListEnumerable<T>;
    function FlatMap<TResult>(const AFunc: TFunc<T, TArray<TResult>>): IListEnumerable<TResult>;
    function Reduce(const AReducer: TFunc<T, T, T>; const AInitialValue: T): T; overload;
    function Reduce(const AReducer: TFunc<T, T, T>): T; overload;
    procedure ForEach(const AAction: TAction<T>);
    function Sum(const ASelector: TFunc<T, Double>): Double; overload;
    function Sum(const ASelector: TFunc<T, Integer>): Integer; overload;
    function Min(const AComparer: TFunc<T, T, Integer>): T; overload;
    function Min: T; overload;
    function Max(const AComparer: TFunc<T, T, Integer>): T; overload;
    function Max: T; overload;
    function Any(const APredicate: TFunc<T, Boolean>): Boolean;
    function FirstOrDefault(const APredicate: TFunc<T, Boolean>): T;
    function Last(const APredicate: TFunc<T, Boolean>): T;
    function LastOrDefault(const APredicate: TFunc<T, Boolean>): T;
    function Count(const APredicate: TFunc<T, Boolean>): Integer;
    function LongCount(const APredicate: TFunc<T, Boolean>): Int64;
    function ToArray: TArray<T>;
    function ToList: TList<T>;
    function ToDictionary<TKey, TValue>(const AKeySelector: TFunc<T, TKey>;
      const AValueSelector: TFunc<T, TValue>): TDictionary<TKey, TValue>;
//    function SelectMany<TResult>(const ASelector: TFunc<T, IListEnumerable<TResult>>): IListEnumerable<TResult>;
//    function GroupJoin<TInner, TKey, TResult>(const AInner: IListEnumerable<TInner>;
//      const AOuterKeySelector: TFunc<T, TKey>; const AInnerKeySelector: TFunc<TInner, TKey>;
//      const AResultSelector: TFunc<T, IListEnumerable<TInner>, TResult>): IListEnumerable<TResult>;
    function TakeWhile(const APredicate: TFunc<T, Boolean>): IListEnumerable<T>;
    function SkipWhile(const APredicate: TFunc<T, Boolean>): IListEnumerable<T>;
    function Average(const ASelector: TFunc<T, Double>): Double;
    function Exclude(const ASecond: IListEnumerable<T>): IListEnumerable<T>;
    function Intersect(const ASecond: IListEnumerable<T>): IListEnumerable<T>;
    function Union(const ASecond: IListEnumerable<T>): IListEnumerable<T>;
    function Concat(const ASecond: IListEnumerable<T>): IListEnumerable<T>;
    function All(const APredicate: TFunc<T, Boolean>): Boolean;
    function Contains(const AValue: T): Boolean;
    function SequenceEqual(const ASecond: IListEnumerable<T>): Boolean;
    function Single(const APredicate: TFunc<T, Boolean>): T;
    function SingleOrDefault(const APredicate: TFunc<T, Boolean>): T;
    function ElementAt(const AIndex: Integer): T;
    function ElementAtOrDefault(const AIndex: Integer): T;
    function OrderBy(const AComparer: TFunc<T, T, Integer>): IListEnumerable<T>;
    function OrderByDesc(const AComparer: TFunc<T, T, Integer>): IListEnumerable<T>;
  end;

  IDictEnumerable<K, V> = record
  private
    FEnumerator: IDictLazyEnumerable<K, V>;
  public
    constructor Create(AEnumerator: IDictLazyEnumerable<K, V>);
    procedure ForEach(const AAction: TAction<TPair<K, V>>);
    function GetEnumerator: IEnumEx<TPair<K, V>>;
    function Filter(const APredicate: TFunc<TPair<K, V>, Boolean>): IDictEnumerable<K, V>;
    function Take(const ACount: Integer): IDictEnumerable<K, V>;
    function Skip(const ACount: Integer): IDictEnumerable<K, V>;
    function OrderBy(const AComparer: TFunc<TPair<K, V>, TPair<K, V>, Integer>): IDictEnumerable<K, V>; overload;
    function OrderBy: IDictEnumerable<K, V>; overload;
    function Distinct: IDictEnumerable<K, V>;
    function Reduce(const AReducer: TFunc<TPair<K, V>, TPair<K, V>, TPair<K, V>>; const AInitialValue: TPair<K, V>): TPair<K, V>; overload;
    function Reduce(const AReducer: TFunc<TPair<K, V>, TPair<K, V>, TPair<K, V>>): TPair<K, V>; overload;
    function Sum(const ASelector: TFunc<TPair<K, V>, Double>): Double; overload;
    function Sum(const ASelector: TFunc<TPair<K, V>, Integer>): Integer; overload;
    function Min(const AComparer: TFunc<TPair<K, V>, TPair<K, V>, Integer>): TPair<K, V>; overload;
    function Min: TPair<K, V>; overload;
    function Max(const AComparer: TFunc<TPair<K, V>, TPair<K, V>, Integer>): TPair<K, V>; overload;
    function Max: TPair<K, V>; overload;
    function Any(const APredicate: TFunc<TPair<K, V>, Boolean>): Boolean;
    function FirstOrDefault(const APredicate: TFunc<TPair<K, V>, Boolean>): TPair<K, V>;
    function Last(const APredicate: TFunc<TPair<K, V>, Boolean>): TPair<K, V>;
    function LastOrDefault(const APredicate: TFunc<TPair<K, V>, Boolean>): TPair<K, V>;
    function Count(const APredicate: TFunc<TPair<K, V>, Boolean>): Integer;
    function LongCount(const APredicate: TFunc<TPair<K, V>, Boolean>): Int64;
    function ToArray: TArray<TPair<K, V>>;
    function ToList: TList<TPair<K, V>>;
    function ToDictionary: TDictionary<K, V>;
    function Map(const AMappingFunc: TFunc<V, V>): IDictEnumerable<K, V>; overload;
    function Map<R>(const AMappingFunc: TFunc<V, R>): IDictEnumerable<K, R>; overload;
    function Map(const AMappingFunc: TFunc<K, V, V>): IDictEnumerable<K, V>; overload;
    function Map<R>(const AMappingFunc: TFunc<K, V, R>): IDictEnumerable<K, R>; overload;
    function GroupBy<TKey>(const AKeySelector: TFunc<TPair<K, V>, TKey>): IGroupedEnumerator<TKey, TPair<K, V>>;
    function Zip<VR, KR>(const AList: IDictEnumerable<K, VR>;
      const AFunc: TFunc<V, VR, KR>): IDictEnumerable<K, KR>;
    function FlatMap<R>(const AFunc: TFunc<V, TArray<R>>): IDictEnumerable<K, R>;
    function Intersect(const AOtherDict: IDictEnumerable<K, V>): IDictEnumerable<K, V>;
    function Exclude(const AOtherDict: IDictEnumerable<K, V>): IDictEnumerable<K, V>;
    function DistinctBy<TKey>(const AKeySelector: TFunc<K, TKey>): IDictEnumerable<TKey, V>;
    function TakeWhile(const APredicate: TPredicate<K>): IDictEnumerable<K, V>;
    function SkipWhile(const APredicate: TPredicate<K>): IDictEnumerable<K, V>;
  end;

  // Interface para listas
  IList<T> = interface(IInterface)
    ['{7CC49CDB-FCED-477A-BE42-F7DE4450A6B3}']
    function AsEnumerable: IListEnumerable<T>;
  end;

  // Interface para dicionários
  IDictionary<K, V> = interface(IInterface)
    ['{B5203408-1BA5-44A0-8543-D62C8624ED49}']
    function AsEnumerable: IDictEnumerable<K, V>;
  end;

  // Interface para agrupamentos (GroupBy)
  IGrouping<TKey, T> = interface(IInterface)
    ['{BCFD5B90-20A5-4675-B78F-84B4B9CFE4AD}']
    function GetKey: TKey;
    function GetEnumerator: IEnumEx<T>;
    function ToArray: TArray<T>;
    property Key: TKey read GetKey;
  end;

  // Interface para enumerador de grupos
  IGroupedEnumerator<TKey, T> = interface(IInterface)
    ['{1392AF16-6369-45CA-9FCE-B30BBBB3D7CA}']
    function GetEnumerator: IEnumEx<IGrouping<TKey, T>>;
    function AsEnumerable: IListEnumerable<IGrouping<TKey, T>>;
  end;

  // Base para enumeráveis lazy de listas
  TListLazyEnumerableBase<T> = class abstract(TInterfacedObject, IListLazyEnumerable<T>)
  protected
    function GetEnumerator: IEnumEx<T>; virtual; abstract;
  public
    procedure ForEach(const AAction: TAction<T>); virtual;
    function Filter(const APredicate: TFunc<T, Boolean>): IListEnumerable<T>; virtual;
    function Take(const ACount: Integer): IListEnumerable<T>; virtual;
    function Skip(const ACount: Integer): IListEnumerable<T>; virtual;
    function OrderBy(const AComparer: TFunc<T, T, Integer>): IListEnumerable<T>; virtual;
    function Distinct: IListEnumerable<T>; virtual;
    function Reduce(const AReducer: TFunc<T, T, T>; const AInitialValue: T): T; overload; virtual;
    function Reduce(const AReducer: TFunc<T, T, T>): T; overload; virtual;
    function Sum(const ASelector: TFunc<T, Double>): Double; overload; virtual;
    function Sum(const ASelector: TFunc<T, Integer>): Integer; overload; virtual;
    function Min(const AComparer: TFunc<T, T, Integer>): T; overload; virtual;
    function Min: T; overload; virtual;
    function Max(const AComparer: TFunc<T, T, Integer>): T; overload; virtual;
    function Max: T; overload; virtual;
    function Any(const APredicate: TFunc<T, Boolean>): Boolean; virtual;
    function FirstOrDefault(const APredicate: TFunc<T, Boolean>): T; virtual;
    function Last(const APredicate: TFunc<T, Boolean>): T; virtual;
    function LastOrDefault(const APredicate: TFunc<T, Boolean>): T; virtual;
    function Count(const APredicate: TFunc<T, Boolean>): Integer; virtual;
    function LongCount(const APredicate: TFunc<T, Boolean>): Int64; virtual;
    function ToArray: TArray<T>; virtual;
    function ToList: TList<T>; virtual;
    function GroupBy<TKey>(const AKeySelector: TFunc<T, TKey>): IGroupedEnumerator<TKey, T>;
  end;

  // Base para enumeráveis lazy de dicionários
  TDictLazyEnumerableBase<K, V> = class abstract(TInterfacedObject, IDictLazyEnumerable<K, V>)
  protected
    function GetEnumerator: IEnumEx<TPair<K, V>>; virtual; abstract;
  public
    procedure ForEach(const AAction: TAction<TPair<K, V>>); virtual;
    function Filter(const APredicate: TFunc<TPair<K, V>, Boolean>): IDictEnumerable<K, V>; virtual;
    function Take(const ACount: Integer): IDictEnumerable<K, V>; virtual;
    function Skip(const ACount: Integer): IDictEnumerable<K, V>; virtual;
    function OrderBy: IDictEnumerable<K, V>; overload; virtual; abstract;
    function OrderBy(const AComparer: TFunc<TPair<K, V>, TPair<K, V>, Integer>): IDictEnumerable<K, V>; overload; virtual;
    function GroupBy<TKey>(const AKeySelector: TFunc<TPair<K, V>, TKey>): IGroupedEnumerator<TKey, TPair<K, V>>;
    function Distinct: IDictEnumerable<K, V>; virtual;
    function Reduce(const AReducer: TFunc<TPair<K, V>, TPair<K, V>, TPair<K, V>>; const AInitialValue: TPair<K, V>): TPair<K, V>; overload; virtual;
    function Reduce(const AReducer: TFunc<TPair<K, V>, TPair<K, V>, TPair<K, V>>): TPair<K, V>; overload; virtual;
    function Sum(const ASelector: TFunc<TPair<K, V>, Double>): Double; overload; virtual;
    function Sum(const ASelector: TFunc<TPair<K, V>, Integer>): Integer; overload; virtual;
    function Min(const AComparer: TFunc<TPair<K, V>, TPair<K, V>, Integer>): TPair<K, V>; overload; virtual;
    function Min: TPair<K, V>; overload; virtual;
    function Max(const AComparer: TFunc<TPair<K, V>, TPair<K, V>, Integer>): TPair<K, V>; overload; virtual;
    function Max: TPair<K, V>; overload; virtual;
    function Any(const APredicate: TFunc<TPair<K, V>, Boolean>): Boolean; virtual;
    function FirstOrDefault(const APredicate: TFunc<TPair<K, V>, Boolean>): TPair<K, V>; virtual;
    function Last(const APredicate: TFunc<TPair<K, V>, Boolean>): TPair<K, V>; virtual;
    function LastOrDefault(const APredicate: TFunc<TPair<K, V>, Boolean>): TPair<K, V>; virtual;
    function Count(const APredicate: TFunc<TPair<K, V>, Boolean>): Integer; virtual;
    function LongCount(const APredicate: TFunc<TPair<K, V>, Boolean>): Int64; virtual;
    function ToArray: TArray<TPair<K, V>>; virtual;
    function ToList: TList<TPair<K, V>>; virtual;
    function ToDictionary: TDictionary<K, V>; virtual;
  end;

//  // Enumeradores lazy
//  TListLazyEnumeratorBase<T> = class(TInterfacedObject, IEnumEx<T>)
//  private
//    [Weak] FSource: IEnumEx<T>;
//    FCurrent: T;
//    FHasNext: Boolean;
//  public
//    constructor Create(const ASource: IEnumEx<T>);
//    destructor Destroy; override;
//    function GetCurrent: T;
//    function MoveNext: Boolean;
//    procedure Reset;
//    property Current: T read GetCurrent;
//  end;

  // Enumerador para Map de listas
  TListLazyMapEnumerator<T, TResult> = class(TInterfacedObject, IEnumEx<TResult>)
  private
    [Weak] FSourceEnum: IEnumEx<T>;
    FSelector: TFunc<T, TResult>;
    FCurrent: TResult;
  public
    constructor Create(const ASourceEnum: IEnumEx<T>; const ASelector: TFunc<T, TResult>);
    destructor Destroy; override;
    function GetCurrent: TResult;
    function MoveNext: Boolean;
    procedure Reset;
    property Current: TResult read GetCurrent;
  end;

  // Enumerable para Map de listas
  TListLazyMapEnumerable<T, TResult> = class(TListLazyEnumerableBase<TResult>)
  private
    FMapEnum: TListLazyMapEnumerator<T, TResult>;
  public
    constructor Create(const AMapEnum: TListLazyMapEnumerator<T, TResult>);
    destructor Destroy; override;
    function GetEnumerator: IEnumEx<TResult>; override;
  end;

  // Enumerador para FlatMap de listas
  TListLazyFlatMapEnumerator<T, TResult> = class(TInterfacedObject, IEnumEx<TResult>)
  private
    [Weak] FSourceEnum: IEnumEx<T>;
    FFunc: TFunc<T, TArray<TResult>>;
    FCurrentArray: TArray<TResult>;
    FCurrentIndex: Integer;
    FCurrent: TResult;
  public
    constructor Create(const ASourceEnum: IEnumEx<T>; const AFunc: TFunc<T, TArray<TResult>>);
    destructor Destroy; override;
    function GetCurrent: TResult;
    function MoveNext: Boolean;
    procedure Reset;
    property Current: TResult read GetCurrent;
  end;

  // Enumerable para FlatMap de listas
  TListLazyFlatMapEnumerable<T, TResult> = class(TListLazyEnumerableBase<TResult>)
  private
    FFlatMapEnum: TListLazyFlatMapEnumerator<T, TResult>;
  public
    constructor Create(const AFlatMapEnum: TListLazyFlatMapEnumerator<T, TResult>);
    destructor Destroy; override;
    function GetEnumerator: IEnumEx<TResult>; override;
  end;

  // Enumerador para GroupJoin de listas
  TListLazyGroupJoinEnumerator<T, TInner, TKey, TResult> = class(TInterfacedObject, IEnumEx<TResult>)
  private
    [Weak] FOuterEnum: IEnumEx<T>;
    FInnerItems: TList<TInner>;
    FOuterKeySelector: TFunc<T, TKey>;
    FInnerKeySelector: TFunc<TInner, TKey>;
    FResultSelector: TFunc<T, IListEnumerable<TInner>, TResult>;
    FOuterCurrent: T;
    FCurrent: TResult;
    FComparer: IEqualityComparer<TKey>;
  public
    constructor Create(const AOuterEnum: IEnumEx<T>; const AInnerItems: TList<TInner>;
      const AOuterKeySelector: TFunc<T, TKey>; const AInnerKeySelector: TFunc<TInner, TKey>;
      const AResultSelector: TFunc<T, IListEnumerable<TInner>, TResult>);
    destructor Destroy; override;
    function GetCurrent: TResult;
    function MoveNext: Boolean;
    procedure Reset;
    property Current: TResult read GetCurrent;
  end;

  // Enumerable para GroupJoin de listas
  TListLazyGroupJoinEnumerable<T, TInner, TKey, TResult> = class(TListLazyEnumerableBase<TResult>)
  private
    FGroupJoinEnum: TListLazyGroupJoinEnumerator<T, TInner, TKey, TResult>;
    FInnerItems: TList<TInner>;
  public
    constructor Create(const AGroupJoinEnum: TListLazyGroupJoinEnumerator<T, TInner, TKey, TResult>;
      const AInnerItems: TList<TInner>);
    destructor Destroy; override;
    function GetEnumerator: IEnumEx<TResult>; override;
  end;

  // Enumerador para TakeWhile de listas
  TListLazyTakeWhileEnumerator<T> = class(TInterfacedObject, IEnumEx<T>)
  private
    [Weak] FSourceEnum: IEnumEx<T>;
    FPredicate: TFunc<T, Boolean>;
    FCurrent: T;
    FDone: Boolean;
  public
    constructor Create(const ASourceEnum: IEnumEx<T>; const APredicate: TFunc<T, Boolean>);
    destructor Destroy; override;
    function GetCurrent: T;
    function MoveNext: Boolean;
    procedure Reset;
    property Current: T read GetCurrent;
  end;

  // Enumerable para TakeWhile de listas
  TListLazyTakeWhileEnumerable<T> = class(TListLazyEnumerableBase<T>)
  private
    FTakeWhileEnum: TListLazyTakeWhileEnumerator<T>;
  public
    constructor Create(const ATakeWhileEnum: TListLazyTakeWhileEnumerator<T>);
    destructor Destroy; override;
    function GetEnumerator: IEnumEx<T>; virtual;
  end;

  // Enumerador para SkipWhile de listas
  TListLazySkipWhileEnumerator<T> = class(TInterfacedObject, IEnumEx<T>)
  private
    [Weak] FSourceEnum: IEnumEx<T>;
    FPredicate: TFunc<T, Boolean>;
    FCurrent: T;
    FSkipping: Boolean;
  public
    constructor Create(const ASourceEnum: IEnumEx<T>; const APredicate: TFunc<T, Boolean>);
    destructor Destroy; override;
    function GetCurrent: T;
    function MoveNext: Boolean;
    procedure Reset;
    property Current: T read GetCurrent;
  end;

  // Enumerable para SkipWhile de listas
  TListLazySkipWhileEnumerable<T> = class(TListLazyEnumerableBase<T>)
  private
    FSkipWhileEnum: TListLazySkipWhileEnumerator<T>;
  public
    constructor Create(const ASkipWhileEnum: TListLazySkipWhileEnumerator<T>);
    destructor Destroy; override;
    function GetEnumerator: IEnumEx<T>; virtual;
  end;

  // Enumerador para Exclude de listas
  TListLazyExcludeEnumerator<T> = class(TInterfacedObject, IEnumEx<T>)
  private
    [Weak] FSourceEnum: IEnumEx<T>;
    [Weak] FExclude: IListLazyEnumerable<T>;
    FCurrent: T;
    FExcludeSet: TDictionary<T, Boolean>;
    FComparer: IEqualityComparer<T>;
  public
    constructor Create(const ASourceEnum: IEnumEx<T>; const AExclude: IListLazyEnumerable<T>);
    destructor Destroy; override;
    function GetCurrent: T;
    function MoveNext: Boolean;
    procedure Reset;
    property Current: T read GetCurrent;
  end;

  // Enumerable para Exclude de listas
  TListLazyExcludeEnumerable<T> = class(TListLazyEnumerableBase<T>)
  private
    FExcludeEnum: TListLazyExcludeEnumerator<T>;
  public
    constructor Create(const AExcludeEnum: TListLazyExcludeEnumerator<T>);
    destructor Destroy; override;
    function GetEnumerator: IEnumEx<T>; virtual;
  end;

  // Enumerador para Intersect de listas
  TListLazyIntersectEnumerator<T> = class(TInterfacedObject, IEnumEx<T>)
  private
    [Weak] FSourceEnum: IEnumEx<T>;
    [Weak] FIntersect: IListLazyEnumerable<T>;
    FCurrent: T;
    FIntersectSet: TDictionary<T, Boolean>;
    FComparer: IEqualityComparer<T>;
  public
    constructor Create(const ASourceEnum: IEnumEx<T>; const AIntersect: IListLazyEnumerable<T>);
    destructor Destroy; override;
    function GetCurrent: T;
    function MoveNext: Boolean;
    procedure Reset;
    property Current: T read GetCurrent;
  end;

  // Enumerable para Intersect de listas
  TListLazyIntersectEnumerable<T> = class(TListLazyEnumerableBase<T>)
  private
    FIntersectEnum: TListLazyIntersectEnumerator<T>;
  public
    constructor Create(const AIntersectEnum: TListLazyIntersectEnumerator<T>);
    destructor Destroy; override;
    function GetEnumerator: IEnumEx<T>; virtual;
  end;

  // Enumerador para Union de listas
  TListLazyUnionEnumerator<T> = class(TInterfacedObject, IEnumEx<T>)
  private
    [Weak] FSourceEnum: IEnumEx<T>;
    [Weak] FSecondEnum: IEnumEx<T>;
    FCurrent: T;
    FSeen: TDictionary<T, Boolean>;
    FComparer: IEqualityComparer<T>;
    FOnSecond: Boolean;
  public
    constructor Create(const ASourceEnum: IEnumEx<T>; const ASecond: IListLazyEnumerable<T>);
    destructor Destroy; override;
    function GetCurrent: T;
    function MoveNext: Boolean;
    procedure Reset;
    property Current: T read GetCurrent;
  end;

  // Enumerable para Union de listas
  TListLazyUnionEnumerable<T> = class(TListLazyEnumerableBase<T>)
  private
    FUnionEnum: TListLazyUnionEnumerator<T>;
  public
    constructor Create(const AUnionEnum: TListLazyUnionEnumerator<T>);
    destructor Destroy; override;
    function GetEnumerator: IEnumEx<T>; virtual;
  end;

  // Enumerador para Concat de listas
  TListLazyConcatEnumerator<T> = class(TInterfacedObject, IEnumEx<T>)
  private
    [Weak] FSourceEnum: IEnumEx<T>;
    [Weak] FSecondEnum: IEnumEx<T>;
    FCurrent: T;
    FOnSecond: Boolean;
  public
    constructor Create(const ASourceEnum: IEnumEx<T>; const ASecond: IListLazyEnumerable<T>);
    destructor Destroy; override;
    function GetCurrent: T;
    function MoveNext: Boolean;
    procedure Reset;
    property Current: T read GetCurrent;
  end;

  // Enumerable para Concat de listas
  TListLazyConcatEnumerable<T> = class(TListLazyEnumerableBase<T>)
  private
    FConcatEnum: TListLazyConcatEnumerator<T>;
  public
    constructor Create(const AConcatEnum: TListLazyConcatEnumerator<T>);
    destructor Destroy; override;
    function GetEnumerator: IEnumEx<T>; virtual;
  end;

  // Enumerador para Zip de listas
  TListLazyZipEnumerator<T, TSecond, TResult> = class(TInterfacedObject, IEnumEx<TResult>)
  private
    [Weak] FEnum1: IEnumEx<T>;
    [Weak] FEnum2: IEnumEx<TSecond>;
    FResultSelector: TFunc<T, TSecond, TResult>;
    FCurrent: TResult;
  public
    constructor Create(const AEnum1: IEnumEx<T>; const AEnum2: IEnumEx<TSecond>; const AResultSelector: TFunc<T, TSecond, TResult>);
    destructor Destroy; override;
    function GetCurrent: TResult;
    function MoveNext: Boolean;
    procedure Reset;
    property Current: TResult read GetCurrent;
  end;

  // Enumerable para Zip de listas
  TListLazyZipEnumerable<T, TSecond, TResult> = class(TListLazyEnumerableBase<TResult>)
  private
    FZipEnum: TListLazyZipEnumerator<T, TSecond, TResult>;
  public
    constructor Create(const AZipEnum: TListLazyZipEnumerator<T, TSecond, TResult>);
    destructor Destroy; override;
    function GetEnumerator: IEnumEx<TResult>; override;
  end;

  // Enumerador para Join de listas
  TListLazyJoinEnumerator<T, TInner, TKey, TResult> = class(TInterfacedObject, IEnumEx<TResult>)
  private
    [Weak] FOuterEnum: IEnumEx<T>;
    FInnerItems: TList<TInner>;
    FOuterKeySelector: TFunc<T, TKey>;
    FInnerKeySelector: TFunc<TInner, TKey>;
    FResultSelector: TFunc<T, TInner, TResult>;
    FCurrent: TResult;
    FInnerIndex: Integer;
    FOuterCurrent: T;
    FComparer: IEqualityComparer<TKey>;
  public
    constructor Create(const AOuterEnum: IEnumEx<T>; const AInnerItems: TList<TInner>;
      const AOuterKeySelector: TFunc<T, TKey>; const AInnerKeySelector: TFunc<TInner, TKey>;
      const AResultSelector: TFunc<T, TInner, TResult>);
    destructor Destroy; override;
    function GetCurrent: TResult;
    function MoveNext: Boolean;
    procedure Reset;
    property Current: TResult read GetCurrent;
  end;

  // Enumerable para Join de listas
  TListLazyJoinEnumerable<T, TInner, TKey, TResult> = class(TListLazyEnumerableBase<TResult>)
  private
    FJoinEnum: TListLazyJoinEnumerator<T, TInner, TKey, TResult>;
    FInnerItems: TList<TInner>;
  public
    constructor Create(const AJoinEnum: TListLazyJoinEnumerator<T, TInner, TKey, TResult>;
      const AInnerItems: TList<TInner>);
    destructor Destroy; override;
    function GetEnumerator: IEnumEx<TResult>; override;
  end;

  TListLazyFilterEnumerator<T> = class(TInterfacedObject, IEnumEx<T>)
  private
    [Weak] FSource: IEnumEx<T>;
    FPredicate: TFunc<T, Boolean>;
    FCurrent: T;
    FHasNext: Boolean;
  public
    constructor Create(const ASource: IEnumEx<T>; const APredicate: TFunc<T, Boolean>);
    destructor Destroy; override;
    function GetCurrent: T;
    function MoveNext: Boolean;
    procedure Reset;
    property Current: T read GetCurrent;
  end;

  TListLazyFilterEnumerable<T> = class(TListLazyEnumerableBase<T>)
  private
    [Weak] FSource: IListLazyEnumerable<T>;
    FPredicate: TFunc<T, Boolean>;
  public
    constructor Create(const ASource: IListLazyEnumerable<T>; const APredicate: TFunc<T, Boolean>);
    destructor Destroy; override;
    function GetEnumerator: IEnumEx<T>; override;
  end;

  TListLazyTakeEnumerator<T> = class(TInterfacedObject, IEnumEx<T>)
  private
    [Weak] FSource: IEnumEx<T>;
    FCount: Integer;
    FCurrent: T;
    FHasNext: Boolean;
    FTaken: Integer;
  public
    constructor Create(const ASource: IEnumEx<T>; const ACount: Integer);
    destructor Destroy; override;
    function GetCurrent: T;
    function MoveNext: Boolean;
    procedure Reset;
    property Current: T read GetCurrent;
  end;

  TListLazyTakeEnumerable<T> = class(TListLazyEnumerableBase<T>)
  private
    [Weak] FSource: IListLazyEnumerable<T>;
    FCount: Integer;
  public
    constructor Create(const ASource: IListLazyEnumerable<T>; const ACount: Integer);
    destructor Destroy; override;
    function GetEnumerator: IEnumEx<T>; override;
  end;

  TListLazyDistinctEnumerator<T> = class(TInterfacedObject, IEnumEx<T>)
  private
    [Weak] FSource: IEnumEx<T>;
    FCurrent: T;
    FHasNext: Boolean;
    FSeen: TList<T>;
  public
    constructor Create(const ASource: IEnumEx<T>);
    destructor Destroy; override;
    function GetCurrent: T;
    function MoveNext: Boolean;
    procedure Reset;
    property Current: T read GetCurrent;
  end;

  TListLazyDistinctEnumerable<T> = class(TListLazyEnumerableBase<T>)
  private
    [Weak] FSource: IListLazyEnumerable<T>;
  public
    constructor Create(const ASource: IListLazyEnumerable<T>);
    destructor Destroy; override;
    function GetEnumerator: IEnumEx<T>; override;
  end;

  TListLazyOrderByEnumerator<T> = class(TInterfacedObject, IEnumEx<T>)
  private
    FItems: TArray<T>;
    FComparer: TFunc<T, T, Integer>;
    FIndex: Integer;
  public
    constructor Create(const ASourceEnum: IEnumEx<T>; const AComparer: TFunc<T, T, Integer>);
    destructor Destroy; override;
    function GetCurrent: T;
    function MoveNext: Boolean;
    procedure Reset;
    property Current: T read GetCurrent;
  end;

  TListLazyOrderByEnumerable<T> = class(TListLazyEnumerableBase<T>)
  private
    [Weak] FSource: IListLazyEnumerable<T>;
    FComparer: TFunc<T, T, Integer>;
  public
    constructor Create(const ASource: IListLazyEnumerable<T>; const AComparer: TFunc<T, T, Integer>);
    destructor Destroy; override;
    function GetEnumerator: IEnumEx<T>; override;
  end;

  TListLazySkipEnumerator<T> = class(TInterfacedObject, IEnumEx<T>)
  private
    [Weak] FSource: IEnumEx<T>;
    FCount: Integer;
    FCurrent: T;
    FHasNext: Boolean;
    FSkipped: Integer;
  public
    constructor Create(const ASource: IEnumEx<T>; const ACount: Integer);
    destructor Destroy; override;
    function GetCurrent: T;
    function MoveNext: Boolean;
    procedure Reset;
    property Current: T read GetCurrent;
  end;

  TListLazySkipEnumerable<T> = class(TListLazyEnumerableBase<T>)
  private
    [Weak] FSource: IListLazyEnumerable<T>;
    FCount: Integer;
  public
    constructor Create(const ASource: IListLazyEnumerable<T>; const ACount: Integer);
    destructor Destroy; override;
    function GetEnumerator: IEnumEx<T>; override;
  end;

  TDictLazyFilterEnumerator<K, V> = class(TInterfacedObject, IEnumEx<TPair<K, V>>)
  private
    [Weak] FSource: IEnumEx<TPair<K, V>>;
    FPredicate: TFunc<TPair<K, V>, Boolean>;
    FCurrent: TPair<K, V>;
    FHasNext: Boolean;
  public
    constructor Create(const ASource: IEnumEx<TPair<K, V>>; const APredicate: TFunc<TPair<K, V>, Boolean>);
    destructor Destroy; override;
    function GetCurrent: TPair<K, V>;
    function MoveNext: Boolean;
    procedure Reset;
    property Current: TPair<K, V> read GetCurrent;
  end;

  TDictLazyFilterEnumerable<K, V> = class(TDictLazyEnumerableBase<K, V>)
  private
    [Weak] FSource: IDictLazyEnumerable<K, V>;
    FPredicate: TFunc<TPair<K, V>, Boolean>;
  public
    constructor Create(const ASource: IDictLazyEnumerable<K, V>; const APredicate: TFunc<TPair<K, V>, Boolean>);
    destructor Destroy; override;
    function GetEnumerator: IEnumEx<TPair<K, V>>; override;
  end;

  TDictLazyTakeEnumerator<K, V> = class(TInterfacedObject, IEnumEx<TPair<K, V>>)
  private
    [Weak] FSource: IEnumEx<TPair<K, V>>;
    FCount: Integer;
    FCurrent: TPair<K, V>;
    FHasNext: Boolean;
    FTaken: Integer;
  public
    constructor Create(const ASource: IEnumEx<TPair<K, V>>; const ACount: Integer);
    destructor Destroy; override;
    function GetCurrent: TPair<K, V>;
    function MoveNext: Boolean;
    procedure Reset;
    property Current: TPair<K, V> read GetCurrent;
  end;

  TDictLazyTakeEnumerable<K, V> = class(TDictLazyEnumerableBase<K, V>)
  private
    [Weak] FSource: IDictLazyEnumerable<K, V>;
    FCount: Integer;
  public
    constructor Create(const ASource: IDictLazyEnumerable<K, V>; const ACount: Integer);
    destructor Destroy; override;
    function GetEnumerator: IEnumEx<TPair<K, V>>; override;
  end;

  TDictLazySkipEnumerator<K, V> = class(TInterfacedObject, IEnumEx<TPair<K, V>>)
  private
    [Weak] FSource: IEnumEx<TPair<K, V>>;
    FCount: Integer;
    FCurrent: TPair<K, V>;
    FHasNext: Boolean;
    FSkipped: Integer;
  public
    constructor Create(const ASource: IEnumEx<TPair<K, V>>; const ACount: Integer);
    destructor Destroy; override;
    function GetCurrent: TPair<K, V>;
    function MoveNext: Boolean;
    procedure Reset;
    property Current: TPair<K, V> read GetCurrent;
  end;

  TDictLazySkipEnumerable<K, V> = class(TDictLazyEnumerableBase<K, V>)
  private
    [Weak] FSource: IDictLazyEnumerable<K, V>;
    FCount: Integer;
  public
    constructor Create(const ASource: IDictLazyEnumerable<K, V>; const ACount: Integer);
    destructor Destroy; override;
    function GetEnumerator: IEnumEx<TPair<K, V>>; override;
  end;

  TDictLazyOrderByEnumerator<K, V> = class(TInterfacedObject, IEnumEx<TPair<K, V>>)
  private
    FItems: TArray<TPair<K, V>>;
    FComparer: TFunc<TPair<K, V>, TPair<K, V>, Integer>;
    FIndex: Integer;
  public
    constructor Create(const ASource: IEnumEx<TPair<K, V>>;
      const AComparer: TFunc<TPair<K, V>, TPair<K, V>, Integer>);
    destructor Destroy; override;
    function GetCurrent: TPair<K, V>;
    function MoveNext: Boolean;
    procedure Reset;
    property Current: TPair<K, V> read GetCurrent;
  end;

  TDictLazyOrderByEnumerable<K, V> = class(TDictLazyEnumerableBase<K, V>)
  private
    [Weak] FSource: IDictLazyEnumerable<K, V>;
    FComparer: TFunc<TPair<K, V>, TPair<K, V>, Integer>;
  public
    constructor Create(const ASource: IDictLazyEnumerable<K, V>;
      const AComparer: TFunc<TPair<K, V>, TPair<K, V>, Integer>);
    destructor Destroy; override;
    function GetEnumerator: IEnumEx<TPair<K, V>>; override;
  end;

  TDictLazyDistinctEnumerator<K, V> = class(TInterfacedObject, IEnumEx<TPair<K, V>>)
  private
    [Weak] FSource: IEnumEx<TPair<K, V>>;
    FCurrent: TPair<K, V>;
    FHasNext: Boolean;
    FSeen: TList<TPair<K, V>>;
  public
    constructor Create(const ASource: IEnumEx<TPair<K, V>>);
    destructor Destroy; override;
    function GetCurrent: TPair<K, V>;
    function MoveNext: Boolean;
    procedure Reset;
    property Current: TPair<K, V> read GetCurrent;
  end;

  TDictLazyDistinctEnumerable<K, V> = class(TDictLazyEnumerableBase<K, V>)
  private
    [Weak] FSource: IDictLazyEnumerable<K, V>;
  public
    constructor Create(const ASource: IDictLazyEnumerable<K, V>);
    destructor Destroy; override;
    function GetEnumerator: IEnumEx<TPair<K, V>>; override;
  end;

  TDictLazyMapEnumerator<K, V, TResult> = class(TInterfacedObject, IEnumEx<TPair<K, TResult>>)
  private
    [Weak] FSourceEnum: IEnumEx<TPair<K, V>>;
    FSelector: TFunc<K, V, TResult>;
    FCurrent: TPair<K, TResult>;
  public
    constructor Create(const ASourceEnum: IEnumEx<TPair<K, V>>; const ASelector: TFunc<K, V, TResult>);
    destructor Destroy; override;
    function GetCurrent: TPair<K, TResult>;
    function MoveNext: Boolean;
    procedure Reset;
    property Current: TPair<K, TResult> read GetCurrent;
  end;

  TDictLazyMapEnumerable<K, V, TResult> = class(TDictLazyEnumerableBase<K, TResult>)
  private
    FMapEnum: TDictLazyMapEnumerator<K, V, TResult>;
  public
    constructor Create(const AMapEnum: TDictLazyMapEnumerator<K, V, TResult>);
    destructor Destroy; override;
    function GetEnumerator: IEnumEx<TPair<K, TResult>>; override;
  end;

  TDictLazyZipEnumerator<K, V, TSecond, TResult> = class(TInterfacedObject, IEnumEx<TPair<K, TResult>>)
  private
    [Weak] FEnum1: IEnumEx<TPair<K, V>>;
    [Weak] FEnum2: IEnumEx<TPair<K, TSecond>>;
    FResultSelector: TFunc<TPair<K, V>, TPair<K, TSecond>, TPair<K, TResult>>;
    FCurrent: TPair<K, TResult>;
  public
    constructor Create(const AEnum1: IEnumEx<TPair<K, V>>; const AEnum2: IEnumEx<TPair<K, TSecond>>;
      const AResultSelector: TFunc<TPair<K, V>, TPair<K, TSecond>, TPair<K, TResult>>);
    destructor Destroy; override;
    function GetCurrent: TPair<K, TResult>;
    function MoveNext: Boolean;
    procedure Reset;
    property Current: TPair<K, TResult> read GetCurrent;
  end;

  TDictLazyZipEnumerable<K, V, TSecond, TResult> = class(TDictLazyEnumerableBase<K, TResult>)
  private
    FZipEnum: TDictLazyZipEnumerator<K, V, TSecond, TResult>;
  public
    constructor Create(const AZipEnum: TDictLazyZipEnumerator<K, V, TSecond, TResult>);
    destructor Destroy; override;
    function GetEnumerator: IEnumEx<TPair<K, TResult>>; override;
  end;

  TDictLazyFlatMapEnumerator<K, V, TResult> = class(TInterfacedObject, IEnumEx<TPair<K, TResult>>)
  private
    [Weak] FSourceEnum: IEnumEx<TPair<K, V>>;
    FFunc: TFunc<TPair<K, V>, TArray<TPair<K, TResult>>>;
    FCurrentArray: TArray<TPair<K, TResult>>;
    FCurrentIndex: Integer;
    FCurrent: TPair<K, TResult>;
  public
    constructor Create(const ASourceEnum: IEnumEx<TPair<K, V>>;
      const AFunc: TFunc<TPair<K, V>, TArray<TPair<K, TResult>>>);
    destructor Destroy; override;
    function GetCurrent: TPair<K, TResult>;
    function MoveNext: Boolean;
    procedure Reset;
    property Current: TPair<K, TResult> read GetCurrent;
  end;

  TDictLazyFlatMapEnumerable<K, V, TResult> = class(TDictLazyEnumerableBase<K, TResult>)
  private
    FFlatMapEnum: TDictLazyFlatMapEnumerator<K, V, TResult>;
  public
    constructor Create(const AFlatMapEnum: TDictLazyFlatMapEnumerator<K, V, TResult>);
    destructor Destroy; override;
    function GetEnumerator: IEnumEx<TPair<K, TResult>>; override;
  end;

  TDictLazyIntersectEnumerator<K, V> = class(TInterfacedObject, IEnumEx<TPair<K, V>>)
  private
    [Weak] FSourceEnum: IEnumEx<TPair<K, V>>;
    [Weak] FIntersect: IDictLazyEnumerable<K, V>;
    FCurrent: TPair<K, V>;
    FIntersectSet: TDictionary<TPair<K, V>, Boolean>;
    FComparer: IEqualityComparer<TPair<K, V>>;
  public
    constructor Create(const ASourceEnum: IEnumEx<TPair<K, V>>;
      const AIntersect: IDictLazyEnumerable<K, V>);
    destructor Destroy; override;
    function GetCurrent: TPair<K, V>;
    function MoveNext: Boolean;
    procedure Reset;
    property Current: TPair<K, V> read GetCurrent;
  end;

  TDictLazyIntersectEnumerable<K, V> = class(TDictLazyEnumerableBase<K, V>)
  private
    FIntersectEnum: TDictLazyIntersectEnumerator<K, V>;
  public
    constructor Create(const AIntersectEnum: TDictLazyIntersectEnumerator<K, V>);
    destructor Destroy; override;
    function GetEnumerator: IEnumEx<TPair<K, V>>; override;
  end;

  TDictLazyExcludeEnumerator<K, V> = class(TInterfacedObject, IEnumEx<TPair<K, V>>)
  private
    [Weak] FSourceEnum: IEnumEx<TPair<K, V>>;
    [Weak] FExclude: IDictLazyEnumerable<K, V>;
    FCurrent: TPair<K, V>;
    FExcludeSet: TDictionary<TPair<K, V>, Boolean>;
    FComparer: IEqualityComparer<TPair<K, V>>;
  public
    constructor Create(const ASourceEnum: IEnumEx<TPair<K, V>>;
      const AExclude: IDictLazyEnumerable<K, V>);
    destructor Destroy; override;
    function GetCurrent: TPair<K, V>;
    function MoveNext: Boolean;
    procedure Reset;
    property Current: TPair<K, V> read GetCurrent;
  end;

  TDictLazyExcludeEnumerable<K, V> = class(TDictLazyEnumerableBase<K, V>)
  private
    FExcludeEnum: TDictLazyExcludeEnumerator<K, V>;
  public
    constructor Create(const AExcludeEnum: TDictLazyExcludeEnumerator<K, V>);
    destructor Destroy; override;
    function GetEnumerator: IEnumEx<TPair<K, V>>; override;
  end;

  TDictLazyDistinctByEnumerator<K, V, TKey> = class(TInterfacedObject, IEnumEx<TPair<TKey, V>>)
  private
    [Weak] FSourceEnum: IEnumEx<TPair<K, V>>;
    FSelector: TFunc<TPair<K, V>, TPair<TKey, V>>;
    FCurrent: TPair<TKey, V>;
    FSeenKeys: TDictionary<TKey, Boolean>;
    FComparer: IEqualityComparer<TKey>;
  public
    constructor Create(const ASourceEnum: IEnumEx<TPair<K, V>>;
      const ASelector: TFunc<TPair<K, V>, TPair<TKey, V>>);
    destructor Destroy; override;
    function GetCurrent: TPair<TKey, V>;
    function MoveNext: Boolean;
    procedure Reset;
    property Current: TPair<TKey, V> read GetCurrent;
  end;

  TDictLazyDistinctByEnumerable<K, V, TKey> = class(TDictLazyEnumerableBase<TKey, V>)
  private
    FDistinctByEnum: TDictLazyDistinctByEnumerator<K, V, TKey>;
  public
    constructor Create(const ADistinctByEnum: TDictLazyDistinctByEnumerator<K, V, TKey>);
    destructor Destroy; override;
    function GetEnumerator: IEnumEx<TPair<TKey, V>>; override;
  end;

  TDictLazyTakeWhileEnumerator<K, V> = class(TInterfacedObject, IEnumEx<TPair<K, V>>)
  private
    [Weak] FSourceEnum: IEnumEx<TPair<K, V>>;
    FPredicate: TFunc<TPair<K, V>, Boolean>;
    FCurrent: TPair<K, V>;
    FDone: Boolean;
  public
    constructor Create(const ASourceEnum: IEnumEx<TPair<K, V>>;
      const APredicate: TFunc<TPair<K, V>, Boolean>);
    destructor Destroy; override;
    function GetCurrent: TPair<K, V>;
    function MoveNext: Boolean;
    procedure Reset;
    property Current: TPair<K, V> read GetCurrent;
  end;

  TDictLazyTakeWhileEnumerable<K, V> = class(TDictLazyEnumerableBase<K, V>)
  private
    FTakeWhileEnum: TDictLazyTakeWhileEnumerator<K, V>;
  public
    constructor Create(const ATakeWhileEnum: TDictLazyTakeWhileEnumerator<K, V>);
    destructor Destroy; override;
    function GetEnumerator: IEnumEx<TPair<K, V>>; override;
  end;

  TDictLazySkipWhileEnumerator<K, V> = class(TInterfacedObject, IEnumEx<TPair<K, V>>)
  private
    [Weak] FSourceEnum: IEnumEx<TPair<K, V>>;
    FPredicate: TFunc<TPair<K, V>, Boolean>;
    FCurrent: TPair<K, V>;
    FSkipping: Boolean;
  public
    constructor Create(const ASourceEnum: IEnumEx<TPair<K, V>>;
      const APredicate: TFunc<TPair<K, V>, Boolean>);
    destructor Destroy; override;
    function GetCurrent: TPair<K, V>;
    function MoveNext: Boolean;
    procedure Reset;
    property Current: TPair<K, V> read GetCurrent;
  end;

  TDictLazySkipWhileEnumerable<K, V> = class(TDictLazyEnumerableBase<K, V>)
  private
    FSkipWhileEnum: TDictLazySkipWhileEnumerator<K, V>;
  public
    constructor Create(const ASkipWhileEnum: TDictLazySkipWhileEnumerator<K, V>);
    destructor Destroy; override;
    function GetEnumerator: IEnumEx<TPair<K, V>>; override;
  end;

  TListLazyGroupByEnumerator<T, TKey> = class(TInterfacedObject, IGroupedEnumerator<TKey, T>)
  private
    [Weak] FSource: IListLazyEnumerable<T>;
    FKeySelector: TFunc<T, TKey>;
    FGroups: TList<IGrouping<TKey, T>>;
  public
    constructor Create(const ASource: IListLazyEnumerable<T>; const AKeySelector: TFunc<T, TKey>);
    destructor Destroy; override;
    function GetEnumerator: IEnumEx<IGrouping<TKey, T>>;
    function AsEnumerable: IListEnumerable<IGrouping<TKey, T>>;
  end;

  // Enumerador de grupos para GroupBy
  TGroupedEnumerator<TKey, T> = class(TInterfacedObject, IGroupedEnumerator<TKey, T>)
  private
    FGroups: TList<IGrouping<TKey, T>>;
  public
    constructor Create(const AGroups: TList<IGrouping<TKey, T>>);
    destructor Destroy; override;
    function GetEnumerator: IEnumEx<IGrouping<TKey, T>>;
    function AsEnumerable: IListEnumerable<IGrouping<TKey, T>>;
  end;

  // Classe de agrupamento para GroupBy
  TGroupingEnumerable<TKey, T> = class(TInterfacedObject, IGrouping<TKey, T>)
  private
    FKey: TKey;
    FItems: TList<T>;
  public
    constructor Create(const AKey: TKey; const AItems: TList<T>);
    destructor Destroy; override;
    function GetKey: TKey;
    function GetEnumerator: IEnumEx<T>;
    function ToArray: TArray<T>;
  end;

  TListLazyReduceWithInitialEnumerable<T> = class(TListLazyEnumerableBase<T>)
  private
    [Weak] FSource: IListLazyEnumerable<T>;
    FReducer: TFunc<T, T, T>;
    FInitialValue: T;
  public
    constructor Create(const ASource: IListLazyEnumerable<T>; const AReducer: TFunc<T, T, T>; const AInitialValue: T);
    destructor Destroy; override;
    function Reduce(const AReducer: TFunc<T, T, T>; const AInitialValue: T): T; override;
    function GetEnumerator: IEnumEx<T>; override;
  end;

  TListLazyReduceEnumerable<T> = class(TListLazyEnumerableBase<T>)
  private
    [Weak] FSource: IListLazyEnumerable<T>;
    FReducer: TFunc<T, T, T>;
  public
    constructor Create(const ASource: IListLazyEnumerable<T>; const AReducer: TFunc<T, T, T>);
    destructor Destroy; override;
    function Reduce(const AReducer: TFunc<T, T, T>): T; override;
    function GetEnumerator: IEnumEx<T>; override;
  end;

  TListLazyForEachEnumerable<T> = class(TListLazyEnumerableBase<T>)
  private
    [Weak] FSource: IListLazyEnumerable<T>;
    FAction: TAction<T>;
  public
    constructor Create(const ASource: IListLazyEnumerable<T>; const AAction: TAction<T>);
    destructor Destroy; override;
    function GetEnumerator: IEnumEx<T>; override;
  end;

  TListLazySumDoubleEnumerable<T> = class(TListLazyEnumerableBase<T>)
  private
    [Weak] FSource: IListLazyEnumerable<T>;
    FSelector: TFunc<T, Double>;
  public
    constructor Create(const ASource: IListLazyEnumerable<T>; const ASelector: TFunc<T, Double>);
    destructor Destroy; override;
    function Sum(const ASelector: TFunc<T, Double>): Double; override;
    function GetEnumerator: IEnumEx<T>; override;
  end;

  TListLazySumIntegerEnumerable<T> = class(TListLazyEnumerableBase<T>)
  private
    [Weak] FSource: IListLazyEnumerable<T>;
    FSelector: TFunc<T, Integer>;
  public
    constructor Create(const ASource: IListLazyEnumerable<T>; const ASelector: TFunc<T, Integer>);
    destructor Destroy; override;
    function Sum(const ASelector: TFunc<T, Integer>): Integer; override;
    function GetEnumerator: IEnumEx<T>; override;
  end;

  TListLazyMinComparerEnumerable<T> = class(TListLazyEnumerableBase<T>)
  private
    [Weak] FSource: IListLazyEnumerable<T>;
    FComparer: TFunc<T, T, Integer>;
  public
    constructor Create(const ASource: IListLazyEnumerable<T>; const AComparer: TFunc<T, T, Integer>);
    destructor Destroy; override;
    function Min(const AComparer: TFunc<T, T, Integer>): T; override;
    function GetEnumerator: IEnumEx<T>; override;
  end;

  TListLazyMinEnumerable<T> = class(TListLazyEnumerableBase<T>)
  private
    [Weak] FSource: IListLazyEnumerable<T>;
  public
    constructor Create(const ASource: IListLazyEnumerable<T>);
    destructor Destroy; override;
    function GetEnumerator: IEnumEx<T>; override;
  end;

  TListLazyMaxComparerEnumerable<T> = class(TListLazyEnumerableBase<T>)
  private
    [Weak] FSource: IListLazyEnumerable<T>;
    FComparer: TFunc<T, T, Integer>;
  public
    constructor Create(const ASource: IListLazyEnumerable<T>; const AComparer: TFunc<T, T, Integer>);
    destructor Destroy; override;
    function Max(const AComparer: TFunc<T, T, Integer>): T; override;
    function GetEnumerator: IEnumEx<T>; override;
  end;

  TListLazyMaxEnumerable<T> = class(TListLazyEnumerableBase<T>)
  private
    [Weak] FSource: IListLazyEnumerable<T>;
  public
    constructor Create(const ASource: IListLazyEnumerable<T>);
    destructor Destroy; override;
    function GetEnumerator: IEnumEx<T>; override;
  end;

  TListLazyAnyEnumerable<T> = class(TListLazyEnumerableBase<T>)
  private
    [Weak] FSource: IListLazyEnumerable<T>;
    FPredicate: TFunc<T, Boolean>;
  public
    constructor Create(const ASource: IListLazyEnumerable<T>; const APredicate: TFunc<T, Boolean>);
    destructor Destroy; override;
    function Any(const APredicate: TFunc<T, Boolean>): Boolean; override;
    function GetEnumerator: IEnumEx<T>; override;
  end;

  TListLazyFirstOrDefaultEnumerable<T> = class(TListLazyEnumerableBase<T>)
  private
    [Weak] FSource: IListLazyEnumerable<T>;
    FPredicate: TFunc<T, Boolean>;
  public
    constructor Create(const ASource: IListLazyEnumerable<T>; const APredicate: TFunc<T, Boolean>);
    destructor Destroy; override;
    function FirstOrDefault(const APredicate: TFunc<T, Boolean>): T; override;
    function GetEnumerator: IEnumEx<T>; override;
  end;

  TListLazyLastEnumerable<T> = class(TListLazyEnumerableBase<T>)
  private
    [Weak] FSource: IListLazyEnumerable<T>;
    FPredicate: TFunc<T, Boolean>;
  public
    constructor Create(const ASource: IListLazyEnumerable<T>; const APredicate: TFunc<T, Boolean>);
    destructor Destroy; override;
    function Last(const APredicate: TFunc<T, Boolean>): T; override;
    function GetEnumerator: IEnumEx<T>; override;
  end;

  TListLazyLastOrDefaultEnumerable<T> = class(TListLazyEnumerableBase<T>)
  private
    [Weak] FSource: IListLazyEnumerable<T>;
    FPredicate: TFunc<T, Boolean>;
  public
    constructor Create(const ASource: IListLazyEnumerable<T>; const APredicate: TFunc<T, Boolean>);
    destructor Destroy; override;
    function LastOrDefault(const APredicate: TFunc<T, Boolean>): T; override;
    function GetEnumerator: IEnumEx<T>; override;
  end;

  TListLazyCountEnumerable<T> = class(TListLazyEnumerableBase<T>)
  private
    [Weak] FSource: IListLazyEnumerable<T>;
    FPredicate: TFunc<T, Boolean>;
  public
    constructor Create(const ASource: IListLazyEnumerable<T>; const APredicate: TFunc<T, Boolean>);
    destructor Destroy; override;
    function Count(const APredicate: TFunc<T, Boolean>): Integer; override;
    function GetEnumerator: IEnumEx<T>; override;
  end;

  TListLazyLongCountEnumerable<T> = class(TListLazyEnumerableBase<T>)
  private
    [Weak] FSource: IListLazyEnumerable<T>;
    FPredicate: TFunc<T, Boolean>;
  public
    constructor Create(const ASource: IListLazyEnumerable<T>; const APredicate: TFunc<T, Boolean>);
    destructor Destroy; override;
    function LongCount(const APredicate: TFunc<T, Boolean>): Int64; override;
    function GetEnumerator: IEnumEx<T>; override;
  end;

  TListLazyToArrayEnumerable<T> = class(TListLazyEnumerableBase<T>)
  private
    [Weak] FSource: IListLazyEnumerable<T>;
  public
    constructor Create(const ASource: IListLazyEnumerable<T>);
    destructor Destroy; override;
    function GetEnumerator: IEnumEx<T>; override;
  end;

  TListLazyToListEnumerable<T> = class(TListLazyEnumerableBase<T>)
  private
    [Weak] FSource: IListLazyEnumerable<T>;
    [Weak] FEnumSource: IEnumEx<T>;
  public
    constructor Create(const ASource: IListLazyEnumerable<T>); overload;
    constructor Create(const AEnumSource: IEnumEx<T>); overload;
    destructor Destroy; override;
    function GetEnumerator: IEnumEx<T>; override;
  end;

  TDictLazyEnumerable<K, V> = class(TDictLazyEnumerableBase<K, V>)
  private
    [Weak] FSource: IDictLazyEnumerable<K, V>;
  public
    constructor Create(const ASource: IDictLazyEnumerable<K, V>);
    destructor Destroy; override;
    function GetEnumerator: IEnumEx<TPair<K, V>>; override;
  end;

  TDictLazyReduceWithInitialEnumerable<K, V> = class(TDictLazyEnumerableBase<K, V>)
  private
    [Weak] FSource: IDictLazyEnumerable<K, V>;
    FReducer: TFunc<TPair<K, V>, TPair<K, V>, TPair<K, V>>;
    FInitialValue: TPair<K, V>;
  public
    constructor Create(const ASource: IDictLazyEnumerable<K, V>; const AReducer: TFunc<TPair<K, V>, TPair<K, V>, TPair<K, V>>; const AInitialValue: TPair<K, V>);
    destructor Destroy; override;
    function Reduce(const AReducer: TFunc<TPair<K, V>, TPair<K, V>, TPair<K, V>>; const AInitialValue: TPair<K, V>): TPair<K, V>; override;
    function GetEnumerator: IEnumEx<TPair<K, V>>; override;
  end;

  TDictLazyReduceEnumerable<K, V> = class(TDictLazyEnumerableBase<K, V>)
  private
    [Weak] FSource: IDictLazyEnumerable<K, V>;
    FReducer: TFunc<TPair<K, V>, TPair<K, V>, TPair<K, V>>;
  public
    constructor Create(const ASource: IDictLazyEnumerable<K, V>; const AReducer: TFunc<TPair<K, V>, TPair<K, V>, TPair<K, V>>);
    destructor Destroy; override;
    function Reduce(const AReducer: TFunc<TPair<K, V>, TPair<K, V>, TPair<K, V>>): TPair<K, V>; override;
    function GetEnumerator: IEnumEx<TPair<K, V>>; override;
  end;

  TDictLazyForEachEnumerable<K, V> = class(TDictLazyEnumerableBase<K, V>)
  private
    [Weak] FSource: IDictLazyEnumerable<K, V>;
    FAction: TAction<TPair<K, V>>;
  public
    constructor Create(const ASource: IDictLazyEnumerable<K, V>; const AAction: TAction<TPair<K, V>>);
    destructor Destroy; override;
    procedure ForEach(const AAction: TAction<TPair<K, V>>); override;
    function GetEnumerator: IEnumEx<TPair<K, V>>; override;
  end;

  TDictLazySumDoubleEnumerable<K, V> = class(TDictLazyEnumerableBase<K, V>)
  private
    [Weak] FSource: IDictLazyEnumerable<K, V>;
    FSelector: TFunc<TPair<K, V>, Double>;
  public
    constructor Create(const ASource: IDictLazyEnumerable<K, V>; const ASelector: TFunc<TPair<K, V>, Double>);
    destructor Destroy; override;
    function Sum(const ASelector: TFunc<TPair<K, V>, Double>): Double; override;
    function GetEnumerator: IEnumEx<TPair<K, V>>; override;
  end;

  TDictLazySumIntegerEnumerable<K, V> = class(TDictLazyEnumerableBase<K, V>)
  private
    [Weak] FSource: IDictLazyEnumerable<K, V>;
    FSelector: TFunc<TPair<K, V>, Integer>;
  public
    constructor Create(const ASource: IDictLazyEnumerable<K, V>; const ASelector: TFunc<TPair<K, V>, Integer>);
    destructor Destroy; override;
    function Sum(const ASelector: TFunc<TPair<K, V>, Integer>): Integer; override;
    function GetEnumerator: IEnumEx<TPair<K, V>>; override;
  end;

  TDictLazyMinComparerEnumerable<K, V> = class(TDictLazyEnumerableBase<K, V>)
  private
    [Weak] FSource: IDictLazyEnumerable<K, V>;
    FComparer: TFunc<TPair<K, V>, TPair<K, V>, Integer>;
  public
    constructor Create(const ASource: IDictLazyEnumerable<K, V>; const AComparer: TFunc<TPair<K, V>, TPair<K, V>, Integer>);
    destructor Destroy; override;
    function Min(const AComparer: TFunc<TPair<K, V>, TPair<K, V>, Integer>): TPair<K, V>; override;
    function GetEnumerator: IEnumEx<TPair<K, V>>; override;
  end;

  TDictLazyMinEnumerable<K, V> = class(TDictLazyEnumerableBase<K, V>)
  private
    [Weak] FSource: IDictLazyEnumerable<K, V>;
  public
    constructor Create(const ASource: IDictLazyEnumerable<K, V>);
    destructor Destroy; override;
    function GetEnumerator: IEnumEx<TPair<K, V>>; override;
  end;

  TDictLazyMaxComparerEnumerable<K, V> = class(TDictLazyEnumerableBase<K, V>)
  private
    [Weak] FSource: IDictLazyEnumerable<K, V>;
    FComparer: TFunc<TPair<K, V>, TPair<K, V>, Integer>;
  public
    constructor Create(const ASource: IDictLazyEnumerable<K, V>; const AComparer: TFunc<TPair<K, V>, TPair<K, V>, Integer>);
    destructor Destroy; override;
    function Max(const AComparer: TFunc<TPair<K, V>, TPair<K, V>, Integer>): TPair<K, V>; override;
    function GetEnumerator: IEnumEx<TPair<K, V>>; override;
  end;

  TDictLazyMaxEnumerable<K, V> = class(TDictLazyEnumerableBase<K, V>)
  private
    [Weak] FSource: IDictLazyEnumerable<K, V>;
  public
    constructor Create(const ASource: IDictLazyEnumerable<K, V>);
    destructor Destroy; override;
    function GetEnumerator: IEnumEx<TPair<K, V>>; override;
  end;

  TDictLazyAnyEnumerable<K, V> = class(TDictLazyEnumerableBase<K, V>)
  private
    [Weak] FSource: IDictLazyEnumerable<K, V>;
    FPredicate: TFunc<TPair<K, V>, Boolean>;
  public
    constructor Create(const ASource: IDictLazyEnumerable<K, V>; const APredicate: TFunc<TPair<K, V>, Boolean>);
    destructor Destroy; override;
    function Any(const APredicate: TFunc<TPair<K, V>, Boolean>): Boolean; override;
    function GetEnumerator: IEnumEx<TPair<K, V>>; override;
  end;

  TDictLazyFirstOrDefaultEnumerable<K, V> = class(TDictLazyEnumerableBase<K, V>)
  private
    [Weak] FSource: IDictLazyEnumerable<K, V>;
    FPredicate: TFunc<TPair<K, V>, Boolean>;
  public
    constructor Create(const ASource: IDictLazyEnumerable<K, V>; const APredicate: TFunc<TPair<K, V>, Boolean>);
    destructor Destroy; override;
    function FirstOrDefault(const APredicate: TFunc<TPair<K, V>, Boolean>): TPair<K, V>; override;
    function GetEnumerator: IEnumEx<TPair<K, V>>; override;
  end;

  TDictLazyLastEnumerable<K, V> = class(TDictLazyEnumerableBase<K, V>)
  private
    [Weak] FSource: IDictLazyEnumerable<K, V>;
    FPredicate: TFunc<TPair<K, V>, Boolean>;
  public
    constructor Create(const ASource: IDictLazyEnumerable<K, V>; const APredicate: TFunc<TPair<K, V>, Boolean>);
    destructor Destroy; override;
    function Last(const APredicate: TFunc<TPair<K, V>, Boolean>): TPair<K, V>; override;
    function GetEnumerator: IEnumEx<TPair<K, V>>; override;
  end;

  TDictLazyLastOrDefaultEnumerable<K, V> = class(TDictLazyEnumerableBase<K, V>)
  private
    [Weak] FSource: IDictLazyEnumerable<K, V>;
    FPredicate: TFunc<TPair<K, V>, Boolean>;
  public
    constructor Create(const ASource: IDictLazyEnumerable<K, V>; const APredicate: TFunc<TPair<K, V>, Boolean>);
    destructor Destroy; override;
    function LastOrDefault(const APredicate: TFunc<TPair<K, V>, Boolean>): TPair<K, V>; override;
    function GetEnumerator: IEnumEx<TPair<K, V>>; override;
  end;

  TDictLazyCountEnumerable<K, V> = class(TDictLazyEnumerableBase<K, V>)
  private
    [Weak] FSource: IDictLazyEnumerable<K, V>;
    FPredicate: TFunc<TPair<K, V>, Boolean>;
  public
    constructor Create(const ASource: IDictLazyEnumerable<K, V>; const APredicate: TFunc<TPair<K, V>, Boolean>);
    destructor Destroy; override;
    function Count(const APredicate: TFunc<TPair<K, V>, Boolean>): Integer; override;
    function GetEnumerator: IEnumEx<TPair<K, V>>; override;
  end;

  TDictLazyLongCountEnumerable<K, V> = class(TDictLazyEnumerableBase<K, V>)
  private
    [Weak] FSource: IDictLazyEnumerable<K, V>;
    FPredicate: TFunc<TPair<K, V>, Boolean>;
  public
    constructor Create(const ASource: IDictLazyEnumerable<K, V>; const APredicate: TFunc<TPair<K, V>, Boolean>);
    destructor Destroy; override;
    function LongCount(const APredicate: TFunc<TPair<K, V>, Boolean>): Int64; override;
    function GetEnumerator: IEnumEx<TPair<K, V>>; override;
  end;

  TDictLazyToArrayEnumerable<K, V> = class(TDictLazyEnumerableBase<K, V>)
  private
    [Weak] FSource: IDictLazyEnumerable<K, V>;
  public
    constructor Create(const ASource: IDictLazyEnumerable<K, V>);
    destructor Destroy; override;
    function GetEnumerator: IEnumEx<TPair<K, V>>; override;
  end;

  TDictLazyToListEnumerable<K, V> = class(TDictLazyEnumerableBase<K, V>)
  private
    [Weak] FSource: IDictLazyEnumerable<K, V>;
  public
    constructor Create(const ASource: IDictLazyEnumerable<K, V>);
    destructor Destroy; override;
    function GetEnumerator: IEnumEx<TPair<K, V>>; override;
  end;

  TDictLazyToDictionaryEnumerable<K, V> = class(TDictLazyEnumerableBase<K, V>)
  private
    [Weak] FSource: IDictLazyEnumerable<K, V>;
  public
    constructor Create(const ASource: IDictLazyEnumerable<K, V>);
    destructor Destroy; override;
    function GetEnumerator: IEnumEx<TPair<K, V>>; override;
  end;

  TDictLazyEnumerator<K, V> = class(TDictLazyEnumerableBase<K, V>)
  private
    [Weak] FSource: IDictLazyEnumerable<K, V>;
  public
    constructor Create(const ASource: IDictLazyEnumerable<K, V>);
    destructor Destroy; override;
    function GetEnumerator: IEnumEx<TPair<K, V>>; override;
  end;

  TDictLazyGroupBy<K, V, TKey> = class(TInterfacedObject, IGroupedEnumerator<TKey, TPair<K, V>>)
  private
    [Weak] FSource: IDictLazyEnumerable<K, V>;
    FKeySelector: TFunc<TPair<K, V>, TKey>;
    FGroups: TList<IGrouping<TKey, TPair<K, V>>>;
  public
    constructor Create(const ASource: IDictLazyEnumerable<K, V>; const AKeySelector: TFunc<TPair<K, V>, TKey>);
    destructor Destroy; override;
    function GetEnumerator: IEnumEx<IGrouping<TKey, TPair<K, V>>>;
    function AsEnumerable: IListEnumerable<IGrouping<TKey, TPair<K, V>>>;
  end;

  TArrayEnumerator<T> = class(TInterfacedObject, IEnumEx<T>)
  private
    FArray: TArray<T>;
    FIndex: Integer;
  public
    constructor Create(const AArray: TArray<T>);
    destructor Destroy; override;
    function GetCurrent: T;
    function MoveNext: Boolean;
    procedure Reset;
    property Current: T read GetCurrent;
  end;

  TEnumeratorAdapter<T> = class(TInterfacedObject, IEnumEx<T>)
  private
    FEnumerator: TEnumerator<T>;
    FCurrent: T;
    FHasNext: Boolean;
  public
    constructor Create(const AEnumerator: TEnumerator<T>);
    destructor Destroy; override;
    function GetCurrent: T;
    function MoveNext: Boolean;
    procedure Reset;
    property Current: T read GetCurrent;
  end;

  TListAdapterEnumerable<T> = class(TInterfacedObject, IListLazyEnumerable<T>)
  private
    FList: TList<T>;
  public
    constructor Create(const AList: TList<T>);
    destructor Destroy; override;
    function GetEnumerator: IEnumEx<T>;
  end;

  TGroupedEnumeratorAdapter<TKey, T> = class(TInterfacedObject, IListLazyEnumerable<IGrouping<TKey, T>>)
  private
    FEnumerator: IGroupedEnumerator<TKey, T>;
  public
    constructor Create(const AEnumerator: IGroupedEnumerator<TKey, T>);
    function GetEnumerator: IEnumEx<IGrouping<TKey, T>>;
  end;

implementation

{ IListEnumerable<T> }

constructor IListEnumerable<T>.Create(AEnumerator: IListLazyEnumerable<T>);
begin
  FEnumerator := AEnumerator;
end;

function IListEnumerable<T>.GetEnumerator: IEnumEx<T>;
begin
  Result := FEnumerator.GetEnumerator;
end;

function IListEnumerable<T>.Map<TResult>(const ASelector: TFunc<T, TResult>): IListEnumerable<TResult>;
begin
  Result := IListEnumerable<TResult>.Create(
    TListLazyMapEnumerable<T, TResult>.Create(
      TListLazyMapEnumerator<T, TResult>.Create(FEnumerator.GetEnumerator, ASelector)));
end;

function IListEnumerable<T>.OfType<TResult>(const AConverter: TConverterFunc<T, TResult>): IListEnumerable<TResult>;
begin
  Result := Self.Map<TResult>(
    function(Item: T): TResult
    var
      LResult: TResult;
    begin
      if AConverter(Item, LResult) then
        Result := LResult
      else
        raise EInvalidOperation.Create('Item cannot be converted to the specified type');
    end);
end;

function IListEnumerable<T>.GroupBy<TKey>(const AKeySelector: TFunc<T, TKey>): IGroupedEnumerator<TKey, T>;
begin
  Result := TListLazyGroupByEnumerator<T, TKey>.Create(FEnumerator, AKeySelector);
end;

function IListEnumerable<T>.Zip<TSecond, TResult>(const ASecond: IListEnumerable<TSecond>;
  const AResultSelector: TFunc<T, TSecond, TResult>): IListEnumerable<TResult>;
begin
  Result := IListEnumerable<TResult>.Create(
    TListLazyZipEnumerable<T, TSecond, TResult>.Create(
      TListLazyZipEnumerator<T, TSecond, TResult>.Create(
        FEnumerator.GetEnumerator, ASecond.GetEnumerator, AResultSelector)));
end;

function IListEnumerable<T>.Join<TInner, TKey, TResult>(const AInner: IListEnumerable<TInner>;
  const AOuterKeySelector: TFunc<T, TKey>; const AInnerKeySelector: TFunc<TInner, TKey>;
  const AResultSelector: TFunc<T, TInner, TResult>): IListEnumerable<TResult>;
var
  LInnerItems: TList<TInner>;
  LEnum: IEnumEx<TInner>;
begin
  LInnerItems := TList<TInner>.Create;
  try
    LEnum := AInner.GetEnumerator;
    while LEnum.MoveNext do
      LInnerItems.Add(LEnum.Current);
    Result := IListEnumerable<TResult>.Create(
      TListLazyJoinEnumerable<T, TInner, TKey, TResult>.Create(
        TListLazyJoinEnumerator<T, TInner, TKey, TResult>.Create(
          FEnumerator.GetEnumerator, LInnerItems, AOuterKeySelector, AInnerKeySelector, AResultSelector),
        LInnerItems));
  except
    LInnerItems.Free;
    raise;
  end;
end;

function IListEnumerable<T>.MinBy<TKey>(const AKeySelector: TFunc<T, TKey>;
  const AComparer: TFunc<TKey, TKey, Integer>): T;
var
  LEnum: IEnumEx<T>;
  LMin: T;
  LMinKey, LCurrentKey: TKey;
  LHasValue: Boolean;
begin
  LEnum := FEnumerator.GetEnumerator;
  LHasValue := False;
  while LEnum.MoveNext do
  begin
    if not LHasValue then
    begin
      LMin := LEnum.Current;
      LMinKey := AKeySelector(LEnum.Current);
      LHasValue := True;
    end
    else
    begin
      LCurrentKey := AKeySelector(LEnum.Current);
      if AComparer(LCurrentKey, LMinKey) < 0 then
      begin
        LMin := LEnum.Current;
        LMinKey := LCurrentKey;
      end;
    end;
  end;
  if not LHasValue then
    raise EInvalidOperation.Create('Sequence contains no elements');
  Result := LMin;
end;

function IListEnumerable<T>.MaxBy<TKey>(const AKeySelector: TFunc<T, TKey>;
  const AComparer: TFunc<TKey, TKey, Integer>): T;
var
  LEnum: IEnumEx<T>;
  LMax: T;
  LMaxKey, LCurrentKey: TKey;
  LHasValue: Boolean;
begin
  LEnum := FEnumerator.GetEnumerator;
  LHasValue := False;
  while LEnum.MoveNext do
  begin
    if not LHasValue then
    begin
      LMax := LEnum.Current;
      LMaxKey := AKeySelector(LEnum.Current);
      LHasValue := True;
    end
    else
    begin
      LCurrentKey := AKeySelector(LEnum.Current);
      if AComparer(LCurrentKey, LMaxKey) > 0 then
      begin
        LMax := LEnum.Current;
        LMaxKey := LCurrentKey;
      end;
    end;
  end;
  if not LHasValue then
    raise EInvalidOperation.Create('Sequence contains no elements');
  Result := LMax;
end;

function IListEnumerable<T>.Filter(const APredicate: TFunc<T, Boolean>): IListEnumerable<T>;
begin
  Result := IListEnumerable<T>.Create(
    TListLazyFilterEnumerable<T>.Create(FEnumerator, APredicate));
end;

function IListEnumerable<T>.Take(const ACount: Integer): IListEnumerable<T>;
begin
  Result := IListEnumerable<T>.Create(
    TListLazyTakeEnumerable<T>.Create(FEnumerator, ACount));
end;

function IListEnumerable<T>.Skip(const ACount: Integer): IListEnumerable<T>;
begin
  Result := IListEnumerable<T>.Create(
    TListLazySkipEnumerable<T>.Create(FEnumerator, ACount));
end;

function IListEnumerable<T>.Distinct: IListEnumerable<T>;
begin
  Result := IListEnumerable<T>.Create(
    TListLazyDistinctEnumerable<T>.Create(FEnumerator));
end;

function IListEnumerable<T>.FlatMap<TResult>(const AFunc: TFunc<T, TArray<TResult>>): IListEnumerable<TResult>;
begin
  Result := IListEnumerable<TResult>.Create(
    TListLazyFlatMapEnumerable<T, TResult>.Create(
      TListLazyFlatMapEnumerator<T, TResult>.Create(FEnumerator.GetEnumerator, AFunc)));
end;

function IListEnumerable<T>.Reduce(const AReducer: TFunc<T, T, T>; const AInitialValue: T): T;
var
  LEnum: IEnumEx<T>;
  LResult: T;
begin
  LEnum := FEnumerator.GetEnumerator;
  LResult := AInitialValue;
  while LEnum.MoveNext do
    LResult := AReducer(LResult, LEnum.Current);
  Result := LResult;
end;

function IListEnumerable<T>.Reduce(const AReducer: TFunc<T, T, T>): T;
var
  LEnum: IEnumEx<T>;
  LResult: T;
  LHasValue: Boolean;
begin
  LEnum := FEnumerator.GetEnumerator;
  LHasValue := False;
  while LEnum.MoveNext do
  begin
    if not LHasValue then
    begin
      LResult := LEnum.Current;
      LHasValue := True;
    end
    else
      LResult := AReducer(LResult, LEnum.Current);
  end;
  if not LHasValue then
    raise EInvalidOperation.Create('Sequence contains no elements');
  Result := LResult;
end;

procedure IListEnumerable<T>.ForEach(const AAction: TAction<T>);
var
  LEnum: IEnumEx<T>;
begin
  LEnum := FEnumerator.GetEnumerator;
  while LEnum.MoveNext do
    AAction(LEnum.Current);
end;

function IListEnumerable<T>.Sum(const ASelector: TFunc<T, Double>): Double;
var
  LEnum: IEnumEx<T>;
  LSum: Double;
begin
  LEnum := FEnumerator.GetEnumerator;
  LSum := 0;
  while LEnum.MoveNext do
    LSum := LSum + ASelector(LEnum.Current);
  Result := LSum;
end;

function IListEnumerable<T>.Sum(const ASelector: TFunc<T, Integer>): Integer;
var
  LEnum: IEnumEx<T>;
  LSum: Integer;
begin
  LEnum := FEnumerator.GetEnumerator;
  LSum := 0;
  while LEnum.MoveNext do
    LSum := LSum + ASelector(LEnum.Current);
  Result := LSum;
end;

function IListEnumerable<T>.Min(const AComparer: TFunc<T, T, Integer>): T;
var
  LEnum: IEnumEx<T>;
  LMin: T;
  LHasValue: Boolean;
begin
  LEnum := FEnumerator.GetEnumerator;
  LHasValue := False;
  while LEnum.MoveNext do
  begin
    if not LHasValue then
    begin
      LMin := LEnum.Current;
      LHasValue := True;
    end
    else if AComparer(LEnum.Current, LMin) < 0 then
      LMin := LEnum.Current;
  end;
  if not LHasValue then
    raise EInvalidOperation.Create('Sequence contains no elements');
  Result := LMin;
end;

function IListEnumerable<T>.Min: T;
var
  LComparer: TFunc<T, T, Integer>;
begin
  LComparer := function(A, B: T): Integer
  begin
    Result := TComparer<T>.Default.Compare(A, B);
  end;
  Result := Min(LComparer);
end;

function IListEnumerable<T>.Max(const AComparer: TFunc<T, T, Integer>): T;
var
  LEnum: IEnumEx<T>;
  LMax: T;
  LHasValue: Boolean;
begin
  LEnum := FEnumerator.GetEnumerator;
  LHasValue := False;
  while LEnum.MoveNext do
  begin
    if not LHasValue then
    begin
      LMax := LEnum.Current;
      LHasValue := True;
    end
    else if AComparer(LEnum.Current, LMax) > 0 then
      LMax := LEnum.Current;
  end;
  if not LHasValue then
    raise EInvalidOperation.Create('Sequence contains no elements');
  Result := LMax;
end;

function IListEnumerable<T>.Max: T;
var
  LComparer: TFunc<T, T, Integer>;
begin
  LComparer := function(A, B: T): Integer
  begin
    Result := TComparer<T>.Default.Compare(A, B);
  end;
  Result := Max(LComparer);
end;

function IListEnumerable<T>.Any(const APredicate: TFunc<T, Boolean>): Boolean;
var
  LEnum: IEnumEx<T>;
begin
  LEnum := FEnumerator.GetEnumerator;
  while LEnum.MoveNext do
    if APredicate(LEnum.Current) then
    begin
      Result := True;
      Exit;
    end;
  Result := False;
end;

function IListEnumerable<T>.FirstOrDefault(const APredicate: TFunc<T, Boolean>): T;
var
  LEnum: IEnumEx<T>;
begin
  LEnum := FEnumerator.GetEnumerator;
  while LEnum.MoveNext do
    if APredicate(LEnum.Current) then
    begin
      Result := LEnum.Current;
      Exit;
    end;
  Result := Default(T);
end;

function IListEnumerable<T>.Last(const APredicate: TFunc<T, Boolean>): T;
var
  LEnum: IEnumEx<T>;
  LLast: T;
  LHasValue: Boolean;
begin
  LEnum := FEnumerator.GetEnumerator;
  LHasValue := False;
  while LEnum.MoveNext do
    if APredicate(LEnum.Current) then
    begin
      LLast := LEnum.Current;
      LHasValue := True;
    end;
  if not LHasValue then
    raise EInvalidOperation.Create('Sequence contains no matching elements');
  Result := LLast;
end;

function IListEnumerable<T>.LastOrDefault(const APredicate: TFunc<T, Boolean>): T;
var
  LEnum: IEnumEx<T>;
  LLast: T;
  LHasValue: Boolean;
begin
  LEnum := FEnumerator.GetEnumerator;
  LHasValue := False;
  while LEnum.MoveNext do
    if APredicate(LEnum.Current) then
    begin
      LLast := LEnum.Current;
      LHasValue := True;
    end;
  if not LHasValue then
    Result := Default(T)
  else
    Result := LLast;
end;

function IListEnumerable<T>.Count(const APredicate: TFunc<T, Boolean>): Integer;
var
  LEnum: IEnumEx<T>;
  LCount: Integer;
begin
  LEnum := FEnumerator.GetEnumerator;
  LCount := 0;
  while LEnum.MoveNext do
    if APredicate(LEnum.Current) then
      Inc(LCount);
  Result := LCount;
end;

function IListEnumerable<T>.LongCount(const APredicate: TFunc<T, Boolean>): Int64;
var
  LEnum: IEnumEx<T>;
  LCount: Int64;
begin
  LEnum := FEnumerator.GetEnumerator;
  LCount := 0;
  while LEnum.MoveNext do
    if APredicate(LEnum.Current) then
      Inc(LCount);
  Result := LCount;
end;

function IListEnumerable<T>.ToArray: TArray<T>;
var
  LList: TList<T>;
  LEnum: IEnumEx<T>;
begin
  LList := TList<T>.Create;
  try
    LEnum := FEnumerator.GetEnumerator;
    while LEnum.MoveNext do
      LList.Add(LEnum.Current);
    Result := LList.ToArray;
  finally
    LList.Free;
  end;
end;

function IListEnumerable<T>.ToList: TList<T>;
var
  LList: TList<T>;
  LEnum: IEnumEx<T>;
begin
  LList := TList<T>.Create;
  LEnum := FEnumerator.GetEnumerator;
  while LEnum.MoveNext do
    LList.Add(LEnum.Current);
  Result := LList;
end;

function IListEnumerable<T>.ToDictionary<TKey, TValue>(const AKeySelector: TFunc<T, TKey>;
  const AValueSelector: TFunc<T, TValue>): TDictionary<TKey, TValue>;
var
  LDict: TDictionary<TKey, TValue>;
  LEnum: IEnumEx<T>;
begin
  LDict := TDictionary<TKey, TValue>.Create;
  try
    LEnum := FEnumerator.GetEnumerator;
    while LEnum.MoveNext do
      LDict.Add(AKeySelector(LEnum.Current), AValueSelector(LEnum.Current));
    Result := LDict;
  except
    LDict.Free;
    raise;
  end;
end;

//function IListEnumerable<T>.SelectMany<TResult>(const ASelector: TFunc<T, IListEnumerable<TResult>>): IListEnumerable<TResult>;
//begin
//  Result := FlatMap<TResult>(
//    function(Item: T): TArray<TResult>
//    begin
//      Result := ASelector(Item).ToArray;
//    end);
//end;

//function IListEnumerable<T>.GroupJoin<TInner, TKey, TResult>(const AInner: IListEnumerable<TInner>;
//  const AOuterKeySelector: TFunc<T, TKey>; const AInnerKeySelector: TFunc<TInner, TKey>;
//  const AResultSelector: TFunc<T, IListEnumerable<TInner>, TResult>): IListEnumerable<TResult>;
//var
//  LInnerItems: TList<TInner>;
//  LEnum: IEnumEx<TInner>;
//begin
//  LInnerItems := TList<TInner>.Create;
//  try
//    LEnum := AInner.GetEnumerator;
//    while LEnum.MoveNext do
//      LInnerItems.Add(LEnum.Current);
//    Result := IListEnumerable<TResult>.Create(
//      TListLazyGroupJoinEnumerable<T, TInner, TKey, TResult>.Create(
//        TListLazyGroupJoinEnumerator<T, TInner, TKey, TResult>.Create(
//          FEnumerator.GetEnumerator, LInnerItems, AOuterKeySelector, AInnerKeySelector, AResultSelector),
//        LInnerItems));
//  except
//    LInnerItems.Free;
//    raise;
//  end;
//end;

function IListEnumerable<T>.TakeWhile(const APredicate: TFunc<T, Boolean>): IListEnumerable<T>;
begin
  Result := IListEnumerable<T>.Create(
    TListLazyTakeWhileEnumerable<T>.Create(
      TListLazyTakeWhileEnumerator<T>.Create(FEnumerator.GetEnumerator, APredicate)));
end;

function IListEnumerable<T>.SkipWhile(const APredicate: TFunc<T, Boolean>): IListEnumerable<T>;
begin
  Result := IListEnumerable<T>.Create(
    TListLazySkipWhileEnumerable<T>.Create(
      TListLazySkipWhileEnumerator<T>.Create(FEnumerator.GetEnumerator, APredicate)));
end;

function IListEnumerable<T>.Average(const ASelector: TFunc<T, Double>): Double;
var
  LEnum: IEnumEx<T>;
  LSum: Double;
  LCount: Int64;
begin
  LEnum := FEnumerator.GetEnumerator;
  LSum := 0;
  LCount := 0;
  while LEnum.MoveNext do
  begin
    LSum := LSum + ASelector(LEnum.Current);
    Inc(LCount);
  end;
  if LCount = 0 then
    raise EInvalidOperation.Create('Sequence contains no elements');
  Result := LSum / LCount;
end;

function IListEnumerable<T>.Exclude(const ASecond: IListEnumerable<T>): IListEnumerable<T>;
begin
  Result := IListEnumerable<T>.Create(
    TListLazyExcludeEnumerable<T>.Create(
      TListLazyExcludeEnumerator<T>.Create(FEnumerator.GetEnumerator, ASecond.FEnumerator)));
end;

function IListEnumerable<T>.Intersect(const ASecond: IListEnumerable<T>): IListEnumerable<T>;
begin
  Result := IListEnumerable<T>.Create(
    TListLazyIntersectEnumerable<T>.Create(
      TListLazyIntersectEnumerator<T>.Create(FEnumerator.GetEnumerator, ASecond.FEnumerator)));
end;

function IListEnumerable<T>.Union(const ASecond: IListEnumerable<T>): IListEnumerable<T>;
begin
  Result := IListEnumerable<T>.Create(
    TListLazyUnionEnumerable<T>.Create(
      TListLazyUnionEnumerator<T>.Create(FEnumerator.GetEnumerator, ASecond.FEnumerator)));
end;

function IListEnumerable<T>.Concat(const ASecond: IListEnumerable<T>): IListEnumerable<T>;
begin
  Result := IListEnumerable<T>.Create(
    TListLazyConcatEnumerable<T>.Create(
      TListLazyConcatEnumerator<T>.Create(FEnumerator.GetEnumerator, ASecond.FEnumerator)));
end;

function IListEnumerable<T>.All(const APredicate: TFunc<T, Boolean>): Boolean;
var
  LEnum: IEnumEx<T>;
begin
  LEnum := FEnumerator.GetEnumerator;
  while LEnum.MoveNext do
    if not APredicate(LEnum.Current) then
    begin
      Result := False;
      Exit;
    end;
  Result := True;
end;

function IListEnumerable<T>.Contains(const AValue: T): Boolean;
var
  LEnum: IEnumEx<T>;
begin
  LEnum := FEnumerator.GetEnumerator;
  while LEnum.MoveNext do
    if TEqualityComparer<T>.Default.Equals(LEnum.Current, AValue) then
    begin
      Result := True;
      Exit;
    end;
  Result := False;
end;

function IListEnumerable<T>.SequenceEqual(const ASecond: IListEnumerable<T>): Boolean;
var
  LEnum1, LEnum2: IEnumEx<T>;
begin
  LEnum1 := FEnumerator.GetEnumerator;
  LEnum2 := ASecond.GetEnumerator;
  while LEnum1.MoveNext do
  begin
    if not LEnum2.MoveNext then
    begin
      Result := False;
      Exit;
    end;
    if not TEqualityComparer<T>.Default.Equals(LEnum1.Current, LEnum2.Current) then
    begin
      Result := False;
      Exit;
    end;
  end;
  Result := not LEnum2.MoveNext;
end;

function IListEnumerable<T>.Single(const APredicate: TFunc<T, Boolean>): T;
var
  LEnum: IEnumEx<T>;
  LResult: T;
  LFound: Boolean;
begin
  LEnum := FEnumerator.GetEnumerator;
  LFound := False;
  while LEnum.MoveNext do
  begin
    if APredicate(LEnum.Current) then
    begin
      if LFound then
        raise EInvalidOperation.Create('Sequence contains more than one matching element');
      LResult := LEnum.Current;
      LFound := True;
    end;
  end;
  if not LFound then
    raise EInvalidOperation.Create('Sequence contains no matching elements');
  Result := LResult;
end;

function IListEnumerable<T>.SingleOrDefault(const APredicate: TFunc<T, Boolean>): T;
var
  LEnum: IEnumEx<T>;
  LResult: T;
  LFound: Boolean;
begin
  LEnum := FEnumerator.GetEnumerator;
  LFound := False;
  while LEnum.MoveNext do
  begin
    if APredicate(LEnum.Current) then
    begin
      if LFound then
        raise EInvalidOperation.Create('Sequence contains more than one matching element');
      LResult := LEnum.Current;
      LFound := True;
    end;
  end;
  if not LFound then
    Result := Default(T)
  else
    Result := LResult;
end;

function IListEnumerable<T>.ElementAt(const AIndex: Integer): T;
var
  LEnum: IEnumEx<T>;
  LIndex: Integer;
begin
  if AIndex < 0 then
    raise EArgumentOutOfRangeException.Create('Index must be non-negative');
  LEnum := FEnumerator.GetEnumerator;
  LIndex := 0;
  while LEnum.MoveNext do
  begin
    if LIndex = AIndex then
    begin
      Result := LEnum.Current;
      Exit;
    end;
    Inc(LIndex);
  end;
  raise EArgumentOutOfRangeException.Create('Index out of range');
end;

function IListEnumerable<T>.ElementAtOrDefault(const AIndex: Integer): T;
var
  LEnum: IEnumEx<T>;
  LIndex: Integer;
begin
  if AIndex < 0 then
    raise EArgumentOutOfRangeException.Create('Index must be non-negative');
  LEnum := FEnumerator.GetEnumerator;
  LIndex := 0;
  while LEnum.MoveNext do
  begin
    if LIndex = AIndex then
    begin
      Result := LEnum.Current;
      Exit;
    end;
    Inc(LIndex);
  end;
  Result := Default(T);
end;

function IListEnumerable<T>.OrderBy(const AComparer: TFunc<T, T, Integer>): IListEnumerable<T>;
begin
  Result := IListEnumerable<T>.Create(
    TListLazyOrderByEnumerable<T>.Create(FEnumerator, AComparer));
end;

function IListEnumerable<T>.OrderByDesc(const AComparer: TFunc<T, T, Integer>): IListEnumerable<T>;
begin
  Result := OrderBy(
    function(A, B: T): Integer
    begin
      Result := -AComparer(A, B);
    end);
end;

{ IDictEnumerable<K, V> }

constructor IDictEnumerable<K, V>.Create(AEnumerator: IDictLazyEnumerable<K, V>);
begin
  FEnumerator := AEnumerator;
end;

procedure IDictEnumerable<K, V>.ForEach(const AAction: TAction<TPair<K, V>>);
var
  LEnum: IEnumEx<TPair<K, V>>;
begin
  LEnum := FEnumerator.GetEnumerator;
  while LEnum.MoveNext do
    AAction(LEnum.Current);
end;

function IDictEnumerable<K, V>.GetEnumerator: IEnumEx<TPair<K, V>>;
begin
  Result := FEnumerator.GetEnumerator;
end;

function IDictEnumerable<K, V>.Filter(const APredicate: TFunc<TPair<K, V>, Boolean>): IDictEnumerable<K, V>;
begin
  Result := IDictEnumerable<K, V>.Create(
    TDictLazyFilterEnumerable<K, V>.Create(FEnumerator, APredicate));
end;

function IDictEnumerable<K, V>.Take(const ACount: Integer): IDictEnumerable<K, V>;
begin
  Result := IDictEnumerable<K, V>.Create(
    TDictLazyTakeEnumerable<K, V>.Create(FEnumerator, ACount));
end;

function IDictEnumerable<K, V>.Skip(const ACount: Integer): IDictEnumerable<K, V>;
begin
  Result := IDictEnumerable<K, V>.Create(
    TDictLazySkipEnumerable<K, V>.Create(FEnumerator, ACount));
end;

function IDictEnumerable<K, V>.OrderBy(const AComparer: TFunc<TPair<K, V>, TPair<K, V>, Integer>): IDictEnumerable<K, V>;
begin
  Result := IDictEnumerable<K, V>.Create(
    TDictLazyOrderByEnumerable<K, V>.Create(FEnumerator, AComparer));
end;

function IDictEnumerable<K, V>.OrderBy: IDictEnumerable<K, V>;
var
  LComparer: TFunc<TPair<K, V>, TPair<K, V>, Integer>;
begin
  LComparer := function(A, B: TPair<K, V>): Integer
  begin
    Result := TComparer<K>.Default.Compare(A.Key, B.Key);
  end;
  Result := OrderBy(LComparer);
end;

function IDictEnumerable<K, V>.Distinct: IDictEnumerable<K, V>;
begin
  Result := IDictEnumerable<K, V>.Create(
    TDictLazyDistinctEnumerable<K, V>.Create(FEnumerator));
end;

function IDictEnumerable<K, V>.Reduce(const AReducer: TFunc<TPair<K, V>, TPair<K, V>, TPair<K, V>>;
  const AInitialValue: TPair<K, V>): TPair<K, V>;
var
  LEnum: IEnumEx<TPair<K, V>>;
  LResult: TPair<K, V>;
begin
  LEnum := FEnumerator.GetEnumerator;
  LResult := AInitialValue;
  while LEnum.MoveNext do
    LResult := AReducer(LResult, LEnum.Current);
  Result := LResult;
end;

function IDictEnumerable<K, V>.Reduce(const AReducer: TFunc<TPair<K, V>, TPair<K, V>, TPair<K, V>>): TPair<K, V>;
var
  LEnum: IEnumEx<TPair<K, V>>;
  LResult: TPair<K, V>;
  LHasValue: Boolean;
begin
  LEnum := FEnumerator.GetEnumerator;
  LHasValue := False;
  while LEnum.MoveNext do
  begin
    if not LHasValue then
    begin
      LResult := LEnum.Current;
      LHasValue := True;
    end
    else
      LResult := AReducer(LResult, LEnum.Current);
  end;
  if not LHasValue then
    raise EInvalidOperation.Create('Sequence contains no elements');
  Result := LResult;
end;

function IDictEnumerable<K, V>.Sum(const ASelector: TFunc<TPair<K, V>, Double>): Double;
var
  LEnum: IEnumEx<TPair<K, V>>;
  LSum: Double;
begin
  LEnum := FEnumerator.GetEnumerator;
  LSum := 0;
  while LEnum.MoveNext do
    LSum := LSum + ASelector(LEnum.Current);
  Result := LSum;
end;

function IDictEnumerable<K, V>.Sum(const ASelector: TFunc<TPair<K, V>, Integer>): Integer;
var
  LEnum: IEnumEx<TPair<K, V>>;
  LSum: Integer;
begin
  LEnum := FEnumerator.GetEnumerator;
  LSum := 0;
  while LEnum.MoveNext do
    LSum := LSum + ASelector(LEnum.Current);
  Result := LSum;
end;

function IDictEnumerable<K, V>.Min(const AComparer: TFunc<TPair<K, V>, TPair<K, V>, Integer>): TPair<K, V>;
var
  LEnum: IEnumEx<TPair<K, V>>;
  LMin: TPair<K, V>;
  LHasValue: Boolean;
begin
  LEnum := FEnumerator.GetEnumerator;
  LHasValue := False;
  while LEnum.MoveNext do
  begin
    if not LHasValue then
    begin
      LMin := LEnum.Current;
      LHasValue := True;
    end
    else if AComparer(LEnum.Current, LMin) < 0 then
      LMin := LEnum.Current;
  end;
  if not LHasValue then
    raise EInvalidOperation.Create('Sequence contains no elements');
  Result := LMin;
end;

function IDictEnumerable<K, V>.Min: TPair<K, V>;
var
  LComparer: TFunc<TPair<K, V>, TPair<K, V>, Integer>;
begin
  LComparer := function(A, B: TPair<K, V>): Integer
  begin
    Result := TComparer<K>.Default.Compare(A.Key, B.Key);
  end;
  Result := Min(LComparer);
end;

function IDictEnumerable<K, V>.Max(const AComparer: TFunc<TPair<K, V>, TPair<K, V>, Integer>): TPair<K, V>;
var
  LEnum: IEnumEx<TPair<K, V>>;
  LMax: TPair<K, V>;
  LHasValue: Boolean;
begin
  LEnum := FEnumerator.GetEnumerator;
  LHasValue := False;
  while LEnum.MoveNext do
  begin
    if not LHasValue then
    begin
      LMax := LEnum.Current;
      LHasValue := True;
    end
    else if AComparer(LEnum.Current, LMax) > 0 then
      LMax := LEnum.Current;
  end;
  if not LHasValue then
    raise EInvalidOperation.Create('Sequence contains no elements');
  Result := LMax;
end;

function IDictEnumerable<K, V>.Max: TPair<K, V>;
var
  LComparer: TFunc<TPair<K, V>, TPair<K, V>, Integer>;
begin
  LComparer := function(A, B: TPair<K, V>): Integer
  begin
    Result := TComparer<K>.Default.Compare(A.Key, B.Key);
  end;
  Result := Max(LComparer);
end;

function IDictEnumerable<K, V>.Any(const APredicate: TFunc<TPair<K, V>, Boolean>): Boolean;
var
  LEnum: IEnumEx<TPair<K, V>>;
begin
  LEnum := FEnumerator.GetEnumerator;
  while LEnum.MoveNext do
    if APredicate(LEnum.Current) then
    begin
      Result := True;
      Exit;
    end;
  Result := False;
end;

function IDictEnumerable<K, V>.FirstOrDefault(const APredicate: TFunc<TPair<K, V>, Boolean>): TPair<K, V>;
var
  LEnum: IEnumEx<TPair<K, V>>;
begin
  LEnum := FEnumerator.GetEnumerator;
  while LEnum.MoveNext do
    if APredicate(LEnum.Current) then
    begin
      Result := LEnum.Current;
      Exit;
    end;
  Result := Default(TPair<K, V>);
end;

function IDictEnumerable<K, V>.Last(const APredicate: TFunc<TPair<K, V>, Boolean>): TPair<K, V>;
var
  LEnum: IEnumEx<TPair<K, V>>;
  LLast: TPair<K, V>;
  LHasValue: Boolean;
begin
  LEnum := FEnumerator.GetEnumerator;
  LHasValue := False;
  while LEnum.MoveNext do
    if APredicate(LEnum.Current) then
    begin
      LLast := LEnum.Current;
      LHasValue := True;
    end;
  if not LHasValue then
    raise EInvalidOperation.Create('Sequence contains no matching elements');
  Result := LLast;
end;

function IDictEnumerable<K, V>.LastOrDefault(const APredicate: TFunc<TPair<K, V>, Boolean>): TPair<K, V>;
var
  LEnum: IEnumEx<TPair<K, V>>;
  LLast: TPair<K, V>;
  LHasValue: Boolean;
begin
  LEnum := FEnumerator.GetEnumerator;
  LHasValue := False;
  while LEnum.MoveNext do
    if APredicate(LEnum.Current) then
    begin
      LLast := LEnum.Current;
      LHasValue := True;
    end;
  if not LHasValue then
    Result := Default(TPair<K, V>)
  else
    Result := LLast;
end;

function IDictEnumerable<K, V>.Count(const APredicate: TFunc<TPair<K, V>, Boolean>): Integer;
var
  LEnum: IEnumEx<TPair<K, V>>;
  LCount: Integer;
begin
  LEnum := FEnumerator.GetEnumerator;
  LCount := 0;
  while LEnum.MoveNext do
    if APredicate(LEnum.Current) then
      Inc(LCount);
  Result := LCount;
end;

function IDictEnumerable<K, V>.LongCount(const APredicate: TFunc<TPair<K, V>, Boolean>): Int64;
var
  LEnum: IEnumEx<TPair<K, V>>;
  LCount: Int64;
begin
  LEnum := FEnumerator.GetEnumerator;
  LCount := 0;
  while LEnum.MoveNext do
    if APredicate(LEnum.Current) then
      Inc(LCount);
  Result := LCount;
end;

function IDictEnumerable<K, V>.ToArray: TArray<TPair<K, V>>;
var
  LList: TList<TPair<K, V>>;
  LEnum: IEnumEx<TPair<K, V>>;
begin
  LList := TList<TPair<K, V>>.Create;
  try
    LEnum := FEnumerator.GetEnumerator;
    while LEnum.MoveNext do
      LList.Add(LEnum.Current);
    Result := LList.ToArray;
  finally
    LList.Free;
  end;
end;

function IDictEnumerable<K, V>.ToList: TList<TPair<K, V>>;
var
  LList: TList<TPair<K, V>>;
  LEnum: IEnumEx<TPair<K, V>>;
begin
  LList := TList<TPair<K, V>>.Create;
  LEnum := FEnumerator.GetEnumerator;
  while LEnum.MoveNext do
    LList.Add(LEnum.Current);
  Result := LList;
end;

function IDictEnumerable<K, V>.ToDictionary: TDictionary<K, V>;
var
  LDict: TDictionary<K, V>;
  LEnum: IEnumEx<TPair<K, V>>;
begin
  LDict := TDictionary<K, V>.Create;
  try
    LEnum := FEnumerator.GetEnumerator;
    while LEnum.MoveNext do
      LDict.Add(LEnum.Current.Key, LEnum.Current.Value);
    Result := LDict;
  except
    LDict.Free;
    raise;
  end;
end;

function IDictEnumerable<K, V>.Map(const AMappingFunc: TFunc<V, V>): IDictEnumerable<K, V>;
begin
  Result := IDictEnumerable<K, V>.Create(
    TDictLazyMapEnumerable<K, V, V>.Create(
      TDictLazyMapEnumerator<K, V, V>.Create(FEnumerator.GetEnumerator,
        function(Key: K; Value: V): V
        begin
          Result := AMappingFunc(Value);
        end)));
end;

function IDictEnumerable<K, V>.Map<R>(const AMappingFunc: TFunc<V, R>): IDictEnumerable<K, R>;
begin
  Result := IDictEnumerable<K, R>.Create(
    TDictLazyMapEnumerable<K, V, R>.Create(
      TDictLazyMapEnumerator<K, V, R>.Create(FEnumerator.GetEnumerator,
        function(Key: K; Value: V): R
        begin
          Result := AMappingFunc(Value);
        end)));
end;

function IDictEnumerable<K, V>.Map(const AMappingFunc: TFunc<K, V, V>): IDictEnumerable<K, V>;
begin
  Result := IDictEnumerable<K, V>.Create(
    TDictLazyMapEnumerable<K, V, V>.Create(
      TDictLazyMapEnumerator<K, V, V>.Create(FEnumerator.GetEnumerator, AMappingFunc)));
end;

function IDictEnumerable<K, V>.Map<R>(const AMappingFunc: TFunc<K, V, R>): IDictEnumerable<K, R>;
begin
  Result := IDictEnumerable<K, R>.Create(
    TDictLazyMapEnumerable<K, V, R>.Create(
      TDictLazyMapEnumerator<K, V, R>.Create(FEnumerator.GetEnumerator, AMappingFunc)));
end;

function IDictEnumerable<K, V>.GroupBy<TKey>(const AKeySelector: TFunc<TPair<K, V>, TKey>): IGroupedEnumerator<TKey, TPair<K, V>>;
begin
  Result := TDictLazyGroupBy<K, V, TKey>.Create(FEnumerator, AKeySelector);
end;

function IDictEnumerable<K, V>.Zip<VR, KR>(const AList: IDictEnumerable<K, VR>;
  const AFunc: TFunc<V, VR, KR>): IDictEnumerable<K, KR>;
begin
  Result := IDictEnumerable<K, KR>.Create(
    TDictLazyZipEnumerable<K, V, VR, KR>.Create(
      TDictLazyZipEnumerator<K, V, VR, KR>.Create(FEnumerator.GetEnumerator, AList.FEnumerator.GetEnumerator,
        function(Pair1: TPair<K, V>; Pair2: TPair<K, VR>): TPair<K, KR>
        begin
          if not TEqualityComparer<K>.Default.Equals(Pair1.Key, Pair2.Key) then
            raise EInvalidOperation.Create('Keys do not match');
          Result := TPair<K, KR>.Create(Pair1.Key, AFunc(Pair1.Value, Pair2.Value));
        end)));
end;

function IDictEnumerable<K, V>.FlatMap<R>(const AFunc: TFunc<V, TArray<R>>): IDictEnumerable<K, R>;
begin
  Result := IDictEnumerable<K, R>.Create(
    TDictLazyFlatMapEnumerable<K, V, R>.Create(
      TDictLazyFlatMapEnumerator<K, V, R>.Create(FEnumerator.GetEnumerator,
        function(Pair: TPair<K, V>): TArray<TPair<K, R>>
        var
          LValues: TArray<R>;
          LFor: Integer;
        begin
          LValues := AFunc(Pair.Value);
          SetLength(Result, System.Length(LValues));
          for LFor := 0 to High(LValues) do
            Result[LFor] := TPair<K, R>.Create(Pair.Key, LValues[LFor]);
        end)));
end;

function IDictEnumerable<K, V>.Intersect(const AOtherDict: IDictEnumerable<K, V>): IDictEnumerable<K, V>;
begin
  Result := IDictEnumerable<K, V>.Create(
    TDictLazyIntersectEnumerable<K, V>.Create(
      TDictLazyIntersectEnumerator<K, V>.Create(FEnumerator.GetEnumerator, AOtherDict.FEnumerator)));
end;

function IDictEnumerable<K, V>.Exclude(const AOtherDict: IDictEnumerable<K, V>): IDictEnumerable<K, V>;
begin
  Result := IDictEnumerable<K, V>.Create(
    TDictLazyExcludeEnumerable<K, V>.Create(
      TDictLazyExcludeEnumerator<K, V>.Create(FEnumerator.GetEnumerator, AOtherDict.FEnumerator)));
end;

function IDictEnumerable<K, V>.DistinctBy<TKey>(const AKeySelector: TFunc<K, TKey>): IDictEnumerable<TKey, V>;
begin
  Result := IDictEnumerable<TKey, V>.Create(
    TDictLazyDistinctByEnumerable<K, V, TKey>.Create(
      TDictLazyDistinctByEnumerator<K, V, TKey>.Create(FEnumerator.GetEnumerator,
        function(Pair: TPair<K, V>): TPair<TKey, V>
        begin
          Result := TPair<TKey, V>.Create(AKeySelector(Pair.Key), Pair.Value);
        end)));
end;

function IDictEnumerable<K, V>.TakeWhile(const APredicate: TPredicate<K>): IDictEnumerable<K, V>;
begin
  Result := IDictEnumerable<K, V>.Create(
    TDictLazyTakeWhileEnumerable<K, V>.Create(
      TDictLazyTakeWhileEnumerator<K, V>.Create(FEnumerator.GetEnumerator,
        function(Pair: TPair<K, V>): Boolean
        begin
          Result := APredicate(Pair.Key);
        end)));
end;

function IDictEnumerable<K, V>.SkipWhile(const APredicate: TPredicate<K>): IDictEnumerable<K, V>;
begin
  Result := IDictEnumerable<K, V>.Create(
    TDictLazySkipWhileEnumerable<K, V>.Create(
      TDictLazySkipWhileEnumerator<K, V>.Create(FEnumerator.GetEnumerator,
        function(Pair: TPair<K, V>): Boolean
        begin
          Result := APredicate(Pair.Key);
        end)));
end;

//{ TListLazyEnumeratorBase<T> }
//
//constructor TListLazyEnumeratorBase<T>.Create(const ASource: IEnumEx<T>);
//begin
//  FSource := ASource;
//  FHasNext := False;
//end;
//
//destructor TListLazyEnumeratorBase<T>.Destroy;
//begin
//  FSource := nil;
//  inherited;
//end;
//
//function TListLazyEnumeratorBase<T>.GetCurrent: T;
//begin
//  Result := FCurrent;
//end;
//
//function TListLazyEnumeratorBase<T>.MoveNext: Boolean;
//begin
//  Result := FHasNext;
//  if Result then
//  begin
//    FCurrent := FSource.Current;
//    FHasNext := FSource.MoveNext;
//  end;
//end;
//
//procedure TListLazyEnumeratorBase<T>.Reset;
//begin
//  FSource.Reset;
//  FHasNext := FSource.MoveNext;
//end;

{ TListLazyMapEnumerator<T, TResult> }

constructor TListLazyMapEnumerator<T, TResult>.Create(const ASourceEnum: IEnumEx<T>; const ASelector: TFunc<T, TResult>);
begin
  FSourceEnum := ASourceEnum;
  FSelector := ASelector;
  FCurrent := Default(TResult);
end;

destructor TListLazyMapEnumerator<T, TResult>.Destroy;
begin
  FSourceEnum := nil;
  inherited;
end;

function TListLazyMapEnumerator<T, TResult>.GetCurrent: TResult;
begin
  Result := FCurrent;
end;

function TListLazyMapEnumerator<T, TResult>.MoveNext: Boolean;
begin
  Result := FSourceEnum.MoveNext;
  if Result then
    FCurrent := FSelector(FSourceEnum.Current);
end;

procedure TListLazyMapEnumerator<T, TResult>.Reset;
begin
  FSourceEnum.Reset;
end;

{ TListLazyMapEnumerable<T, TResult> }

constructor TListLazyMapEnumerable<T, TResult>.Create(const AMapEnum: TListLazyMapEnumerator<T, TResult>);
begin
  FMapEnum := AMapEnum;
end;

destructor TListLazyMapEnumerable<T, TResult>.Destroy;
begin
  FMapEnum.Free;
  inherited;
end;

function TListLazyMapEnumerable<T, TResult>.GetEnumerator: IEnumEx<TResult>;
begin
  Result := FMapEnum;
end;

{ TListLazyFlatMapEnumerator<T, TResult> }

constructor TListLazyFlatMapEnumerator<T, TResult>.Create(const ASourceEnum: IEnumEx<T>; const AFunc: TFunc<T, TArray<TResult>>);
begin
  FSourceEnum := ASourceEnum;
  FFunc := AFunc;
  FCurrentIndex := -1;
  FCurrentArray := nil;
end;

destructor TListLazyFlatMapEnumerator<T, TResult>.Destroy;
begin
  FSourceEnum := nil;
  inherited;
end;

function TListLazyFlatMapEnumerator<T, TResult>.GetCurrent: TResult;
begin
  Result := FCurrent;
end;

function TListLazyFlatMapEnumerator<T, TResult>.MoveNext: Boolean;
begin
  while True do
  begin
    if (FCurrentIndex >= 0) and (FCurrentIndex < Length(FCurrentArray)) then
    begin
      FCurrent := FCurrentArray[FCurrentIndex];
      Inc(FCurrentIndex);
      Result := True;
      Exit;
    end;

    if not FSourceEnum.MoveNext then
    begin
      Result := False;
      Exit;
    end;

    FCurrentArray := FFunc(FSourceEnum.Current);
    FCurrentIndex := 0;
  end;
end;

procedure TListLazyFlatMapEnumerator<T, TResult>.Reset;
begin
  FSourceEnum.Reset;
  FCurrentIndex := -1;
  FCurrentArray := nil;
end;

{ TListLazyFlatMapEnumerable<T, TResult> }

constructor TListLazyFlatMapEnumerable<T, TResult>.Create(const AFlatMapEnum: TListLazyFlatMapEnumerator<T, TResult>);
begin
  FFlatMapEnum := AFlatMapEnum;
end;

destructor TListLazyFlatMapEnumerable<T, TResult>.Destroy;
begin
  FFlatMapEnum.Free;
  inherited;
end;

function TListLazyFlatMapEnumerable<T, TResult>.GetEnumerator: IEnumEx<TResult>;
begin
  Result := FFlatMapEnum;
end;

{ TListLazyGroupJoinEnumerator<T, TInner, TKey, TResult> }

constructor TListLazyGroupJoinEnumerator<T, TInner, TKey, TResult>.Create(const AOuterEnum: IEnumEx<T>;
  const AInnerItems: TList<TInner>; const AOuterKeySelector: TFunc<T, TKey>;
  const AInnerKeySelector: TFunc<TInner, TKey>; const AResultSelector: TFunc<T, IListEnumerable<TInner>, TResult>);
begin
  FOuterEnum := AOuterEnum;
  FInnerItems := AInnerItems;
  FOuterKeySelector := AOuterKeySelector;
  FInnerKeySelector := AInnerKeySelector;
  FResultSelector := AResultSelector;
  FComparer := TEqualityComparer<TKey>.Default;
end;

destructor TListLazyGroupJoinEnumerator<T, TInner, TKey, TResult>.Destroy;
begin
  FOuterEnum := nil;
  FInnerItems.Free;
  inherited;
end;

function TListLazyGroupJoinEnumerator<T, TInner, TKey, TResult>.GetCurrent: TResult;
begin
  Result := FCurrent;
end;

function TListLazyGroupJoinEnumerator<T, TInner, TKey, TResult>.MoveNext: Boolean;
var
  LInnerList: TList<TInner>;
  LOuterKey: TKey;
  LInnerItem: TInner;
begin
  while FOuterEnum.MoveNext do
  begin
    FOuterCurrent := FOuterEnum.Current;
    LOuterKey := FOuterKeySelector(FOuterCurrent);
    LInnerList := TList<TInner>.Create;
    try
      for LInnerItem in FInnerItems do
        if FComparer.Equals(LOuterKey, FInnerKeySelector(LInnerItem)) then
          LInnerList.Add(LInnerItem);
      FCurrent := FResultSelector(FOuterCurrent, IListEnumerable<TInner>.Create(
        TListAdapterEnumerable<TInner>.Create(LInnerList)));
      Result := True;
      Exit;
    except
      LInnerList.Free;
      raise;
    end;
  end;
  Result := False;
end;

procedure TListLazyGroupJoinEnumerator<T, TInner, TKey, TResult>.Reset;
begin
  FOuterEnum.Reset;
end;

{ TListLazyGroupJoinEnumerable<T, TInner, TKey, TResult> }

constructor TListLazyGroupJoinEnumerable<T, TInner, TKey, TResult>.Create(
  const AGroupJoinEnum: TListLazyGroupJoinEnumerator<T, TInner, TKey, TResult>;
  const AInnerItems: TList<TInner>);
begin
  FGroupJoinEnum := AGroupJoinEnum;
  FInnerItems := AInnerItems;
end;

destructor TListLazyGroupJoinEnumerable<T, TInner, TKey, TResult>.Destroy;
begin
  FGroupJoinEnum.Free;
  FInnerItems.Free;
  inherited;
end;

function TListLazyGroupJoinEnumerable<T, TInner, TKey, TResult>.GetEnumerator: IEnumEx<TResult>;
begin
  Result := FGroupJoinEnum;
end;

{ TListLazyTakeWhileEnumerator<T> }

constructor TListLazyTakeWhileEnumerator<T>.Create(const ASourceEnum: IEnumEx<T>; const APredicate: TFunc<T, Boolean>);
begin
  FSourceEnum := ASourceEnum;
  FPredicate := APredicate;
  FDone := False;
end;

destructor TListLazyTakeWhileEnumerator<T>.Destroy;
begin
  FSourceEnum := nil;
  inherited;
end;

function TListLazyTakeWhileEnumerator<T>.GetCurrent: T;
begin
  Result := FCurrent;
end;

function TListLazyTakeWhileEnumerator<T>.MoveNext: Boolean;
begin
  if FDone then
  begin
    Result := False;
    Exit;
  end;

  if FSourceEnum.MoveNext then
  begin
    FCurrent := FSourceEnum.Current;
    if FPredicate(FCurrent) then
    begin
      Result := True;
    end
    else
    begin
      FDone := True;
      Result := False;
    end;
  end
  else
  begin
    FDone := True;
    Result := False;
  end;
end;

procedure TListLazyTakeWhileEnumerator<T>.Reset;
begin
  FSourceEnum.Reset;
  FDone := False;
end;

{ TListLazyTakeWhileEnumerable<T> }

constructor TListLazyTakeWhileEnumerable<T>.Create(const ATakeWhileEnum: TListLazyTakeWhileEnumerator<T>);
begin
  FTakeWhileEnum := ATakeWhileEnum;
end;

destructor TListLazyTakeWhileEnumerable<T>.Destroy;
begin
  FTakeWhileEnum.Free;
  inherited;
end;

function TListLazyTakeWhileEnumerable<T>.GetEnumerator: IEnumEx<T>;
begin
  Result := FTakeWhileEnum;
end;

{ TListLazySkipWhileEnumerator<T> }

constructor TListLazySkipWhileEnumerator<T>.Create(const ASourceEnum: IEnumEx<T>; const APredicate: TFunc<T, Boolean>);
begin
  FSourceEnum := ASourceEnum;
  FPredicate := APredicate;
  FSkipping := True;
end;

destructor TListLazySkipWhileEnumerator<T>.Destroy;
begin
  FSourceEnum := nil;
  inherited;
end;

function TListLazySkipWhileEnumerator<T>.GetCurrent: T;
begin
  Result := FCurrent;
end;

function TListLazySkipWhileEnumerator<T>.MoveNext: Boolean;
begin
  while FSourceEnum.MoveNext do
  begin
    FCurrent := FSourceEnum.Current;
    if FSkipping then
    begin
      if not FPredicate(FCurrent) then
      begin
        FSkipping := False;
        Result := True;
        Exit;
      end;
    end
    else
    begin
      Result := True;
      Exit;
    end;
  end;
  Result := False;
end;

procedure TListLazySkipWhileEnumerator<T>.Reset;
begin
  FSourceEnum.Reset;
  FSkipping := True;
end;

{ TListLazySkipWhileEnumerable<T> }

constructor TListLazySkipWhileEnumerable<T>.Create(const ASkipWhileEnum: TListLazySkipWhileEnumerator<T>);
begin
  FSkipWhileEnum := ASkipWhileEnum;
end;

destructor TListLazySkipWhileEnumerable<T>.Destroy;
begin
  FSkipWhileEnum.Free;
  inherited;
end;

function TListLazySkipWhileEnumerable<T>.GetEnumerator: IEnumEx<T>;
begin
  Result := FSkipWhileEnum;
end;

{ TListLazyExcludeEnumerator<T> }

constructor TListLazyExcludeEnumerator<T>.Create(const ASourceEnum: IEnumEx<T>; const AExclude: IListLazyEnumerable<T>);
begin
  FSourceEnum := ASourceEnum;
  FExclude := AExclude;
  FExcludeSet := TDictionary<T, Boolean>.Create;
  FComparer := TEqualityComparer<T>.Default;
  // Preenche o conjunto de exclusão
  var LEnum := FExclude.GetEnumerator;
  while LEnum.MoveNext do
    FExcludeSet.AddOrSetValue(LEnum.Current, True);
end;

destructor TListLazyExcludeEnumerator<T>.Destroy;
begin
  FSourceEnum := nil;
  FExclude := nil;
  FExcludeSet.Free;
  inherited;
end;

function TListLazyExcludeEnumerator<T>.GetCurrent: T;
begin
  Result := FCurrent;
end;

function TListLazyExcludeEnumerator<T>.MoveNext: Boolean;
begin
  while FSourceEnum.MoveNext do
  begin
    FCurrent := FSourceEnum.Current;
    if not FExcludeSet.ContainsKey(FCurrent) then
    begin
      Result := True;
      Exit;
    end;
  end;
  Result := False;
end;

procedure TListLazyExcludeEnumerator<T>.Reset;
begin
  FSourceEnum.Reset;
end;

{ TListLazyExcludeEnumerable<T> }

constructor TListLazyExcludeEnumerable<T>.Create(const AExcludeEnum: TListLazyExcludeEnumerator<T>);
begin
  FExcludeEnum := AExcludeEnum;
end;

destructor TListLazyExcludeEnumerable<T>.Destroy;
begin
  FExcludeEnum.Free;
  inherited;
end;

function TListLazyExcludeEnumerable<T>.GetEnumerator: IEnumEx<T>;
begin
  Result := FExcludeEnum;
end;

{ TListLazyIntersectEnumerator<T> }

constructor TListLazyIntersectEnumerator<T>.Create(const ASourceEnum: IEnumEx<T>; const AIntersect: IListLazyEnumerable<T>);
begin
  FSourceEnum := ASourceEnum;
  FIntersect := AIntersect;
  FIntersectSet := TDictionary<T, Boolean>.Create;
  FComparer := TEqualityComparer<T>.Default;
  // Preenche o conjunto de interseção
  var LEnum := FIntersect.GetEnumerator;
  while LEnum.MoveNext do
    FIntersectSet.AddOrSetValue(LEnum.Current, True);
end;

destructor TListLazyIntersectEnumerator<T>.Destroy;
begin
  FSourceEnum := nil;
  FIntersect := nil;
  FIntersectSet.Free;
  inherited;
end;

function TListLazyIntersectEnumerator<T>.GetCurrent: T;
begin
  Result := FCurrent;
end;

function TListLazyIntersectEnumerator<T>.MoveNext: Boolean;
begin
  while FSourceEnum.MoveNext do
  begin
    FCurrent := FSourceEnum.Current;
    if FIntersectSet.ContainsKey(FCurrent) then
    begin
      FIntersectSet.Remove(FCurrent);
      Result := True;
      Exit;
    end;
  end;
  Result := False;
end;

procedure TListLazyIntersectEnumerator<T>.Reset;
begin
  FSourceEnum.Reset;
  FIntersectSet.Clear;
  var LEnum := FIntersect.GetEnumerator;
  while LEnum.MoveNext do
    FIntersectSet.AddOrSetValue(LEnum.Current, True);
end;

{ TListLazyIntersectEnumerable<T> }

constructor TListLazyIntersectEnumerable<T>.Create(const AIntersectEnum: TListLazyIntersectEnumerator<T>);
begin
  FIntersectEnum := AIntersectEnum;
end;

destructor TListLazyIntersectEnumerable<T>.Destroy;
begin
  FIntersectEnum.Free;
  inherited;
end;

function TListLazyIntersectEnumerable<T>.GetEnumerator: IEnumEx<T>;
begin
  Result := FIntersectEnum;
end;

{ TListLazyUnionEnumerator<T> }

constructor TListLazyUnionEnumerator<T>.Create(const ASourceEnum: IEnumEx<T>; const ASecond: IListLazyEnumerable<T>);
begin
  FSourceEnum := ASourceEnum;
  FSecondEnum := ASecond.GetEnumerator;
  FSeen := TDictionary<T, Boolean>.Create;
  FComparer := TEqualityComparer<T>.Default;
  FOnSecond := False;
end;

destructor TListLazyUnionEnumerator<T>.Destroy;
begin
  FSourceEnum := nil;
  FSecondEnum := nil;
  FSeen.Free;
  inherited;
end;

function TListLazyUnionEnumerator<T>.GetCurrent: T;
begin
  Result := FCurrent;
end;

function TListLazyUnionEnumerator<T>.MoveNext: Boolean;
begin
  if not FOnSecond then
  begin
    while FSourceEnum.MoveNext do
    begin
      FCurrent := FSourceEnum.Current;
      if not FSeen.ContainsKey(FCurrent) then
      begin
        FSeen.Add(FCurrent, True);
        Result := True;
        Exit;
      end;
    end;
    FOnSecond := True;
  end;

  while FSecondEnum.MoveNext do
  begin
    FCurrent := FSecondEnum.Current;
    if not FSeen.ContainsKey(FCurrent) then
    begin
      FSeen.Add(FCurrent, True);
      Result := True;
      Exit;
    end;
  end;

  Result := False;
end;

procedure TListLazyUnionEnumerator<T>.Reset;
begin
  FSourceEnum.Reset;
  FSecondEnum.Reset;
  FSeen.Clear;
  FOnSecond := False;
end;

{ TListLazyUnionEnumerable<T> }

constructor TListLazyUnionEnumerable<T>.Create(const AUnionEnum: TListLazyUnionEnumerator<T>);
begin
  FUnionEnum := AUnionEnum;
end;

destructor TListLazyUnionEnumerable<T>.Destroy;
begin
  FUnionEnum.Free;
  inherited;
end;

function TListLazyUnionEnumerable<T>.GetEnumerator: IEnumEx<T>;
begin
  Result := FUnionEnum;
end;

{ TListLazyConcatEnumerator<T> }

constructor TListLazyConcatEnumerator<T>.Create(const ASourceEnum: IEnumEx<T>; const ASecond: IListLazyEnumerable<T>);
begin
  FSourceEnum := ASourceEnum;
  FSecondEnum := ASecond.GetEnumerator;
  FOnSecond := False;
end;

destructor TListLazyConcatEnumerator<T>.Destroy;
begin
  FSourceEnum := nil;
  FSecondEnum := nil;
  inherited;
end;

function TListLazyConcatEnumerator<T>.GetCurrent: T;
begin
  Result := FCurrent;
end;

function TListLazyConcatEnumerator<T>.MoveNext: Boolean;
begin
  if not FOnSecond then
  begin
    if FSourceEnum.MoveNext then
    begin
      FCurrent := FSourceEnum.Current;
      Result := True;
      Exit;
    end;
    FOnSecond := True;
  end;

  if FSecondEnum.MoveNext then
  begin
    FCurrent := FSecondEnum.Current;
    Result := True;
    Exit;
  end;

  Result := False;
end;

procedure TListLazyConcatEnumerator<T>.Reset;
begin
  FSourceEnum.Reset;
  FSecondEnum.Reset;
  FOnSecond := False;
end;

{ TListLazyConcatEnumerable<T> }

constructor TListLazyConcatEnumerable<T>.Create(const AConcatEnum: TListLazyConcatEnumerator<T>);
begin
  FConcatEnum := AConcatEnum;
end;

destructor TListLazyConcatEnumerable<T>.Destroy;
begin
  FConcatEnum.Free;
  inherited;
end;

function TListLazyConcatEnumerable<T>.GetEnumerator: IEnumEx<T>;
begin
  Result := FConcatEnum;
end;

{ TListLazyZipEnumerator<T, TSecond, TResult> }

constructor TListLazyZipEnumerator<T, TSecond, TResult>.Create(const AEnum1: IEnumEx<T>;
  const AEnum2: IEnumEx<TSecond>; const AResultSelector: TFunc<T, TSecond, TResult>);
begin
  FEnum1 := AEnum1;
  FEnum2 := AEnum2;
  FResultSelector := AResultSelector;
end;

destructor TListLazyZipEnumerator<T, TSecond, TResult>.Destroy;
begin
  FEnum1 := nil;
  FEnum2 := nil;
  inherited;
end;

function TListLazyZipEnumerator<T, TSecond, TResult>.GetCurrent: TResult;
begin
  Result := FCurrent;
end;

function TListLazyZipEnumerator<T, TSecond, TResult>.MoveNext: Boolean;
begin
  if FEnum1.MoveNext and FEnum2.MoveNext then
  begin
    FCurrent := FResultSelector(FEnum1.Current, FEnum2.Current);
    Result := True;
  end
  else
    Result := False;
end;

procedure TListLazyZipEnumerator<T, TSecond, TResult>.Reset;
begin
  FEnum1.Reset;
  FEnum2.Reset;
end;

{ TListLazyZipEnumerable<T, TSecond, TResult> }

constructor TListLazyZipEnumerable<T, TSecond, TResult>.Create(const AZipEnum: TListLazyZipEnumerator<T, TSecond, TResult>);
begin
  FZipEnum := AZipEnum;
end;

destructor TListLazyZipEnumerable<T, TSecond, TResult>.Destroy;
begin
  FZipEnum.Free;
  inherited;
end;

function TListLazyZipEnumerable<T, TSecond, TResult>.GetEnumerator: IEnumEx<TResult>;
begin
  Result := FZipEnum;
end;

{ TListLazyJoinEnumerator<T, TInner, TKey, TResult> }

constructor TListLazyJoinEnumerator<T, TInner, TKey, TResult>.Create(const AOuterEnum: IEnumEx<T>;
  const AInnerItems: TList<TInner>; const AOuterKeySelector: TFunc<T, TKey>;
  const AInnerKeySelector: TFunc<TInner, TKey>; const AResultSelector: TFunc<T, TInner, TResult>);
begin
  FOuterEnum := AOuterEnum;
  FInnerItems := AInnerItems;
  FOuterKeySelector := AOuterKeySelector;
  FInnerKeySelector := AInnerKeySelector;
  FResultSelector := AResultSelector;
  FComparer := TEqualityComparer<TKey>.Default;
  FInnerIndex := 0;
end;

destructor TListLazyJoinEnumerator<T, TInner, TKey, TResult>.Destroy;
begin
  FOuterEnum := nil;
  FInnerItems.Free;
  inherited;
end;

function TListLazyJoinEnumerator<T, TInner, TKey, TResult>.GetCurrent: TResult;
begin
  Result := FCurrent;
end;

function TListLazyJoinEnumerator<T, TInner, TKey, TResult>.MoveNext: Boolean;
var
  LOuterKey, LInnerKey: TKey;
begin
  while True do
  begin
    if FInnerIndex < FInnerItems.Count then
    begin
      LOuterKey := FOuterKeySelector(FOuterCurrent);
      LInnerKey := FInnerKeySelector(FInnerItems[FInnerIndex]);
      if FComparer.Equals(LOuterKey, LInnerKey) then
      begin
        FCurrent := FResultSelector(FOuterCurrent, FInnerItems[FInnerIndex]);
        Inc(FInnerIndex);
        Result := True;
        Exit;
      end;
      Inc(FInnerIndex);
    end
    else if FOuterEnum.MoveNext then
    begin
      FOuterCurrent := FOuterEnum.Current;
      FInnerIndex := 0;
    end
    else
    begin
      Result := False;
      Exit;
    end;
  end;
end;

procedure TListLazyJoinEnumerator<T, TInner, TKey, TResult>.Reset;
begin
  FOuterEnum.Reset;
  FInnerIndex := 0;
end;

{ TListLazyJoinEnumerable<T, TInner, TKey, TResult> }

constructor TListLazyJoinEnumerable<T, TInner, TKey, TResult>.Create(
  const AJoinEnum: TListLazyJoinEnumerator<T, TInner, TKey, TResult>;
  const AInnerItems: TList<TInner>);
begin
  FJoinEnum := AJoinEnum;
  FInnerItems := AInnerItems;
end;

destructor TListLazyJoinEnumerable<T, TInner, TKey, TResult>.Destroy;
begin
  FJoinEnum.Free;
  FInnerItems.Free;
  inherited;
end;

function TListLazyJoinEnumerable<T, TInner, TKey, TResult>.GetEnumerator: IEnumEx<TResult>;
begin
  Result := FJoinEnum;
end;

{ TListLazyFilter<T> }

constructor TListLazyFilterEnumerable<T>.Create(const ASource: IListLazyEnumerable<T>; const APredicate: TFunc<T, Boolean>);
begin
  FSource := ASource;
  FPredicate := APredicate;
end;

destructor TListLazyFilterEnumerable<T>.Destroy;
begin
  FSource := nil;
  inherited;
end;

function TListLazyFilterEnumerable<T>.GetEnumerator: IEnumEx<T>;
begin
  Result := TListLazyFilterEnumerator<T>.Create(FSource.GetEnumerator, FPredicate);
end;

{ TListLazyFilterEnumerator<T> }

constructor TListLazyFilterEnumerator<T>.Create(const ASource: IEnumEx<T>;
  const APredicate: TFunc<T, Boolean>);
begin
  FSource := ASource;
  FPredicate := APredicate;
  FHasNext := False;
end;

destructor TListLazyFilterEnumerator<T>.Destroy;
begin
  FSource := nil;
  inherited;
end;

function TListLazyFilterEnumerator<T>.GetCurrent: T;
begin
  Result := FCurrent;
end;

function TListLazyFilterEnumerator<T>.MoveNext: Boolean;
begin
  while FSource.MoveNext do
  begin
    FCurrent := FSource.Current;
    if FPredicate(FCurrent) then
    begin
      Result := True;
      Exit;
    end;
  end;
  Result := False;
end;

procedure TListLazyFilterEnumerator<T>.Reset;
begin
  FSource.Reset;
  FHasNext := False;
end;

{ TListLazyTake<T> }

constructor TListLazyTakeEnumerable<T>.Create(const ASource: IListLazyEnumerable<T>; const ACount: Integer);
begin
  FSource := ASource;
  FCount := ACount;
end;

destructor TListLazyTakeEnumerable<T>.Destroy;
begin
  FSource := nil;
  inherited;
end;

function TListLazyTakeEnumerable<T>.GetEnumerator: IEnumEx<T>;
begin
  Result := TListLazyTakeEnumerator<T>.Create(FSource.GetEnumerator, FCount);
end;

{ TListLazyTakeEnumerator<T> }

constructor TListLazyTakeEnumerator<T>.Create(const ASource: IEnumEx<T>;
  const ACount: Integer);
begin
  FSource := ASource;
  FCount := ACount;
  FHasNext := False;
  FTaken := 0;
end;

destructor TListLazyTakeEnumerator<T>.Destroy;
begin
  FSource := nil;
  inherited;
end;

function TListLazyTakeEnumerator<T>.GetCurrent: T;
begin
  Result := FCurrent;
end;

function TListLazyTakeEnumerator<T>.MoveNext: Boolean;
begin
  if FTaken >= FCount then
  begin
    Result := False;
    Exit;
  end;

  if FSource.MoveNext then
  begin
    FCurrent := FSource.Current;
    Inc(FTaken);
    Result := True;
  end
  else
    Result := False;
end;

procedure TListLazyTakeEnumerator<T>.Reset;
begin
  FSource.Reset;
  FTaken := 0;
  FHasNext := False;
end;

{ TListLazySkip<T> }

constructor TListLazySkipEnumerable<T>.Create(const ASource: IListLazyEnumerable<T>; const ACount: Integer);
begin
  FSource := ASource;
  FCount := ACount;
end;

destructor TListLazySkipEnumerable<T>.Destroy;
begin
  FSource := nil;
  inherited;
end;

function TListLazySkipEnumerable<T>.GetEnumerator: IEnumEx<T>;
begin
  Result := TListLazySkipEnumerator<T>.Create(FSource.GetEnumerator, FCount);
end;

{ TListLazySkipEnumerator<T> }

constructor TListLazySkipEnumerator<T>.Create(const ASource: IEnumEx<T>;
  const ACount: Integer);
begin
  FSource := ASource;
  FCount := ACount;
  FHasNext := False;
  FSkipped := 0;
end;

destructor TListLazySkipEnumerator<T>.Destroy;
begin
  FSource := nil;
  inherited;
end;

function TListLazySkipEnumerator<T>.GetCurrent: T;
begin
  Result := FCurrent;
end;

function TListLazySkipEnumerator<T>.MoveNext: Boolean;
begin
  while FSource.MoveNext do
  begin
    if FSkipped < FCount then
    begin
      Inc(FSkipped);
      Continue;
    end;
    FCurrent := FSource.Current;
    Result := True;
    Exit;
  end;
  Result := False;
end;

procedure TListLazySkipEnumerator<T>.Reset;
begin
  FSource.Reset;
  FSkipped := 0;
  FHasNext := False;
end;

{ TListLazyOrderBy<T> }

constructor TListLazyOrderByEnumerable<T>.Create(const ASource: IListLazyEnumerable<T>; const AComparer: TFunc<T, T, Integer>);
begin
  FSource := ASource;
  FComparer := AComparer;
end;

destructor TListLazyOrderByEnumerable<T>.Destroy;
begin
  FSource := nil;
  inherited;
end;

function TListLazyOrderByEnumerable<T>.GetEnumerator: IEnumEx<T>;
begin
  Result := TListLazyOrderByEnumerator<T>.Create(FSource.GetEnumerator, FComparer);
end;

{ TListLazyOrderByEnumerator<T> }

constructor TListLazyOrderByEnumerator<T>.Create(const ASourceEnum: IEnumEx<T>;
  const AComparer: TFunc<T, T, Integer>);
var
  LList: TList<T>;
  LEnum: IEnumEx<T>;
begin
  FComparer := AComparer;
  FIndex := -1;
  LList := TList<T>.Create;
  try
    LEnum := ASourceEnum;
    while LEnum.MoveNext do
      LList.Add(LEnum.Current);
    FItems := LList.ToArray;
    TArray.Sort<T>(FItems, TComparer<T>.Construct(
      function(const Left, Right: T): Integer
      begin
        Result := FComparer(Left, Right);
      end));
  finally
    LList.Free;
  end;
end;

destructor TListLazyOrderByEnumerator<T>.Destroy;
begin
  inherited;
end;

function TListLazyOrderByEnumerator<T>.GetCurrent: T;
begin
  Result := FItems[FIndex];
end;

function TListLazyOrderByEnumerator<T>.MoveNext: Boolean;
begin
  Inc(FIndex);
  Result := FIndex < Length(FItems);
end;

procedure TListLazyOrderByEnumerator<T>.Reset;
begin
  FIndex := -1;
end;

{ TListLazyDistinct<T> }

constructor TListLazyDistinctEnumerable<T>.Create(const ASource: IListLazyEnumerable<T>);
begin
  FSource := ASource;
end;

destructor TListLazyDistinctEnumerable<T>.Destroy;
begin
  FSource := nil;
  inherited;
end;

function TListLazyDistinctEnumerable<T>.GetEnumerator: IEnumEx<T>;
begin
  Result := TListLazyDistinctEnumerator<T>.Create(FSource.GetEnumerator);
end;

{ TListLazyDistinctEnumerator<T> }

constructor TListLazyDistinctEnumerator<T>.Create(const ASource: IEnumEx<T>);
begin
  FSource := ASource;
  FHasNext := False;
  FSeen := TList<T>.Create;
end;

destructor TListLazyDistinctEnumerator<T>.Destroy;
begin
  FSource := nil;
  FSeen.Free;
  inherited;
end;

function TListLazyDistinctEnumerator<T>.GetCurrent: T;
begin
  Result := FCurrent;
end;

function TListLazyDistinctEnumerator<T>.MoveNext: Boolean;
var
  LComparer: IEqualityComparer<T>;
  LFound: Boolean;
begin
  LComparer := TEqualityComparer<T>.Default;
  while FSource.MoveNext do
  begin
    FCurrent := FSource.Current;
    LFound := False;
    for var LItem in FSeen do
    begin
      if LComparer.Equals(LItem, FCurrent) then
      begin
        LFound := True;
        Break;
      end;
    end;
    if not LFound then
    begin
      FSeen.Add(FCurrent);
      Result := True;
      Exit;
    end;
  end;
  Result := False;
end;

procedure TListLazyDistinctEnumerator<T>.Reset;
begin
  FSource.Reset;
  FSeen.Clear;
  FHasNext := False;
end;

{ TListLazyReduceWithInitial<T> }

constructor TListLazyReduceWithInitialEnumerable<T>.Create(const ASource: IListLazyEnumerable<T>;
  const AReducer: TFunc<T, T, T>; const AInitialValue: T);
begin
  FSource := ASource;
  FReducer := AReducer;
  FInitialValue := AInitialValue;
end;

destructor TListLazyReduceWithInitialEnumerable<T>.Destroy;
begin
  FSource := nil;
  inherited;
end;

function TListLazyReduceWithInitialEnumerable<T>.Reduce(const AReducer: TFunc<T, T, T>; const AInitialValue: T): T;
var
  LEnum: IEnumEx<T>;
  LResult: T;
begin
  LEnum := FSource.GetEnumerator;
  LResult := AInitialValue;
  while LEnum.MoveNext do
    LResult := AReducer(LResult, LEnum.Current);
  Result := LResult;
end;

function TListLazyReduceWithInitialEnumerable<T>.GetEnumerator: IEnumEx<T>;
begin
  Result := FSource.GetEnumerator;
end;

{ TListLazyReduce<T> }

constructor TListLazyReduceEnumerable<T>.Create(const ASource: IListLazyEnumerable<T>;
  const AReducer: TFunc<T, T, T>);
begin
  FSource := ASource;
  FReducer := AReducer;
end;

destructor TListLazyReduceEnumerable<T>.Destroy;
begin
  FSource := nil;
  inherited;
end;

function TListLazyReduceEnumerable<T>.Reduce(const AReducer: TFunc<T, T, T>): T;
var
  LEnum: IEnumEx<T>;
  LResult: T;
  LHasValue: Boolean;
begin
  LEnum := FSource.GetEnumerator;
  LHasValue := False;
  while LEnum.MoveNext do
  begin
    if not LHasValue then
    begin
      LResult := LEnum.Current;
      LHasValue := True;
    end
    else
      LResult := AReducer(LResult, LEnum.Current);
  end;
  if not LHasValue then
    raise EInvalidOperation.Create('Sequence contains no elements');
  Result := LResult;
end;

function TListLazyReduceEnumerable<T>.GetEnumerator: IEnumEx<T>;
begin
  Result := FSource.GetEnumerator;
end;

{ TListLazyForEach<T> }

constructor TListLazyForEachEnumerable<T>.Create(const ASource: IListLazyEnumerable<T>;
  const AAction: TAction<T>);
begin
  FSource := ASource;
  FAction := AAction;
end;

destructor TListLazyForEachEnumerable<T>.Destroy;
begin
  FSource := nil;
  inherited;
end;

function TListLazyForEachEnumerable<T>.GetEnumerator: IEnumEx<T>;
var
  LEnum: IEnumEx<T>;
begin
  LEnum := FSource.GetEnumerator;
  while LEnum.MoveNext do
    FAction(LEnum.Current);
  Result := LEnum;
end;

{ TListLazySumDouble<T> }

constructor TListLazySumDoubleEnumerable<T>.Create(const ASource: IListLazyEnumerable<T>;
  const ASelector: TFunc<T, Double>);
begin
  FSource := ASource;
  FSelector := ASelector;
end;

destructor TListLazySumDoubleEnumerable<T>.Destroy;
begin
  FSource := nil;
  inherited;
end;

function TListLazySumDoubleEnumerable<T>.Sum(const ASelector: TFunc<T, Double>): Double;
var
  LEnum: IEnumEx<T>;
  LSum: Double;
begin
  LEnum := FSource.GetEnumerator;
  LSum := 0;
  while LEnum.MoveNext do
    LSum := LSum + ASelector(LEnum.Current);
  Result := LSum;
end;

function TListLazySumDoubleEnumerable<T>.GetEnumerator: IEnumEx<T>;
begin
  Result := FSource.GetEnumerator;
end;

{ TListLazySumInteger<T> }

constructor TListLazySumIntegerEnumerable<T>.Create(const ASource: IListLazyEnumerable<T>;
  const ASelector: TFunc<T, Integer>);
begin
  FSource := ASource;
  FSelector := ASelector;
end;

destructor TListLazySumIntegerEnumerable<T>.Destroy;
begin
  FSource := nil;
  inherited;
end;

function TListLazySumIntegerEnumerable<T>.Sum(const ASelector: TFunc<T, Integer>): Integer;
var
  LEnum: IEnumEx<T>;
  LSum: Integer;
begin
  LEnum := FSource.GetEnumerator;
  LSum := 0;
  while LEnum.MoveNext do
    LSum := LSum + ASelector(LEnum.Current);
  Result := LSum;
end;

function TListLazySumIntegerEnumerable<T>.GetEnumerator: IEnumEx<T>;
begin
  Result := FSource.GetEnumerator;
end;

{ TListLazyMinComparer<T> }

constructor TListLazyMinComparerEnumerable<T>.Create(const ASource: IListLazyEnumerable<T>;
  const AComparer: TFunc<T, T, Integer>);
begin
  FSource := ASource;
  FComparer := AComparer;
end;

destructor TListLazyMinComparerEnumerable<T>.Destroy;
begin
  FSource := nil;
  inherited;
end;

function TListLazyMinComparerEnumerable<T>.Min(const AComparer: TFunc<T, T, Integer>): T;
var
  LEnum: IEnumEx<T>;
  LMin: T;
  LHasValue: Boolean;
begin
  LEnum := FSource.GetEnumerator;
  LHasValue := False;
  while LEnum.MoveNext do
  begin
    if not LHasValue then
    begin
      LMin := LEnum.Current;
      LHasValue := True;
    end
    else if AComparer(LEnum.Current, LMin) < 0 then
      LMin := LEnum.Current;
  end;
  if not LHasValue then
    raise EInvalidOperation.Create('Sequence contains no elements');
  Result := LMin;
end;

function TListLazyMinComparerEnumerable<T>.GetEnumerator: IEnumEx<T>;
begin
  Result := FSource.GetEnumerator;
end;

{ TListLazyMin<T> }

constructor TListLazyMinEnumerable<T>.Create(const ASource: IListLazyEnumerable<T>);
begin
  FSource := ASource;
end;

destructor TListLazyMinEnumerable<T>.Destroy;
begin
  FSource := nil;
  inherited;
end;

function TListLazyMinEnumerable<T>.GetEnumerator: IEnumEx<T>;
begin
  Result := FSource.GetEnumerator;
end;

{ TListLazyMaxComparer<T> }

constructor TListLazyMaxComparerEnumerable<T>.Create(const ASource: IListLazyEnumerable<T>;
  const AComparer: TFunc<T, T, Integer>);
begin
  FSource := ASource;
  FComparer := AComparer;
end;

destructor TListLazyMaxComparerEnumerable<T>.Destroy;
begin
  FSource := nil;
  inherited;
end;

function TListLazyMaxComparerEnumerable<T>.Max(const AComparer: TFunc<T, T, Integer>): T;
var
  LEnum: IEnumEx<T>;
  LMax: T;
  LHasValue: Boolean;
begin
  LEnum := FSource.GetEnumerator;
  LHasValue := False;
  while LEnum.MoveNext do
  begin
    if not LHasValue then
    begin
      LMax := LEnum.Current;
      LHasValue := True;
    end
    else if AComparer(LEnum.Current, LMax) > 0 then
      LMax := LEnum.Current;
  end;
  if not LHasValue then
    raise EInvalidOperation.Create('Sequence contains no elements');
  Result := LMax;
end;

function TListLazyMaxComparerEnumerable<T>.GetEnumerator: IEnumEx<T>;
begin
  Result := FSource.GetEnumerator;
end;

{ TListLazyMax<T> }

constructor TListLazyMaxEnumerable<T>.Create(const ASource: IListLazyEnumerable<T>);
begin
  FSource := ASource;
end;

destructor TListLazyMaxEnumerable<T>.Destroy;
begin
  FSource := nil;
  inherited;
end;

function TListLazyMaxEnumerable<T>.GetEnumerator: IEnumEx<T>;
begin
  Result := FSource.GetEnumerator;
end;

{ TListLazyAny<T> }

constructor TListLazyAnyEnumerable<T>.Create(const ASource: IListLazyEnumerable<T>;
  const APredicate: TFunc<T, Boolean>);
begin
  FSource := ASource;
  FPredicate := APredicate;
end;

destructor TListLazyAnyEnumerable<T>.Destroy;
begin
  FSource := nil;
  inherited;
end;

function TListLazyAnyEnumerable<T>.Any(const APredicate: TFunc<T, Boolean>): Boolean;
var
  LEnum: IEnumEx<T>;
begin
  LEnum := FSource.GetEnumerator;
  while LEnum.MoveNext do
    if APredicate(LEnum.Current) then
    begin
      Result := True;
      Exit;
    end;
  Result := False;
end;

function TListLazyAnyEnumerable<T>.GetEnumerator: IEnumEx<T>;
begin
  Result := FSource.GetEnumerator;
end;

{ TListLazyFirstOrDefault<T> }

constructor TListLazyFirstOrDefaultEnumerable<T>.Create(const ASource: IListLazyEnumerable<T>;
  const APredicate: TFunc<T, Boolean>);
begin
  FSource := ASource;
  FPredicate := APredicate;
end;

destructor TListLazyFirstOrDefaultEnumerable<T>.Destroy;
begin
  FSource := nil;
  inherited;
end;

function TListLazyFirstOrDefaultEnumerable<T>.FirstOrDefault(const APredicate: TFunc<T, Boolean>): T;
var
  LEnum: IEnumEx<T>;
begin
  LEnum := FSource.GetEnumerator;
  while LEnum.MoveNext do
    if APredicate(LEnum.Current) then
    begin
      Result := LEnum.Current;
      Exit;
    end;
  Result := Default(T);
end;

function TListLazyFirstOrDefaultEnumerable<T>.GetEnumerator: IEnumEx<T>;
begin
  Result := FSource.GetEnumerator;
end;

{ TListLazyLast<T> }

constructor TListLazyLastEnumerable<T>.Create(const ASource: IListLazyEnumerable<T>;
  const APredicate: TFunc<T, Boolean>);
begin
  FSource := ASource;
  FPredicate := APredicate;
end;

destructor TListLazyLastEnumerable<T>.Destroy;
begin
  FSource := nil;
  inherited;
end;

function TListLazyLastEnumerable<T>.Last(const APredicate: TFunc<T, Boolean>): T;
var
  LEnum: IEnumEx<T>;
  LLast: T;
  LHasValue: Boolean;
begin
  LEnum := FSource.GetEnumerator;
  LHasValue := False;
  while LEnum.MoveNext do
    if APredicate(LEnum.Current) then
    begin
      LLast := LEnum.Current;
      LHasValue := True;
    end;
  if not LHasValue then
    raise EInvalidOperation.Create('Sequence contains no matching elements');
  Result := LLast;
end;

function TListLazyLastEnumerable<T>.GetEnumerator: IEnumEx<T>;
begin
  Result := FSource.GetEnumerator;
end;

{ TListLazyLastOrDefault<T> }

constructor TListLazyLastOrDefaultEnumerable<T>.Create(const ASource: IListLazyEnumerable<T>;
  const APredicate: TFunc<T, Boolean>);
begin
  FSource := ASource;
  FPredicate := APredicate;
end;

destructor TListLazyLastOrDefaultEnumerable<T>.Destroy;
begin
  FSource := nil;
  inherited;
end;

function TListLazyLastOrDefaultEnumerable<T>.LastOrDefault(const APredicate: TFunc<T, Boolean>): T;
var
  LEnum: IEnumEx<T>;
  LLast: T;
  LHasValue: Boolean;
begin
  LEnum := FSource.GetEnumerator;
  LHasValue := False;
  while LEnum.MoveNext do
    if APredicate(LEnum.Current) then
    begin
      LLast := LEnum.Current;
      LHasValue := True;
    end;
  if not LHasValue then
    Result := Default(T)
  else
    Result := LLast;
end;

function TListLazyLastOrDefaultEnumerable<T>.GetEnumerator: IEnumEx<T>;
begin
  Result := FSource.GetEnumerator;
end;

{ TListLazyCount<T> }

constructor TListLazyCountEnumerable<T>.Create(const ASource: IListLazyEnumerable<T>;
  const APredicate: TFunc<T, Boolean>);
begin
  FSource := ASource;
  FPredicate := APredicate;
end;

destructor TListLazyCountEnumerable<T>.Destroy;
begin
  FSource := nil;
  inherited;
end;

function TListLazyCountEnumerable<T>.Count(const APredicate: TFunc<T, Boolean>): Integer;
var
  LEnum: IEnumEx<T>;
  LCount: Integer;
begin
  LEnum := FSource.GetEnumerator;
  LCount := 0;
  while LEnum.MoveNext do
    if APredicate(LEnum.Current) then
      Inc(LCount);
  Result := LCount;
end;

function TListLazyCountEnumerable<T>.GetEnumerator: IEnumEx<T>;
begin
  Result := FSource.GetEnumerator;
end;

{ TListLazyLongCount<T> }

constructor TListLazyLongCountEnumerable<T>.Create(const ASource: IListLazyEnumerable<T>;
  const APredicate: TFunc<T, Boolean>);
begin
  FSource := ASource;
  FPredicate := APredicate;
end;

destructor TListLazyLongCountEnumerable<T>.Destroy;
begin
  FSource := nil;
  inherited;
end;

function TListLazyLongCountEnumerable<T>.LongCount(const APredicate: TFunc<T, Boolean>): Int64;
var
  LEnum: IEnumEx<T>;
  LCount: Int64;
begin
  LEnum := FSource.GetEnumerator;
  LCount := 0;
  while LEnum.MoveNext do
    if APredicate(LEnum.Current) then
      Inc(LCount);
  Result := LCount;
end;

function TListLazyLongCountEnumerable<T>.GetEnumerator: IEnumEx<T>;
begin
  Result := FSource.GetEnumerator;
end;

{ TListLazyToArray<T> }

constructor TListLazyToArrayEnumerable<T>.Create(const ASource: IListLazyEnumerable<T>);
begin
  FSource := ASource;
end;

destructor TListLazyToArrayEnumerable<T>.Destroy;
begin
  FSource := nil;
  inherited;
end;

function TListLazyToArrayEnumerable<T>.GetEnumerator: IEnumEx<T>;
begin
  Result := FSource.GetEnumerator;
end;

{ TListLazyToList<T> }

constructor TListLazyToListEnumerable<T>.Create(const ASource: IListLazyEnumerable<T>);
begin
  FSource := ASource;
end;

constructor TListLazyToListEnumerable<T>.Create(const AEnumSource: IEnumEx<T>);
begin
  FEnumSource := AEnumSource;
end;

destructor TListLazyToListEnumerable<T>.Destroy;
begin
  FSource := nil;
  FEnumSource := nil;
  inherited;
end;

function TListLazyToListEnumerable<T>.GetEnumerator: IEnumEx<T>;
begin
  if Assigned(FSource) then
    Result := FSource.GetEnumerator
  else
    Result := FEnumSource;
end;

{ TListLazyGroupBy<T, TKey> }

constructor TListLazyGroupByEnumerator<T, TKey>.Create(const ASource: IListLazyEnumerable<T>;
  const AKeySelector: TFunc<T, TKey>);
var
  LEnum: IEnumEx<T>;
  LDict: TDictionary<TKey, TList<T>>;
  LKey: TKey;
  LItem: T;
  LGroup: TList<T>;
begin
  FSource := ASource;
  FKeySelector := AKeySelector;
  FGroups := TList<IGrouping<TKey, T>>.Create;
  LDict := TDictionary<TKey, TList<T>>.Create;
  try
    LEnum := FSource.GetEnumerator;
    while LEnum.MoveNext do
    begin
      LItem := LEnum.Current;
      LKey := FKeySelector(LItem);
      if not LDict.TryGetValue(LKey, LGroup) then
      begin
        LGroup := TList<T>.Create;
        LDict.Add(LKey, LGroup);
        FGroups.Add(TGroupingEnumerable<TKey, T>.Create(LKey, LGroup));
      end;
      LGroup.Add(LItem);
    end;
  finally
    LDict.Free;
  end;
end;

destructor TListLazyGroupByEnumerator<T, TKey>.Destroy;
begin
  FSource := nil;
  FGroups.Free;
  inherited;
end;

function TListLazyGroupByEnumerator<T, TKey>.GetEnumerator: IEnumEx<IGrouping<TKey, T>>;
begin
  Result := TArrayEnumerator<IGrouping<TKey, T>>.Create(FGroups.ToArray);
end;

function TListLazyGroupByEnumerator<T, TKey>.AsEnumerable: IListEnumerable<IGrouping<TKey, T>>;
begin
  Result := IListEnumerable<IGrouping<TKey, T>>.Create(
    TGroupedEnumeratorAdapter<TKey, T>.Create(Self));
end;

{ TDictLazyEnumerable<K, V> }

constructor TDictLazyEnumerable<K, V>.Create(const ASource: IDictLazyEnumerable<K, V>);
begin
  FSource := ASource;
end;

destructor TDictLazyEnumerable<K, V>.Destroy;
begin
  FSource := nil;
  inherited;
end;

function TDictLazyEnumerable<K, V>.GetEnumerator: IEnumEx<TPair<K, V>>;
begin
  Result := FSource.GetEnumerator;
end;

{ TDictLazyFilter<K, V> }

constructor TDictLazyFilterEnumerable<K, V>.Create(const ASource: IDictLazyEnumerable<K, V>;
  const APredicate: TFunc<TPair<K, V>, Boolean>);
begin
  FSource := ASource;
  FPredicate := APredicate;
end;

destructor TDictLazyFilterEnumerable<K, V>.Destroy;
begin
  FSource := nil;
  inherited;
end;

function TDictLazyFilterEnumerable<K, V>.GetEnumerator: IEnumEx<TPair<K, V>>;
begin
  Result := TDictLazyFilterEnumerator<K, V>.Create(FSource.GetEnumerator, FPredicate);
end;

{ TDictLazyFilterEnumerator<K, V> }

constructor TDictLazyFilterEnumerator<K, V>.Create(const ASource: IEnumEx<TPair<K, V>>;
  const APredicate: TFunc<TPair<K, V>, Boolean>);
begin
  FSource := ASource;
  FPredicate := APredicate;
  FHasNext := False;
end;

destructor TDictLazyFilterEnumerator<K, V>.Destroy;
begin
  FSource := nil;
  inherited;
end;

function TDictLazyFilterEnumerator<K, V>.GetCurrent: TPair<K, V>;
begin
  Result := FCurrent;
end;

function TDictLazyFilterEnumerator<K, V>.MoveNext: Boolean;
begin
  while FSource.MoveNext do
  begin
    FCurrent := FSource.Current;
    if FPredicate(FCurrent) then
    begin
      Result := True;
      Exit;
    end;
  end;
  Result := False;
end;

procedure TDictLazyFilterEnumerator<K, V>.Reset;
begin
  FSource.Reset;
  FHasNext := False;
end;

{ TDictLazyTake<K, V> }

constructor TDictLazyTakeEnumerable<K, V>.Create(const ASource: IDictLazyEnumerable<K, V>;
  const ACount: Integer);
begin
  FSource := ASource;
  FCount := ACount;
end;

destructor TDictLazyTakeEnumerable<K, V>.Destroy;
begin
  FSource := nil;
  inherited;
end;

function TDictLazyTakeEnumerable<K, V>.GetEnumerator: IEnumEx<TPair<K, V>>;
begin
  Result := TDictLazyTakeEnumerator<K, V>.Create(FSource.GetEnumerator, FCount);
end;

{ TDictLazyTakeEnumerator<K, V> }

constructor TDictLazyTakeEnumerator<K, V>.Create(const ASource: IEnumEx<TPair<K, V>>;
  const ACount: Integer);
begin
  FSource := ASource;
  FCount := ACount;
  FHasNext := False;
  FTaken := 0;
end;

destructor TDictLazyTakeEnumerator<K, V>.Destroy;
begin
  FSource := nil;
  inherited;
end;

function TDictLazyTakeEnumerator<K, V>.GetCurrent: TPair<K, V>;
begin
  Result := FCurrent;
end;

function TDictLazyTakeEnumerator<K, V>.MoveNext: Boolean;
begin
  if FTaken >= FCount then
  begin
    Result := False;
    Exit;
  end;

  if FSource.MoveNext then
  begin
    FCurrent := FSource.Current;
    Inc(FTaken);
    Result := True;
  end
  else
    Result := False;
end;

procedure TDictLazyTakeEnumerator<K, V>.Reset;
begin
  FSource.Reset;
  FTaken := 0;
  FHasNext := False;
end;

{ TDictLazySkip<K, V> }

constructor TDictLazySkipEnumerable<K, V>.Create(const ASource: IDictLazyEnumerable<K, V>;
  const ACount: Integer);
begin
  FSource := ASource;
  FCount := ACount;
end;

destructor TDictLazySkipEnumerable<K, V>.Destroy;
begin
  FSource := nil;
  inherited;
end;

function TDictLazySkipEnumerable<K, V>.GetEnumerator: IEnumEx<TPair<K, V>>;
begin
  Result := TDictLazySkipEnumerator<K, V>.Create(FSource.GetEnumerator, FCount);
end;

{ TDictLazySkipEnumerator<K, V> }

constructor TDictLazySkipEnumerator<K, V>.Create(const ASource: IEnumEx<TPair<K, V>>;
  const ACount: Integer);
begin
  FSource := ASource;
  FCount := ACount;
  FHasNext := False;
  FSkipped := 0;
end;

destructor TDictLazySkipEnumerator<K, V>.Destroy;
begin
  FSource := nil;
  inherited;
end;

function TDictLazySkipEnumerator<K, V>.GetCurrent: TPair<K, V>;
begin
  Result := FCurrent;
end;

function TDictLazySkipEnumerator<K, V>.MoveNext: Boolean;
begin
  while FSource.MoveNext do
  begin
    if FSkipped < FCount then
    begin
      Inc(FSkipped);
      Continue;
    end;
    FCurrent := FSource.Current;
    Result := True;
    Exit;
  end;
  Result := False;
end;

procedure TDictLazySkipEnumerator<K, V>.Reset;
begin
  FSource.Reset;
  FSkipped := 0;
  FHasNext := False;
end;

{ TDictLazyOrderBy<K, V> }

constructor TDictLazyOrderByEnumerable<K, V>.Create(const ASource: IDictLazyEnumerable<K, V>;
  const AComparer: TFunc<TPair<K, V>, TPair<K, V>, Integer>);
begin
  FSource := ASource;
  FComparer := AComparer;
end;

destructor TDictLazyOrderByEnumerable<K, V>.Destroy;
begin
  FSource := nil;
  inherited;
end;

function TDictLazyOrderByEnumerable<K, V>.GetEnumerator: IEnumEx<TPair<K, V>>;
begin
  Result := TDictLazyOrderByEnumerator<K, V>.Create(FSource.GetEnumerator, FComparer);
end;

{ TDictLazyOrderByEnumerator<K, V> }

constructor TDictLazyOrderByEnumerator<K, V>.Create(const ASource: IEnumEx<TPair<K, V>>;
  const AComparer: TFunc<TPair<K, V>, TPair<K, V>, Integer>);
var
  LList: TList<TPair<K, V>>;
  LEnum: IEnumEx<TPair<K, V>>;
begin
  FComparer := AComparer;
  FIndex := -1;
  LList := TList<TPair<K, V>>.Create;
  try
    LEnum := ASource;
    while LEnum.MoveNext do
      LList.Add(LEnum.Current);
    FItems := LList.ToArray;
    TArray.Sort<TPair<K, V>>(FItems, TComparer<TPair<K, V>>.Construct(
      function(const Left, Right: TPair<K, V>): Integer
      begin
        Result := FComparer(Left, Right);
      end));
  finally
    LList.Free;
  end;
end;

destructor TDictLazyOrderByEnumerator<K, V>.Destroy;
begin
  inherited;
end;

function TDictLazyOrderByEnumerator<K, V>.GetCurrent: TPair<K, V>;
begin
  Result := FItems[FIndex];
end;

function TDictLazyOrderByEnumerator<K, V>.MoveNext: Boolean;
begin
  Inc(FIndex);
  Result := FIndex < Length(FItems);
end;

procedure TDictLazyOrderByEnumerator<K, V>.Reset;
begin
  FIndex := -1;
end;

{ TDictLazyDistinct<K, V> }

constructor TDictLazyDistinctEnumerable<K, V>.Create(const ASource: IDictLazyEnumerable<K, V>);
begin
  FSource := ASource;
end;

destructor TDictLazyDistinctEnumerable<K, V>.Destroy;
begin
  FSource := nil;
  inherited;
end;

function TDictLazyDistinctEnumerable<K, V>.GetEnumerator: IEnumEx<TPair<K, V>>;
begin
  Result := TDictLazyDistinctEnumerator<K, V>.Create(FSource.GetEnumerator);
end;

{ TDictLazyDistinctEnumerator<K, V> }

constructor TDictLazyDistinctEnumerator<K, V>.Create(const ASource: IEnumEx<TPair<K, V>>);
begin
  FSource := ASource;
  FHasNext := False;
  FSeen := TList<TPair<K, V>>.Create;
end;

destructor TDictLazyDistinctEnumerator<K, V>.Destroy;
begin
  FSource := nil;
  FSeen.Free;
  inherited;
end;

function TDictLazyDistinctEnumerator<K, V>.GetCurrent: TPair<K, V>;
begin
  Result := FCurrent;
end;

function TDictLazyDistinctEnumerator<K, V>.MoveNext: Boolean;
var
  LComparer: IEqualityComparer<TPair<K, V>>;
  LFound: Boolean;
begin
  LComparer := TEqualityComparer<TPair<K, V>>.Default;
  while FSource.MoveNext do
  begin
    FCurrent := FSource.Current;
    LFound := False;
    for var LItem in FSeen do
    begin
      if LComparer.Equals(LItem, FCurrent) then
      begin
        LFound := True;
        Break;
      end;
    end;
    if not LFound then
    begin
      FSeen.Add(FCurrent);
      Result := True;
      Exit;
    end;
  end;
  Result := False;
end;

procedure TDictLazyDistinctEnumerator<K, V>.Reset;
begin
  FSource.Reset;
  FSeen.Clear;
  FHasNext := False;
end;

{ TDictLazyReduceWithInitial<K, V> }

constructor TDictLazyReduceWithInitialEnumerable<K, V>.Create(const ASource: IDictLazyEnumerable<K, V>;
  const AReducer: TFunc<TPair<K, V>, TPair<K, V>, TPair<K, V>>; const AInitialValue: TPair<K, V>);
begin
  FSource := ASource;
  FReducer := AReducer;
  FInitialValue := AInitialValue;
end;

destructor TDictLazyReduceWithInitialEnumerable<K, V>.Destroy;
begin
  FSource := nil;
  inherited;
end;

function TDictLazyReduceWithInitialEnumerable<K, V>.Reduce(const AReducer: TFunc<TPair<K, V>, TPair<K, V>, TPair<K, V>>;
  const AInitialValue: TPair<K, V>): TPair<K, V>;
var
  LEnum: IEnumEx<TPair<K, V>>;
  LResult: TPair<K, V>;
begin
  LEnum := FSource.GetEnumerator;
  LResult := AInitialValue;
  while LEnum.MoveNext do
    LResult := AReducer(LResult, LEnum.Current);
  Result := LResult;
end;

function TDictLazyReduceWithInitialEnumerable<K, V>.GetEnumerator: IEnumEx<TPair<K, V>>;
begin
  Result := FSource.GetEnumerator;
end;

{ TDictLazyReduce<K, V> }

constructor TDictLazyReduceEnumerable<K, V>.Create(const ASource: IDictLazyEnumerable<K, V>;
  const AReducer: TFunc<TPair<K, V>, TPair<K, V>, TPair<K, V>>);
begin
  FSource := ASource;
  FReducer := AReducer;
end;

destructor TDictLazyReduceEnumerable<K, V>.Destroy;
begin
  FSource := nil;
  inherited;
end;

function TDictLazyReduceEnumerable<K, V>.Reduce(const AReducer: TFunc<TPair<K, V>, TPair<K, V>, TPair<K, V>>): TPair<K, V>;
var
  LEnum: IEnumEx<TPair<K, V>>;
  LResult: TPair<K, V>;
  LHasValue: Boolean;
begin
  LEnum := FSource.GetEnumerator;
  LHasValue := False;
  while LEnum.MoveNext do
  begin
    if not LHasValue then
    begin
      LResult := LEnum.Current;
      LHasValue := True;
    end
    else
      LResult := AReducer(LResult, LEnum.Current);
  end;
  if not LHasValue then
    raise EInvalidOperation.Create('Sequence contains no elements');
  Result := LResult;
end;

function TDictLazyReduceEnumerable<K, V>.GetEnumerator: IEnumEx<TPair<K, V>>;
begin
  Result := FSource.GetEnumerator;
end;

{ TDictLazyForEach<K, V> }

constructor TDictLazyForEachEnumerable<K, V>.Create(const ASource: IDictLazyEnumerable<K, V>;
  const AAction: TAction<TPair<K, V>>);
begin
  FSource := ASource;
  FAction := AAction;
end;

destructor TDictLazyForEachEnumerable<K, V>.Destroy;
begin
  FSource := nil;
  inherited;
end;

procedure TDictLazyForEachEnumerable<K, V>.ForEach(const AAction: TAction<TPair<K, V>>);
var
  LEnum: IEnumEx<TPair<K, V>>;
begin
  LEnum := FSource.GetEnumerator;
  while LEnum.MoveNext do
    AAction(LEnum.Current);
end;

function TDictLazyForEachEnumerable<K, V>.GetEnumerator: IEnumEx<TPair<K, V>>;
begin
  Result := FSource.GetEnumerator;
end;

{ TDictLazySumDouble<K, V> }

constructor TDictLazySumDoubleEnumerable<K, V>.Create(const ASource: IDictLazyEnumerable<K, V>;
  const ASelector: TFunc<TPair<K, V>, Double>);
begin
  FSource := ASource;
  FSelector := ASelector;
end;

destructor TDictLazySumDoubleEnumerable<K, V>.Destroy;
begin
  FSource := nil;
  inherited;
end;

function TDictLazySumDoubleEnumerable<K, V>.Sum(const ASelector: TFunc<TPair<K, V>, Double>): Double;
var
  LEnum: IEnumEx<TPair<K, V>>;
  LSum: Double;
begin
  LEnum := FSource.GetEnumerator;
  LSum := 0;
  while LEnum.MoveNext do
    LSum := LSum + ASelector(LEnum.Current);
  Result := LSum;
end;

function TDictLazySumDoubleEnumerable<K, V>.GetEnumerator: IEnumEx<TPair<K, V>>;
begin
  Result := FSource.GetEnumerator;
end;

{ TDictLazySumInteger<K, V> }

constructor TDictLazySumIntegerEnumerable<K, V>.Create(const ASource: IDictLazyEnumerable<K, V>;
  const ASelector: TFunc<TPair<K, V>, Integer>);
begin
  FSource := ASource;
  FSelector := ASelector;
end;

destructor TDictLazySumIntegerEnumerable<K, V>.Destroy;
begin
  FSource := nil;
  inherited;
end;

function TDictLazySumIntegerEnumerable<K, V>.Sum(const ASelector: TFunc<TPair<K, V>, Integer>): Integer;
var
  LEnum: IEnumEx<TPair<K, V>>;
  LSum: Integer;
begin
  LEnum := FSource.GetEnumerator;
  LSum := 0;
  while LEnum.MoveNext do
    LSum := LSum + ASelector(LEnum.Current);
  Result := LSum;
end;

function TDictLazySumIntegerEnumerable<K, V>.GetEnumerator: IEnumEx<TPair<K, V>>;
begin
  Result := FSource.GetEnumerator;
end;

{ TDictLazyMinComparer<K, V> }

constructor TDictLazyMinComparerEnumerable<K, V>.Create(const ASource: IDictLazyEnumerable<K, V>;
  const AComparer: TFunc<TPair<K, V>, TPair<K, V>, Integer>);
begin
  FSource := ASource;
  FComparer := AComparer;
end;

destructor TDictLazyMinComparerEnumerable<K, V>.Destroy;
begin
  FSource := nil;
  inherited;
end;

function TDictLazyMinComparerEnumerable<K, V>.Min(const AComparer: TFunc<TPair<K, V>, TPair<K, V>, Integer>): TPair<K, V>;
var
  LEnum: IEnumEx<TPair<K, V>>;
  LMin: TPair<K, V>;
  LHasValue: Boolean;
begin
  LEnum := FSource.GetEnumerator;
  LHasValue := False;
  while LEnum.MoveNext do
  begin
    if not LHasValue then
    begin
      LMin := LEnum.Current;
      LHasValue := True;
    end
    else if AComparer(LEnum.Current, LMin) < 0 then
      LMin := LEnum.Current;
  end;
  if not LHasValue then
    raise EInvalidOperation.Create('Sequence contains no elements');
  Result := LMin;
end;

function TDictLazyMinComparerEnumerable<K, V>.GetEnumerator: IEnumEx<TPair<K, V>>;
begin
  Result := FSource.GetEnumerator;
end;

{ TDictLazyMin<K, V> }

constructor TDictLazyMinEnumerable<K, V>.Create(const ASource: IDictLazyEnumerable<K, V>);
begin
  FSource := ASource;
end;

destructor TDictLazyMinEnumerable<K, V>.Destroy;
begin
  FSource := nil;
  inherited;
end;

function TDictLazyMinEnumerable<K, V>.GetEnumerator: IEnumEx<TPair<K, V>>;
begin
  Result := FSource.GetEnumerator;
end;

{ TDictLazyMaxComparer<K, V> }

constructor TDictLazyMaxComparerEnumerable<K, V>.Create(const ASource: IDictLazyEnumerable<K, V>;
  const AComparer: TFunc<TPair<K, V>, TPair<K, V>, Integer>);
begin
  FSource := ASource;
  FComparer := AComparer;
end;

destructor TDictLazyMaxComparerEnumerable<K, V>.Destroy;
begin
  FSource := nil;
  inherited;
end;

function TDictLazyMaxComparerEnumerable<K, V>.Max(const AComparer: TFunc<TPair<K, V>, TPair<K, V>, Integer>): TPair<K, V>;
var
  LEnum: IEnumEx<TPair<K, V>>;
  LMax: TPair<K, V>;
  LHasValue: Boolean;
begin
  LEnum := FSource.GetEnumerator;
  LHasValue := False;
  while LEnum.MoveNext do
  begin
    if not LHasValue then
    begin
      LMax := LEnum.Current;
      LHasValue := True;
    end
    else if AComparer(LEnum.Current, LMax) > 0 then
      LMax := LEnum.Current;
  end;
  if not LHasValue then
    raise EInvalidOperation.Create('Sequence contains no elements');
  Result := LMax;
end;

function TDictLazyMaxComparerEnumerable<K, V>.GetEnumerator: IEnumEx<TPair<K, V>>;
begin
  Result := FSource.GetEnumerator;
end;

{ TDictLazyMax<K, V> }

constructor TDictLazyMaxEnumerable<K, V>.Create(const ASource: IDictLazyEnumerable<K, V>);
begin
  FSource := ASource;
end;

destructor TDictLazyMaxEnumerable<K, V>.Destroy;
begin
  FSource := nil;
  inherited;
end;

function TDictLazyMaxEnumerable<K, V>.GetEnumerator: IEnumEx<TPair<K, V>>;
begin
  Result := FSource.GetEnumerator;
end;

{ TDictLazyAny<K, V> }

constructor TDictLazyAnyEnumerable<K, V>.Create(const ASource: IDictLazyEnumerable<K, V>;
  const APredicate: TFunc<TPair<K, V>, Boolean>);
begin
  FSource := ASource;
  FPredicate := APredicate;
end;

destructor TDictLazyAnyEnumerable<K, V>.Destroy;
begin
  FSource := nil;
  inherited;
end;

function TDictLazyAnyEnumerable<K, V>.Any(const APredicate: TFunc<TPair<K, V>, Boolean>): Boolean;
var
  LEnum: IEnumEx<TPair<K, V>>;
begin
  LEnum := FSource.GetEnumerator;
  while LEnum.MoveNext do
    if APredicate(LEnum.Current) then
    begin
      Result := True;
      Exit;
    end;
  Result := False;
end;

function TDictLazyAnyEnumerable<K, V>.GetEnumerator: IEnumEx<TPair<K, V>>;
begin
  Result := FSource.GetEnumerator;
end;

{ TDictLazyFirstOrDefault<K, V> }

constructor TDictLazyFirstOrDefaultEnumerable<K, V>.Create(const ASource: IDictLazyEnumerable<K, V>;
  const APredicate: TFunc<TPair<K, V>, Boolean>);
begin
  FSource := ASource;
  FPredicate := APredicate;
end;

destructor TDictLazyFirstOrDefaultEnumerable<K, V>.Destroy;
begin
  FSource := nil;
  inherited;
end;

function TDictLazyFirstOrDefaultEnumerable<K, V>.FirstOrDefault(const APredicate: TFunc<TPair<K, V>, Boolean>): TPair<K, V>;
var
  LEnum: IEnumEx<TPair<K, V>>;
begin
  LEnum := FSource.GetEnumerator;
  while LEnum.MoveNext do
    if APredicate(LEnum.Current) then
    begin
      Result := LEnum.Current;
      Exit;
    end;
  Result := Default(TPair<K, V>);
end;

function TDictLazyFirstOrDefaultEnumerable<K, V>.GetEnumerator: IEnumEx<TPair<K, V>>;
begin
  Result := FSource.GetEnumerator;
end;

{ TDictLazyLast<K, V> }

constructor TDictLazyLastEnumerable<K, V>.Create(const ASource: IDictLazyEnumerable<K, V>;
  const APredicate: TFunc<TPair<K, V>, Boolean>);
begin
  FSource := ASource;
  FPredicate := APredicate;
end;

destructor TDictLazyLastEnumerable<K, V>.Destroy;
begin
  FSource := nil;
  inherited;
end;

function TDictLazyLastEnumerable<K, V>.Last(const APredicate: TFunc<TPair<K, V>, Boolean>): TPair<K, V>;
var
  LEnum: IEnumEx<TPair<K, V>>;
  LLast: TPair<K, V>;
  LHasValue: Boolean;
begin
  LEnum := FSource.GetEnumerator;
  LHasValue := False;
  while LEnum.MoveNext do
    if APredicate(LEnum.Current) then
    begin
      LLast := LEnum.Current;
      LHasValue := True;
    end;
  if not LHasValue then
    raise EInvalidOperation.Create('Sequence contains no matching elements');
  Result := LLast;
end;

function TDictLazyLastEnumerable<K, V>.GetEnumerator: IEnumEx<TPair<K, V>>;
begin
  Result := FSource.GetEnumerator;
end;

{ TDictLazyLastOrDefault<K, V> }

constructor TDictLazyLastOrDefaultEnumerable<K, V>.Create(const ASource: IDictLazyEnumerable<K, V>;
  const APredicate: TFunc<TPair<K, V>, Boolean>);
begin
  FSource := ASource;
  FPredicate := APredicate;
end;

destructor TDictLazyLastOrDefaultEnumerable<K, V>.Destroy;
begin
  FSource := nil;
  inherited;
end;

function TDictLazyLastOrDefaultEnumerable<K, V>.LastOrDefault(const APredicate: TFunc<TPair<K, V>, Boolean>): TPair<K, V>;
var
  LEnum: IEnumEx<TPair<K, V>>;
  LLast: TPair<K, V>;
  LHasValue: Boolean;
begin
  LEnum := FSource.GetEnumerator;
  LHasValue := False;
  while LEnum.MoveNext do
    if APredicate(LEnum.Current) then
    begin
      LLast := LEnum.Current;
      LHasValue := True;
    end;
  if not LHasValue then
    Result := Default(TPair<K, V>)
  else
    Result := LLast;
end;

function TDictLazyLastOrDefaultEnumerable<K, V>.GetEnumerator: IEnumEx<TPair<K, V>>;
begin
  Result := FSource.GetEnumerator;
end;

{ TDictLazyCount<K, V> }

constructor TDictLazyCountEnumerable<K, V>.Create(const ASource: IDictLazyEnumerable<K, V>;
  const APredicate: TFunc<TPair<K, V>, Boolean>);
begin
  FSource := ASource;
  FPredicate := APredicate;
end;

destructor TDictLazyCountEnumerable<K, V>.Destroy;
begin
  FSource := nil;
  inherited;
end;

function TDictLazyCountEnumerable<K, V>.Count(const APredicate: TFunc<TPair<K, V>, Boolean>): Integer;
var
  LEnum: IEnumEx<TPair<K, V>>;
  LCount: Integer;
begin
  LEnum := FSource.GetEnumerator;
  LCount := 0;
  while LEnum.MoveNext do
    if APredicate(LEnum.Current) then
      Inc(LCount);
  Result := LCount;
end;

function TDictLazyCountEnumerable<K, V>.GetEnumerator: IEnumEx<TPair<K, V>>;
begin
  Result := FSource.GetEnumerator;
end;

{ TDictLazyLongCount<K, V> }

constructor TDictLazyLongCountEnumerable<K, V>.Create(const ASource: IDictLazyEnumerable<K, V>;
  const APredicate: TFunc<TPair<K, V>, Boolean>);
begin
  FSource := ASource;
  FPredicate := APredicate;
end;

destructor TDictLazyLongCountEnumerable<K, V>.Destroy;
begin
  FSource := nil;
  inherited;
end;

function TDictLazyLongCountEnumerable<K, V>.LongCount(const APredicate: TFunc<TPair<K, V>, Boolean>): Int64;
var
  LEnum: IEnumEx<TPair<K, V>>;
  LCount: Int64;
begin
  LEnum := FSource.GetEnumerator;
  LCount := 0;
  while LEnum.MoveNext do
    if APredicate(LEnum.Current) then
      Inc(LCount);
  Result := LCount;
end;

function TDictLazyLongCountEnumerable<K, V>.GetEnumerator: IEnumEx<TPair<K, V>>;
begin
  Result := FSource.GetEnumerator;
end;

{ TDictLazyToArray<K, V> }

constructor TDictLazyToArrayEnumerable<K, V>.Create(const ASource: IDictLazyEnumerable<K, V>);
begin
  FSource := ASource;
end;

destructor TDictLazyToArrayEnumerable<K, V>.Destroy;
begin
  FSource := nil;
  inherited;
end;

function TDictLazyToArrayEnumerable<K, V>.GetEnumerator: IEnumEx<TPair<K, V>>;
begin
  Result := FSource.GetEnumerator;
end;

{ TDictLazyToList<K, V> }

constructor TDictLazyToListEnumerable<K, V>.Create(const ASource: IDictLazyEnumerable<K, V>);
begin
  FSource := ASource;
end;

destructor TDictLazyToListEnumerable<K, V>.Destroy;
begin
  FSource := nil;
  inherited;
end;

function TDictLazyToListEnumerable<K, V>.GetEnumerator: IEnumEx<TPair<K, V>>;
begin
  Result := FSource.GetEnumerator;
end;

{ TDictLazyToDictionary<K, V> }

constructor TDictLazyToDictionaryEnumerable<K, V>.Create(const ASource: IDictLazyEnumerable<K, V>);
begin
  FSource := ASource;
end;

destructor TDictLazyToDictionaryEnumerable<K, V>.Destroy;
begin
  FSource := nil;
  inherited;
end;

function TDictLazyToDictionaryEnumerable<K, V>.GetEnumerator: IEnumEx<TPair<K, V>>;
begin
  Result := FSource.GetEnumerator;
end;

{ TDictLazyEnumerator<K, V> }

constructor TDictLazyEnumerator<K, V>.Create(const ASource: IDictLazyEnumerable<K, V>);
begin
  FSource := ASource;
end;

destructor TDictLazyEnumerator<K, V>.Destroy;
begin
  FSource := nil;
  inherited;
end;

function TDictLazyEnumerator<K, V>.GetEnumerator: IEnumEx<TPair<K, V>>;
begin
  Result := FSource.GetEnumerator;
end;

{ TDictLazyGroupBy<K, V, TKey> }

constructor TDictLazyGroupBy<K, V, TKey>.Create(const ASource: IDictLazyEnumerable<K, V>;
  const AKeySelector: TFunc<TPair<K, V>, TKey>);
var
  LEnum: IEnumEx<TPair<K, V>>;
  LDict: TDictionary<TKey, TList<TPair<K, V>>>;
  LKey: TKey;
  LItem: TPair<K, V>;
  LGroup: TList<TPair<K, V>>;
begin
  FSource := ASource;
  FKeySelector := AKeySelector;
  FGroups := TList<IGrouping<TKey, TPair<K, V>>>.Create;
  LDict := TDictionary<TKey, TList<TPair<K, V>>>.Create;
  try
    LEnum := FSource.GetEnumerator;
    while LEnum.MoveNext do
    begin
      LItem := LEnum.Current;
      LKey := FKeySelector(LItem);
      if not LDict.TryGetValue(LKey, LGroup) then
      begin
        LGroup := TList<TPair<K, V>>.Create;
        LDict.Add(LKey, LGroup);
        FGroups.Add(TGroupingEnumerable<TKey, TPair<K, V>>.Create(LKey, LGroup));
      end;
      LGroup.Add(LItem);
    end;
  finally
    LDict.Free;
  end;
end;

destructor TDictLazyGroupBy<K, V, TKey>.Destroy;
begin
  FSource := nil;
  FGroups.Free;
  inherited;
end;

function TDictLazyGroupBy<K, V, TKey>.GetEnumerator: IEnumEx<IGrouping<TKey, TPair<K, V>>>;
begin
  Result := TArrayEnumerator<IGrouping<TKey, TPair<K, V>>>.Create(FGroups.ToArray);
end;

function TDictLazyGroupBy<K, V, TKey>.AsEnumerable: IListEnumerable<IGrouping<TKey, TPair<K, V>>>;
begin
  Result := IListEnumerable<IGrouping<TKey, TPair<K, V>>>.Create(
    TGroupedEnumeratorAdapter<TKey, TPair<K, V>>.Create(Self));
end;

{ TGroupedEnumerator<TKey, T> }

constructor TGroupedEnumerator<TKey, T>.Create(const AGroups: TList<IGrouping<TKey, T>>);
begin
  FGroups := AGroups;
end;

destructor TGroupedEnumerator<TKey, T>.Destroy;
begin
  FGroups.Free;
  inherited;
end;

function TGroupedEnumerator<TKey, T>.GetEnumerator: IEnumEx<IGrouping<TKey, T>>;
begin
  Result := TArrayEnumerator<IGrouping<TKey, T>>.Create(FGroups.ToArray);
end;

function TGroupedEnumerator<TKey, T>.AsEnumerable: IListEnumerable<IGrouping<TKey, T>>;
begin
  Result := IListEnumerable<IGrouping<TKey, T>>.Create(
    TGroupedEnumeratorAdapter<TKey, T>.Create(Self));
end;

{ TDictLazyMapEnumerator<K, V, TResult> }

constructor TDictLazyMapEnumerator<K, V, TResult>.Create(const ASourceEnum: IEnumEx<TPair<K, V>>;
  const ASelector: TFunc<K, V, TResult>);
begin
  FSourceEnum := ASourceEnum;
  FSelector := ASelector;
  FCurrent := Default(TPair<K, TResult>);
end;

destructor TDictLazyMapEnumerator<K, V, TResult>.Destroy;
begin
  FSourceEnum := nil;
  inherited;
end;

function TDictLazyMapEnumerator<K, V, TResult>.GetCurrent: TPair<K, TResult>;
begin
  Result := FCurrent;
end;

function TDictLazyMapEnumerator<K, V, TResult>.MoveNext: Boolean;
begin
  Result := FSourceEnum.MoveNext;
  if Result then
  begin
    var LPair := FSourceEnum.Current;
    FCurrent := TPair<K, TResult>.Create(LPair.Key, FSelector(LPair.Key, LPair.Value));
  end;
end;

procedure TDictLazyMapEnumerator<K, V, TResult>.Reset;
begin
  FSourceEnum.Reset;
end;

{ TDictLazyMapEnumerable<K, V, TResult> }

constructor TDictLazyMapEnumerable<K, V, TResult>.Create(const AMapEnum: TDictLazyMapEnumerator<K, V, TResult>);
begin
  FMapEnum := AMapEnum;
end;

destructor TDictLazyMapEnumerable<K, V, TResult>.Destroy;
begin
  FMapEnum.Free;
  inherited;
end;

function TDictLazyMapEnumerable<K, V, TResult>.GetEnumerator: IEnumEx<TPair<K, TResult>>;
begin
  Result := FMapEnum;
end;

{ TDictLazyZipEnumerator<K, V, TSecond, TResult> }

constructor TDictLazyZipEnumerator<K, V, TSecond, TResult>.Create(const AEnum1: IEnumEx<TPair<K, V>>;
  const AEnum2: IEnumEx<TPair<K, TSecond>>; const AResultSelector: TFunc<TPair<K, V>, TPair<K, TSecond>, TPair<K, TResult>>);
begin
  FEnum1 := AEnum1;
  FEnum2 := AEnum2;
  FResultSelector := AResultSelector;
end;

destructor TDictLazyZipEnumerator<K, V, TSecond, TResult>.Destroy;
begin
  FEnum1 := nil;
  FEnum2 := nil;
  inherited;
end;

function TDictLazyZipEnumerator<K, V, TSecond, TResult>.GetCurrent: TPair<K, TResult>;
begin
  Result := FCurrent;
end;

function TDictLazyZipEnumerator<K, V, TSecond, TResult>.MoveNext: Boolean;
begin
  if FEnum1.MoveNext and FEnum2.MoveNext then
  begin
    FCurrent := FResultSelector(FEnum1.Current, FEnum2.Current);
    Result := True;
  end
  else
    Result := False;
end;

procedure TDictLazyZipEnumerator<K, V, TSecond, TResult>.Reset;
begin
  FEnum1.Reset;
  FEnum2.Reset;
end;

{ TDictLazyZipEnumerable<K, V, TSecond, TResult> }

constructor TDictLazyZipEnumerable<K, V, TSecond, TResult>.Create(
  const AZipEnum: TDictLazyZipEnumerator<K, V, TSecond, TResult>);
begin
  FZipEnum := AZipEnum;
end;

destructor TDictLazyZipEnumerable<K, V, TSecond, TResult>.Destroy;
begin
  FZipEnum.Free;
  inherited;
end;

function TDictLazyZipEnumerable<K, V, TSecond, TResult>.GetEnumerator: IEnumEx<TPair<K, TResult>>;
begin
  Result := FZipEnum;
end;

{ TDictLazyFlatMapEnumerator<K, V, TResult> }

constructor TDictLazyFlatMapEnumerator<K, V, TResult>.Create(const ASourceEnum: IEnumEx<TPair<K, V>>;
  const AFunc: TFunc<TPair<K, V>, TArray<TPair<K, TResult>>>);
begin
  FSourceEnum := ASourceEnum;
  FFunc := AFunc;
  FCurrentIndex := -1;
  FCurrentArray := nil;
end;

destructor TDictLazyFlatMapEnumerator<K, V, TResult>.Destroy;
begin
  FSourceEnum := nil;
  inherited;
end;

function TDictLazyFlatMapEnumerator<K, V, TResult>.GetCurrent: TPair<K, TResult>;
begin
  Result := FCurrent;
end;

function TDictLazyFlatMapEnumerator<K, V, TResult>.MoveNext: Boolean;
begin
  while True do
  begin
    if (FCurrentIndex >= 0) and (FCurrentIndex < Length(FCurrentArray)) then
    begin
      FCurrent := FCurrentArray[FCurrentIndex];
      Inc(FCurrentIndex);
      Result := True;
      Exit;
    end;

    if not FSourceEnum.MoveNext then
    begin
      Result := False;
      Exit;
    end;

    FCurrentArray := FFunc(FSourceEnum.Current);
    FCurrentIndex := 0;
  end;
end;

procedure TDictLazyFlatMapEnumerator<K, V, TResult>.Reset;
begin
  FSourceEnum.Reset;
  FCurrentIndex := -1;
  FCurrentArray := nil;
end;

{ TDictLazyFlatMapEnumerable<K, V, TResult> }

constructor TDictLazyFlatMapEnumerable<K, V, TResult>.Create(
  const AFlatMapEnum: TDictLazyFlatMapEnumerator<K, V, TResult>);
begin
  FFlatMapEnum := AFlatMapEnum;
end;

destructor TDictLazyFlatMapEnumerable<K, V, TResult>.Destroy;
begin
  FFlatMapEnum.Free;
  inherited;
end;

function TDictLazyFlatMapEnumerable<K, V, TResult>.GetEnumerator: IEnumEx<TPair<K, TResult>>;
begin
  Result := FFlatMapEnum;
end;

{ TDictLazyIntersectEnumerator<K, V> }

constructor TDictLazyIntersectEnumerator<K, V>.Create(const ASourceEnum: IEnumEx<TPair<K, V>>;
  const AIntersect: IDictLazyEnumerable<K, V>);
begin
  FSourceEnum := ASourceEnum;
  FIntersect := AIntersect;
  FIntersectSet := TDictionary<TPair<K, V>, Boolean>.Create;
  FComparer := TEqualityComparer<TPair<K, V>>.Default;
  // Preenche o conjunto de interseção
  var LEnum := FIntersect.GetEnumerator;
  while LEnum.MoveNext do
    FIntersectSet.AddOrSetValue(LEnum.Current, True);
end;

destructor TDictLazyIntersectEnumerator<K, V>.Destroy;
begin
  FSourceEnum := nil;
  FIntersect := nil;
  FIntersectSet.Free;
  inherited;
end;

function TDictLazyIntersectEnumerator<K, V>.GetCurrent: TPair<K, V>;
begin
  Result := FCurrent;
end;

function TDictLazyIntersectEnumerator<K, V>.MoveNext: Boolean;
begin
  while FSourceEnum.MoveNext do
  begin
    FCurrent := FSourceEnum.Current;
    if FIntersectSet.ContainsKey(FCurrent) then
    begin
      FIntersectSet.Remove(FCurrent);
      Result := True;
      Exit;
    end;
  end;
  Result := False;
end;

procedure TDictLazyIntersectEnumerator<K, V>.Reset;
begin
  FSourceEnum.Reset;
  FIntersectSet.Clear;
  var LEnum := FIntersect.GetEnumerator;
  while LEnum.MoveNext do
    FIntersectSet.AddOrSetValue(LEnum.Current, True);
end;

{ TDictLazyIntersectEnumerable<K, V> }

constructor TDictLazyIntersectEnumerable<K, V>.Create(
  const AIntersectEnum: TDictLazyIntersectEnumerator<K, V>);
begin
  FIntersectEnum := AIntersectEnum;
end;

destructor TDictLazyIntersectEnumerable<K, V>.Destroy;
begin
  FIntersectEnum.Free;
  inherited;
end;

function TDictLazyIntersectEnumerable<K, V>.GetEnumerator: IEnumEx<TPair<K, V>>;
begin
  Result := FIntersectEnum;
end;

{ TDictLazyExcludeEnumerator<K, V> }

constructor TDictLazyExcludeEnumerator<K, V>.Create(const ASourceEnum: IEnumEx<TPair<K, V>>;
  const AExclude: IDictLazyEnumerable<K, V>);
begin
  FSourceEnum := ASourceEnum;
  FExclude := AExclude;
  FExcludeSet := TDictionary<TPair<K, V>, Boolean>.Create;
  FComparer := TEqualityComparer<TPair<K, V>>.Default;
  // Preenche o conjunto de exclusão
  var LEnum := FExclude.GetEnumerator;
  while LEnum.MoveNext do
    FExcludeSet.AddOrSetValue(LEnum.Current, True);
end;

destructor TDictLazyExcludeEnumerator<K, V>.Destroy;
begin
  FSourceEnum := nil;
  FExclude := nil;
  FExcludeSet.Free;
  inherited;
end;

function TDictLazyExcludeEnumerator<K, V>.GetCurrent: TPair<K, V>;
begin
  Result := FCurrent;
end;

function TDictLazyExcludeEnumerator<K, V>.MoveNext: Boolean;
begin
  while FSourceEnum.MoveNext do
  begin
    FCurrent := FSourceEnum.Current;
    if not FExcludeSet.ContainsKey(FCurrent) then
    begin
      Result := True;
      Exit;
    end;
  end;
  Result := False;
end;

procedure TDictLazyExcludeEnumerator<K, V>.Reset;
begin
  FSourceEnum.Reset;
  FExcludeSet.Clear;
  var LEnum := FExclude.GetEnumerator;
  while LEnum.MoveNext do
    FExcludeSet.AddOrSetValue(LEnum.Current, True);
end;

{ TDictLazyExcludeEnumerable<K, V> }

constructor TDictLazyExcludeEnumerable<K, V>.Create(
  const AExcludeEnum: TDictLazyExcludeEnumerator<K, V>);
begin
  FExcludeEnum := AExcludeEnum;
end;

destructor TDictLazyExcludeEnumerable<K, V>.Destroy;
begin
  FExcludeEnum.Free;
  inherited;
end;

function TDictLazyExcludeEnumerable<K, V>.GetEnumerator: IEnumEx<TPair<K, V>>;
begin
  Result := FExcludeEnum;
end;

{ TDictLazyDistinctByEnumerator<K, V, TKey> }

constructor TDictLazyDistinctByEnumerator<K, V, TKey>.Create(const ASourceEnum: IEnumEx<TPair<K, V>>;
  const ASelector: TFunc<TPair<K, V>, TPair<TKey, V>>);
begin
  FSourceEnum := ASourceEnum;
  FSelector := ASelector;
  FSeenKeys := TDictionary<TKey, Boolean>.Create(TEqualityComparer<TKey>.Default);
  FComparer := TEqualityComparer<TKey>.Default;
end;

destructor TDictLazyDistinctByEnumerator<K, V, TKey>.Destroy;
begin
  FSourceEnum := nil;
  FSeenKeys.Free;
  inherited;
end;

function TDictLazyDistinctByEnumerator<K, V, TKey>.GetCurrent: TPair<TKey, V>;
begin
  Result := FCurrent;
end;

function TDictLazyDistinctByEnumerator<K, V, TKey>.MoveNext: Boolean;
begin
  while FSourceEnum.MoveNext do
  begin
    var LPair := FSourceEnum.Current;
    FCurrent := FSelector(LPair);
    if not FSeenKeys.ContainsKey(FCurrent.Key) then
    begin
      FSeenKeys.Add(FCurrent.Key, True);
      Result := True;
      Exit;
    end;
  end;
  Result := False;
end;

procedure TDictLazyDistinctByEnumerator<K, V, TKey>.Reset;
begin
  FSourceEnum.Reset;
  FSeenKeys.Clear;
end;

{ TDictLazyDistinctByEnumerable<K, V, TKey> }

constructor TDictLazyDistinctByEnumerable<K, V, TKey>.Create(
  const ADistinctByEnum: TDictLazyDistinctByEnumerator<K, V, TKey>);
begin
  FDistinctByEnum := ADistinctByEnum;
end;

destructor TDictLazyDistinctByEnumerable<K, V, TKey>.Destroy;
begin
  FDistinctByEnum.Free;
  inherited;
end;

function TDictLazyDistinctByEnumerable<K, V, TKey>.GetEnumerator: IEnumEx<TPair<TKey, V>>;
begin
  Result := FDistinctByEnum;
end;

{ TDictLazyTakeWhileEnumerator<K, V> }

constructor TDictLazyTakeWhileEnumerator<K, V>.Create(const ASourceEnum: IEnumEx<TPair<K, V>>;
  const APredicate: TFunc<TPair<K, V>, Boolean>);
begin
  FSourceEnum := ASourceEnum;
  FPredicate := APredicate;
  FDone := False;
end;

destructor TDictLazyTakeWhileEnumerator<K, V>.Destroy;
begin
  FSourceEnum := nil;
  inherited;
end;

function TDictLazyTakeWhileEnumerator<K, V>.GetCurrent: TPair<K, V>;
begin
  Result := FCurrent;
end;

function TDictLazyTakeWhileEnumerator<K, V>.MoveNext: Boolean;
begin
  if FDone then
  begin
    Result := False;
    Exit;
  end;

  if FSourceEnum.MoveNext then
  begin
    FCurrent := FSourceEnum.Current;
    if FPredicate(FCurrent) then
    begin
      Result := True;
    end
    else
    begin
      FDone := True;
      Result := False;
    end;
  end
  else
  begin
    FDone := True;
    Result := False;
  end;
end;

procedure TDictLazyTakeWhileEnumerator<K, V>.Reset;
begin
  FSourceEnum.Reset;
  FDone := False;
end;

{ TDictLazyTakeWhileEnumerable<K, V> }

constructor TDictLazyTakeWhileEnumerable<K, V>.Create(
  const ATakeWhileEnum: TDictLazyTakeWhileEnumerator<K, V>);
begin
  FTakeWhileEnum := ATakeWhileEnum;
end;

destructor TDictLazyTakeWhileEnumerable<K, V>.Destroy;
begin
  FTakeWhileEnum.Free;
  inherited;
end;

function TDictLazyTakeWhileEnumerable<K, V>.GetEnumerator: IEnumEx<TPair<K, V>>;
begin
  Result := FTakeWhileEnum;
end;

{ TDictLazySkipWhileEnumerator<K, V> }

constructor TDictLazySkipWhileEnumerator<K, V>.Create(const ASourceEnum: IEnumEx<TPair<K, V>>;
  const APredicate: TFunc<TPair<K, V>, Boolean>);
begin
  FSourceEnum := ASourceEnum;
  FPredicate := APredicate;
  FSkipping := True;
end;

destructor TDictLazySkipWhileEnumerator<K, V>.Destroy;
begin
  FSourceEnum := nil;
  inherited;
end;

function TDictLazySkipWhileEnumerator<K, V>.GetCurrent: TPair<K, V>;
begin
  Result := FCurrent;
end;

function TDictLazySkipWhileEnumerator<K, V>.MoveNext: Boolean;
begin
  while FSourceEnum.MoveNext do
  begin
    FCurrent := FSourceEnum.Current;
    if FSkipping then
    begin
      if not FPredicate(FCurrent) then
      begin
        FSkipping := False;
        Result := True;
        Exit;
      end;
    end
    else
    begin
      Result := True;
      Exit;
    end;
  end;
  Result := False;
end;

procedure TDictLazySkipWhileEnumerator<K, V>.Reset;
begin
  FSourceEnum.Reset;
  FSkipping := True;
end;

{ TDictLazySkipWhileEnumerable<K, V> }

constructor TDictLazySkipWhileEnumerable<K, V>.Create(
  const ASkipWhileEnum: TDictLazySkipWhileEnumerator<K, V>);
begin
  FSkipWhileEnum := ASkipWhileEnum;
end;

destructor TDictLazySkipWhileEnumerable<K, V>.Destroy;
begin
  FSkipWhileEnum.Free;
  inherited;
end;

function TDictLazySkipWhileEnumerable<K, V>.GetEnumerator: IEnumEx<TPair<K, V>>;
begin
  Result := FSkipWhileEnum;
end;

{ TGroupingEnumerable<TKey, T> }

constructor TGroupingEnumerable<TKey, T>.Create(const AKey: TKey; const AItems: TList<T>);
begin
  FKey := AKey;
  FItems := AItems;
end;

destructor TGroupingEnumerable<TKey, T>.Destroy;
begin
  FItems.Free;
  inherited;
end;

function TGroupingEnumerable<TKey, T>.GetKey: TKey;
begin
  Result := FKey;
end;

function TGroupingEnumerable<TKey, T>.GetEnumerator: IEnumEx<T>;
begin
  Result := TArrayEnumerator<T>.Create(FItems.ToArray);
end;

function TGroupingEnumerable<TKey, T>.ToArray: TArray<T>;
begin
  Result := FItems.ToArray;
end;

{ TArrayEnumerator<T> }

constructor TArrayEnumerator<T>.Create(const AArray: TArray<T>);
begin
  FArray := AArray;
  FIndex := -1;
end;

destructor TArrayEnumerator<T>.Destroy;
begin
  inherited;
end;

function TArrayEnumerator<T>.GetCurrent: T;
begin
  Result := FArray[FIndex];
end;

function TArrayEnumerator<T>.MoveNext: Boolean;
begin
  Inc(FIndex);
  Result := FIndex < Length(FArray);
end;

procedure TArrayEnumerator<T>.Reset;
begin
  FIndex := -1;
end;

{ TEnumeratorAdapter<T> }

constructor TEnumeratorAdapter<T>.Create(const AEnumerator: TEnumerator<T>);
begin
  FEnumerator := AEnumerator;
  FHasNext := False;
end;

destructor TEnumeratorAdapter<T>.Destroy;
begin
  FEnumerator.Free;
  inherited;
end;

function TEnumeratorAdapter<T>.GetCurrent: T;
begin
  Result := FCurrent;
end;

function TEnumeratorAdapter<T>.MoveNext: Boolean;
begin
  Result := FEnumerator.MoveNext;
  if Result then
    FCurrent := FEnumerator.Current;
end;

procedure TEnumeratorAdapter<T>.Reset;
begin
  raise ENotSupportedException.Create('Reset is not supported for TEnumeratorAdapter');
end;

{ TListAdapterEnumerable<T> }

constructor TListAdapterEnumerable<T>.Create(const AList: TList<T>);
begin
  FList := AList;
end;

destructor TListAdapterEnumerable<T>.Destroy;
begin
  FList.Free;
  inherited;
end;

function TListAdapterEnumerable<T>.GetEnumerator: IEnumEx<T>;
begin
  Result := TArrayEnumerator<T>.Create(FList.ToArray);
end;

{ TGroupedEnumeratorAdapter<TKey, T> }

constructor TGroupedEnumeratorAdapter<TKey, T>.Create(const AEnumerator: IGroupedEnumerator<TKey, T>);
begin
  FEnumerator := AEnumerator;
end;

function TGroupedEnumeratorAdapter<TKey, T>.GetEnumerator: IEnumEx<IGrouping<TKey, T>>;
begin
  Result := FEnumerator.GetEnumerator;
end;

{ TListLazyEnumerableBase<T> }

function TListLazyEnumerableBase<T>.Filter(const APredicate: TFunc<T, Boolean>): IListEnumerable<T>;
begin
  Result := IListEnumerable<T>.Create(
    TListLazyFilterEnumerable<T>.Create(Self, APredicate));
end;

function TListLazyEnumerableBase<T>.Take(const ACount: Integer): IListEnumerable<T>;
begin
  Result := IListEnumerable<T>.Create(
    TListLazyTakeEnumerable<T>.Create(Self, ACount));
end;

function TListLazyEnumerableBase<T>.Skip(const ACount: Integer): IListEnumerable<T>;
begin
  Result := IListEnumerable<T>.Create(
    TListLazySkipEnumerable<T>.Create(Self, ACount));
end;

function TListLazyEnumerableBase<T>.OrderBy(const AComparer: TFunc<T, T, Integer>): IListEnumerable<T>;
begin
  Result := IListEnumerable<T>.Create(
    TListLazyOrderByEnumerable<T>.Create(Self, AComparer));
end;

function TListLazyEnumerableBase<T>.Distinct: IListEnumerable<T>;
begin
  Result := IListEnumerable<T>.Create(
    TListLazyDistinctEnumerable<T>.Create(Self));
end;

function TListLazyEnumerableBase<T>.Reduce(const AReducer: TFunc<T, T, T>;
  const AInitialValue: T): T;
var
  LEnum: IEnumEx<T>;
  LResult: T;
begin
  LEnum := GetEnumerator;
  LResult := AInitialValue;
  while LEnum.MoveNext do
    LResult := AReducer(LResult, LEnum.Current);
  Result := LResult;
end;

function TListLazyEnumerableBase<T>.Reduce(const AReducer: TFunc<T, T, T>): T;
var
  LEnum: IEnumEx<T>;
  LResult: T;
  LHasValue: Boolean;
begin
  LEnum := GetEnumerator;
  LHasValue := False;
  while LEnum.MoveNext do
  begin
    if not LHasValue then
    begin
      LResult := LEnum.Current;
      LHasValue := True;
    end
    else
      LResult := AReducer(LResult, LEnum.Current);
  end;
  if not LHasValue then
    raise EInvalidOperation.Create('Sequence contains no elements');
  Result := LResult;
end;

procedure TListLazyEnumerableBase<T>.ForEach(const AAction: TAction<T>);
var
  LEnum: IEnumEx<T>;
begin
  LEnum := GetEnumerator;
  while LEnum.MoveNext do
    AAction(LEnum.Current);
end;

function TListLazyEnumerableBase<T>.Sum(const ASelector: TFunc<T, Double>): Double;
var
  LEnum: IEnumEx<T>;
  LSum: Double;
begin
  LEnum := GetEnumerator;
  LSum := 0;
  while LEnum.MoveNext do
    LSum := LSum + ASelector(LEnum.Current);
  Result := LSum;
end;

function TListLazyEnumerableBase<T>.Sum(const ASelector: TFunc<T, Integer>): Integer;
var
  LEnum: IEnumEx<T>;
  LSum: Integer;
begin
  LEnum := GetEnumerator;
  LSum := 0;
  while LEnum.MoveNext do
    LSum := LSum + ASelector(LEnum.Current);
  Result := LSum;
end;

function TListLazyEnumerableBase<T>.Min(const AComparer: TFunc<T, T, Integer>): T;
var
  LEnum: IEnumEx<T>;
  LMin: T;
  LHasValue: Boolean;
begin
  LEnum := GetEnumerator;
  LHasValue := False;
  while LEnum.MoveNext do
  begin
    if not LHasValue then
    begin
      LMin := LEnum.Current;
      LHasValue := True;
    end
    else if AComparer(LEnum.Current, LMin) < 0 then
      LMin := LEnum.Current;
  end;
  if not LHasValue then
    raise EInvalidOperation.Create('Sequence contains no elements');
  Result := LMin;
end;

function TListLazyEnumerableBase<T>.Min: T;
var
  LComparer: TFunc<T, T, Integer>;
begin
  LComparer := function(A, B: T): Integer
  begin
    Result := TComparer<T>.Default.Compare(A, B);
  end;
  Result := Min(LComparer);
end;

function TListLazyEnumerableBase<T>.Max(const AComparer: TFunc<T, T, Integer>): T;
var
  LEnum: IEnumEx<T>;
  LMax: T;
  LHasValue: Boolean;
begin
  LEnum := GetEnumerator;
  LHasValue := False;
  while LEnum.MoveNext do
  begin
    if not LHasValue then
    begin
      LMax := LEnum.Current;
      LHasValue := True;
    end
    else if AComparer(LEnum.Current, LMax) > 0 then
      LMax := LEnum.Current;
  end;
  if not LHasValue then
    raise EInvalidOperation.Create('Sequence contains no elements');
  Result := LMax;
end;

function TListLazyEnumerableBase<T>.Max: T;
var
  LComparer: TFunc<T, T, Integer>;
begin
  LComparer := function(A, B: T): Integer
  begin
    Result := TComparer<T>.Default.Compare(A, B);
  end;
  Result := Max(LComparer);
end;

function TListLazyEnumerableBase<T>.Any(const APredicate: TFunc<T, Boolean>): Boolean;
var
  LEnum: IEnumEx<T>;
begin
  LEnum := GetEnumerator;
  while LEnum.MoveNext do
    if APredicate(LEnum.Current) then
    begin
      Result := True;
      Exit;
    end;
  Result := False;
end;

function TListLazyEnumerableBase<T>.FirstOrDefault(const APredicate: TFunc<T, Boolean>): T;
var
  LEnum: IEnumEx<T>;
begin
  LEnum := GetEnumerator;
  while LEnum.MoveNext do
    if APredicate(LEnum.Current) then
    begin
      Result := LEnum.Current;
      Exit;
    end;
  Result := Default(T);
end;

function TListLazyEnumerableBase<T>.Last(const APredicate: TFunc<T, Boolean>): T;
var
  LEnum: IEnumEx<T>;
  LLast: T;
  LHasValue: Boolean;
begin
  LEnum := GetEnumerator;
  LHasValue := False;
  while LEnum.MoveNext do
    if APredicate(LEnum.Current) then
    begin
      LLast := LEnum.Current;
      LHasValue := True;
    end;
  if not LHasValue then
    raise EInvalidOperation.Create('Sequence contains no matching elements');
  Result := LLast;
end;

function TListLazyEnumerableBase<T>.LastOrDefault(const APredicate: TFunc<T, Boolean>): T;
var
  LEnum: IEnumEx<T>;
  LLast: T;
  LHasValue: Boolean;
begin
  LEnum := GetEnumerator;
  LHasValue := False;
  while LEnum.MoveNext do
    if APredicate(LEnum.Current) then
    begin
      LLast := LEnum.Current;
      LHasValue := True;
    end;
  if not LHasValue then
    Result := Default(T)
  else
    Result := LLast;
end;

function TListLazyEnumerableBase<T>.Count(const APredicate: TFunc<T, Boolean>): Integer;
var
  LEnum: IEnumEx<T>;
  LCount: Integer;
begin
  LEnum := GetEnumerator;
  LCount := 0;
  while LEnum.MoveNext do
    if APredicate(LEnum.Current) then
      Inc(LCount);
  Result := LCount;
end;

function TListLazyEnumerableBase<T>.LongCount(const APredicate: TFunc<T, Boolean>): Int64;
var
  LEnum: IEnumEx<T>;
  LCount: Int64;
begin
  LEnum := GetEnumerator;
  LCount := 0;
  while LEnum.MoveNext do
    if APredicate(LEnum.Current) then
      Inc(LCount);
  Result := LCount;
end;

function TListLazyEnumerableBase<T>.ToArray: TArray<T>;
var
  LList: TList<T>;
  LEnum: IEnumEx<T>;
begin
  LList := TList<T>.Create;
  try
    LEnum := GetEnumerator;
    while LEnum.MoveNext do
      LList.Add(LEnum.Current);
    Result := LList.ToArray;
  finally
    LList.Free;
  end;
end;

function TListLazyEnumerableBase<T>.ToList: TList<T>;
var
  LList: TList<T>;
  LEnum: IEnumEx<T>;
begin
  LList := TList<T>.Create;
  LEnum := GetEnumerator;
  while LEnum.MoveNext do
    LList.Add(LEnum.Current);
  Result := LList;
end;

function TListLazyEnumerableBase<T>.GroupBy<TKey>(const AKeySelector: TFunc<T, TKey>): IGroupedEnumerator<TKey, T>;
begin
  Result := TListLazyGroupByEnumerator<T, TKey>.Create(Self, AKeySelector);
end;

{ TDictLazyEnumerableBase<K, V> }

procedure TDictLazyEnumerableBase<K, V>.ForEach(const AAction: TAction<TPair<K, V>>);
var
  LEnum: IEnumEx<TPair<K, V>>;
begin
  LEnum := GetEnumerator;
  while LEnum.MoveNext do
    AAction(LEnum.Current);
end;

function TDictLazyEnumerableBase<K, V>.Filter(const APredicate: TFunc<TPair<K, V>, Boolean>): IDictEnumerable<K, V>;
begin
  Result := IDictEnumerable<K, V>.Create(
    TDictLazyFilterEnumerable<K, V>.Create(Self, APredicate));
end;

function TDictLazyEnumerableBase<K, V>.Take(const ACount: Integer): IDictEnumerable<K, V>;
begin
  Result := IDictEnumerable<K, V>.Create(
    TDictLazyTakeEnumerable<K, V>.Create(Self, ACount));
end;

function TDictLazyEnumerableBase<K, V>.Skip(const ACount: Integer): IDictEnumerable<K, V>;
begin
  Result := IDictEnumerable<K, V>.Create(
    TDictLazySkipEnumerable<K, V>.Create(Self, ACount));
end;

function TDictLazyEnumerableBase<K, V>.OrderBy(const AComparer: TFunc<TPair<K, V>, TPair<K, V>, Integer>): IDictEnumerable<K, V>;
begin
  Result := IDictEnumerable<K, V>.Create(
    TDictLazyOrderByEnumerable<K, V>.Create(Self, AComparer));
end;

function TDictLazyEnumerableBase<K, V>.GroupBy<TKey>(const AKeySelector: TFunc<TPair<K, V>, TKey>): IGroupedEnumerator<TKey, TPair<K, V>>;
begin
  Result := TDictLazyGroupBy<K, V, TKey>.Create(Self, AKeySelector);
end;

function TDictLazyEnumerableBase<K, V>.Distinct: IDictEnumerable<K, V>;
begin
  Result := IDictEnumerable<K, V>.Create(
    TDictLazyDistinctEnumerable<K, V>.Create(Self));
end;

function TDictLazyEnumerableBase<K, V>.Reduce(const AReducer: TFunc<TPair<K, V>, TPair<K, V>, TPair<K, V>>;
  const AInitialValue: TPair<K, V>): TPair<K, V>;
var
  LEnum: IEnumEx<TPair<K, V>>;
  LResult: TPair<K, V>;
begin
  LEnum := GetEnumerator;
  LResult := AInitialValue;
  while LEnum.MoveNext do
    LResult := AReducer(LResult, LEnum.Current);
  Result := LResult;
end;

function TDictLazyEnumerableBase<K, V>.Reduce(const AReducer: TFunc<TPair<K, V>, TPair<K, V>, TPair<K, V>>): TPair<K, V>;
var
  LEnum: IEnumEx<TPair<K, V>>;
  LResult: TPair<K, V>;
  LHasValue: Boolean;
begin
  LEnum := GetEnumerator;
  LHasValue := False;
  while LEnum.MoveNext do
  begin
    if not LHasValue then
    begin
      LResult := LEnum.Current;
      LHasValue := True;
    end
    else
      LResult := AReducer(LResult, LEnum.Current);
  end;
  if not LHasValue then
    raise EInvalidOperation.Create('Sequence contains no elements');
  Result := LResult;
end;

function TDictLazyEnumerableBase<K, V>.Sum(const ASelector: TFunc<TPair<K, V>, Double>): Double;
var
  LEnum: IEnumEx<TPair<K, V>>;
  LSum: Double;
begin
  LEnum := GetEnumerator;
  LSum := 0;
  while LEnum.MoveNext do
    LSum := LSum + ASelector(LEnum.Current);
  Result := LSum;
end;

function TDictLazyEnumerableBase<K, V>.Sum(const ASelector: TFunc<TPair<K, V>, Integer>): Integer;
var
  LEnum: IEnumEx<TPair<K, V>>;
  LSum: Integer;
begin
  LEnum := GetEnumerator;
  LSum := 0;
  while LEnum.MoveNext do
    LSum := LSum + ASelector(LEnum.Current);
  Result := LSum;
end;

function TDictLazyEnumerableBase<K, V>.Min(const AComparer: TFunc<TPair<K, V>, TPair<K, V>, Integer>): TPair<K, V>;
var
  LEnum: IEnumEx<TPair<K, V>>;
  LMin: TPair<K, V>;
  LHasValue: Boolean;
begin
  LEnum := GetEnumerator;
  LHasValue := False;
  while LEnum.MoveNext do
  begin
    if not LHasValue then
    begin
      LMin := LEnum.Current;
      LHasValue := True;
    end
    else if AComparer(LEnum.Current, LMin) < 0 then
      LMin := LEnum.Current;
  end;
  if not LHasValue then
    raise EInvalidOperation.Create('Sequence contains no elements');
  Result := LMin;
end;

function TDictLazyEnumerableBase<K, V>.Min: TPair<K, V>;
var
  LComparer: TFunc<TPair<K, V>, TPair<K, V>, Integer>;
begin
  LComparer := function(A, B: TPair<K, V>): Integer
  begin
    Result := TComparer<K>.Default.Compare(A.Key, B.Key);
  end;
  Result := Min(LComparer);
end;

function TDictLazyEnumerableBase<K, V>.Max(const AComparer: TFunc<TPair<K, V>, TPair<K, V>, Integer>): TPair<K, V>;
var
  LEnum: IEnumEx<TPair<K, V>>;
  LMax: TPair<K, V>;
  LHasValue: Boolean;
begin
  LEnum := GetEnumerator;
  LHasValue := False;
  while LEnum.MoveNext do
  begin
    if not LHasValue then
    begin
      LMax := LEnum.Current;
      LHasValue := True;
    end
    else if AComparer(LEnum.Current, LMax) > 0 then
      LMax := LEnum.Current;
  end;
  if not LHasValue then
    raise EInvalidOperation.Create('Sequence contains no elements');
  Result := LMax;
end;

function TDictLazyEnumerableBase<K, V>.Max: TPair<K, V>;
var
  LComparer: TFunc<TPair<K, V>, TPair<K, V>, Integer>;
begin
  LComparer := function(A, B: TPair<K, V>): Integer
  begin
    Result := TComparer<K>.Default.Compare(A.Key, B.Key);
  end;
  Result := Max(LComparer);
end;

function TDictLazyEnumerableBase<K, V>.Any(const APredicate: TFunc<TPair<K, V>, Boolean>): Boolean;
var
  LEnum: IEnumEx<TPair<K, V>>;
begin
  LEnum := GetEnumerator;
  while LEnum.MoveNext do
    if APredicate(LEnum.Current) then
    begin
      Result := True;
      Exit;
    end;
  Result := False;
end;

function TDictLazyEnumerableBase<K, V>.FirstOrDefault(const APredicate: TFunc<TPair<K, V>, Boolean>): TPair<K, V>;
var
  LEnum: IEnumEx<TPair<K, V>>;
begin
  LEnum := GetEnumerator;
  while LEnum.MoveNext do
    if APredicate(LEnum.Current) then
    begin
      Result := LEnum.Current;
      Exit;
    end;
  Result := Default(TPair<K, V>);
end;

function TDictLazyEnumerableBase<K, V>.Last(const APredicate: TFunc<TPair<K, V>, Boolean>): TPair<K, V>;
var
  LEnum: IEnumEx<TPair<K, V>>;
  LLast: TPair<K, V>;
  LHasValue: Boolean;
begin
  LEnum := GetEnumerator;
  LHasValue := False;
  while LEnum.MoveNext do
    if APredicate(LEnum.Current) then
    begin
      LLast := LEnum.Current;
      LHasValue := True;
    end;
  if not LHasValue then
    raise EInvalidOperation.Create('Sequence contains no matching elements');
  Result := LLast;
end;

function TDictLazyEnumerableBase<K, V>.LastOrDefault(const APredicate: TFunc<TPair<K, V>, Boolean>): TPair<K, V>;
var
  LEnum: IEnumEx<TPair<K, V>>;
  LLast: TPair<K, V>;
  LHasValue: Boolean;
begin
  LEnum := GetEnumerator;
  LHasValue := False;
  while LEnum.MoveNext do
    if APredicate(LEnum.Current) then
    begin
      LLast := LEnum.Current;
      LHasValue := True;
    end;
  if not LHasValue then
    Result := Default(TPair<K, V>)
  else
    Result := LLast;
end;

function TDictLazyEnumerableBase<K, V>.Count(const APredicate: TFunc<TPair<K, V>, Boolean>): Integer;
var
  LEnum: IEnumEx<TPair<K, V>>;
  LCount: Integer;
begin
  LEnum := GetEnumerator;
  LCount := 0;
  while LEnum.MoveNext do
    if APredicate(LEnum.Current) then
      Inc(LCount);
  Result := LCount;
end;

function TDictLazyEnumerableBase<K, V>.LongCount(const APredicate: TFunc<TPair<K, V>, Boolean>): Int64;
var
  LEnum: IEnumEx<TPair<K, V>>;
  LCount: Int64;
begin
  LEnum := GetEnumerator;
  LCount := 0;
  while LEnum.MoveNext do
    if APredicate(LEnum.Current) then
      Inc(LCount);
  Result := LCount;
end;

function TDictLazyEnumerableBase<K, V>.ToArray: TArray<TPair<K, V>>;
var
  LList: TList<TPair<K, V>>;
  LEnum: IEnumEx<TPair<K, V>>;
begin
  LList := TList<TPair<K, V>>.Create;
  try
    LEnum := GetEnumerator;
    while LEnum.MoveNext do
      LList.Add(LEnum.Current);
    Result := LList.ToArray;
  finally
    LList.Free;
  end;
end;

function TDictLazyEnumerableBase<K, V>.ToList: TList<TPair<K, V>>;
var
  LList: TList<TPair<K, V>>;
  LEnum: IEnumEx<TPair<K, V>>;
begin
  LList := TList<TPair<K, V>>.Create;
  LEnum := GetEnumerator;
  while LEnum.MoveNext do
    LList.Add(LEnum.Current);
  Result := LList;
end;

function TDictLazyEnumerableBase<K, V>.ToDictionary: TDictionary<K, V>;
var
  LDict: TDictionary<K, V>;
  LEnum: IEnumEx<TPair<K, V>>;
begin
  LDict := TDictionary<K, V>.Create;
  try
    LEnum := GetEnumerator;
    while LEnum.MoveNext do
      LDict.Add(LEnum.Current.Key, LEnum.Current.Value);
    Result := LDict;
  except
    LDict.Free;
    raise;
  end;
end;

end.
