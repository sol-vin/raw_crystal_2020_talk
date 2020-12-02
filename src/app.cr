require "kemal"
require "celestine"
require "perlin_noise"

require "./macros"

FileUtils.mkdir_p("./public")
FileUtils.mkdir_p("./public/images")
FileUtils.mkdir_p("./public/images/mineshift")

get "/" do |env|
end


Kemal.config.port = ARGV.size == 0 ? 3000 : ARGV[0].to_i
Kemal.run