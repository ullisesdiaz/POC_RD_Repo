#!/bin/bash
rootPath=$1
testFile=$2
host=$3
idReporte=$4
fqdnContenedor="https://resulttest.blob.core.windows.net/%24web"

echo "======================== PARAMETROS ========================"
echo "Root path: $rootPath"
echo "Test file: $testFile"
echo "Host: $host"
echo "Nombre reporte: $idReporte"

echo "===================== Decodificar SAS"
SAS_CONTENEDOR_REPORTES=`echo $SAS_CONTENEDOR_REPORTESB64 | base64 --decode`

T_DIR=.

# Reporting dir: start fresh
R_DIR=$T_DIR/report
rm -rf $R_DIR > /dev/null 2>&1
mkdir -p $R_DIR

rm -f $T_DIR/test-plan.jtl $T_DIR/jmeter.log  > /dev/null 2>&1

./run.sh $rootPath -Dlog_level.jmeter=DEBUG \
	-Jhost=$host \
	-n -t /test/$testFile -l $T_DIR/test-plan.jtl -j $T_DIR/jmeter.log \
	-e -o $R_DIR

echo "===================== Descarga de AzCopy"
wget -O azcopy.tar.gz https://aka.ms/downloadazcopy-v10-linux && tar -xf azcopy.tar.gz --strip-components=1
echo "===================== Descarga de Index"
./azcopy copy "$fqdnContenedor/index.html?$SAS_CONTENEDOR_REPORTES" "./index.html"
echo "===================== Carga de reporte a $fqdnContenedor/rep/$idReporte"
./azcopy copy "./report" "$fqdnContenedor/rep/$idReporte?$SAS_CONTENEDOR_REPORTES" --recursive=true
liReporte="<li><a href='rep/$idReporte/report/index.html'>Build $idReporte</a></li>"
echo "===================== Actualizando Index con $liReporte"
echo "$liReporte" >> ./index.html
echo "===================== Carga de Index"
./azcopy copy "./index.html" "$fqdnContenedor/index.html?$SAS_CONTENEDOR_REPORTES" --recursive=true
