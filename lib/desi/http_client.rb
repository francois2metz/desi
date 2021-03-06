# encoding: utf-8

require "net/https"
require "addressable/uri"
require "json"

module Desi

  class HttpClient

    def initialize(host)
      @uri = to_uri(host)

      case @uri.scheme
      when 'https'
        @http = ::Net::HTTP.new(@uri.host, 443)
        @http.use_ssl = true
        @http.verify_mode = ::OpenSSL::SSL::VERIFY_PEER
      when 'http'
        @http = ::Net::HTTP.new(@uri.host, @uri.port)
      else
        raise ArgumentError, "Won't process scheme #{@uri.scheme}"
      end
    end

    def get(uri, limit = 5)
      raise "Too many HTTP redirects!" if limit <= 0

      response = @http.request(Net::HTTP::Get.new(uri))

      case response
        when Net::HTTPSuccess
          response
        when Net::HTTPRedirection
          get(response['location'], limit - 1)
        else
          raise response.error!
      end
    end

    def delete(uri)
      response = @http.request(Net::HTTP::Delete.new(uri))

      case response
        when Net::HTTPSuccess
          response
        else
          raise response.error!
      end
    end

    private

    def to_uri(host_string)
      host_string = "http://#{host_string}" unless host_string.to_s =~ %r[^https?://]
      URI(host_string)
    end
  end

end
