local scenegraph_definition = {
  sg_root = {
    size = {1920, 1080},
    position = {0, 0, UILayer.default},

    is_root = true,
  },

    sg_aligner = {
      size = {1920, 1080},
      position = {0, 0, 1},

      parent = "sg_root",

      scale = "fit",
      horizontal_alignment = "center",
      vertical_alignment = "center"
    },

      sg_rect_left = {
        size = {800, 800},
        position = {80, 0, 2},

        parent = "sg_aligner",

        horizontal_alignment = "left",
        vertical_alignment = "center"
      },

      sg_rect_right = {
        size = {800, 800},
        position = {-80, 0, 2},

        parent = "sg_aligner",

        horizontal_alignment = "right",
        vertical_alignment = "center"
      }
}

local widgets_definition = {
  letterbox = {
    scenegraph_id = "sg_aligner",
    element = {
      passes = {
        {
          pass_type = "hotspot",
          style_id = "rect_left",
          content_id = "hotspot_left"
        },
        {
          pass_type = "hotspot",
          style_id = "rect_right",
          content_id = "hotspot_right"
        },
        {
          pass_type = "rect",
          style_id = "rect_left",
          content_check_function = function(content, style)
            if content.hotspot_left.is_hover then
              style.color[2] = 50
              style.color[3] = 150
              style.color[4] = 50
            else
              style.color[2] = 0
              style.color[3] = 0
              style.color[4] = 0
            end
            return true
          end
        },
        {
          pass_type = "rect",
          style_id = "rect_right",
          content_check_function = function(content, style)
            if content.hotspot_right.is_hover then
              style.color[2] = 150
              style.color[3] = 50
              style.color[4] = 50
            else
              style.color[2] = 0
              style.color[3] = 0
              style.color[4] = 0
            end
            return true
          end
        },
      }
    },
    content = {
      hotspot_left = {},
      hotspot_right = {}
    },
    style = {
      rect_left = {
        color = {150, 0, 0, 0},
        scenegraph_id = "sg_rect_left"
      },
      rect_right = {
        color = {150, 0, 0, 0},
        scenegraph_id = "sg_rect_right"
      }
    }
  }
}

return {
  scenegraph_definition = scenegraph_definition,
  widgets_definition = widgets_definition
}
