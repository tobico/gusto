(function(){
  var page = require('webpage').create(),
      system = require('system');

  if (system.args.length === 1) {
    console.log('Usage: runner.js <port>');
    phantom.exit();
  }

  var port = system.args[1];
  var address = "http://localhost:" + port + "/?headless=1";
  page.open(address, function (status) {
    var result = page.evaluate(function() {
      return (new Spec.RootSuite()).run();
    });
    console.log(JSON.stringify(result));
    phantom.exit();
  });
})();
