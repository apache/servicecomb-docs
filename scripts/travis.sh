#!/usr/bin/env bash
## ---------------------------------------------------------------------------
## Licensed to the Apache Software Foundation (ASF) under one or more
## contributor license agreements.  See the NOTICE file distributed with
## this work for additional information regarding copyright ownership.
## The ASF licenses this file to You under the Apache License, Version 2.0
## (the "License"); you may not use this file except in compliance with
## the License.  You may obtain a copy of the License at
##
##      http://www.apache.org/licenses/LICENSE-2.0
##
## Unless required by applicable law or agreed to in writing, software
## distributed under the License is distributed on an "AS IS" BASIS,
## WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
## See the License for the specific language governing permissions and
## limitations under the License.
## ---------------------------------------------------------------------------
#bin/sh

echo "start building servicecomb-docs."
echo "env TRAVIS_BRANCH=$TRAVIS_BRANCH"
echo "env PARAM1=$1"

if [ "$1" == "install" ]; then
  npm install gitbook-cli -g
  gitbook build java-chassis-reference docs/java-chassis
  gitbook build saga-reference docs/saga
  gitbook build service-center-reference docs/service-center
  git clone --depth=10 --branch=master https://$PUSH_TARGET_URL servicecomb-java-chassis-doc
  if [ "$TRAVIS_BRANCH" == "master" ]; then
    cp -r docs/ servicecomb-java-chassis-doc/
  elif [ "$TRAVIS_BRANCH" == "java-chassis-1.x" ]; then
    cp -r docs/java-chassis servicecomb-java-chassis-doc/java-chassis/1.x
  else
    exit 1
  fi
elif [ "$1" == "deploy" ]; then
  cd servicecomb-java-chassis-doc
  git checkout -b master
  git add docs
  git commit -m "Publish gitbook docs"
  git push https://$DEPLOY_TOKEN@$PUSH_TARGET_URL master
else 
  exit 1
fi

