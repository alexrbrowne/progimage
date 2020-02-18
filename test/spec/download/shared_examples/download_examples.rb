require 'spec_helper'

shared_examples "with /download" do |file_type, file_name|

	before :all do
    # clear our working space
		File.delete(*Dir.glob('/images/*'))
    File.delete(*Dir.glob('/downloads/*'))
    file = File.expand_path(file_name)

    target_file = "#{SecureRandom.uuid}.#{file_type}"

    FileUtils.cp(file, "/images/#{target_file}")

		# add record to redis
    redis = Redis.new(host: "redis", port: 6379, db:0)
    redis.set(target_file, target_file)

		conn = Faraday::Connection.new "http://download"
    # puts "http://download/#{target_file}"
		@response = conn.get("/images/#{target_file}")

    File.open("/downloads/#{target_file}", 'wb') { |fp| fp.write(@response.body) }

		@uploaded_file = Dir["/images/*.#{file_type}"][0]
		@download_file = Dir["/downloads/*.#{file_type}"][0]
	end

	context "download #{file_name} via GET" do

		describe "it works" do

			it "returns a 200" do
				expect(@response.status).to eq 200
      end

			it 'returns a powered by header' do
				expect(@response.headers['powered-by']).to eq 'ProgImage: https://proimage.innovology.io'
			end

			it "returns the correct image header" do
				expect(@response.headers["Content-Type"]).to eq file_type == 'svg' ? "image/svg+xml" : "image/#{file_type}"
			end

			it "downloads the file uploaded" do
      	(FileUtils.compare_file(@uploaded_file,@download_file))
			end

		end
	end
end
