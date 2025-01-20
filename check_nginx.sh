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

