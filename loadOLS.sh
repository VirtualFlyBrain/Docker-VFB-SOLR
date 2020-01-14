#!/bin/bash

init-solr-home

echo START LOADING

cd ${WORKSPACE}/
wget https://github.com/VirtualFlyBrain/VFB_owl/raw/${VFB_OWL_VERSION}/src/owl/vfb.owl.gz
gzip -d vfb.owl.gz

curl -sSf http://localhost:8983/solr

curl -sSf http://localhost:8983/solr/ontology

curl -sSf http://localhost:8983/solr/ontology/select

java -Xmx2g -jar -Dspring.profiles.active=vfb ${WORKSPACE}/OLS/ols-apps/ols-solr-app/target/ols-solr-app.jar

sleep 10s

solr-foreground -Dsolr.solr.home=/opt/VFB/OLS/ols-solr/src/main/solr-5-config/ -Dsolr.data.dir=/opt/VFB/OLS/ols-solr/src/main/solr-5-config &

sleep 1m

export PYTHONPATH=/opt/VFB_neo4j/src

mkdir -p /opt/
cd /opt && git clone https://github.com/VirtualFlyBrain/VFB_neo4j.git 

conda create -y -n env python=3.7

conda config --append channels conda-forge

conda install -y -n env --file /opt/VFB_neo4j/requirements.txt

source activate env

cd /opt/VFB_neo4j/src/

pip install -r /opt/VFB_neo4j/requirements.txt

python -m uk.ac.ebi.vfb.neo4j.neo2solr.ols_neo2solr $PDBserver http://localhost:8983/solr/ontology

cd /

rm -rf cd /opt/VFB_neo4j
rm -rf cd /opt/conda

echo END LOADING

sleep 9m

while (true)
do
  if [ $(curl -sSf "https://localhost:8983/solr/ontology/select?q=*:*&distrib=false&fl=short_form&rows=100&wt=json&indent=true" | grep FBbt | wc -l) -gt 1 ]
  then
    echo FBbt docs found - PASS
    sleep 10m
  else
    echo FBbt docs found - FAIL
    break
   fi
  if [ $(curl -sSf "https://localhost:8983/solr/ontology/select?q=*:*&distrib=false&fl=short_form&rows=100&wt=json&indent=true" | grep VFBexp_ | wc -l) - gt 1 ]
  then
    echo VFBexp docs found - PASS
    sleep 10m
  else
    echo VFBexp docs found - FAIL
    break
   fi
done
