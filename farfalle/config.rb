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
    # index starts with 0
    #
    # define either
    #   :user_id
    #   OR
    #   :remote_host AND :user_agent
    # in order to oount Unique Users
    FileElements = {
      :request_first_line => 4,
      :referrer           => 7,
      :access_time        => 3,

      :user_id            => nil,
      :remote_host        => 0,
      :user_agent         => 8,
    }
    SearchEngine = [
      { :domain => 'www.google.co.jp',    :uri_path => '/search', :query_key => 'q' },
      { :domain => 'www.google.com',      :uri_path => '/search', :query_key => 'q' },
      { :domain => 'search.yahoo.co.jp',  :uri_path => '/search', :query_key => 'p' },
    ]
  end

end
