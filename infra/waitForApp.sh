#!/bin/bash
uri=$1

echo "========== Iniciando espera de respuesta para $uri ..."

while true
do
  STATUS=$(curl -s -o /dev/null -w '%{http_code}' $uri)
  if [ $STATUS -eq 200 ]; then
    echo "App OK"
    break
  else
    echo "App no disponible $STATUS "
  fi
  sleep 3
done

echo "==========  Fin de la espera"