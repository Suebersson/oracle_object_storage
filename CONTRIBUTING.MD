## Como contribuir com este package

- Localizar e corrigir erros de execuções em qualquer método de requisição

- Criar um novo método de requisição ou uma categoria inteira para usar os serviços Oracle Cloud e solicitar a implementação

- Sugestões de como melhoar o package

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


## [Contribuintes](https://github.com/Suebersson/oracle_object_storage/graphs/contributors)

<a href="https://github.com/Suebersson/oracle_object_storage/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=Suebersson/oracle_object_storage" />
</a>

Made with [contrib.rocks](https://contrib.rocks).