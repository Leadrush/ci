var BASE_URL = casper.cli.get('base_url'),
    capture_path = casper.cli.get('capture_path') || './',
    test_name = casper.cli.has(0) ? casper.cli.get(0) : 'test',
    utils = require('utils');

(function(casper) {
    var logLevel = casper.cli.get('log-level');
    if (casper.cli.get('color-dummy')) {
        casper.options.colorizerType = 'Dummy';
    }
    if (logLevel) {
        casper.options.logLevel = logLevel;
    }

    casper.options.waitTimeout = 10000;

    test_name = test_name.split('/');
    test_name = test_name[test_name.length - 1].replace('.js', '').replace('.coffee', '');

    casper.on('error', function(msg, backtrace) {
        this.capture(capture_path + test_name + '-error.png', {
            top: 0,
            left: 0,
            width: 1024,
            height: 768
        });
    });

})(casper);
