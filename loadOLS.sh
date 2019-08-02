#!/bin/bash

init-solr-home

solr start -p 8983 -Dsolr.solr.home=/opt/VFB/OLS/ols-solr/src/main/solr-5-config/ -Dsolr.data.dir=/opt/VFB/OLS/ols-solr/src/main/solr-5-config

cd ${WORKSPACE}/
wget https://github.com/VirtualFlyBrain/VFB_owl/raw/${VFB_OWL_VERSION}/src/owl/vfb.owl.gz
gzip -d vfb.owl.gz

curl -sSf http://localhost:8983/solr

curl -sSf http://localhost:8983/solr/ontology

curl -sSf http://localhost:8983/solr/ontology/select

java -Xmx2g -jar -Dspring.profiles.active=vfb ${WORKSPACE}/OLS/ols-apps/ols-solr-app/target/ols-solr-app.jar

export PYTHONPATH=/opt/VFB_neo4j/src

mkdir -p /opt/
cd /opt && git clone https://github.com/VirtualFlyBrain/VFB_neo4j.git 

conda create -y -n env python=3.7

conda config --append channels conda-forge

conda install -y -n env --file /opt/VFB_neo4j/requirements.txt

source activate env

cd /opt/VFB_neo4j/src/

python -m uk.ac.ebi.vfb.neo4j.neo2solr.ols_neo2solr $PDBserver http://localhost:8983/solr/ontology

cd /

rm -rf cd /opt/VFB_neo4j
rm -rf cd /opt/conda

solr stop

solr-foreground -Dsolr.solr.home=/opt/VFB/OLS/ols-solr/src/main/solr-5-config/ -Dsolr.data.dir=/opt/VFB/OLS/ols-solr/src/main/solr-5-config
