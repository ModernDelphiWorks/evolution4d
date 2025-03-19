# Evolution Core Library (ECL) para Delphi

Bem-vindo à **Evolution Core Library (ECL)** — a solução que moderniza o Delphi e o coloca no mesmo patamar das linguagens mais avançadas de hoje, como Rust, Kotlin e Python. Se você é um desenvolvedor Delphi que ama a robustez da linguagem, mas sente falta de recursos contemporâneos como *pattern matching*, *null safety*, *async/await* ou programação funcional, o ECL é para você. Criado para preencher as lacunas do Delphi nativo, o ECL traz ferramentas poderosas que aumentam sua produtividade, reduzem erros e tornam seu código mais elegante e manutenível.

## Por que o ECL?

O Delphi é uma lenda no desenvolvimento desktop e empresarial, mas o mundo da programação evoluiu. Recursos como *Option/Maybe*, *Result/Either*, *tuplas* e *currying* — comuns em linguagens modernas — estão ausentes ou limitados no Delphi nativo. O ECL muda isso, oferecendo:

- **Segurança contra `nil`:** Com `TOption<T>`, diga adeus aos erros de ponteiro nulo. Force o tratamento seguro de valores opcionais, como em Rust ou Haskell.
- **Resultados tipados:** Substitua exceções caóticas por `TResultPair<S,F>`, um sistema de sucesso/falha previsível e funcional.
- **Pattern Matching:** Use `TMatch<T>` para escrever código expressivo e substituir cadeias de `if-else`, ao estilo de C# ou F#.
- **Assincronia simplificada:** O `TScheduler` traz o poder de *async/await* ao Delphi, eliminando a complexidade de threads manuais.
- **Programação funcional:** Métodos como `Map`, `Filter` e `Reduce` em `TArrayEx`, `TListEx` e `TStringHelperEx` tornam manipulações de coleções e strings intuitivas e concisas.
- **Tuplas e destruturação:** `TTuple<T>` e `TTuple` permitem estruturas leves como `(1, 'a')`, com extração direta de valores.
- **Currying:** `TCurrying` introduz funções parciais, como `f(x)(y)`, ao estilo de Haskell ou Scala.

### Vantagens que Convencem

Por que adotar o ECL? Porque ele transforma o Delphi em uma ferramenta competitiva no desenvolvimento moderno, sem sacrificar o que você já ama na linguagem:

- **Produtividade:** Escreva menos código boilerplate com *lambdas* simplificadas, *list comprehensions* e *flatmaps*.
- **Robustez:** Evite bugs comuns com *null safety* e tratamento explícito de erros.
- **Manutenibilidade:** Código funcional e declarativo é mais fácil de entender e atualizar.
- **Integração:** O ECL se encaixa perfeitamente no ecossistema Delphi, mantendo performance e compatibilidade.

Não é apenas uma biblioteca — é uma evolução. Com o ECL, você leva o Delphi além de suas limitações, abraçando o melhor da programação atual enquanto mantém a essência que torna o Delphi único. Experimente e veja como seu próximo projeto pode ser mais rápido, seguro e elegante.

**[Explore a documentação abaixo para começar!](#documentação)**

## ecl.vector - Vetor Dinâmico Genérico

### Descrição
A unidade `ecl.vector` introduz a estrutura `TVector<T>`, um vetor dinâmico genérico que oferece uma alternativa moderna e flexível aos arrays tradicionais do Delphi. Inspirado em recursos de linguagens modernas, como listas dinâmicas e coleções genéricas, o `TVector<T>` suporta manipulação eficiente de elementos com operações como adição, remoção, filtragem, mapeamento e redução, tudo isso com tipagem forte graças aos recursos genéricos do Delphi.

**Principais Características:**
- **Capacidade dinâmica:** Ajusta automaticamente o tamanho interno com fatores de crescimento e redução otimizados.
- **Operadores sobrecarregados:** Suporta operações como `+` (concatenar), `-` (remover), `in` (verificar pertinência), entre outros.
- **Métodos funcionais:** Inclui `Filter`, `Map`, `Reduce` e `Comprehend`, trazendo paradigmas de programação funcional para o Delphi.
- **Iteração:** Fornece um enumerador (`IVectorEnumerator<T>`) para percorrer os elementos de forma segura e idiomática.
- **Conversão:** Permite conversões implícitas entre `TVector<T>` e `TArray<T>`, além de métodos como `ToArray` e `AsList`.

Essa unidade é ideal para cenários que exigem coleções dinâmicas com alta flexibilidade e desempenho, como manipulação de dados em tempo real ou estruturas complexas.

### Exemplo de Uso
```delphi
uses
  ecl.vector;

var
  Vec: TVector<Integer>;
  I: Integer;
begin
  // Inicializa um vetor vazio
  Vec := TVector<Integer>.Empty;

  // Adiciona elementos
  Vec.Add(10);
  Vec.Add(20);
  Vec.Add(30);

  // Concatena com outro vetor usando o operador +
  Vec := Vec + TVector<Integer>.Create([40, 50]);

  // Filtra números pares
  Vec := Vec.Filter(function(const Value: Integer): Boolean
    begin
      Result := Value mod 2 = 0;
    end);

  // Itera sobre os elementos
  for I in Vec do
    Writeln(I); // Saída: 10, 20, 30, 40, 50

  // Reduz a soma dos elementos
  Writeln(Vec.Reduce(function(Acc, Value: Integer): Integer
    begin
      Result := Acc + Value;
    end)); // Saída: 150
end;

## ecl.tuple - Tuplas Posicionais e Nomeadas

### Descrição
A unidade `ecl.tuple` introduz duas estruturas de tuplas para o Delphi: `TTuple` (tupla posicional) e `TTuple<K>` (tupla nomeada baseada em chaves). Essas estruturas trazem o conceito de tuplas, comum em linguagens modernas como Python e C#, para o Delphi, permitindo agrupar valores heterogêneos de forma eficiente e tipada.

#### `TTuple` - Tupla Posicional
- Armazena uma sequência de valores (`TValue`) acessíveis por índice.
- Suporta conversão implícita de/para arrays de `TValue` e `Variant`.
- Inclui o método `Dest` para desestruturar os valores em variáveis.

#### `TTuple<K>` - Tupla Nomeada
- Armazena pares chave-valor, onde as chaves são de tipo genérico `K` e os valores são `TValue`.
- Implementada com um dicionário interno (`TDictionary<K, TValue>`), acessível via interface `ITupleDict<K>`.
- Permite acesso a valores por chave com tipagem forte via métodos `Get<T>` e `TryGet<T>`.

**Principais Características:**
- **Flexibilidade:** Suporta valores de diferentes tipos em uma única estrutura.
- **Operadores sobrecarregados:** Inclui `=` e `<>` para comparação de tuplas.
- **Conversão implícita:** Facilita a integração com arrays e coleções existentes.
- **Acesso tipado:** Métodos genéricos para recuperar valores com segurança de tipo.

Essas tuplas são úteis para retornar múltiplos valores de funções, agrupar dados heterogêneos ou simular estruturas de dados nomeadas sem criar classes específicas.

### Exemplo de Uso
```delphi
uses
  ecl.tuple;

var
  PosTuple: TTuple;
  NamedTuple: TTuple<String>;
  Name: String;
  Age: Integer;
begin
  // Criando uma tupla posicional
  PosTuple := TTuple.New([TValue.From('Isaque'), TValue.From(30)]);
  Writeln('Nome: ', PosTuple.Get<String>(0)); // Saída: Nome: Isaque
  Writeln('Idade: ', PosTuple.Get<Integer>(1)); // Saída: Idade: 30

  // Desestruturando a tupla posicional
  PosTuple.Dest([@Name, @Age]);
  Writeln('Desestruturado - Nome: ', Name, ', Idade: ', Age);
  // Saída: Desestruturado - Nome: Isaque, Idade: 30

  // Criando uma tupla nomeada
  NamedTuple := TTuple<String>.New(
    ['nome', 'idade'],
    [TValue.From('Isaque'), TValue.From(30)]
  );
  Writeln('Nome: ', NamedTuple.Get<String>('nome')); // Saída: Nome: Isaque
  Writeln('Idade: ', NamedTuple.Get<Integer>('idade')); // Saída: Idade: 30

  // Verificando um valor com TryGet
  if NamedTuple.TryGet<Integer>('idade', Age) then
    Writeln('Idade recuperada: ', Age); // Saída: Idade recuperada: 30
end;

## ecl.objects - Fábrica de Objetos e Ponteiros Inteligentes

### Descrição
A unidade `ecl.objects` oferece ferramentas modernas para criação e gerenciamento de objetos em Delphi, trazendo conceitos avançados como reflexão (RTTI), ponteiros inteligentes e inicialização preguiçosa (lazy loading). Ela é dividida em três componentes principais:

#### `TObjectEx` - Fábrica de Objetos com RTTI
- Implementa a interface `IObject` para criar instâncias de classes ou interfaces dinamicamente.
- Suporta construção padrão (`Create`) ou com argumentos personalizados via RTTI.
- Usa um `TRttiContext` singleton para eficiência e thread-safety.

#### `TSmartPtr<T>` - Ponteiro Inteligente com Lazy Loading
- Gerencia o ciclo de vida de objetos (`T: class`) com inicialização preguiçosa e liberação automática.
- Inclui métodos como `Match` (para pattern matching) e `Scoped` (para execução com limpeza automática).
- Thread-safe com uso de `TAutoRefLock` (baseado em `TCriticalSection`).

#### `TMutableRef<T>` - Referência Mutável/Imutável
- Permite gerenciar valores (classes ou tipos simples) com controle de mutabilidade.
- Suporta operações seguras com `Scoped` e `Match`, respeitando o estado mutável/imutável.

**Principais Características:**
- **Reflexão Dinâmica:** Criação de objetos sem necessidade de chamadas explícitas ao construtor.
- **Gerenciamento Automático:** Ponteiros inteligentes cuidam da alocação e liberação de recursos.
- **Thread-Safety:** Mecanismos de bloqueio garantem segurança em ambientes multi-thread.
- **Programação Funcional:** Suporte a pattern matching e escopo controlado.

Essa unidade é ideal para cenários que exigem flexibilidade na criação de objetos ou gerenciamento seguro de recursos, como sistemas multi-thread ou arquiteturas complexas.

### Exemplo de Uso
```delphi
uses
  ecl.objects;

type
  TMyClass = class
  private
    FValue: Integer;
  public
    constructor Create(AValue: Integer);
    property Value: Integer read FValue;
  end;

constructor TMyClass.Create(AValue: Integer);
begin
  FValue := AValue;
end;

var
  ObjFactory: IObject;
  SmartPtr: TSmartPtr<TMyClass>;
  MutableRef: TMutableRef<TMyClass>;
begin
  // Criando uma fábrica de objetos
  ObjFactory := TObjectEx.New;

  // Instanciando um objeto com argumentos via RTTI
  Writeln(TMyClass(ObjFactory.Factory(TMyClass, [TValue.From(42)], 'Create')).Value);
  // Saída: 42

  // Usando um ponteiro inteligente com lazy loading
  SmartPtr := TSmartPtr<TMyClass>.Create(nil);
  Writeln(SmartPtr.AsRef.Value); // Instancia automaticamente e retorna 0 (construtor padrão)
  
  // Pattern matching com SmartPtr
  Writeln(SmartPtr.Match<String>(
    function: String begin Result := 'Nulo'; end,
    function(AObj: TMyClass): String begin Result := AObj.Value.ToString; end
  )); // Saída: 0

  // Usando escopo com SmartPtr
  SmartPtr.Scoped(procedure(AObj: TMyClass)
    begin
      Writeln('Dentro do escopo: ', AObj.Value); // Saída: Dentro do escopo: 0
    end);

  // Criando uma referência mutável
  MutableRef := TMutableRef<TMyClass>.Create(TMyClass.Create(100), True);
  MutableRef.Scoped(function(AObj: TMyClass): TValue
    begin
      Writeln('Antes: ', AObj.Value); // Saída: Antes: 100
      Result := TValue.From<TMyClass>(TMyClass.Create(200));
    end);
  Writeln('Depois: ', MutableRef.AsRef.Value); // Saída: Depois: 200
end;

## ecl.threading - Programação Assíncrona Simplificada

### Descrição
A unidade `ecl.threading` introduz a estrutura `TAsync`, que simplifica a execução de operações assíncronas em Delphi usando o framework de tarefas (`TTask`). Inspirada em construções como `async/await` de linguagens modernas, ela permite executar procedimentos ou funções em threads separadas, com opções para aguardar resultados, tratar erros e gerenciar o estado da tarefa de forma segura.

**Principais Características:**
- **Execução Assíncrona:** Suporta procedimentos (`TProc`) e funções (`TFunc<TValue>`) em threads paralelas.
- **Await:** Método para aguardar a conclusão da tarefa com timeout configurável e continuação opcional.
- **Run/NoAwait:** Inicia a execução com ou sem espera, com suporte a tratamento de erros via callback.
- **Thread-Safety:** Usa `TAutoLock` (baseado em `TCriticalSection`) para sincronização segura.
- **Estado e Controle:** Métodos como `Status`, `Cancel` e `GetId` para gerenciar a tarefa.

Essa unidade é perfeita para aplicações que precisam de concorrência, como operações demoradas em segundo plano ou integração com APIs assíncronas, mantendo o código limpo e legível.

### Exemplo de Uso
```delphi
uses
  ecl.threading;

var
  AsyncTask: TAsync;
  FutureResult: TFuture;
begin
  // Executando um procedimento assíncrono com await
  AsyncTask := Async(procedure
    begin
      Sleep(1000); // Simula uma tarefa demorada
      Writeln('Tarefa concluída!');
    end);
  FutureResult := AsyncTask.Await(2000); // Aguarda até 2 segundos
  if FutureResult.IsSuccess then
    Writeln('Sucesso: ', FutureResult.Value.AsBoolean) // Saída: Sucesso: True
  else
    Writeln('Erro: ', FutureResult.Error);

  // Executando uma função assíncrona com resultado
  AsyncTask := Async(function: TValue
    begin
      Sleep(500);
      Result := TValue.From<Integer>(42);
    end);
  FutureResult := AsyncTask.Await(
    procedure
    begin
      Writeln('Continuação após a tarefa');
    end, 1000);
  if FutureResult.IsSuccess then
    Writeln('Resultado: ', FutureResult.Value.AsInteger); // Saída: Resultado: 42

  // Executando sem esperar (NoAwait) com tratamento de erro
  AsyncTask := Async(procedure
    begin
      Sleep(300);
      raise Exception.Create('Erro simulado');
    end);
  AsyncTask.NoAwait(function(E: Exception): TFuture
    begin
      Writeln('Erro capturado: ', E.Message); // Saída: Erro capturado: Erro simulado
      Result.SetOk(True);
    end);
end;

## ecl.stream - Leitura Avançada de Streams

### Descrição
A unidade `ecl.stream` apresenta a classe `TStreamReaderEx`, uma extensão avançada do `TStreamReader` padrão do Delphi. Inspirada em paradigmas funcionais e fluxos de dados (streams) de linguagens modernas, ela oferece métodos para manipulação de linhas de texto em streams ou arquivos, como mapeamento, filtragem, redução e agrupamento, além de suporte a notificações via listeners e gerenciamento automático de recursos com `TSmartPtr`.

**Principais Características:**
- **Funcionalidades Funcionais:** Inclui `Map`, `Filter`, `Reduce`, `ForEach`, `GroupBy` e `Comprehend` para manipulação de dados.
- **Gerenciamento de Recursos:** Usa `TSmartPtr` para liberar automaticamente streams internos.
- **Listeners:** Permite adicionar ouvintes para monitorar operações em tempo real.
- **Flexibilidade:** Suporta leitura de streams ou arquivos com várias opções de encoding e buffer.
- **Métodos de Fluxo:** Oferece `Skip`, `Take`, `Sort`, `Distinct`, `Concat` e `Partition` para controle granular do conteúdo.

Essa classe é ideal para processar grandes volumes de dados textuais, como logs, arquivos CSV ou streams de rede, com uma API fluida e moderna.

### Exemplo de Uso
```delphi
uses
  ecl.stream;

var
  Reader: TStreamReaderEx;
  Result: Integer;
begin
  // Criando um stream reader a partir de um arquivo
  Reader := TStreamReaderEx.New('example.txt');
  
  // Adicionando um listener para monitorar operações
  Reader.AddListener(procedure(const Line: String; const Operation: String)
    begin
      Writeln(Operation, ': ', Line);
    end);

  // Mapeando linhas para maiúsculas
  Reader.Map(function(const Line: String): String
    begin
      Result := UpperCase(Line);
    end);

  // Filtrando linhas que começam com 'A'
  Reader.Filter(function(const Line: String): Boolean
    begin
      Result := Line.StartsWith('A');
    end);

  // Reduzindo para contar caracteres
  Result := Reader.Reduce(function(Acc: Integer; const Line: String): Integer
    begin
      Result := Acc + Length(Line);
    end, 0);
  Writeln('Total de caracteres: ', Result);

  // Agrupando por primeira letra
  var Groups := Reader.GroupBy(function(const Line: String): String
    begin
      Result := Line[1];
    end);
  for var Key in Groups.Keys do
    Writeln('Grupo ', Key, ': ', Groups[Key].Count, ' linhas');

  // Lendo como string final
  Writeln('Conteúdo final: ', Reader.AsString);
end;

## ecl.arrow.fun - Ferramentas Funcionais para Valores e Variáveis

### Descrição
A unidade `ecl.arrow.fun` apresenta o record `TArrow`, uma utilidade para programação funcional em Delphi que permite criar procedimentos e funções para manipular valores (`TValue`) e variáveis de forma flexível. Inspirado em conceitos como "arrows" de linguagens funcionais, o `TArrow` suporta atribuições a variáveis, efeitos colaterais e recuperação de valores com conversão de tipos segura, incluindo operações com tuplas para múltiplos valores.

**Principais Características:**
- **Procedimentos Dinâmicos:** Cria `TProc` para atribuir valores a variáveis internas ou externas.
- **Funções com Resultado:** Gera `TFunc<TValue>` para computar e retornar valores.
- **Suporte a Tuplas:** Permite atualizar múltiplas variáveis a partir de um `Tuple` com type-safety.
- **Conversão de Tipos:** Métodos como `Value<T>` recuperam valores com cast automático.
- **Gerenciamento de Estado:** Armazena o último valor processado em uma variável interna (`FValue`).

Essa unidade é útil para cenários que exigem manipulação funcional de dados, como pipelines de transformação ou atribuições condicionais em fluxos de código.

### Exemplo de Uso
```delphi
uses
  ecl.arrow.fun,
  ecl.tuple;

var
  Proc: TProc;
  Func: TFunc<TValue>;
  StrVar: String;
  IntVar: Integer;
  MultiProc: TProc<TValue>;
begin
  // Criando um procedimento simples
  Proc := TArrow.Fn(TValue.From('Hello'));
  Proc(); // Atribui 'Hello' ao FValue interno
  Writeln(TArrow.Value<String>); // Saída: Hello

  // Criando uma função que retorna um valor
  Func := TArrow.Result(TValue.From(42));
  Writeln(Func().AsInteger); // Saída: 42

  // Atribuindo a uma variável tipada
  StrVar := 'Initial';
  Proc := TArrow.Fn<String>(StrVar, 'Updated');
  Proc(TValue.Empty); // Executa a atribuição
  Writeln(StrVar); // Saída: Updated

  // Atribuindo múltiplos valores com tupla
  IntVar := 0;
  MultiProc := TArrow.Fn([@StrVar, @IntVar], Tuple.New([TValue.From('Multi'), TValue.From(100)]));
  MultiProc(TValue.Empty);
  Writeln('String: ', StrVar, ', Integer: ', IntVar); // Saída: String: Multi, Integer: 100
end;

## ecl.coroutine - Sistema de Corrotinas

### Descrição
A unidade `ecl.coroutine` implementa um sistema de corrotinas em Delphi, permitindo a execução cooperativa de tarefas com controle de estado e comunicação entre elas. Composta pela classe `TCoroutine` e pela interface `IScheduler` (implementada por `TScheduler`), ela oferece uma alternativa leve à programação assíncrona tradicional, inspirada em mecanismos como generators e coroutines de linguagens modernas.

**Componentes Principais:**
- **`TCoroutine`:** Representa uma corrotina com estado (`Active`, `Paused`, `Finished`), função principal (`TFuncCoroutine`), e suporte a observers para notificação.
- **`IScheduler` / `TScheduler`:** Gerencia múltiplas corrotinas, controlando execução, suspensão, retomada e comunicação via `Send` e `Yield`.

**Principais Características:**
- **Execução Cooperativa:** Corrotinas cedem controle explicitamente com `Yield`, permitindo multitarefa sem threads pesados.
- **Comunicação:** Suporta envio de valores (`Send`) e recebimento (`Yield`) entre corrotinas e o scheduler.
- **Controle de Tempo:** Permite definir intervalos de execução para cada corrotina.
- **Thread-Safety:** Usa `TCriticalSection` para sincronização segura.
- **Callbacks:** Oferece eventos para início (`Started`), fim (`Finished`) e tratamento de erros.

Essa unidade é ideal para cenários como simulações, pipelines de processamento ou tarefas cíclicas que requerem coordenação leve e eficiente.

### Exemplo de Uso
```delphi
uses
  ecl.coroutine;

var
  Scheduler: IScheduler;
  Counter: Integer;
begin
  Scheduler := TScheduler.New(100); // Intervalo de 100ms entre execuções

  // Adicionando uma corrotina simples
  Scheduler.Add('Counter', function(ASendValue, AValue: TValue): TFuture
    begin
      Counter := AValue.AsInteger + 1;
      Writeln('Counter: ', Counter);
      Result.SetOk(TValue.From(Counter));
      if Counter >= 3 then
        Result := TCompletion; // Finaliza a corrotina
    end, TValue.From(0));

  // Adicionando uma corrotina com intervalo e envio
  Scheduler.Add('Sender', function(ASendValue, AValue: TValue): TFuture
    begin
      if not ASendValue.IsEmpty then
        Writeln('Received: ', ASendValue.AsString);
      Result.SetOk(TValue.From('Ping'));
    end, TValue.Empty, nil, 500); // Intervalo de 500ms

  // Configurando callbacks
  Scheduler.Started(procedure
    begin
      Writeln('Scheduler iniciado!');
    end).Finished(procedure
    begin
      Writeln('Scheduler finalizado!');
    end).Run(procedure(AMessage: String)
    begin
      Writeln('Erro: ', AMessage);
    end);

  // Enviando valor e esperando
  Sleep(1000);
  Scheduler.Send('Sender', TValue.From('Hello'));
  Sleep(1000);
  Scheduler.Stop;

  Writeln('Valor final do Counter: ', Counter);
end;

## ecl.currying - Programação Funcional Avançada

### Descrição
A unidade `ecl.currying` oferece um conjunto robusto de ferramentas para programação funcional em Delphi, incluindo currying, memoização, pipelines e operações numéricas genéricas. Inspirada em linguagens como Haskell e F#, ela traz conceitos avançados como composição de funções, aplicação parcial e manipulação funcional de listas, além de suporte a tipos numéricos diversos via a interface `INumeric<T>`.

**Componentes Principais:**
- **`TCurrying`:** Record que suporta operações curried e manipulação de valores (`TValue`) com métodos como `Op` e `Concat`.
- **`TPipeline<T>`:** Estrutura para encadear transformações em valores de forma fluida.
- **`TMemoizedCache<T, U>`:** Cache thread-safe para memoização de resultados de funções.
- **`INumeric<T>`:** Interface implementada por classes como `TNumericInteger` e `TNumericString` para operações numéricas genéricas.

**Principais Características:**
- **Currying:** Transforma funções multi-argumento em sequências de funções de um argumento (`Curry`, `UnCurry`, `Partial`).
- **Memoização:** Otimiza funções com cache de resultados (`Memoize`).
- **Pipelines:** Encadeia operações com `TPipeline<T>` usando `Apply`, `Map` e `Thn`.
- **Manipulação de Listas:** Métodos como `Map`, `Filter`, `Fold`, `GroupBy`, `Zip` e mais para trabalhar com `TList<T>`.
- **Operações Numéricas:** Suporte a tipos como `Integer`, `Double`, `String`, `Boolean` e `TDateTime` via `INumeric<T>`.

Essa unidade é ideal para desenvolvedores que buscam aplicar paradigmas funcionais em Delphi, otimizando código e trabalhando com dados de maneira declarativa.

### Exemplo de Uso
```delphi
uses
  ecl.currying;

var
  Curried: TCurrying;
  Pipeline: TPipeline<Integer>;
  List: TList<Integer>;
  MemoizedFib: TFunc<Integer, Integer>;
begin
  // Usando currying para somar valores
  Curried := TCurrying.Create(TValue.From<Integer>(5));
  var AddFunc := Curried.Op<Integer>(function(X, Y: Integer): Integer begin Result := X + Y; end);
  Writeln(AddFunc(3).Value<Integer>); // Saída: 8

  // Criando um pipeline
  Pipeline := TCurrying.Pipe<Integer>(10)
    .Map<Integer>(function(X: Integer): Integer begin Result := X * 2; end)
    .Thn<string>(function(X: Integer): string begin Result := 'Valor: ' + X.ToString; end);
  Writeln(Pipeline.Value); // Saída: Valor: 20

  // Memoizando uma função de Fibonacci
  MemoizedFib := TCurrying.Memoize<Integer, Integer>(
    function(N: Integer): Integer
    begin
      if N <= 1 then Result := N else Result := MemoizedFib(N - 1) + MemoizedFib(N - 2);
    end);
  Writeln(MemoizedFib(10)); // Saída: 55 (calculado rapidamente graças ao cache)

  // Manipulando uma lista
  List := TList<Integer>.Create;
  try
    List.AddRange([1, 2, 3, 4, 5]);
    var Doubled := TCurrying.Map<Integer, Integer>(List, function(X: Integer): Integer begin Result := X * 2; end);
    Writeln(TCurrying.ArrayToString<Integer>(Doubled.ToArray)); // Saída: 2, 4, 6, 8, 10
  finally
    List.Free;
  end;

  // Usando INumeric para operações
  var Num := TNumericInteger.Create(10);
  Writeln(Num.Add(5).ToString); // Saída: 15
end;

## ecl.dictionary - Dicionário Avançado com Funcionalidades Estendidas

### Descrição
A unidade `ecl.dictionary` apresenta a classe `TDictEx<K, V>`, uma extensão do `TDictionary<K, V>` padrão do Delphi que incorpora funcionalidades avançadas para manipulação de pares chave-valor. Inspirada em paradigmas funcionais e coleções de linguagens modernas, ela oferece métodos para filtragem, mapeamento, redução, agrupamento e mais, além de operações como rotação, interseção e exclusão.

**Principais Características:**
- **Manipulação Funcional:** Métodos como `Map`, `Filter`, `Reduce` e `GroupBy` para transformações declarativas.
- **Iteração Avançada:** Suporte a `ForEach` e `ForEachIndexed` para ações em pares chave-valor.
- **Ordenação e Aleatoriedade:** Inclui `SortedKeys`, `ShuffleKeys` e `Rotate` para reorganização de dados.
- **Operações de Conjunto:** `Intersect`, `Except` e `Partition` para manipulação baseada em lógica de conjuntos.
- **Flexibilidade:** Métodos como `Take`, `Skip`, `Slice` e `FlatMap` para controle granular dos dados.

Essa classe é ideal para cenários que exigem manipulação sofisticada de dicionários, como processamento de dados, análises ou estruturas de configuração complexas.

### Exemplo de Uso
```delphi
uses
  ecl.dictionary;

var
  Dict: TDictEx<string, Integer>;
  Filtered: TMap<string, Integer>;
  Mapped: TMap<string, string>;
begin
  // Criando e populando o dicionário
  Dict := TDictEx<string, Integer>.Create;
  try
    Dict.Add('apple', 5);
    Dict.Add('banana', 3);
    Dict.Add('cherry', 8);

    // Iterando com ForEach
    Dict.ForEach(procedure(Key: string; Value: Integer)
      begin
        Writeln(Key, ': ', Value);
      end);
    // Saída: apple: 5, banana: 3, cherry: 8

    // Filtrando valores maiores que 4
    Filtered := Dict.Filter(function(Key: string; Value: Integer): Boolean
      begin
        Result := Value > 4;
      end);
    Writeln(Filtered.ToString); // Saída: apple=5, cherry=8

    // Mapeando valores para strings
    Mapped := Dict.Map<string>(function(Value: Integer): string
      begin
        Result := 'Qty: ' + Value.ToString;
      end);
    Writeln(Mapped.ToString); // Saída: apple=Qty: 5, banana=Qty: 3, cherry=Qty: 8

    // Agrupando por paridade
    var Groups := Dict.GroupBy<Boolean>(function(Value: Integer): Boolean
      begin
        Result := Value mod 2 = 0;
      end);
    Writeln('Pares: ', Groups[True].Count, ', Ímpares: ', Groups[False].Count);
    // Saída: Pares: 1, Ímpares: 2

    // Pegando os primeiros 2 itens
    var Taken := Dict.Take(2);
    Writeln(Taken.ToString); // Saída: apple=5, banana=3
  finally
    Dict.Free;
  end;
end;

## ecl.directory - Manipulação Avançada de Diretórios

### Descrição
A unidade `ecl.directory` apresenta o record `TDirEx`, uma abstração que encapsula e aprimora as funcionalidades do `TDirectory` da unidade `IOUtils` do Delphi. Ele oferece métodos para listar diretórios, arquivos e entradas do sistema de arquivos, retornando resultados em um `TVector<String>` para integração com outras partes da ECL. Suporta filtros, padrões de busca e opções de recursão, mantendo uma API simples e consistente.

**Principais Características:**
- **Listagem Flexível:** Métodos como `GetDirectories`, `GetFiles` e `GetFileSystemEntries` com várias sobrecargas.
- **Filtros Personalizados:** Suporte a `TFilterPredicate` para filtragem baseada em condições.
- **Padrões de Busca:** Permite especificar padrões como `*.txt` para restringir resultados.
- **Recursão:** Opção `TSearchOption` para busca em subdiretórios.
- **Integração com ECL:** Retorna `TVector<String>` para fácil manipulação com outras unidades.

Essa unidade é ideal para tarefas de gerenciamento de arquivos e diretórios, como varreduras de sistema, busca de arquivos específicos ou integração com pipelines de processamento de dados.

### Exemplo de Uso
```delphi
uses
  ecl.directory;

var
  Dirs: TVector<String>;
  Files: TVector<String>;
begin
  // Listando todos os diretórios em um caminho
  Dirs := TDirEx.GetDirectories('C:\Example');
  Writeln('Diretórios: ', Dirs.ToString);
  // Saída exemplo: [C:\Example\Folder1, C:\Example\Folder2]

  // Listando arquivos .txt em um diretório
  Files := TDirEx.GetFiles('C:\Example', '*.txt');
  Writeln('Arquivos .txt: ', Files.ToString);
  // Saída exemplo: [C:\Example\file1.txt, C:\Example\file2.txt]

  // Filtrando arquivos por tamanho (> 1KB) em subdiretórios
  Files := TDirEx.GetFiles('C:\Example', '*.txt', TSearchOption.soAllDirectories,
    function(const Path: string; const SearchRec: TSearchRec): Boolean
    begin
      Result := SearchRec.Size > 1024;
    end);
  Writeln('Arquivos .txt > 1KB: ', Files.ToString);
  // Saída exemplo: [C:\Example\Subfolder\largefile.txt]

  // Listando entradas do sistema de arquivos com filtro
  var Entries := TDirEx.GetFileSystemEntries('C:\Example',
    function(const Path: string; const SearchRec: TSearchRec): Boolean
    begin
      Result := Pos('test', LowerCase(SearchRec.Name)) > 0;
    end);
  Writeln('Entradas com "test": ', Entries.ToString);
  // Saída exemplo: [C:\Example\testfolder, C:\Example\testfile.txt]
end;

## ecl.dot.env - Gerenciamento Avançado de Variáveis de Ambiente

### Descrição
A unidade `ecl.dot.env` apresenta a classe `TDotEnv`, uma ferramenta poderosa para gerenciamento de variáveis de ambiente em Delphi. Inspirada em bibliotecas populares como `dotenv` de outras linguagens, ela permite carregar, manipular e salvar variáveis de um arquivo `.env`, além de interagir com variáveis de ambiente do sistema. Suporta interpolação de variáveis, acesso tipado e fallback opcional para o sistema.

**Principais Características:**
- **Suporte a `.env`:** Carrega e salva variáveis de arquivos `.env` com facilidade.
- **Interpolação:** Resolve referências como `${VAR}` em valores de variáveis.
- **Acesso Tipado:** Métodos como `Get<T>`, `TryGet<T>` e `Value<T>` para conversão segura de tipos.
- **Fallback do Sistema:** Opção de usar variáveis de ambiente do sistema quando não encontradas no arquivo.
- **Manipulação:** Adiciona, atualiza e remove variáveis no arquivo ou no sistema operacional.

Essa classe é ideal para gerenciar configurações de aplicativos, como chaves de API, caminhos ou parâmetros, de forma centralizada e segura.

### Exemplo de Uso
```delphi
uses
  ecl.dot.env;

var
  Env: TDotEnv;
begin
  // Criando uma instância e carregando .env
  Env := TDotEnv.Create('.env', True);
  try
    // Exemplo de conteúdo do arquivo .env:
    // API_KEY=abc123
    // PORT=8080
    // BASE_URL=http://${API_KEY}@example.com

    // Acessando valores com conversão de tipo
    Writeln('API Key: ', Env.Get<String>('API_KEY')); // Saída: API Key: abc123
    Writeln('Port: ', Env.Get<Integer>('PORT')); // Saída: Port: 8080

    // Usando interpolação
    Writeln('Base URL: ', Env.Get<String>('BASE_URL')); // Saída: Base URL: http://abc123@example.com

    // Adicionando uma nova variável
    Env.Push('DEBUG', TValue.From<Boolean>(True));
    Writeln('Debug: ', Env.Value<Boolean>('DEBUG')); // Saída: Debug: True

    // Salvando alterações no arquivo
    Env.Save;

    // Obtendo com fallback
    Writeln('User: ', Env.GetOr<String>('USER', 'default')); // Usa sistema ou 'default'

    // Manipulando variáveis do sistema
    Env.EnvCreate('TEMP_VAR', 'test');
    Writeln('Temp Var: ', Env.EnvLoad('TEMP_VAR')); // Saída: Temp Var: test
    Env.EnvDelete('TEMP_VAR');
  finally
    Env.Free;
  end;
end;

## ecl.list - Lista Avançada com Funcionalidades Estendidas

### Descrição
A unidade `ecl.list` apresenta a classe `TListEx<T>`, uma extensão do `TList<T>` padrão do Delphi que incorpora funcionalidades avançadas para manipulação de listas genéricas. Inspirada em paradigmas funcionais e coleções de linguagens modernas, ela oferece métodos para filtragem, mapeamento, redução, agrupamento e mais, retornando resultados em `TVector<T>` para integração com a ECL, além de operações como rotação, embaralhamento e interseção.

**Principais Características:**
- **Manipulação Funcional:** Métodos como `Map`, `Filter`, `Reduce`, `GroupBy` e `Comprehend` para transformações declarativas.
- **Iteração Avançada:** Suporte a `ForEach` e `ForEachIndexed` para ações em elementos.
- **Ordenação e Aleatoriedade:** Inclui `SortBy`, `Shuffle` e `Rotate` para reorganização de elementos.
- **Operações de Conjunto:** `Intersect`, `Except` e `Partition` para manipulação baseada em lógica de conjuntos.
- **Flexibilidade:** Métodos como `Take`, `Skip`, `Slice` e `FlatMap` para controle granular da lista.

Essa classe é ideal para cenários que exigem manipulação sofisticada de listas, como processamento de dados, ordenação personalizada ou integração com outras estruturas da ECL.

### Exemplo de Uso
```delphi
uses
  ecl.list;

var
  List: TListEx<Integer>;
  Filtered: TVector<Integer>;
  Mapped: TVector<String>;
begin
  // Criando e populando a lista
  List := TListEx<Integer>.Create;
  try
    List.AddRange([1, 2, 3, 4, 5]);

    // Iterando com ForEach
    List.ForEach(procedure(Value: Integer)
      begin
        Writeln('Item: ', Value);
      end);
    // Saída: Item: 1, Item: 2, Item: 3, Item: 4, Item: 5

    // Filtrando valores pares
    Filtered := List.Filter(function(Value: Integer): Boolean
      begin
        Result := Value mod 2 = 0;
      end);
    Writeln('Pares: ', Filtered.ToString); // Saída: Pares: [2, 4]

    // Mapeando para strings
    Mapped := List.Map<String>(function(Value: Integer): String
      begin
        Result := 'Num: ' + Value.ToString;
      end);
    Writeln('Mapeado: ', Mapped.ToString); // Saída: Mapeado: [Num: 1, Num: 2, Num: 3, Num: 4, Num: 5]

    // Reduzindo para soma
    Writeln('Soma: ', List.Reduce(function(Acc, Value: Integer): Integer
      begin
        Result := Acc + Value;
      end, 0)); // Saída: Soma: 15

    // Embaralhando a lista
    List.Shuffle;
    Writeln('Embaralhado: ', List.ToString); // Saída exemplo: Embaralhado: [3, 1, 5, 2, 4]
  finally
    List.Free;
  end;
end;

## ecl.map - Mapa Genérico Personalizado

### Descrição
A unidade `ecl.map` apresenta a estrutura `TMap<K, V>`, uma implementação personalizada de mapa (dicionário) genérico em Delphi que oferece uma alternativa ao `TDictionary<K, V>` padrão. Construída com uma tabela de hash otimizada e suporte a operações funcionais, ela inclui métodos para manipulação avançada de pares chave-valor, como mapeamento, filtragem e iteração, com suporte a colisões via sondagem linear.

**Principais Características:**
- **Tabela de Hash:** Usa sondagem linear para resolver colisões, com controle de capacidade e rehashing.
- **Manipulação Funcional:** Métodos como `Map`, `Filter` e `ForEach` para transformações declarativas.
- **Flexibilidade:** Suporte a adição, remoção, e acesso tipado com `TryGetValue` e `GetValue`.
- **Serialização:** Oferece `ToJson` e `ToString`, com variantes `Raw` para maior desempenho.
- **Iteração:** Inclui enumerador personalizado para percorrer pares chave-valor.

Essa estrutura é ideal para cenários que exigem controle fino sobre mapas, como gerenciamento de configurações, caches ou dados estruturados com alta eficiência.

### Exemplo de Uso
```delphi
uses
  ecl.map;

var
  Map: TMap<String, Integer>;
  Filtered: TMap<String, Integer>;
begin
  // Criando um mapa vazio
  Map := TMap<String, Integer>.Empty;

  // Adicionando pares chave-valor
  Map.Add('apple', 5);
  Map.Add('banana', 3);
  Map.Add('cherry', 8);

  // Iterando com ForEach
  Map.ForEach(procedure(Key: String; Value: Integer)
    begin
      Writeln(Key, ': ', Value);
    end);
  // Saída: apple: 5, banana: 3, cherry: 8

  // Filtrando valores maiores que 4
  Filtered := Map.Filter(function(Key: String; Value: Integer): Boolean
    begin
      Result := Value > 4;
    end);
  Writeln('Filtrado: ', Filtered.ToString); // Saída: Filtrado: apple=5 cherry=8

  // Mapeando valores para o dobro
  var Doubled := Map.Map(function(Value: Integer): Integer
    begin
      Result := Value * 2;
    end);
  Writeln('Dobrados: ', Doubled.ToString); // Saída: Dobrados: apple=10 banana=6 cherry=16

  // Acessando um valor
  Writeln('Banana: ', Map.GetValue('banana')); // Saída: Banana: 3

  // Convertendo para JSON
  Writeln('JSON: ', Map.ToJson); // Saída: JSON: {"apple": "5", "banana": "3", "cherry": "8"}
end;

## ecl.match - Correspondência de Padrões Avançada

### Descrição
A unidade `ecl.match` apresenta a estrutura `TMatch<T>`, uma implementação robusta de correspondência de padrões (pattern matching) em Delphi. Inspirada em linguagens funcionais como F# e Scala, ela permite definir casos condicionais complexos para valores genéricos, incluindo comparações de igualdade, intervalos, tipos, expressões regulares e tratamento de exceções, com suporte a guardas e resultados tipados.

**Principais Características:**
- **Casos Diversificados:** Suporta `CaseIf`, `CaseEq`, `CaseGt`, `CaseLt`, `CaseIn`, `CaseIs`, `CaseRange`, `CaseRegex` e `Default`.
- **Guardas:** Permite condições adicionais com `CaseIf` para filtrar casos.
- **Expressões Regulares:** Integração com `ecl.regexlib` para `CaseRegex`.
- **Flexibilidade:** Suporte a procedimentos (`TProc`) e funções (`TFunc`) como ações, com sobrecargas para diferentes tipos.
- **Exceções:** Inclui `TryExcept` para tratamento de erros durante a execução.

Essa estrutura é ideal para substituir cadeias de `if-else` complexas, oferecendo uma abordagem declarativa e expressiva para lógica condicional em aplicações Delphi.

### Exemplo de Uso
```delphi
uses
  ecl.match;

var
  Match: TMatch<Integer>;
  Result: TResultPair<String, String>;
begin
  // Criando um padrão de correspondência
  Match := TMatch<Integer>.Value(42);

  // Definindo casos
  Match.CaseIf(True, procedure begin Writeln('Guard passed'); end)
       .CaseEq(42, procedure(Value: Integer) begin Writeln('Equals 42'); end)
       .CaseGt(40, function: String begin Result := 'Greater than 40'; end)
       .CaseLt(50, function(Value: Integer): String begin Result := 'Less than ' + Value.ToString; end)
       .CaseRange(0, 100, procedure begin Writeln('In range 0-100'); end)
       .Default(function: String begin Result := 'No match'; end);

  // Executando e obtendo resultado
  Result := Match.Execute<String>;
  if Result.IsSuccess then
    Writeln('Resultado: ', Result.ValueSuccess) // Saída: Resultado: Greater than 40
  else
    Writeln('Erro: ', Result.ValueFailure);

  // Exemplo com regex e try-except
  Match := TMatch<String>.Value('Hello123');
  Match.CaseRegex('Hello\d+', procedure begin Writeln('Matches regex'); end)
       .TryExcept(procedure begin Writeln('Exception handled'); end)
       .Execute;
  // Saída: Matches regex
end;

## ecl.option - Manipulação Segura de Valores Opcionais

### Descrição
A unidade `ecl.option` apresenta a estrutura `TOption<T>`, uma implementação do padrão Option (ou Maybe) em Delphi para gerenciar valores que podem ou não estar presentes. Inspirada em linguagens como Rust e Haskell, ela oferece uma alternativa segura ao uso de `nil` ou valores padrão, evitando exceções inesperadas e promovendo um estilo de programação mais funcional.

**Principais Características:**
- **Estados:** `Some(T)` para valores presentes e `None` para ausência de valor.
- **Acesso Seguro:** Métodos como `Unwrap`, `UnwrapOr`, `Expect` e `UnwrapOrElse` para extrair valores com controle.
- **Transformações:** Suporte a `Map`, `Filter`, `AndThen` e `Flatten` para manipulação funcional.
- **Correspondência:** `Match` e `IfSome` para execução condicional baseada no estado.
- **Integração:** Converte para `TResultPair` via `OkOr` e suporta operações como `Zip` e `Replace`.

Essa estrutura é ideal para cenários onde valores podem ser indefinidos, como resultados de consultas, entradas opcionais ou operações que podem falhar, substituindo verificações manuais por uma API elegante e segura.

### Exemplo de Uso
```delphi
uses
  ecl.option;

var
  Opt: TOption<Integer>;
  Result: String;
begin
  // Criando um TOption com valor
  Opt := TOption<Integer>.Some(42);

  // Verificando estado
  Writeln('IsSome: ', Opt.IsSome); // Saída: IsSome: True
  Writeln('Value: ', Opt.Unwrap); // Saída: Value: 42

  // Transformando com Map
  var StrOpt := Opt.Map<String>(function(Value: Integer): String
    begin
      Result := 'Number: ' + Value.ToString;
    end);
  Writeln('Mapped: ', StrOpt.Unwrap); // Saída: Mapped: Number: 42

  // Usando Match
  Opt.Match(procedure(Value: Integer) begin Result := 'Some: ' + Value.ToString; end,
            procedure begin Result := 'None'; end);
  Writeln(Result); // Saída: Some: 42

  // Criando um TOption vazio
  Opt := TOption<Integer>.None;
  Writeln('UnwrapOr: ', Opt.UnwrapOr(0)); // Saída: UnwrapOr: 0

  // Tratando ausência com Expect
  try
    Opt.Expect('Valor esperado não encontrado');
  except
    on E: Exception do
      Writeln('Erro: ', E.Message); // Saída: Erro: Valor esperado não encontrado
  end;
end;

## ecl.result.pair - Manipulação Segura de Resultados com Sucesso ou Falha

### Descrição
A unidade `ecl.result.pair` apresenta a estrutura `TResultPair<S, F>`, uma implementação do padrão Result em Delphi para encapsular resultados que podem ser um sucesso (`S`) ou uma falha (`F`). Inspirada em linguagens como Rust e Haskell, ela oferece uma alternativa robusta ao uso de exceções ou valores nulos para representar operações que podem falhar, promovendo um estilo de programação funcional e seguro.

**Principais Características:**
- **Estados:** `Success(S)` para resultados bem-sucedidos e `Failure(F)` para falhas.
- **Acesso Seguro:** Métodos como `SuccessOrException`, `FailureOrElse`, `ValueSuccess` e `ValueFailure` para extrair valores com controle.
- **Transformações:** Suporte a `Map`, `FlatMap`, `When` e `Reduce` para manipulação funcional dos resultados.
- **Exceções Personalizadas:** Inclui `EFailureException<F>` e `ESuccessException<S>` para erros específicos ao acessar valores inválidos.
- **Flexibilidade:** Permite combinar ações e transformações baseadas no estado do resultado.

Essa estrutura é ideal para cenários onde operações podem falhar, como chamadas de API, leitura de arquivos ou cálculos, oferecendo uma maneira clara e segura de tratar ambos os casos sem depender exclusivamente de exceções.

### Exemplo de Uso
```delphi
uses
  ecl.result.pair;

var
  Result: TResultPair<Integer, String>;
begin
  // Criando um resultado de sucesso
  Result := TResultPair<Integer, String>.Success(42);
  Writeln('IsSuccess: ', Result.IsSuccess); // Saída: IsSuccess: True
  Writeln('Value: ', Result.ValueSuccess); // Saída: Value: 42

  // Transformando com Map
  var StrResult := Result.Map<String>(function(Value: Integer): String
    begin
      Result := 'Number: ' + Value.ToString;
    end);
  Writeln('Mapped: ', StrResult.ValueSuccess); // Saída: Mapped: Number: 42

  // Usando When para ação condicional
  Result.When(procedure(Value: Integer) begin Writeln('Success: ', Value); end,
              procedure(Error: String) begin Writeln('Failure: ', Error); end);
  // Saída: Success: 42

  // Criando um resultado de falha
  Result := TResultPair<Integer, String>.Failure('Erro ao processar');
  Writeln('IsFailure: ', Result.IsFailure); // Saída: IsFailure: True

  // Tratando falha com SuccessOrElse
  Writeln('SuccessOrElse: ', Result.SuccessOrElse(function: Integer begin Result := 0; end));
  // Saída: SuccessOrElse: 0

  // Acessando falha com exceção
  try
    Result.SuccessOrException;
  except
    on E: EFailureException<String> do
      Writeln('Erro: ', E.Message); // Saída: Erro: A generic exception occurred with value Erro ao processar
  end;
end;

## ecl.safetry - Execução Segura de Blocos Try-Except-Finally

### Descrição
A unidade `ecl.safetry` apresenta as estruturas `TSafeTry` e `TSafeResult`, que oferecem uma maneira segura e funcional de executar blocos try-except-finally em Delphi. Inspirada em padrões como `try`/`catch`/`finally` de outras linguagens, ela encapsula a execução de código potencialmente falível, retornando um resultado (`TSafeResult`) que indica sucesso ou falha sem lançar exceções diretamente.

**Componentes Principais:**
- **`TSafeTry`:** Configura e executa um bloco try-except-finally com métodos encadeáveis (`Try`, `Except`, `Finally`, `End`).
- **`TSafeResult`:** Representa o resultado da execução, contendo um valor (`TValue`) em caso de sucesso ou uma mensagem de erro em caso de falha.

**Principais Características:**
- **Encadeamento Fluente:** Permite configurar try, except e finally em uma única expressão.
- **Acesso Seguro:** Métodos como `GetValue`, `TryGetValue` e `AsType<T>` para acessar o resultado com controle.
- **Flexibilidade:** Suporta tanto procedimentos (`TProc`) quanto funções (`TFunc<TValue>`) no bloco try.
- **Tipagem Genérica:** Converte resultados para tipos específicos com `AsType<T>`.

Essa unidade é ideal para cenários onde você deseja evitar exceções não tratadas, como operações de I/O, parsing ou chamadas externas, oferecendo uma alternativa funcional e segura ao gerenciamento tradicional de erros.

### Exemplo de Uso
```delphi
uses
  ecl.safetry;

var
  Safe: TSafeResult;
begin
  // Executando um bloco com função
  Safe := &Try(function: TValue
    begin
      Result := TValue.From(42 div 0); // Simula uma divisão por zero
    end)
    .&Except(procedure(E: Exception)
      begin
        Writeln('Exceção capturada: ', E.Message);
      end)
    .&Finally(procedure
      begin
        Writeln('Finalizando execução');
      end)
    .&End;

  Writeln('IsOk: ', Safe.IsOk); // Saída: IsOk: False
  Writeln('Erro: ', Safe.ExceptionMessage); // Saída: Erro: Division by zero

  // Executando um bloco com procedimento
  Safe := &Try(procedure
    begin
      Writeln('Executando com sucesso');
    end)
    .&End;

  Writeln('IsOk: ', Safe.IsOk); // Saída: IsOk: True
  if Safe.TryGetValue(var Value: TValue) then
    Writeln('Valor: ', Value.AsBoolean); // Saída: Valor: True

  // Convertendo para tipo específico
  Safe := &Try(function: TValue
    begin
      Result := TValue.From(123);
    end)
    .&End;
  Writeln('Valor como Integer: ', Safe.AsType<Integer>); // Saída: Valor como Integer: 123
end;

## ecl.std - Utilitários Padrão e Estruturas Fundamentais

### Descrição
A unidade `ecl.std` é o núcleo de utilitários da Evolution Core Library (ECL), fornecendo estruturas e funções essenciais para suporte às demais unidades. Ela inclui ferramentas para manipulação de arrays (`TArrayEx`), conjuntos (`TSet<T>`), resultados futuros (`TFuture`), streams baseados em ponteiros (`TPointerStream`), e utilitários gerais (`TStd`), além de definições como `Tuple` e `TListString`.

**Componentes Principais:**
- **`TFuture`:** Representa um valor futuro que pode ser sucesso ou erro.
- **`TArrayEx`:** Extende `TArray` com métodos funcionais como `Map`, `Filter`, `Reduce` e `GroupBy`.
- **`TSet<T>`:** Conjunto genérico para itens únicos com operações como `Union` e `Contains`.
- **`TStd`:** Classe singleton com funções utilitárias como `Min`, `Max`, `Split` e conversão ISO 8601.
- **`TPointerStream`:** Stream baseado em ponteiros para manipulação direta de memória.

**Principais Características:**
- **Funcionalidade:** Oferece métodos funcionais para arrays e conversões de dados.
- **Flexibilidade:** Suporte genérico para tipos diversos em `TSet` e `TArrayEx`.
- **Utilitários:** Funções comuns como manipulação de strings, datas e memória.

Essa unidade é a base para muitas funcionalidades da ECL, sendo ideal para operações genéricas, manipulação de coleções e integração com outras partes da biblioteca.

### Exemplo de Uso
```delphi
uses
  ecl.std;

var
  Future: TFuture;
  Set: TSet<Integer>;
  ArrayEx: TArray<Integer>;
begin
  // Usando TFuture
  Future.SetOk(TValue.From(42));
  Writeln('Future Ok: ', Future.IsOk); // Saída: Future Ok: True
  Writeln('Future Value: ', Future.Ok<Integer>); // Saída: Future Value: 42

  // Usando TSet
  Set := TSet<Integer>.Create;
  try
    Set.Add(1); Set.Add(2); Set.Add(1);
    Writeln('Set Count: ', Set.Count); // Saída: Set Count: 2
    Writeln('Set Contains 2: ', Set.Contains(2)); // Saída: Set Contains 2: True
  finally
    Set.Free;
  end;

  // Usando TArrayEx
  ArrayEx := TArrayEx.Map<Integer, String>([1, 2, 3], function(Value: Integer): String
    begin
      Result := 'Num: ' + Value.ToString;
    end);
  Writeln('Mapped Array: ', TStd.JoinStrings(ArrayEx, ', ')); // Saída: Mapped Array: Num: 1, Num: 2, Num: 3

  // Usando TStd
  Writeln('Min: ', TStd.Min(5, 10)); // Saída: Min: 5
  Writeln('ISO Date: ', TStd.DateTimeToIso8601(Now, True)); // Saída exemplo: ISO Date: 2025-03-19T14:30:00
end;

## ecl.str - Extensões Funcionais para Tipos Básicos

### Descrição
A unidade `ecl.str` oferece extensões funcionais para tipos básicos do Delphi (`Char`, `String`, `Integer`, `Boolean`, `Double`, `TDateTime`) por meio de record helpers. Inspirada em paradigmas funcionais, ela adiciona métodos como `Map`, `Filter`, `Reduce` e outros, permitindo manipulações expressivas e declarativas diretamente sobre esses tipos.

**Componentes Principais:**
- **`TCharHelperEx`:** Métodos como `ToUpper`, `ToLower`, `IsLetter`, `IsDigit`.
- **`TStringHelperEx`:** Funções funcionais (`Map`, `Filter`, `Reduce`) e utilitários (`Sort`, `Reverse`, `GroupBy`).
- **`TIntegerHelperEx`:** Métodos como `Map`, `IsEven`, `IsOdd`, `Times`.
- **`TBooleanHelperEx`:** Métodos como `Map`, `IfTrue`, `IfFalse`.
- **`TFloatHelperEx`:** Métodos como `Map`, `Round`, `ApproxEqual`.
- **`TDateTimeHelperEx`:** Métodos como `Map`, `AddDays`, `IsPast`, `ToFormat`.

**Principais Características:**
- **Programação Funcional:** Métodos como `Map` e `Reduce` para transformações e agregações.
- **Utilitários Práticos:** Funções para manipulação direta de valores básicos.
- **Integração:** Usa `TVector` (de `ecl.vector`) e `TDictionary` para operações avançadas.

Essa unidade é ideal para simplificar operações em tipos básicos, promovendo um código mais conciso e funcional em aplicações Delphi.

### Exemplo de Uso
```delphi
uses
  ecl.str;

var
  Str: String;
  Vec: TVector<String>;
  Int: Integer;
  Date: TDateTime;
begin
  // Extensões para String
  Str := 'Hello123';
  Writeln('Filtered: ', Str.Filter(function(C: Char): Boolean begin Result := C.IsLetter; end));
  // Saída: Filtered: Hello
  Writeln('Mapped: ', Str.Map(function(C: Char): Char begin Result := C.ToUpper; end));
  // Saída: Mapped: HELLO123
  Writeln('Sum: ', Str.Sum); // Saída: Sum: 6 (1+2+3)
  Vec := Str.Collect;
  Writeln('Collected: ', Vec.ToString); // Saída: Collected: [H, e, l, l, o, 1, 2, 3]

  // Extensões para Integer
  Int := 5;
  Writeln('Mapped: ', Int.Map(function(X: Integer): Integer begin Result := X * 2; end));
  // Saída: Mapped: 10
  Writeln('IsEven: ', Int.IsEven); // Saída: IsEven: False

  // Extensões para Boolean
  if True.IfTrue(procedure begin Writeln('True'); end) then; // Saída: True

  // Extensões para Double
  Writeln('Rounded: ', 3.7.Round); // Saída: Rounded: 4

  // Extensões para TDateTime
  Date := Now;
  Writeln('Formatted: ', Date.ToFormat('yyyy-mm-dd')); // Saída exemplo: Formatted: 2025-03-19
  Writeln('Past: ', Date.AddDays(-1).IsPast); // Saída: Past: True
end;

<!-- Contribuição -->
## ⛏️ Contribuição

Eu adoraria receber contribuições para os meus projetos open source. Se você tiver alguma ideia ou correção de bug, sinta-se à vontade para abrir uma issue ou enviar uma pull request.

Create [Issues](https://github.com/HashLoad/ECL/issues)

Para enviar uma pull request, siga estas etapas:

1. Faça um fork do projeto
2. Crie uma nova branch (`git checkout -b minha-nova-funcionalidade`)
3. Faça suas alterações e commit (`git commit -am 'Adicionando nova funcionalidade'`)
4. Faça push da branch (`git push origin minha-nova-funcionalidade`)
5. Abra uma pull request

<!-- Licença -->
## ✍️ Licença

[![License](https://img.shields.io/badge/Licence-LGPL--3.0-blue.svg)](https://opensource.org/licenses/LGPL-3.0)

<!-- Contato -->
## 💬 Contato

- [Youtube Channel](https://www.youtube.com.br/isaquepinheirooficialbr)
- [FaceBook](https://www.facebook.com/isaquepinheirooficialbr)
- [Instagram](https://www.instagram.com/isaquepinheirooficialbr)
- [Linkedin](https://www.instagram.com/isaquepinheirooficialbr)