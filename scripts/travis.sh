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
CUR_DIR=$PWD
echo "start building servicecomb-docs."
echo "env TRAVIS_BRANCH=$TRAVIS_BRANCH"
echo "env PARAM1=$1"
echo "env CUR_DIR=$CUR_DIR"

if [ "$1" == "script" ]; then
  gitbook build saga-reference docs/saga
  gitbook build service-center-reference docs/service-center
  cd $CUR_DIR/java-chassis-reference/zh_CN
  mkdocs build -d ../../docs/java-chassis/zh_CN
  cd $CUR_DIR/java-chassis-reference/en_US
  mkdocs build -d ../../docs/java-chassis/en_US
  cd $CUR_DIR

  git clone --depth=10 --branch=master https://$PUSH_TARGET_URL servicecomb-java-chassis-doc
  if [ "$TRAVIS_BRANCH" == "master" ]; then
    rm -r servicecomb-java-chassis-doc/docs/java-chassis/zh_CN/*
    rm -r servicecomb-java-chassis-doc/docs/java-chassis/en_US/*
    rm -r servicecomb-java-chassis-doc/docs/saga/*
    rm -r servicecomb-java-chassis-doc/docs/service-center/*
    cp -r docs/ servicecomb-java-chassis-doc/
    ls -l servicecomb-java-chassis-doc/docs/java-chassis
    ls -l servicecomb-java-chassis-doc/docs/java-chassis/1.x
  else
    exit 1
  fi
elif [ "$1" == "after_success" ]; then
  if [ -z $DEPLOY_TOKEN ]; then
    echo "PR release if ignored"
  else
    cd servicecomb-java-chassis-doc
    git add docs
    git commit -m "Publish gitbook docs"
    git push https://$DEPLOY_TOKEN@$PUSH_TARGET_URL master
  fi
else 
  exit 1
fi

