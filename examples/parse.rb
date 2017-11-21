dir = File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib'))
require File.join(dir, 'feedium')

# puts Feedium.parse('http://mangastream.com/rss')
puts Feedium.find('http://www.gazzettadelsud.it/feed.jsp')