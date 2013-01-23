module Colors
  THEME_HUE         = 26                     #alpha #hue 0..360 #saturation 0..1 #value 0..1
  INACTIVE          = Gosu::Color.from_ahsv 96,    THEME_HUE,  0.35,            0.2
  ACTIVE            = Gosu::Color.from_ahsv 255,   THEME_HUE,  0.7,             0.2
  BACKGROUND        = Gosu::Color.from_ahsv 255,   THEME_HUE,  0.1,             0.95
  ACTIVE_BACKGROUND = Gosu::Color.from_ahsv 255,   THEME_HUE,  0.1,             0.85
  DESCRIPTION       = ACTIVE
  HARM              = Gosu::Color.new(0xFFFF0000)
  HEAL              = Gosu::Color.new(0xFF00FFFF)
end
