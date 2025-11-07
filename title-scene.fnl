(local lg love.graphics)
(local button (require :button))
(local sm (require :scene-manager))

(local scene {})

(fn scene.load []
  (set scene.play (button.new {:x 500 :y 500 :width 100 :height 100
                               :text "Hello"
                               :t-off-x 0 :t-off-y 0 :txt-scale 64
                               :onclick (fn [] (sm.change-scene :test))})))

(fn scene.draw []
  (button.draw scene.play))

(fn scene.update [dt]
  (button.update scene.play dt))

(fn scene.mousepressed [])
(fn scene.mousereleased []
  (button.mousepressed scene.play))

(fn scene.keypressed [])

scene
