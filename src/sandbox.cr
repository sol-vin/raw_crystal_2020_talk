require "kemal"
require "celestine"
require "perlin_noise"

@@seed = rand(1, Int32::MAX-1)

get "/" do |env|
  perlin = PerlinNoise.new(seed)
  Celestine.draw do |ctx|
    # Celestine DSL code goes here
  end
end


Kemal.config.port = ARGV.size == 0 ? 3000 : ARGV[0].to_i
Kemal.run