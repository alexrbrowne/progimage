require 'spec_helper'

describe "download tests" do
  Dir.glob('./samples/*').grep(/^((?!_as)(?!failures).)*$/).select {|f| File.directory? f}.each do | directory |

    ext = directory.split("./samples/")[1]

    Dir["#{directory}/*.#{ext}"].each do |file|
      if File.size(file) < 1500000
        sleep((File.size(file) / 10.0**8)/3)
        if ext == "svg"
          if File.size(file) < 500000
            it_should_behave_like "conversion /download", ext, file, 'png'
            it_should_behave_like "conversion /download", ext, file, 'jpeg'
            it_should_behave_like "conversion /download", ext, file, 'jpg'
            it_should_behave_like "conversion /download", ext, file, 'gif'
          end
        else
          it_should_behave_like "conversion /download", ext, file, 'svg' if File.size(file) < 500000
          it_should_behave_like "conversion /download", ext, file, 'png' unless file.match "./samples/png/*"
          it_should_behave_like "conversion /download", ext, file, 'gif' unless file.match "./samples/gif/*"
          it_should_behave_like "conversion /download", ext, file, 'jpeg' unless file.match "./samples/jpeg/*"
          it_should_behave_like "conversion /download", ext, file, 'jpg' unless file.match "./samples/jpg/*"
        end
      end
    end
  end
end
