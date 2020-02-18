require 'spec_helper'


describe "With /upload" do
  before :all do
    @conn = Faraday::Connection.new "http://upload"
  end

  context "on other methods" do

		describe "should respond" do
			it "to [GET] with HTTP 405" do
				expect(@conn.get('/upload').status).to eq 405
			end

      it "to [PATCH] with HTTP 405" do
				expect(@conn.patch('/upload').status).to eq 405
			end

      it "to [PUT] with HTTP 405" do
        expect(@conn.put('/upload').status).to eq 405
      end

      it "to [DELETE] with HTTP 405" do
        expect(@conn.delete('/upload').status).to eq 405
      end
		end
	end

  context "on other uris" do
    describe "should respond" do
      it_should_behave_like "404", "/"
      # some examples
      it_should_behave_like "404", "/anything_else"
      it_should_behave_like "404", "/admin"
      it_should_behave_like "404", "/php"
      it_should_behave_like "404", "/downloadz"
      it_should_behave_like "404", "/upload/upload"
      it_should_behave_like "404", "/upload/download"
      it_should_behave_like "404", "/controller"
    end
  end
end

describe "image failures" do
  Dir["./samples/failures/*"].each do |file|
    ext = file.gsub("./samples/failures/", "").split("\.")[1]
    it_should_behave_like "with failed /upload", ext, file
  end
end

describe "incorrect mimetype image tests" do
  Dir.glob('./samples/*_as').grep(/^(.*)_as$/).select {|f| File.directory? f}.each do | directory |
    true_file_type = directory.split("./samples/")[1].gsub("_as","")
    Dir["#{directory}/*"].each do |file|
      ext = file.gsub(/((.*)\.)/, "")
  		sleep((File.size(file) / 10.0**8)/3)
      it_should_behave_like "with /upload", ext, file, true_file_type
    end
  end
end
