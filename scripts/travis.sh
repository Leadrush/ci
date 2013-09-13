#! /bin/sh

run ()
{
    if [ "$1" = 'local' ]
    then
        echo "Test suite local"
        ci/scripts/test.sh run
        return $?
    else
        export PHANTOMJS_EXECUTABLE="`pwd`/ci/vendor/phantomjs/bin/phantomjs --local-to-remote-url-access=yes --ignore-ssl-errors=yes"
        export DISPLAY=:99.0
        sh -e /etc/init.d/xvfb start

        DISPLAY=:99.0 ci/scripts/test.sh run
        return $?
    fi
}

echo "Test suite begin"
if [ "$1" != 'local' ]
    then
    ci/scripts/init.sh
fi
run
temp=$?

if [ $temp != 0  -a "$1" != 'local' ]
    then
    ci/scripts/init.sh
    run
    temp=$?
fi

echo "#############################"
echo "Cookie settings"
cat ./application/config/config.php | grep cookie
echo ""


echo "#############################"
echo "Apache Access Log"
sudo cat /var/log/apache2/access.log
echo ""

echo "#############################"
echo "Apache Error Log"
sudo cat /var/log/apache2/error.log
echo ""

echo "#############################"
echo "Cookies CasperJS & PhantomJS"
cat ./ci/tests/casperjs/cookie.txt
echo ""


echo "Test suite end : $temp"

if [ $temp != 0  -a "$1" != 'local' ]
then

    if [ -d screenshot ]
    then
        IMAGESHACK_DEVELOPER_KEY=HWOZIUMF2ec52f515ea63b0b4a783cc88fde5593
        export IMAGESHACK_DEVELOPER_KEY

        for file in screenshot/*
        do
            echo "Send $file to imageshack"
            ci/vendor/imageshack-upload -i "$file"
        done
    fi
fi
exit $temp
