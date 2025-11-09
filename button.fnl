(local util (require :util))
(local assets (require :assets))
(local lg love.graphics)

(fn update [b dt]
  (set b.hover? (util.cursor-within? {:x (- b.x (/ b.width 2))
                                      :y (- b.y (/ b.height 2))
                                      :width b.width
                                      :height b.height}))
  (set b.pressed? (and b.hover? (love.mouse.isDown 1))))

(fn draw [b]
  (local color [(/ 241 255) (/ 140 255) (/ 241 255)] )
  (love.graphics.push)
  (love.graphics.translate b.x b.y)
  (local origin-x (- 0 (/ b.width 2)))
  (local origin-y (- 0 (/ b.height 2)))
  (love.graphics.rotate b.rotation)
  (lg.setColor color)
  (lg.rectangle :fill origin-x origin-y b.width b.height)

  (lg.setColor 1 1 1)
  (lg.rectangle :fill (+ origin-x 5) (+ origin-y 5) (- b.width 10) (- b.height 10))

  (lg.setColor color)
  (lg.rectangle :fill (+ origin-x 10) (+ origin-y 10) (- b.width 20) (- b.height 20))

  (if b.hover?
      (lg.setColor 0.3 0.3 0.3)
      (lg.setColor 0.1 0.1 0.1))
  (lg.rectangle :fill (+ origin-x 13) (+ origin-y 13) (- b.width 26) (- b.height 26))
  (lg.setColor 1 1 1)
  (let [font assets.font
        text b.text
        textWidth (font:getWidth text)
        textHeight (font:getHeight)]
    (love.graphics.print text 0 0 0 b.txt-size b.txt-size (/ textWidth 2)
                         (/ textHeight 2)))
  (love.graphics.pop))

(fn mousepressed [b]
  (when (util.cursor-within? {:x (- b.x (/ b.width 2))
                              :y (- b.y (/ b.height 2))
                              :width b.width
                              :height b.height})
    (b.onclick)))

(fn keypressed [b key]
  (when (= b.keybinding key)
    (b.onclick)))

(fn new [{: text
          : x
          : y
          : width
          : height
          : onclick
          : keybinding
          : txt-size
          &as button}]
  (set button.txt-size (or txt-size 1))
  (set button.rotation 0)
  (set button.keypressed (or keypressed (fn [])))
  button)

{: update : draw : mousepressed : new : keypressed}
