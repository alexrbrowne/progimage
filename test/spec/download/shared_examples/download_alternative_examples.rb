require 'spec_helper'

shared_examples "conversion /download" do |original_file_type, file_name, new_file_type|

	before :all do
    # clear our working space
		File.delete(*Dir.glob('/images/*'))
    File.delete(*Dir.glob('/downloads/*'))
    file = File.expand_path(file_name)
    uuid = SecureRandom.uuid
    original_file = "#{uuid}.#{original_file_type}"
    @download_file = "#{uuid}.#{new_file_type}"
    # put the original file in place
    FileUtils.cp(file, "/images/#{original_file}")

    # add record to redis
    redis = Redis.new(host: "redis", port: 6379, db:0)
    redis.set(@download_file, original_file)

    # puts "original_file: #{original_file}"
    # puts "Saved: #{redis.get(@download_file)} in db"

		conn = Faraday::Connection.new "http://download"
    # puts "http://download/#{@download_file}"
		@response = conn.get("/images/#{@download_file}")

    File.open("/downloads/#{@download_file}", 'wb') { |fp| fp.write(@response.body) }

    @uploaded_files = Dir["/images/*"]
		@converted_file = Dir["/images/*.#{new_file_type}"][0]
    @original_file = Dir["/images/*.#{original_file_type}"][0]
		@downloaded_file = Dir["/downloads/*.#{new_file_type}"][0]
    @original_converted_date = File.mtime(@converted_file)
	end

	context "download #{file_name} via GET as #{new_file_type}" do

		describe "it works" do

			it "returns a 200" do
				expect(@response.status).to eq 200
      end

      it "should have a second file on the server" do
        expect(@uploaded_files.count).to eq 2
      end

			it 'returns a powered by header' do
				expect(@response.headers['powered-by']).to eq 'ProgImage: https://proimage.innovology.io'
			end

			it "returns the correct image header" do
				expect(@response.headers["Content-Type"]).to eq new_file_type == 'svg' ? "image/svg+xml" : "image/#{new_file_type}"
			end

			it "downloads the converted file" do
      	(FileUtils.compare_file(@converted_file,@downloaded_file))
			end

			## Too slow
			# it "test the file is of the new nature"  do
			# 	image = MiniMagick::Image.open(@downloaded_file)
			# 	expect(image.data["format"].downcase).to eq new_file_type
			# end

		end

    context "download #{file_name} via GET as #{new_file_type} again" do
      before :all do
        # clear our working space
        File.delete(*Dir.glob('/downloads/*'))

        # wait one second, timecop can not help here
        sleep(1)

        conn = Faraday::Connection.new "http://download"
        @response = conn.get("/images/#{@download_file}")

        File.open("/downloads/#{@download_file}", 'wb') { |fp| fp.write(@response.body) }

        @uploaded_files = Dir["/images/*"]
        @converted_file = Dir["/images/*.#{new_file_type}"][0]
        @downloaded_file = Dir["/downloads/*.#{new_file_type}"][0]
        @new_converted_date = File.mtime(@converted_file)
      end

  		describe "it works" do

  			it "returns a 200" do
  				expect(@response.status).to eq 200
        end

        it "should have still have two files on the server" do
          expect(@uploaded_files.count).to eq 2
        end

  			it 'returns a powered by header' do
  				expect(@response.headers['powered-by']).to eq 'ProgImage: https://proimage.innovology.io'
  			end

  			it "returns the correct image header" do
  				expect(@response.headers["Content-Type"]).to eq new_file_type == 'svg' ? "image/svg+xml" : "image/#{new_file_type}"
  			end

        it "downloads the converted file" do
        	(FileUtils.compare_file(@converted_file,@downloaded_file))
  			end

        it "does not modify the file" do
        	expect(@new_converted_date).to eq @original_converted_date
  			end

  		end
    end
	end
end
