## Como contribuir com este package

- Localizar e corrigir erros de execuções ou pontos que podem ser melhorados em qualquer método de requisição

- Criar um novo método de requisição ou uma categoria inteira para usar os serviços Oracle Cloud

- Sugestões de como melhorar o package


## Regras de implementações

- Manter o padrão de organização da arquitetura do package. Cada categoria é um micro package que contém seus métodos de requisições, cada método/serviço é independente e isolado sem herdar os métodos e atributos de outros métodos

- Manter o padrão de nomeclaturas de cada método/serviço de requisição da Oracle Cloud

- Criar um arquivo {.md} com exemplo em dart de como usar o método de serviço, com o mesmo nome do arquivo {.dart} do método de requisição. Dentro do arquivo de exemplo {.md} inserir o link da documentação oficial Oracle do método de requisição

    Ex:<br>
    método de requisição: put_object.dart<br>
    exemplo de com usar: put_object.md

    ## [PutObject](https://pub.dev/packages/oracle_object_storage#PutObject)

    ```dart
    ...code example
    ```

- Não expor dados confidenciais

    tenancyOCI<br>
    userOCI<br>
    nameSpace<br>
    apiKey<br>
    fingerprint<br>
    ...

- Declarar a categoria e seus métodos de requisições no arquivo README.md


## Como enviar sua contribuição

1. Faça um fork deste repositório
2. Faça as correções, ajustes ou implementações
3. Formate todos os arquivos .dart na pasta lib: dart format 'lib\.'
4. Use o dart analyze para encontrar má pratica de desenvolmento: dart analyze 'lib\.'
5. Verificar se existe algum problema com o package: dart pub publish --dry-run
6. Gerar um relatório sobre o package: [pana](https://pub.dev/packages/pana)
7. Faça o pull request do repositório com suas contribuições
8. Sua solitação pull request será analizada pelos mantenedores deste package e será implantada se aprovada

Para instalar o pana: dart pub global activate pana

Pontos a serem considerados:
  - as plataformas compatíveis com o package
	- pontuação, sempre buscar pontuação máxima tratando todos pontos a serem melhorados 
	- se existe algum problema com as denpendências
	- se tem suporte ao null-safety
	- se possuí uma documentação
	- se possuí um projeto de como usar este package, pasta 'example'
	- se os arquivos [pubspec](https://dart.dev/tools/pub/pubspec).yaml, README.md, CHANGELOG.md, LICENCE estão todos corretos
	- se atende ao critério de pelo menos 20% de comentários no códigos fonte


## [Contribuidores](https://github.com/Suebersson/oracle_object_storage/graphs/contributors)

<a href="https://github.com/Suebersson/oracle_object_storage/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=Suebersson/oracle_object_storage" />
</a>

Made with [contrib.rocks](https://contrib.rocks).