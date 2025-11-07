(local push (require :lib.push))
(local lg love.graphics)

(local game {})

(fn load []
  (set game.player {:x (/ _G.game-width 2) :y (/ _G.game-height 2) :angle 0}))

(fn draw-rotated-rectangle [mode x y width height angle]
  (lg.push)
  (lg.translate x y)
  (lg.rotate angle)
  (lg.rectangle mode (- 0 (/ width 2)) (- 0 (/ height 2)) width height)
  (lg.pop))

(fn draw []
  ;; (lg.setColor 0.6 0.6 1)
  ;; (lg.rectangle :fill 0 0 _G.game-width _G.game-height)
  (draw-rotated-rectangle :fill game.player.x game.player.y 80 150
                          game.player.angle)
  (lg.circle :line _G.cursor.x _G.cursor.y 10)
  (lg.print (string.format "Mouse X: %f Mouse Y: %f" _G.cursor.x _G.cursor.y))
  (lg.print (string.format "Player X: %f Player Y: %f" game.player.x
                           game.player.y) nil 20)
  (lg.print (string.format "Angle: %f" game.player.angle) nil 40))

(fn update [_dt]
  (local (mouse-x mouse-y) (push:toGame (love.mouse.getPosition)))
  (when (and mouse-x mouse-y)
    (local angle-to-mouse
           (math.atan2 (- mouse-y game.player.y) (- mouse-x game.player.x)))
    (set game.player.angle angle-to-mouse)
    (set _G.cursor.x mouse-x)
    (set _G.cursor.y mouse-y)))

(fn mousepressed [])
(fn mousereleased [])
(fn keypressed [])

{: draw : update : load : mousepressed : mousereleased : keypressed}
