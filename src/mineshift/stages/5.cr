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
    {bg: "#d8dbe2", levels: ["#a9bcd0", "#58a4b0", "#373f51", "#1b1b1e"]},
    {bg: "#f6aa1c", levels: ["#bc3908", "#941b0c", "#621708", "#220901"]},
    {bg: "#e0fbfc", levels: ["#c2dfe3", "#9db4c0", "#5c6b73", "#253237"]},
    {bg: "#9742a1", levels: ["#7c3085", "#611f69", "#4a154b", "#340f34"]},
    {bg: "#c4fff9", levels: ["#9ceaef", "#68d8d6", "#3dccc7", "#07beb8"]},
    {bg: "#ffffff", levels: ["#5bc0be", "#3a506b", "#1c2541", "#0b132b"]},
    {bg: "#ff9b54", levels: ["#ff7f51", "#ce4257", "#720026", "#4f000b"]},
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

  
  LVL_SIZES = {
    0 => 0.02,
    1 => 0.04,
    2 => 0.06,
    3 => 0.08,
  }

  # Data for the size of levels
  LEVEL_DATA = {
    0 => {
      max_distance: ((WIDTH/2)*LVL_SIZES[0]).to_i * 10,
      max_blocks:   4,
      block_size:   ((WIDTH/2)*LVL_SIZES[0]).to_i,
      deviation:    4,
    },

    1 => {
      max_distance: ((WIDTH/2)*LVL_SIZES[1]).to_i * 12,
      max_blocks:   3,
      block_size:   ((WIDTH/2)*LVL_SIZES[1]).to_i,
      deviation:    2,
    },

    2 => {
      max_distance: ((WIDTH/2)*LVL_SIZES[2]).to_i * 16,
      max_blocks:   3,
      block_size:   ((WIDTH/2)*LVL_SIZES[2]).to_i,
      deviation:    3,
    },

    3 => {
      max_distance: ((WIDTH/2)*LVL_SIZES[3]).to_i * 20,
      max_blocks:   7,
      block_size:   ((WIDTH/2)*LVL_SIZES[3]).to_i,
      deviation:    2,
    },
  }


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
    BLOCK_SPACING         = 0.283673_f32
    CENTER_MASK_DEVIATION = 0.834728_f32
  end



  def self.make_center_mask_rectangles(perlin, level : Int32)
    center_rects = [] of NamedTuple(x: Int32, y: Int32, w: Int32, h: Int32)

    center = (WIDTH/2).to_i
    current_height = 0
    # Perlin counter (provides random values by increasing seed)
    p_counter = 0
    # Creates the middle mask rectangles
    until current_height > FRAME_HEIGHT
      mask_rect_bb = {} of Symbol => Int32
      mask_rect = Celestine::Rectangle.new


      additional_block_spacing = perlin.prng_int(p_counter, current_height, level + 1, 0, LEVEL_DATA[level][:max_blocks], Seeds::BLOCK_SPACING) * LEVEL_DATA[level][:block_size]
      p_counter += 1
      mask_rect.width = mask_rect_bb[:w] = LEVEL_DATA[level][:max_distance] - additional_block_spacing
      mask_rect.height = mask_rect_bb[:h] = LEVEL_DATA[level][:block_size] + 1 # Offset by one because of svg antialiasing issues
       
      position_x = center - (mask_rect_bb[:w].to_i/2).to_i
      deviation = (perlin.int(current_height, p_counter, level + 1, -LEVEL_DATA[level][:deviation], LEVEL_DATA[level][:deviation], Seeds::CENTER_MASK_DEVIATION) * LEVEL_DATA[level][:block_size])
      mask_rect.y = mask_rect_bb[:y] = current_height - 1 # Offset by one to ensure lines don't draw (svg antialiasing)
      mask_rect.x = mask_rect_bb[:x] = position_x - deviation
      current_height += LEVEL_DATA[level][:block_size]

      center_rects << {x: mask_rect_bb[:x], y: mask_rect_bb[:y], w: mask_rect_bb[:w], h: mask_rect_bb[:h]}
    end
    center_rects
  end

  def self.make
    perlin = PerlinNoise.new(@@seed.to_i)
    colors = perlin.prng_item(0, COLORS, Seeds::COLORS)

    Celestine.draw do |ctx|
      ctx.view_box = {x: 0, y: 0, w: WIDTH, h: HEIGHT}

      # Draw background
      ctx.rectangle do |rect|
        rect.id = "background"
        rect.x = 0
        rect.y = 0
        rect.width = WIDTH
        rect.height = HEIGHT
        rect.fill = colors[:bg]
        rect
      end

      MAX_LEVELS.times do |level|
        ctx.mask do |mask|
          mask.id = "lvl#{level}-mask"

          mask.rectangle do |r|
            r.id = "bg-mask"
            r.x = 0
            r.y = 0
            r.width = WIDTH
            r.height = FRAME_HEIGHT
            r.fill = "white"
            r
          end

          center_rectangles = make_center_mask_rectangles(perlin, level)

          center_rectangles.each_with_index do |r, i| 
            rect = Celestine::Rectangle.new
            rect.id = "mask-rect-#{level}-#{i}"
            rect.fill = "black"
            rect.x = r[:x]
            rect.y = r[:y]
            rect.width = r[:w]
            rect.height = r[:h]

            mask << rect
          end

          ctx.group do |group|
            lvl_rect = group.rectangle do |rect|
              rect.id = "lvl#{level}-rect"
              rect.x = 0
              rect.y = -1
              rect.width = WIDTH
              rect.height = FRAME_HEIGHT + 1
              rect.fill = colors[:levels][level]
              rect.set_mask mask
              rect
            end

            group.animate_motion do |anim|
              anim.duration = ((((3 - level)/3.0)*200) + 40)
              anim.duration_units = "s"
              anim.repeat_count = "indefinite"
              anim.mpath do |path|
                path.r_move(0, 0)
                path.r_line(0, -FRAME_HEIGHT - 1)
                path
              end
              anim
            end

            group.use(lvl_rect) do |use|
              use.y = (FRAME_HEIGHT) - 2
              use
            end

            group
          end
          mask
        end
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