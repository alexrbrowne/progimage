require 'spec_helper'

shared_examples "404" do |path|
  describe 'could not find' do
    it "to #{path} with HTTP 404" do
      expect(@conn.get(path).status).to eq 404
      expect(@conn.put(path).status).to eq 404
      expect(@conn.patch(path).status).to eq 404
      expect(@conn.delete(path).status).to eq 404
    end
  end
end
