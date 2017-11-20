module Feedium
  # @abstact Exceptions raised by Botomizer inherit from Error
  class Error < StandardError; end

  class RequestError < StandardError; end
end