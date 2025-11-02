(local lg love.graphics)

(fn draw []
  (lg.setColor 0.6 0.6 1)
  (lg.rectangle :fill 0 0 _G.game-width _G.game-height))

(fn update [dt]
  (print "Hello wolrd"))

(fn load [])

{: draw : update : load}
