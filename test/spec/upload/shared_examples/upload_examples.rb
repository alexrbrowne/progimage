require 'spec_helper'

shared_examples "with /upload" do |file_type, file_name, true_file_type|

	before :all do
		File.delete(*Dir.glob('/images/*'))

		content_type = file_type == 'svg' ? "image/svg+xml" : "image/#{file_type}"

		file = File.expand_path(file_name)

		conn = Faraday::Connection.new "http://upload"

		@response = conn.post("/upload") do |req|
									req.headers['Content-Type'] = content_type
									req.body = File.binread(file)
								end

		@data = JSON.parse(@response.body || {})

		@uploaded_file = Dir["/images/*.#{true_file_type || file_type}"][0]
		@uploaded_files_list=Dir["/images/*.#{true_file_type || file_type}"]
	end

	context "uploading #{file_name} via POST" do

		describe "it works" do

			it "returns a 201" do
				expect(@response.status).to eq 201
			end

			it 'returns a powered by header' do
				expect(@response.headers['powered-by']).to eq 'ProgImage: https://proimage.innovology.io'
			end

			it "reports a size that matches" do
				expect(@data["image"]["size"]).to eq File.size(File.expand_path(file_name))
			end

			it "reports a TTL of + ~30 minutes" do
        min_time = (Time.now + 29.minutes).to_i
        max_time = (Time.now + 31.minutes).to_i
				expect(@data["image"]["ttl"]).to be >= min_time
        expect(@data["image"]["ttl"]).to be <= max_time
			end

      it "it saves the file" do
        expect(@uploaded_files_list.count).to be 1
			end

      it "it provides a valid href" do
        expect(valid_url? "http://progimage.com/#{@data["image"]["href"]}").to eq true
			end

			it "it provides a 5 alteratives format urls" do
				expect(@data["image"]['alternative_formats'].count).to eq 5
			end

			it_should_behave_like "alt_url", "png"
			it_should_behave_like "alt_url", "jpg"
			it_should_behave_like "alt_url", "jpeg"
			it_should_behave_like "alt_url", "svg"
			it_should_behave_like "alt_url", "gif"

      it 'the file & the href match' do
        expect(@uploaded_file).to eq @data["image"]["href"]
      end
		end
	end
end
