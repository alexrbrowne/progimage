require 'spec_helper'

describe "healthz" do
	it_should_behave_like "testing /healthz", "http://download"
	it_should_behave_like "testing /healthz", "http://upload"
end
