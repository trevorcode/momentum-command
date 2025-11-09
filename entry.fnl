(local push (require :lib.push))
(local scene-manager (require :scene-manager))
(local assets (require :assets))

(set _G.game-width 1920)
(set _G.game-height 1080)
(set _G.cursor {:x 0 :y 0})

(fn love.load []
  (local (window-width window-height) (love.window.getDesktopDimensions))
  ;;(love.graphics.setDefaultFilter "nearest" "nearest")
  (love.graphics.setColor 1 1 1)
  (push:setupScreen _G.game-width _G.game-height (* 0.4 window-width)
                    (* 0.4 window-height) {:vsync true :resizable true})

  (assets.load-assets)
  (love.graphics.setFont assets.font)
  (scene-manager.change-scene :title-scene))

(fn love.draw [] ; TODO: nil check these values before using ; (local font-height ((love.graphics.getFont):getHeight))
  (push:start)
  (scene-manager.draw)
  (push:finish))

(fn love.update [dt]
  (scene-manager.update dt))

(fn love.keypressed [key]
  (scene-manager.keypressed key))

(fn love.mousepressed [x y button istouch presses]
  (scene-manager.mousepressed x y button istouch presses))

(fn love.mousereleased [x y button istouch presses]
  (scene-manager.mousereleased x y button istouch presses))

(fn love.resize [w h]
  (push:resize w h))
