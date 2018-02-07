#!/bin/bash

export AppEnv="devel"

source .credentials.${AppEnv}.sh

echo "PWID for root:    " ${MyUser["root"]}
echo "PWID for john_doe:" ${MyUser["john_doe"]}
echo "PWID for phpuser: " ${MyUser["phpuser"]}

function PassWebClientGet() { wget -qO - --post-data="pwid=$1&mode=$2" --no-check-certificate https://PassWebTool/get.py; }

PassWebClientGet ${MyUser["john_doe"]} "password"
PassWebClientGet ${MyUser["john_doe"]} "username"


sql="
grant all privileges on '*'.'*' to   'root'@'%'
\n\tidentified by '`PassWebClientGet ${MyUser["root"]} "password"`';"

for sqluser in john_doe phpuser; do
    sql="${sql}\ngrant all on            '*.*' to     '`PassWebClientGet ${MyUser[${sqluser}]} "username"`'@'%'
     \n\tidentified by '`PassWebClientGet ${MyUser[${sqluser}]} "password"`'; "
     done

sql="${sql}\nflush privileges;\nselect user,host from mysql.user;
"

echo "--------------_"
echo -e ${sql}