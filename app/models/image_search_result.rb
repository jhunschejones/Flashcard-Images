class ImageSearchResult
  attr_reader :url, :alt

  def initialize(url, alt="image search result")
    @url = url
    @alt = alt
  end
end
