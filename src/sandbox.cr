require "celestine"
require "kemal"


get "/" do |env|
  Celestine.draw do |ctx|
  
  end
end

Kemal.config.port = ARGV.size == 0 ? 3000 : ARGV[0].to_i
Kemal.run

