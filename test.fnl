(local push (require :lib.push))
(local lg love.graphics)
(local util (require :util))

(local game {})

(fn load []
  ; game world
  (set game.world (love.physics.newWorld 0 0 true))
  ; (love.physics.setMeter 10)

  ; (set game.bounds {})
  ; (set game.bounds.body (love.physics.newBody game.world (/ _G.game-width 2) (/ _G.game-height 2) :static))
  ; (set game.bounds.shape (love.physics.newRectangleShape _G.game-width _G.game-height))
  ; (set game.bounds.fixture (love.physics.newFixture game.bounds.body game.bounds.shape))
  ; player
  (set game.player {:x (/ _G.game-width 2) :y (/ _G.game-height 2) :angle 0 :speed 10})
  ; (set game.player.body (love.physics.newBody game.world game.player.x game.player.y ))
  ; ball
  (set game.ball {:x (/ _G.game-width 2) :y (/ _G.game-height 2) :speed 5 :angle 0 :radius 50})
  (set game.ball.body (love.physics.newBody game.world game.ball.x game.ball.y :dynamic))
  (set game.ball.shape (love.physics.newCircleShape game.ball.radius))
  (set game.ball.fixture (love.physics.newFixture game.ball.body game.ball.shape 0.1))

  (game.ball.body:applyForce 100 200))

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
  (lg.circle :fill (game.ball.body:getX) (game.ball.body:getY) (game.ball.shape:getRadius))
  (lg.print (string.format "Mouse X: %f Mouse Y: %f" _G.cursor.x _G.cursor.y))
  (lg.print (string.format "Player X: %f Player Y: %f" game.player.x
                           game.player.y) nil 20)
  (lg.print (string.format "Angle: %f" game.player.angle) nil 40))

(fn update [dt]
  (game.world:update dt)
  (local (mouse-x mouse-y) (push:toGame (love.mouse.getPosition)))
  ; mouse within game
  (when (and mouse-x mouse-y)
    (local angle-to-mouse
           (math.atan2 (- mouse-y game.player.y) (- mouse-x game.player.x)))
    (set game.player.angle angle-to-mouse)
    (set _G.cursor.x mouse-x)
    (set _G.cursor.y mouse-y))

  ; player movement
  (local (old-x old-y) (values game.player.x game.player.y))
  (var (new-x new-y) (values old-x old-y))
  (when (love.keyboard.isDown "w")
    (set new-y (- game.player.y game.player.speed)))

  (when (love.keyboard.isDown "s")
    (set new-y (+ game.player.y game.player.speed)))

  (when (love.keyboard.isDown "a")
    (set new-x (- game.player.x game.player.speed)))

  (when (love.keyboard.isDown "d")
    (set new-x (+ game.player.x game.player.speed)))

  ; check that player position is within game
  (when (util.point-within? {:x new-x :y new-y} {:x 0 :y 0 :width _G.game-width :height _G.game-height})
    (set game.player.x new-x)
    (set game.player.y new-y)))
    

(fn mousepressed [])
(fn mousereleased [])
(fn keypressed [])

{: draw : update : load : mousepressed : mousereleased : keypressed}
