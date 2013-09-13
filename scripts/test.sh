#!/bin/sh

set -e

DB_HOST='localhost'
DB_NAME='leadrush_dev'
DB_USER='root'
DB_PASSWORD=''
URL='http://leadrush-ci/'
SCREENSHOT=screenshot/
REPORT=report
CASPERJS=ci/vendor/casperjs/bin/casperjs

DATE=$(date +"%F-%H-%M-%S")
SCREENSHOTDATE="${SCREENSHOT}${DATE}-"
CASPER_OPTIONS="--fail-fast --direct --log-level=warning --capture_path=$SCREENSHOTDATE --includes=./ci/tests/casperjs/pre.js --base_url=$URL"

help ()
{
    echo "Test suite for Leadrush LTD"
    echo ""
    echo "    test init             - initialise Novius OS test instance";
    echo "    test install [wizard] - runs begin of tests suite, install and appmanager";
    echo "    test run [stepname]   - runs complete tests suite";
}

db ()
{
    	echo "Create Database"
	$(mysql -h $DB_HOST -u $DB_USER --password=$DB_PASSWORD -e "DROP DATABASE IF EXISTS $DB_NAME;CREATE DATABASE $DB_NAME DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;")
	
	echo "Dump sql from app"
	
}

init ()
{	
	
	chmod +x $CASPERJS;
	chmod +x ci/vendor/imageshack-upload;
	
	db

    	echo "Debug started"
	cd $ROOT

}

install ()
{
    set -e

    echo "Test install begin"
	cd $ROOT

	$CASPERJS test ./ci/tests/casperjs/install.js --xunit=$REPORT/casper-install.xml $CASPER_OPTIONS --host="$DB_HOST" --user="$DB_USER" --password="$DB_PASSWORD" --db=$DB_NAME

    if [ "$1" = "wizard" ]; then return; fi

    $CASPERJS test ./ci/tests/casperjs/appmanager.js --xunit=$REPORT/casper-appmanager.xml $CASPER_OPTIONS
}

run ()
{
    set -e
    echo "Test begin"
	cd $ROOT

	install

    if [ -n $1 ]
    then
        CASPER_OPTIONS="$CASPER_OPTIONS --nos_step=$1"
    fi

    $CASPERJS test ./ci/tests/casperjs/scenario.js  $CASPER_OPTIONS
}

ROOT=$(pwd)/

if [ $1 ]
then
    case "$1" in
		"init")
			init
			exit $?
		;;
		"install")
			init
			install  $2
			exit $?
		;;
		"run")
			init
			run $2
			exit $?
		;;
		*)
			help
		;;
	esac
else
    help
fi
