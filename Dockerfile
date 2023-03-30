# Using CentOS 8 as base image to support rpmbuild (packages will be Dist el8)
FROM rockylinux/rockylinux:8

# Copying all contents of rpmbuild repo inside container
COPY . .

# Installing tools needed for rpmbuild , 
# depends on BuildRequires field in specfile, (TODO: take as input & install)
RUN yum install -y rpm-build rpmdevtools gcc make coreutils-single python3 tar git rsync 
RUN yum install -y epel-release 
RUN yum install -y python3-setuptools python3-devel python3-pbr python3-pip 

RUN pip3 install --upgrade tox

# Setting up node to run our JS file
# Download Node Linux binary
RUN curl -O https://nodejs.org/dist/v12.16.1/node-v12.16.1-linux-x64.tar.xz

# Extract and install
RUN tar --strip-components 1 -xvf node-v* -C /usr/local

# Install all dependecies to execute main.js
RUN npm install -g typescript \
    && npm install --save @types/node\
    && npm install --production  \ 
    && npm run-script build

# All remaining logic goes inside main.js , 
# where we have access to both tools of this container and 
# contents of git repo at /github/workspace
ENTRYPOINT ["node", "/lib/main.js"]
