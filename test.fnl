(local push (require :lib.push))
(local lg love.graphics)

(fn draw-rotated-rectangle [mode x y width height angle]
  (love.graphics.push)
  (love.graphics.translate x y)
  (love.graphics.rotate angle)
  (love.graphics.rectangle mode (- 0 (/ width 2)) (- 0 (/ height 2)) width height)
  (love.graphics.pop))

(fn draw []
  ;; (lg.setColor 0.6 0.6 1)
  ;; (lg.rectangle :fill 0 0 _G.game-width _G.game-height)
  (draw-rotated-rectangle "fill" _G.player.x _G.player.y 80 150 _G.player.angle)
  (love.graphics.circle "line" _G.cursor.x _G.cursor.y 10)
  (love.graphics.print (string.format "Mouse X: %f Mouse Y: %f" _G.cursor.x _G.cursor.y ))
  (love.graphics.print (string.format "Player X: %f Player Y: %f" _G.player.x _G.player.y) nil 20)
  (love.graphics.print (string.format "Angle: %f" _G.player.angle) nil 40)
  )

(fn update [dt]
  (local (mouse-x mouse-y) (push:toGame (love.mouse.getPosition)))
  (local angle-to-mouse (math.atan2 (- mouse-y _G.player.y) (- mouse-x _G.player.x)))
  (tset _G.player :angle angle-to-mouse)
  (tset _G.cursor :x mouse-x)
  (tset _G.cursor :y mouse-y))

(fn load [])
(fn mousepressed [])
(fn mousereleased [])
(fn keypressed [])

{: draw : update : load : mousepressed : mousereleased : keypressed}
