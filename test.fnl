(local push (require :lib.push))
(local lg love.graphics)
(local util (require :util))
(local enemy (require :enemy))

(local game {})

(fn is-either [a b either1 either2]
  (and (not= a b) (or (= a either1))))

(fn on-collision-enter [a b contact]
  (contact:setEnabled false)
  (let [entity-a (a:getUserData)
        entity-b (b:getUserData)]
    (case [(?. entity-a :tag) (?. entity-b :tag)]
      [:enemy :enemy] (print "ENEMY")
      [:enemy :ball] (entity-a:collide-with-ball)
      [:ball :enemy] (entity-b:collide-with-ball)
      [nil nil] (print "NIL NIL"))))

(fn on-collision-exit [a b contact])

(fn load-walls []
  (set game.bounds.left
       {:body (love.physics.newBody game.world 0 0 :static)
        :shape (love.physics.newEdgeShape 0 0 0 _G.game-height)})
  (set game.bounds.left.fixture
       (love.physics.newFixture game.bounds.left.body game.bounds.left.shape))
  ; right
  (set game.bounds.right
       {:body (love.physics.newBody game.world _G.game-width 0 :static)
        :shape (love.physics.newEdgeShape 0 0 0 _G.game-height)})
  (set game.bounds.right.fixture
       (love.physics.newFixture game.bounds.right.body game.bounds.right.shape))
  ; top
  (set game.bounds.top
       {:body (love.physics.newBody game.world 0 0 :static)
        :shape (love.physics.newEdgeShape 0 0 _G.game-width 0)})
  (set game.bounds.top.fixture
       (love.physics.newFixture game.bounds.top.body game.bounds.top.shape))
  (set game.bounds.bottom
       {:body (love.physics.newBody game.world 0 _G.game-height :static)
        :shape (love.physics.newEdgeShape 0 0 _G.game-width 0)})
  (set game.bounds.bottom.fixture
       (love.physics.newFixture game.bounds.bottom.body
                                game.bounds.bottom.shape)))

(fn create-ball []
  (set game.ball {:x (/ _G.game-width 2) :y (/ _G.game-height 2) :radius 10})
  (set game.ball.tag :ball)
  (set game.player.body
       (love.physics.newBody game.world game.player.x game.player.y :kinematic))
  ; The collision of the player is larger than the sprite, for good feels
  (set game.player.shape (love.physics.newPolygonShape -30 0 30 110 30 -110))
  (set game.player.fixture
       (love.physics.newFixture game.player.body game.player.shape)) ; ball
  (set game.ball.body (love.physics.newBody game.world game.ball.x game.ball.y
                                            :dynamic))
  (set game.ball.shape (love.physics.newCircleShape game.ball.radius))
  (set game.ball.fixture
       (love.physics.newFixture game.ball.body game.ball.shape))
  (game.ball.fixture:setUserData game.ball) ; restitution is how much % energy the fixture keeps after collision
  (game.ball.fixture:setRestitution 1)
  (game.ball.body:setMass 50)
  (game.ball.body:setLinearVelocity 1500 500))

(fn load [] ; game world
  (set game.world (love.physics.newWorld 0 0 true)) ; (love.physics.setMeter 10)
  (game.world:setCallbacks on-collision-enter on-collision-exit)
  (set game.bounds {}) 
  (set game.objects []) 
  (set game.player {:x (/ _G.game-width 2)
                    :y (/ _G.game-height 2)
                    :angle 0
                    :speed 10}) ; ball
  
  (load-walls)
  (create-ball)

  (table.insert game.objects (enemy.new game.world 50 50))
  (table.insert game.objects (enemy.new game.world 100 100))
  (table.insert game.objects (enemy.new game.world 200 200))
  (table.insert game.objects (enemy.new game.world 200 200)))

(fn draw-rotated-rectangle [mode x y width height angle]
  (lg.push)
  (lg.translate x y)
  (lg.rotate angle)
  (lg.rectangle mode (- 0 (/ width 2)) (- 0 (/ height 2)) width height)
  (lg.pop))

(fn draw-player []
  (draw-rotated-rectangle :fill game.player.x game.player.y 60 180
                          game.player.angle)
  (lg.setColor 0.6 0.6 1)
  (lg.polygon :fill
              (game.player.body:getWorldPoints (game.player.shape:getPoints)))
  (lg.setColor 0 0 1)
  (lg.circle :line game.player.x game.player.y 10)
  (lg.setColor 1 1 1)
  )

(fn draw-ball []
  (lg.circle :line _G.cursor.x _G.cursor.y 10)
  (lg.circle :fill (game.ball.body:getX) (game.ball.body:getY)
             (game.ball.shape:getRadius)))

(fn draw []
  (draw-player)
  (draw-ball)
  (lg.print (string.format "Mouse X: %f Mouse Y: %f" _G.cursor.x _G.cursor.y))
  (lg.print (string.format "Player X: %f Player Y: %f" game.player.x
                           game.player.y) nil 20)
  (lg.print (string.format "Angle: %f" game.player.angle) nil 40)
  (lg.print (let [(vx vy) (game.ball.body:getLinearVelocity)
                  (v) (math.sqrt (+ (math.pow vx 2) (math.pow vy 2)))]
              (string.format "Ball Linear Speed: %f vx:%f vy:%f" v vx vy))
            nil 60)
  (each [_ o (ipairs game.objects)]
    (o:draw)))

(fn update [dt]
  (game.world:update dt)
  (local (mouse-x mouse-y) (push:toGame (love.mouse.getPosition))) ; mouse within game
  (when (and mouse-x mouse-y)
    (local angle-to-mouse
           (math.atan2 (- mouse-y game.player.y) (- mouse-x game.player.x)))
    (set game.player.angle angle-to-mouse)
    (game.player.body:setAngle angle-to-mouse)
    (set _G.cursor.x mouse-x)
    (set _G.cursor.y mouse-y)) ; player movement
  (local (old-x old-y) (values game.player.x game.player.y))
  (var (new-x new-y) (values old-x old-y))
  (when (love.keyboard.isDown :w)
    (set new-y (- game.player.y game.player.speed)))
  (when (love.keyboard.isDown :s)
    (set new-y (+ game.player.y game.player.speed)))
  (when (love.keyboard.isDown :a)
    (set new-x (- game.player.x game.player.speed)))
  (when (love.keyboard.isDown :d)
    (set new-x (+ game.player.x game.player.speed))) ; check that player position is within game
  (when (util.point-within? {:x new-x :y new-y}
                            {:x 0
                             :y 0
                             :width _G.game-width
                             :height _G.game-height})
    (set game.player.x new-x)
    (set game.player.y new-y))
  (set game.objects (icollect [_ o (ipairs game.objects)]
                      (if o.destroy?
                          (do
                            (case o.body b (b:destroy))
                            nil)
                          o)))
  (set game.player.y new-y)
  (game.player.body:setPosition new-x new-y))

(fn mousepressed [])
(fn mousereleased [])
(fn keypressed [])

{: draw : update : load : mousepressed : mousereleased : keypressed}
