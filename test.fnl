(local push (require :lib.push))
(local lg love.graphics)
(local util (require :util))
(local enemy (require :enemy))
(local fennel (require :lib.fennel))
(local projectile (require :projectile))
(local assets (require :assets))

(local game {})

(fn player-pushes-ball [_player ball]
  (: (assets.laser-sound:clone) :play)
  (let [ball-body (ball:getBody)
        (vx vy) (ball-body:getLinearVelocity)
        [new-vx new-vy] (util.vector-scale [vx vy] 1.1)]
    (ball-body:setLinearVelocity new-vx new-vy)))

(fn player-hits-projectile [_player projectile]
  (: (assets.paddlehurt-sound:clone) :play)
  (set projectile.destroy? true)
  (set game.player.health (- game.player.health 1)))

; TODO: use Body.getUserData for this

(fn on-collision-enter [a b contact]
  (contact:setEnabled false)
  (let [entity-a (a:getUserData)
        entity-b (b:getUserData)
        tag-a (?. entity-a :tag)
        tag-b (?. entity-b :tag)]
    (case [tag-a tag-b]
      [:enemy :enemy] nil
      [:enemy :ball] (entity-a:collide-with-ball)
      [:ball :enemy] (entity-b:collide-with-ball)
      [:projectile :player] (player-hits-projectile entity-b entity-a)
      [:player :projectile] (player-hits-projectile entity-a entity-b)
      [a b] nil)))

(fn on-collision-exit [a b contact]
  (let [entity-a (a:getUserData)
        entity-b (b:getUserData)
        tag-a (?. entity-a :tag)
        tag-b (?. entity-b :tag)]
    (case [tag-a tag-b]
      [:player :ball] (player-pushes-ball a b)
      [:ball :player] (player-pushes-ball b a)
      [_a _b] nil)))

(fn load-walls [] ; left
  (set game.bounds.left
       {:body (love.physics.newBody game.world -25 (/ _G.game-height 2) :static)
        :shape (love.physics.newRectangleShape 50 _G.game-height)})
  (set game.bounds.left.fixture
       (love.physics.newFixture game.bounds.left.body game.bounds.left.shape))
  ; right
  (set game.bounds.right
       {:body (love.physics.newBody game.world (+ _G.game-width 25)
                                    (/ _G.game-height 2) :static)
        :shape (love.physics.newRectangleShape 50 _G.game-height)})
  (set game.bounds.right.fixture
       (love.physics.newFixture game.bounds.right.body game.bounds.right.shape))
  ; top
  (set game.bounds.top
       {:body (love.physics.newBody game.world (/ _G.game-width 2) -25 :static)
        :shape (love.physics.newRectangleShape _G.game-width 50)})
  (set game.bounds.top.fixture
       (love.physics.newFixture game.bounds.top.body game.bounds.top.shape)) ; bottom
  (set game.bounds.bottom
       {:body (love.physics.newBody game.world (/ _G.game-width 2)
                                    (+ _G.game-height 25) :static)
        :shape (love.physics.newRectangleShape _G.game-width 50)})
  (set game.bounds.bottom.fixture
       (love.physics.newFixture game.bounds.bottom.body
                                game.bounds.bottom.shape)))

(fn create-new-projectile [objects player]
  (fn [self]
    (local p (projectile.new (self.body:getWorld) (self.body:getX)
                             (self.body:getY) (player.body:getX)
                             (player.body:getY)))
    (table.insert objects p)))

(fn create-ball []
  (set game.ball {:x (/ _G.game-width 2) :y (/ _G.game-height 2) :radius 10 :in-bounds? true :oob-max-duration 2})
  (set game.ball.tag :ball)
  (set game.ball.body (love.physics.newBody game.world game.ball.x game.ball.y
                                            :dynamic))
  (set game.ball.shape (love.physics.newCircleShape game.ball.radius))
  (set game.ball.fixture
       (love.physics.newFixture game.ball.body game.ball.shape))
  (game.ball.fixture:setUserData game.ball) ; restitution is how much % energy the fixture keeps after collision
  (game.ball.fixture:setRestitution 1)
  (game.ball.body:setMass 50)
  (game.ball.body:setLinearVelocity 500 500))

(fn create-player []
  (set game.player {:x (/ _G.game-width 2)
                    :y (/ _G.game-height 2)
                    :angle 0
                    :speed 10
                    :health 5})
  (set game.player.tag :player)
  (set game.player.body
       (love.physics.newBody game.world game.player.x game.player.y :static)) ; The collision of the player is larger than the sprite, for good feels
  (set game.player.shape
       (love.physics.newPolygonShape -30 0 0 110 30 110 30 -110 0 -110))
  (set game.player.fixture
       (love.physics.newFixture game.player.body game.player.shape))
  (game.player.fixture:setUserData game.player))

(fn load []
  (push:setupCanvas [{:name "shader"
                      :shader [assets.glow-shader-x assets.glow-shader-y]}
                     {:name "noshader"}])
  (set game.world (love.physics.newWorld 0 0 true))
  (game.world:setCallbacks on-collision-enter on-collision-exit)
  (set game.spawn-timer 0)
  (set game.bounds {})
  (set game.objects [])
  (load-walls)
  (create-ball)
  (create-player)
  (print (fennel.view (util.vector-rotate [1 0] math.pi)))
  (let [create-proj (create-new-projectile game.objects game.player)]
    (table.insert game.objects (enemy.new game.world create-proj game.player 50
                                          50))
    (table.insert game.objects (enemy.new game.world create-proj game.player
                                          100))
    (table.insert game.objects
                  (enemy.new game.world create-proj game.player 200 200))
    (table.insert game.objects
                  (enemy.new game.world create-proj game.player 300 300))))

(fn draw-rotated-rectangle [mode x y width height angle]
  (lg.push)
  (lg.translate x y)
  (lg.rotate angle)
  (lg.rectangle mode (- 0 (/ width 2)) (- 0 (/ height 2)) width height)
  (lg.pop))

(fn draw-player []
  (when (not game.player.game-over?)
    (local (r g b) (lg.getColor))
    (let [hitbox-points [(game.player.shape:getPoints)]
          [x1 y1 x2 y2 x3 y3 x4 y4 x5 y5] hitbox-points
          ; TODO: fix offset directions
          ; 1: lower right rectangle
          ; 2: lower left rectangle
          ; 3: upper left rectangle
          ; 4: triangle tip
          ; 5: upper right rectangle
          hitbox-white [(- x1 4)
                        (+ y1 4)
                        (- x2 4)
                        (- y2 4)
                        (+ x3 4)
                        (- y3 4)
                        (+ x4 4)
                        (+ y4 0)
                        (+ x5 4)
                        (+ y5 4)]
          hitbox-black [(- x1 8)
                        (+ y1 8)
                        (- x2 8)
                        (- y2 8)
                        (+ x3 8)
                        (- y3 8)
                        (+ x4 8)
                        (+ y4 0)
                        (+ x5 8)
                        (+ y5 8)]]
      (lg.setColor 0.6 0.6 1)
      (lg.polygon :fill
                  (game.player.body:getWorldPoints (unpack hitbox-points)))
      (lg.setColor 1 1 1)
      (lg.polygon :fill (game.player.body:getWorldPoints (unpack hitbox-white)))
      (lg.setColor 0 0 0)
      (lg.polygon :fill (game.player.body:getWorldPoints (unpack hitbox-black)))
      (lg.setColor 1 0.6 0.6)
      (lg.circle :line game.player.x game.player.y 10)
      (lg.setColor r g b))))

(fn draw-ball []
  (lg.setColor 1 1 1)
  (lg.circle :line _G.cursor.x _G.cursor.y 10)
  (lg.circle :fill (game.ball.body:getX) (game.ball.body:getY)
             (game.ball.shape:getRadius)))

(fn draw-scene []
  (let [enemies (icollect [_ o (ipairs game.objects)]
                  (when (= o.tag :enemy) o))
        projectiles (icollect [_ o (ipairs game.objects)]
                      (when (= o.tag :projectile) o))]
    (assets.glow-shader-x:send "stepSize"
                               [(/ 1 _G.game-width) (/ 1 _G.game-height)])
    (assets.glow-shader-y:send "stepSize"
                               [(/ 1 _G.game-width) (/ 1 _G.game-height)])
    (assets.glow-shader-x:send "blurRadius" 40)
    (assets.glow-shader-y:send "blurRadius" 40)
    (each [_ o (ipairs enemies)]
      (o:draw))
    (each [_ o (ipairs projectiles)]
      (o:draw))))

(fn draw []
  (push:setCanvas "shader")
  (draw-scene)
  (push:setCanvas "noshader")
  (draw-player)
  (draw-ball)
  (draw-scene)
  (lg.setColor 1 1 1)

  (when game.game-over?
    (lg.printf "Game Over" 0 300 (/ _G.game-width 8) "center" 0 8 8 0 0 0))

  (lg.print (string.format "Mouse X: %f Mouse Y: %f" _G.cursor.x _G.cursor.y))
  (lg.print (string.format "Player X: %f Player Y: %f" game.player.x
                           game.player.y) nil 20)
  (lg.print (string.format "Angle: %f" game.player.angle) nil 40)
  (lg.print (string.format "Spawn Timer: %f" game.spawn-timer) nil 80)
  (lg.print (let [(vx vy) (game.ball.body:getLinearVelocity)
                  (v) (math.sqrt (+ (math.pow vx 2) (math.pow vy 2)))]
              (string.format "Ball Linear Speed: %f vx:%f vy:%f" v vx vy))
            nil 60)
  (lg.print (string.format "Health: %d" game.player.health) nil 100))

(fn delete-destroyed-game-objects! [objects]
  (for [i (length objects) 1 -1]
    (let [o (. objects i)]
      (when o.destroy?
        (case o.body b (b:destroy))
        (table.remove objects i)))))

(fn set-game-over []
  (set game.game-over? true)
  (set game.player.game-over? true)
  (game.player.body:setActive false)
  (: (assets.explosion-sound:clone) :play))

(fn update-game [dt]
  (local ball-now-in-bounds?
    (let [(ball-x ball-y) (game.ball.body:getPosition)]
      (util.point-within? {:x ball-x :y ball-y} {:x 0 :y 0 :width _G.game-width :height _G.game-height})))
  (when (<= game.player.health 0)
    (set-game-over))
  (if (<= game.spawn-timer 0)
      (do
        (set game.spawn-timer (+ 0.25 (love.math.random 0 8)))
        (let [create-proj (create-new-projectile game.objects game.player)]
          (table.insert game.objects
                        (enemy.new game.world create-proj game.player
                                   (love.math.random 50 (- _G.game-width 50))
                                   (love.math.random 50 (- _G.game-height 50))))))
      (set game.spawn-timer (- game.spawn-timer dt)))
  (each [_ o (ipairs game.objects)]
    (o:update dt))
  ; When ball continues to be out-of-bounds
  (when (not ball-now-in-bounds?)
    (if game.ball.in-bounds?
      (do ; Initial out of bounds frame
        (set game.ball.in-bounds? false)
        (set game.ball.oob-timer (love.timer.getTime)))
      (let [oob-duration (- (love.timer.getTime) game.ball.oob-timer)
           [new-vx new-vy] (util.vector-rotate [(game.ball.body:getLinearVelocity)] (math.floor (math.random 0 100000)))]
        (when (<= game.ball.oob-max-duration oob-duration) ; CONSIDER: Reseting the ball linear velocity to a different direction
          (game.ball.body:setPosition (/ _G.game-width 2) (/ _G.game-height 2))
          (game.ball.body:setLinearVelocity new-vx new-vy)
          (set game.ball.in-bounds? true))))) 
        
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
  (let [(vx vy) (game.ball.body:getLinearVelocity)
        speed (util.vector-length [vx vy])]
    (when (< speed 600)
      (let [[new-vx new-vy] (util.vector-scale (util.vector-normalize [vx vy])
                                               600)]
        (game.ball.body:setLinearVelocity new-vx new-vy))))
  (delete-destroyed-game-objects! game.objects)
  (game.player.body:setPosition new-x new-y))

(fn update [dt]
  (game.world:update dt)
  (if game.game-over?
      nil
      (update-game dt)))

(fn mousepressed [])
(fn mousereleased [])
(fn keypressed [])

{: draw : update : load : mousepressed : mousereleased : keypressed}
