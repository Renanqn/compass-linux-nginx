# Monitoramento Nginx - Ambiente Linux no Windows #

Este projeto descreve a criação de um ambiente Linux no Windows, configuração de um servidor Nginx e a automação do monitoramento do serviço. O objetivo é verificar periodicamente o status do Nginx, registrar os resultados em arquivos de log e automatizar a execução do script.

## Sumário
1. [Pré-requisitos](#pré-requisitos)
2. [Instalação do Ambiente](#configuração-do-wsl)
3. [Configuração do Servidor Nginx](#servidor-nginx)
4. [Script de Monitoramento](#script-de-monitoramento)
5. [Automação da Execução](#automatização-de-tarefas-com-o-cron)
6. [Resultados](#resultados)
   
# Pré-requisitos
Sistema Operacional:
   * Linux (Ubuntu foi o sistema escolhido para o teste)
     
Pacotes:
   * nginx : Servidor
   * cron : Automatização da execução
     
Permissões:
   * Usuário root 

## Configuração do WSL
1. Instalação WSL
   * Abrir terminal como Administrador
   * Execute o comando:
     ```
       wsl --install
    *Acesse a Microsoft Store,instale o Ubuntu e configure nome de usuário e senha.
  
2. Atualizar o Sistema:
   * No terminal Ubuntu, execute:
    ```
    sudo apt update && sudo apt upgrade -y

## Servidor Nginx
1. Instalação:
   * No terminal do Ubuntu, execute:
     ```
     sudo apt install nginx -y
2. Após instalação, inicie o serviço:
     ```
     sudo systemctl start nginx
     ```  
4. Teste no navegador
   * Execute:
     ```
     sudo systemctl status nginx
   * Abra o navegador e acesse `http://localhost`. Se o Nginx estiver rodando, você verá a página padrão.

## Script de Monitoramento
O script verifica o estado do Nginx e grava logs em `/var/log/nginx-server`.
* Crie o arquivo do script:
  ```
  nano ~/check_nginx.sh
  ```
* Adicione o código:
  ```
  #!/bin/bash

  # Variáveis
  datetime=$(date "+%d-%m-%Y %H:%M:%S")  # Data e hora no formato dia/mês/ano horas:minutos:segundos
  service="nginx"  # Serviço a ser monitorado
  log_dir="/home/$(whoami)/nginx-logs"  # Diretório dos logs
  online_log="$log_dir/nginx_online.log"  # logs de serviço online
  offline_log="$log_dir/nginx_offline.log"  # logs de serviço offline

  # Cores da saída no terminal
  red='\033[0;31m'
  green='\033[0;32m'
  yellow='\033[1;33m'
  nocolor='\033[0m'

  # Criação do diretório de logs, caso não exista
  if [ ! -d "$log_dir" ]; then
    mkdir -p "$log_dir"
    echo -e "${yellow}[INFO] Diretório de logs criado em: $log_dir${nocolor}"
  fi

  # Verificação do status do serviço
  if systemctl is-active --quiet "$service"; then
    message="$datetime | $service | ONLINE | O serviço está funcionando corretamente."
    echo -e "${green}[OK] $message${nocolor}"
    echo "$message" >> "$online_log"
  else
    message="$datetime | $service | OFFLINE | O serviço está parado ou com problemas!"
    echo -e "${red}[ERROR] $message${nocolor}"
    echo "$message" >> "$offline_log"
  fi
  ```
Torne o script executável:
```
chmod +x ~/check_nginx.sh
```
O script realiza tarefas, como:
 * Verificação automática de status do serviço Nginx.
 * Criação do diretório de logs, se ele não existir.
 * Registra o status atual na respectiva pasta
 * Inclui informações como:
     * Nome do serviço
     * Status do serviço
     * Data e hora

## Automatização de Tarefas com o Cron
Para automatiza o script, instalamos e configuramos o `cron`.
1. Instale o cron:
   ```
   sudo apt update && sudo apt upgrade
   sudo apt install cron
2. Use o comando abaixo para abrir o crontab e editar as tarefas:
   ```
   crontab -e
3. Edite o arquivo `crontab` e adicione o código abaixo no final do documento:
   ```
   */5 * * * * /home/$(whoami)/check_nginx.sh >> /home/$(whoami)/nginx-logs/cron_output.log 2>&1
   ```
 * Log centralizado:
   * Cria um log central que inclui quaisquer mensagens ou erros que o script possa gerar.
4. Verifique os logs em tempo real:
   ```
   tail -f /var/log/nginx-logs/cron_output.log
   ```
   * Altere o caminho para onde se encontra o arquivo `cron_output.log`
## Resultados
* Para status `OFFLINE` deve aparecer algo como:
  ```
  [ERROR] 20-01-2025 15:55:01 | nginx | OFFLINE | O serviço está parado ou com problemas!
  ```
* Para status `ONLINE` deve aparecer algo como:
  ```
  [OK] 20-01-2025 15:50:01 | nginx | ONLINE | O serviço está funcionando corretamente.
  ```
