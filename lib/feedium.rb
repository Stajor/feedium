require 'feedium/version'
require 'feedium/exceptions'
require 'feedium/request'

require 'open-uri'
require 'net/http'
require 'open_uri_redirections'
require 'nokogiri'
require 'feedjira'

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
    return @request.url if self.feed?(url)

    doc   = Nokogiri::HTML(@request.io.read)

    if doc.at('base') && doc.at('base')['href']
      base_uri = doc.at('base')['href']
    else
      base_uri = "#{@request.uri.scheme}://#{@request.uri.host}"
    end

    doc.xpath("//link[@rel='alternate'][@href][@type]").each do |l|
      if CONTENT_TYPES.include?(l['type'].downcase.strip)
        return @request.url if self.feed?(base_uri ? URI.parse(base_uri).merge(l['href']).to_s : l['href'])
      end
    end

    doc.xpath("//a[@href]").each do |a|
      url = %w(feed rss atom).detect {|k| a['href'].end_with?(k) }
      return @request.url if url && self.feed?(base_uri ? URI.parse(base_uri).merge(url).to_s : url)
    end

    nil
  end

  def self.feed?(url)
    @request = Request.new(url)
    @request.send

    content_type = @request.io.content_type.downcase
    content_type = @request.io.meta['content-type'].gsub(/;.*$/, '') if content_type == 'application/octet-stream'

    CONTENT_TYPES.include?(content_type) ? true : false
  end

  def self.parse(url)
    request = Request.new(url)
    request.send

    Feedjira::Feed.parse(request.io.read)
  end
end
