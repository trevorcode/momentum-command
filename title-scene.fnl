(local lg love.graphics)
(local button (require :button))
(local sm (require :scene-manager))
(local assets (require :assets))
(local push (require :lib.push))

(var scene {})

(fn scene.load []
  (push:setupCanvas [{:name "shader"
                      :shader [assets.glow-shader-x assets.glow-shader-y]}
                     {:name "noshader"}])

    (assets.glow-shader-x:send "stepSize"
                               [(/ 1 _G.game-width) (/ 1 _G.game-height)])
    (assets.glow-shader-y:send "stepSize"
                               [(/ 1 _G.game-width) (/ 1 _G.game-height)])
  (set scene {})
  (set scene.play
       (button.new {:x (/ _G.game-width 2)
                    :y (+ (/ _G.game-height 2) 100)
                    :width 600
                    :height 200
                    :text "Start!"
                    :txt-size 6
                    :onclick (fn []
                               (: (assets.laser-sound:clone) :play)
                               (sm.change-scene :game-scene))})))

(fn scene.draw []
  (push:setCanvas "shader")
  (let [font assets.font
        text "MOMENTUM COMMAND"
        textWidth (font:getWidth text)
        textHeight (font:getHeight)]
    (love.graphics.print text (/ _G.game-width 2) (- (/ _G.game-height 2) 200)
                         0 10 10 (/ textWidth 2) (/ textHeight 2)))

  (push:setCanvas "noshader")

  (let [font assets.font
        text "MOMENTUM COMMAND"
        textWidth (font:getWidth text)
        textHeight (font:getHeight)]
    (love.graphics.print text (/ _G.game-width 2) (- (/ _G.game-height 2) 200)
                         0 10 10 (/ textWidth 2) (/ textHeight 2)))
  (button.draw scene.play)
  )

(fn scene.update [dt]
  (button.update scene.play dt))

(fn scene.mousepressed [])
(fn scene.mousereleased []
  (button.mousepressed scene.play))

(fn scene.keypressed [])

scene
