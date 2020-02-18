
require 'spec_helper'

shared_examples "alt_url" do |ext|
  it "returns a ext url" do
    expect(@data["image"]['alternative_formats'][ext]).to match "/images/(.*).#{ext}"
  end

  it 'returns in the correct format' do
    expect(valid_url? "http://progimage.com/#{@data["image"]['alternative_formats'][ext]}").to eq true
  end
end
