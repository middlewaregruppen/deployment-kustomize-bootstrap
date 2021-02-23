#!/bin/bash
echo '+--------------------------------+'
echo '| OpenShift deployment bootstrap |'
echo '+--------------------------------+'
echo 'Please provide the following:'
echo 'OpenShift:'
read -p '  project name: ' projectname
read -p '  dev namespace: ' devns
read -p '  test namespace: ' testns
read -p '  prod namespace: ' prodns
echo 
echo 'Thank you, your values are:'
echo 
echo '  Project name:' $projectname
echo '  Namespaces:'
echo '    Dev:' ${devns}
echo '    Test:' $testns
echo '    Prod:' $prodns

if test -e build
then
  echo "Cleaning build folder..."
  rm -rf build
  mkdir build
fi

echo "Recreating build folder..."
mkdir -p build/Deployments/$projectname/{base,overlays}
mkdir -p build/Deployments/$projectname/overlays/{dev,prod,test}

echo "Copying files to build/Deployments/"$projectname
echo 

# Base config
cp Deployments/Project/base/kustomization.yaml build/Deployments/$projectname/base/
sed -e 's/mdsregistryapi/'$projectname'/g' Deployments/Project/base/deployment.yaml > build/Deployments/$projectname/base/deployment.yaml
sed -e 's/mdsregistryapi/'$projectname'/g' Deployments/Project/base/route.yaml > build/Deployments/$projectname/base/route.yaml
sed -e 's/mdsregistryapi/'$projectname'/g' Deployments/Project/base/service.yaml > build/Deployments/$projectname/base/service.yaml

# Dev kustomizations
sed -e 's/openshift-namespace/'$devns'/g' Deployments/Project/overlays/dev/kustomization.yaml > build/Deployments/$projectname/overlays/dev/kustomization.yaml
sed -e 's/mdsregistryapi/'$projectname'/g' Deployments/Project/overlays/dev/sizing.yaml > build/Deployments/$projectname/overlays/dev/sizing.yaml

# Test kustomizations
sed -e 's/openshift-namespace/'$testns'/g' Deployments/Project/overlays/test/kustomization.yaml > build/Deployments/$projectname/overlays/test/kustomization.yaml
sed -e 's/mdsregistryapi/'$projectname'/g' Deployments/Project/overlays/test/sizing.yaml > build/Deployments/$projectname/overlays/test/sizing.yaml

# Prod kustomizations
sed -e 's/openshift-namespace/'$prodns'/g' Deployments/Project/overlays/prod/kustomization.yaml > build/Deployments/$projectname/overlays/prod/kustomization.yaml
sed -e 's/mdsregistryapi/'$projectname'/g' Deployments/Project/overlays/prod/sizing.yaml > build/Deployments/$projectname/overlays/prod/sizing.yaml

tree build
