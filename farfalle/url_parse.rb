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

  class URLParse
    attr_reader :domain, :uri_path, :queries, :fragment
    ### private :uri, query_string
    def initialize( url )
      @url = url

      @domain = ''
      @uri_path = ''
      @queries = Hash.new([].freeze)
      @fragment = ''

      parse_domain
      parse_uri_path
      parse_queries
      parse_fragment
    end

  def get_search_keyword
    Farfalle::Config::SearchEngine.each do | search_engine | 
      if( @domain == search_engine[:domain] && @uri_path == search_engine[:uri_path] )
        @queries.each do | key,value |
          if( key == search_engine[:query_key] )
            return URI.decode(value).toutf8
          end
        end
      end
    end
    return ''
  end

  private
    def parse_domain
      if %r{
          ^           # beginning
          https?://   # http(s):// 
          ([^/]+)     # domain including port num
          (.*)        # URI path
        }x =~ @url

        @domain = $1
        @uri    = $2
      else
        @domain = ''
        @uri    = @url
      end
    end

    def parse_uri_path
      if %r{
          ([^?\#]*)    # uri path
          (\?[^\#]*)?  # query string
          (\#.*)?      # fragment
        }x =~ @uri
        @uri_path     = $1 || ''
        @query_string = $2 || ''
        @fragment     = $3 || ''
      else
        @uri_path     = @uri
        @query_string = ''
        @fragment     = ''
      end
    end

    def parse_queries
      if( @query_string != '' )
        @query_string = @query_string[1..-1] ### get rid of "?"
        @query_string.split(/&(?:amp;)?/).each do |element|
          if( element == '' )
            next
          end

          key, value = element.split(/=/, 2)
          if( key == '' )
            next
          end
          key.downcase! ### this may be problematic in some situations

          @queries[ key ] = value
        end
      end
    end

    def parse_fragment
      if( @fragment != '' )
        @fragment = @fragment[1..-1] ### get rid of "#"
      end
    end
  end

end
