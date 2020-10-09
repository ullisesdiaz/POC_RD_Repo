#!/bin/bash

ROOTPATH='/usr/bin'
VERSIONANALISIS=$1

echo "======= Instalando Sonar Scaner Path: $ROOTPATH"
sudo dotnet tool install --tool-path=$ROOTPATH dotnet-sonarscanner --version 4.10.0
echo "======= Inicializando análisis Versión: $VERSIONANALISIS"
sudo dotnet sonarscanner begin /o:gerardoat /k:gerardoat_pocdevops /d:sonar.host.url=https://sonarcloud.io /version:$VERSIONANALISIS
echo "======= Compilando código"
sudo dotnet build src --configuration Release
echo "======= Finalizando análisis"
sudo SONAR_TOKEN=$SONARTOKEN dotnet sonarscanner end
