(local test-scene (require :test))
(local scene-manager (require :scene-manager))
(local push (require :lib.push))

(set _G.game-width 1080)
(set _G.game-height 720)

(fn love.load []
  (local (window-width window-height) (love.window.getDesktopDimensions))
  (love.graphics.setDefaultFilter "nearest" "nearest")
  (push:setupScreen _G.game-width _G.game-height
                    (* 0.4 window-width)
                    (* 0.4 window-height)
                    {:vsync true :resizable true})
  (scene-manager.change-scene test-scene))

(fn love.draw []
  (push:start)
  (scene-manager.draw)
  (push:finish))

(fn love.update [dt]
  (scene-manager.update dt))

(fn love.resize [w h]
  (push:resize w h))
