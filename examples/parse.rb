dir = File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib'))
require File.join(dir, 'feedium')

puts Feedium.find('https://github.com/Stajor/feedium')