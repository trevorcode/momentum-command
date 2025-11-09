(local lg love.graphics)
(local assets (require :assets))
(local projectile (require :projectile))
(local fennel (require :lib.fennel))

(local enemy {})
(local max-tiers 4)
(local projectile-reload 100)
(local speed 20)

(fn collide-with-ball [enemy]
  (if (<= enemy.tier 1)
      (do
        (: (assets.explosion-sound:clone) :play)
        (set enemy.destroy? true))
      (do 
        (: (assets.hit-hurt-sound:clone) :play)
        (set enemy.tier (- enemy.tier 1))
        (set enemy.radius (+ 30 (* enemy.tier 5))))))

(fn draw [self]
  (let [color (case self.tier
                1 [0.5 0.5 0.5]
                2 [0.8 0.3 0.1]
                3 [0.4 0.1 0.9]
                4 [0.7 0.5 0.9]
                nil [0.3 0.5 0.1])]
    (lg.setColor color)
    (lg.circle :fill (self.body:getX) (self.body:getY) self.radius)))

(fn update [self dt]
  (let [p-x (self.player.body:getX)
        p-y (self.player.body:getY)
        self-x (self.body:getX)
        self-y (self.body:getY)
        angle (math.atan2 (- p-y self-y) (- p-x self-x))
        vx (* speed (math.cos angle))
        vy (* speed (math.sin angle))]
    (self.body:setLinearVelocity vx vy))

  (if (<= self.projectile-timer 0)
      (do
        (set self.projectile-timer (+ projectile-reload (love.math.random 1 50)))
        (self:create-projectile))
      (set self.projectile-timer (- self.projectile-timer 1))))

(fn new [world create-projectile player ?x ?y ?tier]
  (let [new-enemy {}
        x (or ?x 50)
        y (or ?y 50)
        tier (or ?tier (love.math.random 1 max-tiers))
        radius (+ 30 (* tier 10))
        body (love.physics.newBody world x y :dynamic)
        shape (love.physics.newCircleShape 50)
        fixture (love.physics.newFixture body shape)]
    (fixture:setRestitution 1.0)
    (body:setMass 40)
    (body:setLinearVelocity (love.math.random 1 250) (love.math.random 1 250))
    (fixture:setUserData new-enemy)
    (doto new-enemy
      (tset :tag :enemy)
      (tset :tier tier)
      (tset :radius radius)
      (tset :body body)
      (tset :fixture fixture)
      (tset :shape shape)
      (tset :draw draw)
      (tset :collide-with-ball collide-with-ball)
      (tset :projectile-timer 30)
      (tset :create-projectile create-projectile)
      (tset :player player)
      (tset :update update))
    new-enemy))

{: new}
