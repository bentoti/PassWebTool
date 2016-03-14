#!/bin/bash

function getpwid_wget() {
    wget --post-data="pwid=$1&mode=$2" -qO - --no-check-certificate https://PassWebTool/get.py
}

function getpwid_curl(){
    curl -s --data "pwid=$1&mode=$2" --insecure https://PassWebTool/get.py
}

function getpwid_py() {
    /usr/bin/env python -c "import requests
print requests.post('https://PassWebTool/get.py', data={'pwid': '$1','mode':'$2'}, verify=False).text" 2> /dev/null
}

cID="0I1L5X"
cred_all=`getpwid_curl ${cID}`
cred_pass=`getpwid_py ${cID} password`
cred_host=`getpwid_wget ${cID} host`
cred_url=`getpwid_py ${cID} url`
cred_mysql=`getpwid_py ${cID} mysql`

echo "for your host '${cred_host}' with password ${cred_pass} best chances are:"
echo "as url:     http://${cred_url}"
echo "as args:    some_command ${cred_mysql}"
