#
# URI aggregation for Ruby
#
# Author:: Rorkaido <rorkaido@gmail.com>
# Documentation:: Rorkaido <rorkaido@gmail.com>
# License::
#  Copyright (c) 2010 Rorkaido <rorkaido@gmail.com>
#  You can redistribute it and/or modify it under the same term as Ruby.
#

module Farfalle

  module Config
    File = {
      :AccessLogs   => '/etc/apache/logs/access_log*',
    }
    SearchEngine = [
      { :domain => 'www.google.co.jp',    :uri_path => '/search', :query_key => 'q' },
      { :domain => 'www.google.com',      :uri_path => '/search', :query_key => 'q' },
      { :domain => 'search.yahoo.co.jp',  :uri_path => '/search', :query_key => 'p' },
    ]
  end

end
