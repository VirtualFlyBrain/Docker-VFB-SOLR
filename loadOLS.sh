#!/bin/bash

solr-foreground -Dsolr.solr.home=/opt/VFB/OLS/ols-solr/src/main/solr-5-config/ -Dsolr.data.dir=/opt/VFB/OLS/ols-solr/src/main/solr-5-config &

echo START LOADING

cd /opt/VFB
wget https://github.com/VirtualFlyBrain/VFB_owl/raw/${VFB_OWL_VERSION}/src/owl/vfb.owl.gz
gzip -d vfb.owl.gz

curl -sSf http://localhost:8983/solr/ontology

curl -sSf http://localhost:8983/solr/ontology/select

java -Xmx2g -jar -Dspring.profiles.active=vfb /opt/VFB/OLS/ols-apps/ols-solr-app/target/ols-solr-app.jar

echo COMMIT and OPTIMIZE
curl http://localhost:8983/solr/ontology/update?stream.body=%3Ccommit+waitSearcher%3D%22false%22%2F%3E%3Ccommit+waitSearcher%3D%22false%22+expungeDeletes%3D%22true%22%2F%3E%3Coptimize+waitSearcher%3D%22false%22%2F%3E

sleep 10s

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

echo COMMIT and OPTIMIZE
curl http://localhost:8983/solr/ontology/update?stream.body=%3Ccommit+waitSearcher%3D%22false%22%2F%3E%3Ccommit+waitSearcher%3D%22false%22+expungeDeletes%3D%22true%22%2F%3E%3Coptimize+waitSearcher%3D%22false%22%2F%3E

curl -sSf "http://localhost:8983/solr/ontology/select?q=*:*&wt=json&indent=true"

rm -rf /opt/VFB_neo4j
rm -rf /opt/conda
rm -rf /opt/VFB/vfb.owl

echo END LOADING

sleep 20m

while (true)
do
  if [ $(curl -sSf "http://localhost:8983/solr/ontology/select?q=short_form:FBbt*&distrib=false&fl=short_form&rows=100&wt=json&indent=true" | grep FBbt | wc -l) -gt 1 ]
  then
    echo FBbt docs found - PASS
    sleep 10m
  else
    echo FBbt docs found - FAIL
    break
   fi
  if [ $(curl -sSf "http://localhost:8983/solr/ontology/select?q=short_form:VFBexp_*&distrib=false&fl=short_form&rows=100&wt=json&indent=true" | grep VFBexp_ | wc -l) -gt 1 ]
  then
    echo VFBexp docs found - PASS
    sleep 10m
  else
    echo VFBexp docs found - FAIL
    break
   fi
done
