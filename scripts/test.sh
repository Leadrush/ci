#!/bin/sh

set -e

DB_HOST='localhost'
DB_NAME='leadrush_dev'
DB_USER='root'
DB_PASSWORD=''
URL='http://leadrush-ci'
SCREENSHOT=screenshot/
REPORT=report
CASPERJS=ci/vendor/casperjs/bin/casperjs
PHANTOMJS=ci/vendor/phantomjs/bin/phantomjs

DATE=$(date +"%F-%H-%M-%S")
SCREENSHOTDATE="${SCREENSHOT}${DATE}-"
CASPER_OPTIONS="--fail-fast --direct --log-level=debug --capture_path=$SCREENSHOTDATE --includes=./ci/tests/casperjs/pre.js --base_url=$URL"

help ()
{
        echo "Test suite for Leadrush LTD"
        echo ""
        echo "    test init             - initialise Novius OS test instance";
        echo "    test run [stepname]   - runs complete tests suite";
}

db ()
{
    	echo "Create Database"
	$(mysql -h $DB_HOST -u $DB_USER --password=$DB_PASSWORD -e "DROP DATABASE IF EXISTS $DB_NAME;CREATE DATABASE $DB_NAME DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;")
	
	echo "Dump sql from app tests/db.sql"
        $(mysql -h $DB_HOST -u $DB_USER --password=$DB_PASSWORD $DB_NAME < tests/db.sql)
	
}

init ()
{	
	chmod +x $CASPERJS;
	chmod +x $PHANTOMJS;
	chmod +x ci/vendor/imageshack-upload;
	
	db

    	echo "Debug started"
	cd $ROOT

}


run ()
{
        set -e
        echo "Test begin"
            cd $ROOT


        $CASPERJS test ./tests/scenario.coffee  $CASPER_OPTIONS
}

ROOT=$(pwd)/

if [ $1 ]
then
    case "$1" in
		"init")
			init
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
