#!/bin/bash

export AppEnv="devel"

source .credentials.${AppEnv}.sh

echo "PWID for root:    " ${MyUsers["root"]}
echo "PWID for john_doe:" ${MyUsers["john_doe"]}
echo "PWID for phpuser: " ${MyUsers["phpuser"]}

function PassWebClientGet() { wget -qO - --post-data="pwid=$1&mode=$2" --no-check-certificate https://PassWebTool/get.py; }

PassWebClientGet ${MyUsers["john_doe"]} "password"
PassWebClientGet ${MyUsers["john_doe"]} "username"


sql="
grant all privileges on '*'.'*' to   'root'@'%'
\n\tidentified by '`PassWebClientGet ${MyUsers["root"]} "password"`';"

for sqluser in john_doe phpuser; do
    sql="${sql}\ngrant all on            '*.*' to     '`PassWebClientGet ${MyUsers[${sqluser}]} "username"`'@'%'
     \n\tidentified by '`PassWebClientGet ${MyUsers[${sqluser}]} "password"`'; "
     done

sql="${sql}\nflush privileges;\nselect user,host from mysql.user;
"

echo "--------------_"
echo -e ${sql}