#!/bin/bash
set -e

: "${FULL_IMAGE:?FULL_IMAGE not set}"

rm -rf gitops-repo
git clone https://${GIT_USER}:${GIT_PASS}@github.com/HamzaAITMOUHAOUALLA/gitops-repo.git

cd gitops-repo/data-demo

sed -i "s|image: .*|image: ${FULL_IMAGE}|" deployment.yaml

git config user.email "ci@jenkins.com"
git config user.name "Jenkins CI"

git add deployment.yaml
git commit -m "chore(deploy): update image ${FULL_IMAGE} [skip ci]" || echo "No changes"

git push
