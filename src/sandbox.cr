require "kemal"
require "celestine"
require "perlin_noise"

@@seed = rand(1, Int32::MAX-1)

get "/" do |env|
  @@seed += 1
  perlin = PerlinNoise.new(seed)
  Celestine.draw do |ctx|
    # Put your awesome code here bro!
    # Have fun and stay safe!
  end
end


Kemal.config.port = ARGV.size == 0 ? 3000 : ARGV[0].to_i
Kemal.run