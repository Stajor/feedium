class Feedium::Request
  attr_reader :uri, :url, :io

  URI_REQEX         = /^(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?(\/.*)?$/ix
  MAX_CONTENT_SIZE  = 5 * 1048576 # bytes in 1MB

  def initialize(url, base_uri = nil)
    url = URI.parse(base_uri).merge(url).to_s if base_uri

    begin
      @uri = URI.parse(url)
    rescue URI::InvalidURIError => e
      raise Feedium::RequestError.new(e.message)
    end
  end

  def send
    @uri.scheme = 'http' unless %w(http https).include?(@uri.scheme)
    query       = @uri.query.nil? ? '' : "?#{@uri.query}"
    @url        = "#{@uri.scheme}://#{@uri.host}#{@uri.path}#{query}"

    raise Feedium::RequestError.new('Not valid url') unless @url =~ URI_REQEX

    begin
      @io = open(url, {
          allow_redirections: :all,
          read_timeout: 10,
          open_timeout: 10,
          content_length_proc: ->(size) {
            raise Feedium::RequestError.new('File Too Large') if size && size > MAX_CONTENT_SIZE
          },
          progress_proc: ->(size) {
            raise Feedium::RequestError.new('File Too Large') if size > MAX_CONTENT_SIZE
          },
          'User-Agent' => 'Feedium'
      })
    rescue Net::ReadTimeout => e
      raise Feedium::RequestError.new(e.message == 'Net::ReadTimeout' ? '598 Network Read Timeout Error' : e.message)
    rescue Net::OpenTimeout => e
      raise Feedium::RequestError.new(e.message)
    rescue OpenURI::HTTPError => e
      raise Feedium::RequestError.new(e.message)
    rescue OpenSSL::SSL::SSLError => e
      raise Feedium::RequestError.new(e.message)
    rescue Errno::ECONNREFUSED => e
      raise Feedium::RequestError.new(e.message)
    end
  end
end