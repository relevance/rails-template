webserver_versions = {
  'thin'      => '>= 1.5.0',
  'unicorn'   => '>= 4.3.1',
}

## Web Server
if (prefs[:dev_webserver] == prefs[:prod_webserver])
  gem prefs[:dev_webserver], webserver_versions[prefs[:dev_webserver]]
else
  gem prefs[:dev_webserver], webserver_versions[prefs[:dev_webserver]], :group => [:development, :test]
  gem prefs[:prod_webserver], webserver_versions[prefs[:prod_webserver]], :group => :production
end

__END__

name: webserver
description: "Placeholder for full webserver recipe."
author: Relevance

category: components
requires: [setup, gems]
run_after: [gems]
