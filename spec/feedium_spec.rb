RSpec.describe Feedium do
  it 'has a version number' do
    expect(Feedium::VERSION).not_to be nil
  end

  it 'has an invalid url' do
    expect { Feedium.find('not_a_url') }.to raise_error(Feedium::RequestError, 'Not valid url')
    expect { Feedium.find('http:not_a_url') }.to raise_error(Feedium::RequestError, 'Not valid url')
    expect { Feedium.find('http|not_a_url') }.to raise_error(Feedium::RequestError, 'bad URI(is not URI?): http|not_a_url')
  end

  it 'has a valid url' do
    expect { Feedium.find('http://github.com') }.not_to raise_error
    expect { Feedium.find('https://github.com') }.not_to raise_error
    expect { Feedium.find('https://www.github.com') }.not_to raise_error
  end

  it 'has a feed url' do
    url = 'https://github.com/Stajor/feedium'
    expect(Feedium.find(url)).to eq(url + '/commits/master.atom')
  end
end
