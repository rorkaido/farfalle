#
# URI support for Ruby
#
# Author:: Rorkaido <rorkaido@gmail.com>
# Documentation:: Rorkaido <rorkaido@gmail.com>
# License::
#  Copyright (c) 2010 Rorkaido <rorkaido@gmail.com>
#  You can redistribute it and/or modify it under the same term as Ruby.
#

module Farfalle

  class LineParse
    attr_reader :url, :referrer, :user_id, :access_time
    def initialize( line )
      @line = line
      # date time field has [blah blah] format
      # So, it needs to be changed to be quoted with "
      @line.gsub!(/\[([^"\]]+)\]/, '"\1"')
      @parsed_elements = CSV.parse_line( @line, ' ' )
      set_url
      set_referrer
      set_user_id
      set_access_time
    end

  private
    def set_url
      url_elements = CSV.parse_line( @parsed_elements[Farfalle::Config::FileElements[:request_first_line]], ' ' )
      @url = url_elements[1]
    end

    def set_referrer
      @referrer = @parsed_elements[Farfalle::Config::FileElements[:referrer]]
    end

    def set_user_id
      if Farfalle::Config::FileElements[:user_id]
        @user_id = @parsed_elements[Farfalle::Config::FileElements[:user_id]]
      else
        @user_id = [ 
                      @parsed_elements[Farfalle::Config::FileElements[:remote_host]],
                      @parsed_elements[Farfalle::Config::FileElements[:user_agent]]
                   ].join("\t")
      end
    end

    def set_access_time
      datetime_str = @parsed_elements[Farfalle::Config::FileElements[:access_time]]
      ### convert @access_time to be readable for ParseDate
      datetime_str.gsub!(%r{^([^:]+)/([^:]+)/([^:]+):}, '\1-\2-\3T' )
      parsed_date =  ParseDate::parsedate( datetime_str )
      @access_time = Time::local(*parsed_date[0..-3]) ### further change might be needed for timezone consideration
    end
  end

end
