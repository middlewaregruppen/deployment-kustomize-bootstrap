#!/bin/bash
echo '+------------------------------------------+'
echo '| OpenShift Kustomize deployment bootstrap |'
echo '+------------------------------------------+'
echo 
read -p 'Project name: ' projectname

max=5
numenvs=""
while [[ ! $numenvs =~ ^[0-9]{1} ]]; do
  read -p 'Number of environments needed (max 5): ' numenvs
  if (( 0 > $numenvs || $numenvs > $max )); then 
    echo "> Please enter a number between 1 and 5";
    numenvs=""
  fi
done

echo "You have chosen ${numenvs} environments: "

declare -a ekeys
declare -a evals
i=1
while [ $i -le $numenvs ]
do
  read -p "  - Name of environment $i (eg: dev, test, prod): " nextenv
  read -p "  - Name of $nextenv environment in openshift (eg: online-dev, myapp-dev): " nextos
  ekeys+=($nextenv)
  evals+=($nextos)
  ((i++))
done

echo 
echo 'The following files will be created:'
echo ' Deployments'
echo '  + '$projectname
echo '    + base' 
search_dir='./Deployments/Project/base'
for file in "$search_dir"/*.*
do
  echo '      - '$(basename $file)
done
echo '    + overlays'
for (( index=0 ; index<numenvs; index++ ));
do
  echo '      + '${ekeys[$index]}
  search_dir='./Deployments/Project/overlays/dev'
  for file in "$search_dir"/*.*
  do
    echo '        - '$(basename $file)
  done
done
echo 
read -p "Continue (y/n): " cancontinue

if [ $cancontinue == 'y' ]
then
  if test -e build
  then
    echo "> Cleaning build folder..."
    rm -rf build
    mkdir build
  fi

  mkdir -p build/Deployments/$projectname/{base,overlays}
  for (( index=0 ; index<numenvs; index++ ));
  do 
    mkdir -p build/Deployments/$projectname/overlays/${ekeys[$index]}
  done

  echo '> Writing files...'
  search_dir='./Deployments/Project/base'
  for file in "$search_dir"/*.*
  do
    cp $file build/Deployments/$projectname/base/$(basename $file)
    sed -e 's/projectname/'$projectname'/g' $file > build/Deployments/$projectname/base/$(basename $file)
  done

  for (( index=0 ; index<numenvs; index++ ));
  do
    search_dir='./Deployments/Project/overlays/dev'
    for file in "$search_dir"/*.*
    do
      cp $file build/Deployments/$projectname/overlays/${ekeys[$index]}/$(basename $file)
      sed -e 's/openshift-namespace/'${evals[$index]}'/g' Deployments/Project/overlays/dev/$(basename $file) > build/Deployments/$projectname/overlays/${ekeys[$index]}/$(basename $file)
      sed -e 's/projectname/'$projectname'/g' build/Deployments/$projectname/overlays/${ekeys[$index]}/$(basename $file) > build/Deployments/$projectname/overlays/${ekeys[$index]}/$(basename $file).copy
      mv build/Deployments/$projectname/overlays/${ekeys[$index]}/$(basename $file).copy build/Deployments/$projectname/overlays/${ekeys[$index]}/$(basename $file)
    done
  done

else
  echo '> Exiting without doing anything.'
fi
