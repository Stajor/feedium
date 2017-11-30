require 'feedium/version'
require 'feedium/exceptions'
require 'feedium/request'

require 'open-uri'
require 'net/http'
require 'open_uri_redirections'
require 'nokogiri'
require 'feedjira'
require 'openssl'

module Feedium
  CONTENT_TYPES = %w(
    application/x.atom+xml
    application/atom+xml
    application/xml
    text/xml
    application/rss+xml
    application/rdf+xml
    application/json
  ).freeze

  def self.find(url)
    begin
      uri   = URI.parse(url.downcase.index('http') ? url : "http://#{url}")
      query = uri.query.nil? ? '' : "?#{uri.query}"
      url   = "#{uri.scheme}://#{uri.host}#{uri.path}#{query}"
    rescue URI::InvalidURIError => e
      raise Feedium::RequestError.new(e.message)
    end

    return @request.url if self.feed?(url)

    @body = @body || @request.io.read

    doc = Nokogiri::HTML(@body)

    if doc.at('base') && doc.at('base')['href']
      @base_uri = doc.at('base')['href']
    else
      @base_uri = "#{@request.uri.scheme}://#{@request.uri.host}"
    end

    doc.xpath("//link[@rel='alternate'][@href][@type]").each do |l|
      if CONTENT_TYPES.include?(l['type'].downcase.strip)
        return @request.url if self.feed?(l['href'])
      end
    end

    doc.xpath("//a[@href]").each do |a|
      found = %w(feed rss atom).detect {|k| !a['href'].index(k).nil? }

      begin
        return @request.url if found && self.feed?(a['href'])
      rescue Feedium::RequestError
        next
      end
    end

    nil
  end

  def self.find!(url)
    feed = self.find(url)

    raise Feedium::RequestError.new('Feed not found') if feed.nil?

    feed
  end

  def self.feed?(url)
    @request = Request.new(url, @base_uri)
    @request.send
    meta_type = @request.io.meta['content-type']

    content_type = @request.io.content_type.downcase
    content_type = meta_type.gsub(/;.*$/, '') if content_type == 'application/octet-stream' && !meta_type.nil?

    is_feed = CONTENT_TYPES.include?(content_type) ? true : false

    if !is_feed
      begin
        @body = @request.io.read
        is_feed = !self.parse(url, @body).class.name.index('Feedjira::Parser').nil?
        rescue
      end
    end

    is_feed
  end

  def self.parse(url, content = nil)
    if content.nil?
      request = Request.new(url)
      request.send
      content = request.io.read

      if request.io.meta['content-encoding'] == 'gzip'
        content = Zlib::GzipReader.new(StringIO.new(content)).read.force_encoding('utf-8')
      end
    end

    Feedjira::Feed.parse(content)
  end
end
