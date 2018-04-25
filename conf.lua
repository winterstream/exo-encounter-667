love.conf = function(t)
   t.gammacorrect = true
   t.title, t.identity = "EXO_encounter-667", "exo-encounter-667"
   t.modules.joystick, t.modules.physics = false, false
   t.modules.audio = false -- hopefully we can add this later
   t.window.width, t.window.height = 720, 450
   t.window.vsync = false
   t.version = "11.1"
end
