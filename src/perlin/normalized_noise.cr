require "kemal"
require "celestine"
require "perlin_noise"

module Perlin::Noise
  class_property seed = 1
  WIDTH  = 600
  HEIGHT = 200

  def self.make
    perlin = PerlinNoise.new(seed)
    Celestine.draw do |ctx|
      ctx.view_box = {x: 0, y: 0, w: WIDTH, h: HEIGHT}

      ctx.rectangle do |r|
        r.x = 0
        r.y = 0
        r.width = WIDTH
        r.height = HEIGHT
        r.fill = "#F0F0F0"
        r
      end

      # Grid line
      ctx.path do |path|
        path.a_move(0, HEIGHT/2.0)
        path.r_h_line(WIDTH)
        path.stroke = "black"
        path
      end

      # Perlin line
      step = WIDTH/100.0
      ctx.path do |path|
        path.a_move(0, HEIGHT/2.0 - perlin.normalize_noise(0, 0, 0) * HEIGHT/2.0)
        100.times do |x|
          path.a_line(step * x, HEIGHT/2.0 - perlin.normalize_noise(x, x, x) * HEIGHT/2.0)
        end
        path.stroke = "red"
        path.fill = "none"
        path
      end

      ctx.text do |t|
        t.text = "0"
        t.x = 1
        t.y = 100 - 2
        t
      end
    end
  end
end

get "/" do |env|
  Perlin::Noise.seed += 1
  Perlin::Noise.make
end

Kemal.config.port = ARGV.size == 0 ? 3000 : ARGV[0].to_i
Kemal.run
