require 'spec_helper'

shared_examples "with failed /upload" do |file_type, file_name|

	before :all do
		File.delete(*Dir.glob('/images/*'))

		mimetypes = {
			"zip" => "application/zip",
			"doc" => "application/msword",
			"dxf" => "image/x-dwg",
			"mkv" => "video/mp4",
			"mp3" => "audio/mpeg3",
			"pdf" => "application/pdf",
			"ppt" => "application/mspowerpoint",
			"psd" => "application/octet-stream",
			"sql" => "text/sql",
			"txt" => "text/plain",
			"xls" => "application/msexcel"
		}

		content_type = mimetypes[file_type]

		conn = Faraday::Connection.new "http://upload"

		file = File.expand_path(file_name)

		@response = conn.post("/upload") do |req|
										req.headers['Content-Type'] = content_type
										begin
											req.body = File.binread(file)
										rescue
											# binread is still open on large files when the 405 is thrown... this is excepted behaviour
											puts "expected file upload cancelled"
										end
									end

		@data = JSON.parse(@response.body || {})


		@uploaded_file = Dir["/images/*.#{file_type}"][0]
		@uploaded_files_list=Dir["/images/*.#{file_type}"]
	end

	context "uploading #{file_name} via POST" do

		describe "it fails" do

			it "returns a 400" do
				expect(@response.status).to eq 400
			end

      it "& saves no file" do
        expect(Dir["/images/*"].count).to eq 0
			end

			it 'returns an invalid header warning' do
				expect(@data["title"]).to eq "Invalid header value"
			end

      it 'returns no body' do
        expect(@data["description"]).to eq "The value provided for the Content-Type header is invalid. Please contact the provider for list of acceptable headers"
      end
		end
	end
end
