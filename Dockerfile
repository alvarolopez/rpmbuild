# Using CentOS 8 as base image to support rpmbuild (packages will be Dist el8)
FROM rockylinux/rockylinux:9

# Copying all contents of rpmbuild repo inside container
COPY . .

# Installing tools needed for rpmbuild , 
# depends on BuildRequires field in specfile, (TODO: take as input & install)
RUN yum install -y rpm-build rpmdevtools gcc make coreutils-single python3 tar git rsync 
RUN yum install -y epel-release 
RUN yum install -y python3-setuptools python3-devel python3-pip python3-pbr

# Install npm
RUN dnf install nodejs -y

ENV PATH=/root/.local/bin:$PATH

RUN python3 -m ensurepip --upgrade && \
    pip3 install --user --upgrade pip && \
    pip3 install --user --upgrade tox pbr

RUN tox

# Install all dependecies to execute main.js
RUN npm install -g typescript \
    && npm install --save @types/node\
    && npm install --production  \ 
    && npm run-script build

# All remaining logic goes inside main.js , 
# where we have access to both tools of this container and 
# contents of git repo at /github/workspace
ENTRYPOINT ["node", "/lib/main.js"]
