require "kemal"
require "celestine"
require "perlin_noise"

module Mineshift
  COLORS = [
    {bg: "#e2f1af", levels: ["#e3d888", "#84714f", "#5a3a31", "#31231e"]},
    {bg: "#ddf3b5", levels: ["#83c923", "#74a31d", "#577a15", "#39510e"]},
    {bg: "#ecfee8", levels: ["#c2efeb", "#6ea4bf", "#41337a", "#331e36"]},
    {bg: "#f0f3bd", levels: ["#02c39a", "#00a896", "#028090", "#06668d"]},
    {bg: "#ffcdB2", levels: ["#ffb4a2", "#e5989b", "#b5838d", "#6d6875"]},
    {bg: "#6fffe9", levels: ["#5bc0be", "#3a506b", "#1c2541", "#0b132b"]},
    {bg: "#f6aa1c", levels: ["#bc3908", "#941b0c", "#621708", "#220901"]},
    {bg: "#e0fbfc", levels: ["#c2dfe3", "#9db4c0", "#5c6b73", "#253237"]},
    {bg: "#9742a1", levels: ["#7c3085", "#611f69", "#4a154b", "#340f34"]},
    {bg: "#c4fff9", levels: ["#9ceaef", "#68d8d6", "#3dccc7", "#07beb8"]},
    {bg: "#ffffff", levels: ["#5bc0be", "#3a506b", "#1c2541", "#0b132b"]},
    {bg: "#ff9b54", levels: ["#ff7f51", "#ce4257", "#720026", "#4f000b"]},
    {bg: "#d8dbe2", levels: ["#a9bcd0", "#58a4b0", "#373f51", "#1b1b1e"]},
    {bg: "#edeec9", levels: ["#dde7c7", "#bfd8bd", "#98c9a3", "#77bfa3"]},
    {bg: "#b8f3ff", levels: ["#8ac6d0", "#63768d", "#554971", "#36213e"]},
    {bg: "#f0ebd8", levels: ["#748cab", "#3e5c76", "#1d2d44", "#0d1321"]},
    {bg: "#f9dbbd", levels: ["#ffa5ab", "#da627d", "#a53860", "#450920"]},
    {bg: "#e09f7d", levels: ["#ef5d60", "#ec4067", "#a01a7d", "#311847"]},
    {bg: "#53b3cb", levels: ["#f9c22e", "#f15946", "#e01a4f", "#0c090d"]},
    {bg: "#fefcfb", levels: ["#1282a2", "#034078", "#001f54", "#0a1128"]},
    {bg: "#e0d68a", levels: ["#cb9173", "#8e443d", "#511730", "#320a28"]},
    {bg: "#f3c677", levels: ["#f9564f", "#b33f62", "#7b1e7a", "#0c0a3e"]},
    {bg: "#efd9ce", levels: ["#dec0f1", "#b79ced", "#957fef", "#7161ef"]},
    {bg: "#f0f465", levels: ["#9cec5b", "#50c5b7", "#6184db", "#533a71"]},
    {bg: "#ad2831", levels: ["#800e13", "#640d14", "#38040e", "#250902"]},
  ]

  HEIGHT       = 1000
  WIDTH        =  800
  FRAME_COPIES =    2
  FRAME_HEIGHT = HEIGHT * FRAME_COPIES
  MAX_LEVELS   = 4

  class_property seed : Int32 = 1

  module Seeds
    COLORS = 1.1_f32
    CENTER_RECT_DEVIATION = 1.2_f32
    CENTER_RECT_PERLIN_DEVIATION = 1.3_f32
    CENTER_RECT_WIDTH = 1.4_f32
  end

  def self.make
    perlin = PerlinNoise.new(seed)
    colors = perlin.prng_item(0, COLORS, Seeds::COLORS)
    Celestine.draw do |ctx|
      ctx.view_box = {x: 0, y: 0, w: WIDTH, h: HEIGHT}

      ctx.rectangle do |r|
        r.x = 0
        r.y = 0
        r.width = WIDTH
        r.height = HEIGHT
        r.fill = colors[:bg]
        r
      end
    end
  end
end


get "/" do |env|
  Mineshift.seed += 1
  Mineshift.make
end

Kemal.config.port = ARGV.size == 0 ? 3000 : ARGV[0].to_i
Kemal.run