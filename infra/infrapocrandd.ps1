$env = $args[0]
$prj = $args[1]
$loc = $args[2]

$rgp = $env+'rgp'+$prj
$akv = $env+'akv'+$prj
$acr = $env+'acr'+$prj
$asp = $env+'asp'+$prj
$aks = $env+'aks'+$prj

# Creacion del grupo de recursos
Write-Output 'Verificacion de existencia de $($rgp)'
$rgCheck = az group list --query "[?name=='$rgp']" | ConvertFrom-Json
$rgExists = $rgCheck.Length -gt 0
if (!$rgExists){
    Write-Output 'Creando $rgp'
    az group create --name $rgp --location $loc
    Write-Output $rgp' creado'
}

# Creacion del KeyVault
Write-Output 'Verificacion de existencia de '$akv
$kvCheck = az keyvault  list --query "[?name=='$akv']" | ConvertFrom-Json
$kvExists = $kvCheck.Length -gt 0
if (!$kvExists){
    Write-Output 'Creando '$akv
    az keyvault create --location $loc --name $akv --resource-group $rgp
    Write-Output $akv' creado'
}

# Creacion del Container Registry
Write-Output 'Verificacion de existencia de '$acr
$acrCheck = az acr list --query "[?name=='$acr']" | ConvertFrom-Json
$acrExists = $acrCheck.Length -gt 0
if (!$acrExists) {
    Write-Output 'Creando '$acr
    az acr create --resource-group $rgp --name $acr --sku Basic
    Write-Output $acr' creado'
}

# Creacion del ServicePrincipal
Write-Output 'Verificacion de existencia de '$asp
$spCheck = az ad sp list --query "[?displayName=='$asp']" | ConvertFrom-Json
$spExists = $spCheck.Length -gt 0
if (!$spExists) {
    Write-Output 'Creando '$asp
    $spResp = $(az ad sp create-for-rbac -n $asp | ConvertFrom-Json )
    Write-Output $asp' creado'
    Write-Output 'Guardando credenciales de '$asp
    az keyvault secret set --vault-name $akv --name $asp'appId' --value $spResp.appId
    az keyvault secret set --vault-name $akv --name $asp'password' --value $spResp.password
    Write-Output 'Credenciales de '$asp' guardadas'
}

# Asignacion de roles a ServicePrincipal sobre el Container Registry
Write-Output 'asignacion de permiso a '$asp' sobre '$acr
$acrId = $(az acr show --name $acr --query id --output tsv)
$spId = $(az ad sp list --query "[?displayName=='dosppocrandd']" | ConvertFrom-Json).appId
az role assignment create --assignee $spId --scope $acrId --role acrpull

# Creacion del Kubernetes Service
$aksCheck = az aks list --query "[?name=='$aks']" | ConvertFrom-Json
$aksExists = $aksCheck.Length -gt 0
if (!$aksExists) {
    Write-Output 'Recuperando credenciales de '$asp
    $spId = $(az keyvault secret show --vault-name $akv --name $asp'appId' | ConvertFrom-Json).value
    $spPw = $(az keyvault secret show --vault-name $akv --name $asp'password' | ConvertFrom-Json).value
    Write-Output 'Creando '$aks
    az aks create -n $aks -g $rgp --location $loc --node-count 1 --load-balancer-sku basic --service-principal $spId --client-secret $spPw --generate-ssh-keys
    Write-Output $aks' creado'
}
