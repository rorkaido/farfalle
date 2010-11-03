#
# URI support for Ruby
#
# Author:: Rorkaido <rorkaido@gmail.com>
# Documentation:: Rorkaido <rorkaido@gmail.com>
# License::
#  Copyright (c) 2010 Rorkaido <rorkaido@gmail.com>
#  You can redistribute it and/or modify it under the same term as Ruby.
#

require 'csv'
require 'parsedate'

module Farfalle

  module Config
    File = {
      :AccessLogs   => '/etc/apache/logs/access_log*',
    }
  end

  def initialize
    # date(YYYY-MM-DD) =>
    #   :URL =>
    #     URL =>
    #       :PV => PV count
    #       :UserIDs =>
    #          UserID => 1
    #   :Keyword =>
    #     Keyword =>
    #       :Entry => Entry count
    #       :UserIDs =>
    #          UserID => 1
    @counted = {}
  end

  def read_access_logs
    logs = Dir.glob( Farfalle::Config::File[:AccessLogs] )
    logs.each do |log_file|
      open( log_file ) do |fh|
        fh.each do |line|
          line.chomp!
          elements = get_line_elements( line )
          count_elements( elements )
        end
      end
    end
  end

private
  # returns a hash of
  # :URL        => URL
  # :Referrer   => Referrer
  # :UserID     => Unique Browser Identifier
  # :AccessTime => Unix Timestamp
  def get_line_elements (line)
    line_parser = LineParse.new(line)

    elements = Hash.new([].freeze)
    elements[:URL]        = line_parser.url
    elements[:Referrer]   = line_parser.referrer
    elements[:UserID]     = line_parser.user_id
    elements[:AccessTime] = line_parser.access_time
    elements
  end

  def count_elements( elements )
    user_id = elements[:UserID]
    url = elements[:URL]
    date_str = elements[:AccessTime].strftime("%Y-%m-%d")
# FOR NOW
    keyword = nil
    if not @counted.key?( date_str )
      init_counted_key( date_str )
    end

    # URL count
    if not @counted[date_str][:URL].key?( url )
      init_counted_url_key( date_str, url )
    end
    @counted[date_str][:URL][url][:PV] += 1
    @counted[date_str][:URL][url][:UserIDs][user_id] = 1

    # Keyword count
    if keyword
      if not @counted[date_str][:Keyword].key?( keyword )
        init_counted_url_key( date_str, keyword )
      end
      @counted[date_str][:Keyword][keyword][:Entry] += 1
      @counted[date_str][:Keyword][keyword][:UserIDs][user_id] = 1
    end
  end

  def init_counted_key( date_str )
    @counted[ date_str ] = {}
    @counted[ date_str ][:URL] = {}
    @counted[ date_str ][:Keyword] = {}
  end

  def init_counted_url_key( date_str, url )
    @counted[ date_str ][ :URL ][ url ] = {}
    @counted[ date_str ][ :URL ][ url ][:PV] = 0
    @counted[ date_str ][ :URL ][ url ][:UserIDs] = {}
  end

  def init_counted_keyword_key( date_str, keyword )
    @counted[ date_str ][ :Keyword ][ keyword ] = {}
    @counted[ date_str ][ :Keyword ][ keyword ][:Entry] = 0
    @counted[ date_str ][ :Keyword ][ keyword ][:UserIDs] = {}
  end

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

    def set_url
      url_elements = CSV.parse_line( @parsed_elements[4], ' ' )
      @url = url_elements[1]
    end

    def set_referrer
      @referrer = @parsed_elements[7]
    end

    def set_user_id
      @user_id = @parsed_elements[8]
    end

    def set_access_time
      datetime_str = @parsed_elements[3]
      ### convert @access_time to be readable for ParseDate
      datetime_str.gsub!(%r{^([^:]+)/([^:]+)/([^:]+):}, '\1-\2-\3T' )
      parsed_date =  ParseDate::parsedate( datetime_str )
      @access_time = Time::local(*parsed_date[0..-3]) ### further change might be needed for timezone consideration
    end
  end
end
