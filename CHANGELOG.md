# Atlas

## CHANGELOG

## 0.16.1
- Added FileStorageRepository

## 0.16.0
- Added Melhoras na entidade de request_context

## 0.15.0
  - Added Melhor tratamento de erros e notificações no s3Repository

## 0.15.0
- Added Melhor tratamento de erros e notificações no BaseMongoidRepository

## 0.14.5
- Fixed s3 check

## 0.14.4
- Added err_code para repositorios

## 0.14.3
- Added i18n para mongoid

## 0.14.1
- Added notificações de erros nos repositorios

## 0.14.0
- Added Agrupamento por múltiplos campos

## 0.13.0
- Added Mecanismo de agrupamento
- Fixed Várias coisas p/ migração

## 0.12.1
- Fixed BaseS3Repository

## 0.12.0
- Changed BaseMongoidRepository to receive model and entity in initialize

## 0.11.0
- Changed Suporte a múltiplos namespaces de serializers

## 0.10.4
- Changed Tamanho do stacktrace nos alertas do Slack
- Added Identificação do job nas informações adicionais de falha

## 0.10.3
 - Added find_last

## 0.10.2
 - Added Adicionando ruby concurrent para processar a emissão de telemetria de forma assíncrona

## 0.10.1
 - Fixed phone format number

## 0.10.0
 - Removed BaseMongoidRepository::Mixin::FindInBatches
 - Removed BaseMongoidRepository::Mixin::Find

## 0.9.7
 - Changed Retornar enum ao em vez de array no find_paginated
 - Changed Remover render_* do base controller

## 0.9.6
 - Fixed custom channel to slack notifier

## 0.9.5
 - Added Noop para jobs

## 0.9.4
- Added SERVER to all slack notifier messages

## 0.9.3
- Added SERVER to slack notifier error messages

## 0.9.2
- Added REPROCESS_MESSAGE nos jobs

### 0.9.1
- Added Mais informações no middleware de telemetria

### 0.9.0
- Added Método `find_one` para o base_mongoid_repository

### 0.8.0
- Changed Exposição da telemetria e adapters
- Added Estrutura de Jobs

### 0.7.0
- Added Adapter Noop de Telemetria

### 0.6.2
- Added Regex para validação de telefone

### 0.6.1
- Added Regex para validação de email

### 0.6.0
- Added Refatoração reek/rubocop

### 0.5.1
- Added Informações adicionais no alerta do Slack

### 0.5.0
- Added sub parameters ordenables

### 0.4.5
- Added Alerta de erro no slack

### 0.4.4
- Fixed PDF render

## 0.4.3
- Fixed nil operator in filter params

## 0.4.2
- Added changes on notificate slack

## 0.4.1
- Added notificate to slack

## 0.4.0
- Added sub parameters filter

## 0.3.1
- Correção na mensagem de erro quando não encontra o registro

## 0.3.0
- Added método para retornar erro quando não encontrar registro

### 0.2.2
- Added Adapter para envidar dados de telemetria para o Kafka
- Added Retorno de mensagens de erro em json
- Correção do Método `find_in_batches_enum`

### 0.2.1
- Added Suporte a transformação

### 0.2.0
- Added Atualização de entidades no mongoid repository
- Added Arquivos de renderização de pdf
- Added Atributos sujos para a base entity
- Added Suporte a serializer
- Added Suporte a I18N
- Added Dependência da biblioteca de geração de pdf
- Added Suporte a UTF-8 para a biblioteca de geração de pdf

### 0.1.0 [2017-05-22]
- Versão inicial
- Added Configuração na BaseEntity

## Informações adicionais
- Todas as mudanças notáveis neste projeto serão documentadas neste arquivo.
- Este projeto adere a [Semantic Versioning](http://semver.org/) e às  guidelines [Keep-a-Changelog](https://github.com/olivierlacan/keep-a-changelog).
