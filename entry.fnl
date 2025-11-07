(local push (require :lib.push))

(set _G.game-width 1920)
(set _G.game-height 1080)
(set _G.player {:x (/ _G.game-width 2) :y (/ _G.game-height 2) :angle 0})
(set _G.cursor {:x 0 :y 0})

(fn draw-rotated-rectangle [mode x y width height angle]
  (love.graphics.push)
  (love.graphics.translate x y)
  (love.graphics.rotate angle)
  (love.graphics.rectangle mode (- 0 (/ width 2)) (- 0 (/ height 2)) width height)
  (love.graphics.pop))

(fn love.load []
  (local (window-width window-height) (love.window.getDesktopDimensions))
  ;;(love.graphics.setDefaultFilter "nearest" "nearest")
  (love.graphics.setColor 1 1 1)
  (push:setupScreen _G.game-width _G.game-height
                    (* 0.4 window-width)
                    (* 0.4 window-height)
                    {:vsync true :resizable true}))

(fn love.draw []
  ; TODO: nil check these values before using
  ; (local font-height ((love.graphics.getFont):getHeight))
  (push:start)
  (draw-rotated-rectangle "fill" _G.player.x _G.player.y 80 150 _G.player.angle)
  (love.graphics.circle "line" _G.cursor.x _G.cursor.y 10)
  (love.graphics.print (string.format "Mouse X: %f Mouse Y: %f" _G.cursor.x _G.cursor.y ))
  (love.graphics.print (string.format "Player X: %f Player Y: %f" _G.player.x _G.player.y) nil 20)
  (love.graphics.print (string.format "Angle: %f" _G.player.angle) nil 40)
  (push:finish))

(fn love.update [dt]
  (local (mouse-x mouse-y) (push:toGame (love.mouse.getPosition)))
  (local angle-to-mouse (math.atan2 (- mouse-y _G.player.y) (- mouse-x _G.player.x)))
  (tset _G.player :angle angle-to-mouse)
  (tset _G.cursor :x mouse-x)
  (tset _G.cursor :y mouse-y))

(fn love.resize [w h]
  (push:resize w h))
