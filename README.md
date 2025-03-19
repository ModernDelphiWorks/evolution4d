ECL - Evolution Core Library for Delphi
Bem-vindo à Evolution Core Library (ECL), uma biblioteca moderna e poderosa para Delphi que traz funcionalidades avançadas inspiradas em paradigmas de programação contemporâneos, como programação funcional, gerenciamento seguro de recursos e operações assíncronas. Desenvolvida por Isaque Pinheiro, a ECL é projetada para aumentar a produtividade e oferecer ferramentas robustas para desenvolvedores Delphi.

Visão Geral
A ECL é uma coleção de unidades que fornecem estruturas de dados genéricas, utilitários de manipulação de tipos, suporte a expressões regulares, operações assíncronas, e muito mais. Licenciada sob a GNU Lesser General Public License v3.0 (LGPL-3.0), ela é gratuita para uso em projetos comerciais e de código aberto, desde que os termos da licença sejam respeitados.

Principais Recursos
Estruturas de Dados Genéricas: Inclui TVector<T> para arrays dinâmicos e TTuple<K> para tuplas baseadas em chave-valor.
Programação Funcional: Suporte a métodos como Map, Filter, Reduce, e Comprehend em várias estruturas.
Gerenciamento Seguro de Recursos: Uso de TSmartPtr<T> para gerenciamento automático de memória e TSafeTry para tratamento seguro de exceções.
Operações Assíncronas: TAsync e TFuture para tarefas assíncronas modernas.
Manipulação de Streams: TStreamReaderEx com funcionalidades avançadas de transformação e filtragem.
Utilitários Diversos: Expressões regulares (TRegExLib), extensões de tipos básicos (TStringHelperEx, TIntegerHelperEx, etc.), e mais.
Estrutura do Projeto
A biblioteca é composta por várias unidades independentes, cada uma com um propósito específico:

Unidade	Descrição
ecl.objects	Ferramentas para criação dinâmica de objetos via RTTI e smart pointers.
ecl.result.pair	Implementação de TResultPair<S, F> para resultados sucesso/falha.
ecl.option	TOption<T> para valores opcionais (similar ao Option do Rust).
ecl.regexlib	Utilitários de expressões regulares com validações comuns (e.g., CPF, URL).
ecl.std	Funções utilitárias padrão, como manipulação de arrays e streams.
ecl.str	Extensões funcionais para tipos básicos (String, Integer, Boolean, etc.).
ecl.safetry	TSafeTry para blocos try-except-finally seguros com resultados tipados.
ecl.tuple	Tuplas posicionais (TTuple) e baseadas em dicionário (TTuple<K>).
ecl.threading	Suporte a operações assíncronas com TAsync e TFuture.
ecl.stream	TStreamReaderEx para manipulação avançada de streams.
ecl.vector	TVector<T> para arrays dinâmicos com operações funcionais.
Requisitos
Delphi: Versão XE7 ou superior (recomenda-se a versão mais recente para suporte completo a genéricos e RTTI).
Dependências: Nenhuma dependência externa; utiliza apenas bibliotecas padrão do Delphi.
Instalação
Clone o Repositório:
bash

Collapse

Wrap

Copy
git clone https://github.com/IsaquePinheiro/ecl.git
Adicione ao Projeto:
Copie os arquivos .pas para o diretório do seu projeto ou para uma pasta acessível.
Adicione o caminho da biblioteca ao seu projeto no Delphi IDE (Project > Options > Delphi Compiler > Search Path).
Inclua as Unidades: Adicione as unidades necessárias ao seu código com uses, por exemplo:
delphi

Collapse

Wrap

Copy
uses
  ecl.vector, ecl.stream, ecl.safetry;
Exemplos de Uso
1. Trabalhando com TVector<T>
delphi

Collapse

Wrap

Copy
var
  LVector: TVector<Integer>;
  LFiltered: TVector<Integer>;
begin
  LVector := TVector<Integer>.Create([1, 2, 3, 4, 5]);
  LVector.Add(6);

  // Filtrar números pares
  LFiltered := LVector.Filter(function(const AValue: Integer): Boolean
    begin
      Result := AValue mod 2 = 0;
    end);

  WriteLn(LFiltered.ToString); // Saída: [2, 4, 6]
end;
2. Usando TSafeTry para Tratamento Seguro de Exceções
delphi

Collapse

Wrap

Copy
var
  LResult: TSafeResult;
begin
  LResult := TSafeTry.Try(function: TValue
    begin
      Result := TValue.From<Integer>(StrToInt('123abc')); // Gera exceção
    end)
    .Except(procedure(AException: Exception)
      begin
        WriteLn('Erro: ', AException.Message);
      end)
    .Finally(procedure
      begin
        WriteLn('Finalizando...');
      end)
    .End;

  if LResult.IsOk then
    WriteLn('Sucesso: ', LResult.GetValue.AsInteger)
  else
    WriteLn('Falha: ', LResult.ExceptionMessage);
end;
3. Processamento de Streams com TStreamReaderEx
delphi

Collapse

Wrap

Copy
var
  LStream: TStreamReaderEx;
begin
  LStream := TStreamReaderEx.New('example.txt');
  LStream
    .Filter(function(const ALine: String): Boolean
      begin
        Result := ContainsText(ALine, 'error');
      end)
    .Map(function(const ALine: String): String
      begin
        Result := UpperCase(ALine);
      end);

  WriteLn(LStream.AsString);
end;
Contribuição
Contribuições são bem-vindas! Para contribuir:

Faça um fork do repositório.
Crie uma branch para sua feature ou correção (git checkout -b feature/nova-funcionalidade).
Envie um pull request com uma descrição clara das mudanças.
Por favor, siga as diretrizes de código do Delphi e inclua testes quando possível.

Licença
A ECL é distribuída sob a GNU Lesser General Public License v3.0 (LGPL-3.0). Veja o arquivo LICENSE para mais detalhes.

Contato
Autor: Isaque Pinheiro
Email: isaquepsp@gmail.com
Discord: https://discord.gg/T2zJC8zX