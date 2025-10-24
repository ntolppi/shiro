# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.

ARG SHIRO_VERSION="2.0.5"
FROM maven:sapmachine AS build

# Redeclare ARG
ARG SHIRO_VERSION

WORKDIR /src

# Get tar.gz release using curl, wget not installed in maven:sapmachine by default
# -L Follow redirect, empty tar otherwise
# -O File is named same as remote file, ie shiro-root-${SHIRO_VERSION}.tar.gz
RUN curl -L -O https://github.com/apache/shiro/archive/refs/tags/shiro-root-${SHIRO_VERSION}.tar.gz

# Use tar, unzip not installed in maven:sapmachine by default
RUN tar -xzf shiro-root-${SHIRO_VERSION}.tar.gz
WORKDIR /src/shiro-shiro-root-${SHIRO_VERSION}
RUN mvn clean package 

FROM openjdk:25-slim

# Redeclare ARG
ARG SHIRO_VERSION

# Make ENV var for use in entrypoint
ENV SHIRO_VERSION_VAR=${SHIRO_VERSION}

WORKDIR /opt/app/

# Copy shiro hasher cli jar from previous stage
COPY --from=build /src/shiro-shiro-root-${SHIRO_VERSION}/tools/hasher/target/shiro-tools-hasher-${SHIRO_VERSION}-cli.jar /opt/app/shiro-tools-hasher-cli.jar

# Run cli jar
ENTRYPOINT ["java", "-jar", "/opt/app/shiro-tools-hasher-cli.jar"]

CMD ["--help"]
