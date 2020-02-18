require 'spec_helper'

shared_examples "testing /healthz" do |host|

	context "On method: GET" do

		before do
			conn = Faraday::Connection.new host
			@response = conn.get('/healthz')
			@data = JSON.parse(@response.body)
		end

		describe "its alive" do

			it "returns a 200" do
				expect(@response.status).to eq 200
			end

			it "reports a status txt of OK" do
				expect(@data["status"]).to eq "OK"
			end

			it "returns a 200" do
				expect(@data["health"]).to eq 1.0
			end

		end
	end
end
