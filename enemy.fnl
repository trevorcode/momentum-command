(local lg love.graphics)
(local assets (require :assets))
(local projectile (require :projectile))
(local fennel (require :lib.fennel))

(local enemy {})
(local max-tiers 4)

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

(fn create-new-projectile [objects]
  (fn [self] 
    (local p (projectile.new (self.body:getWorld) 30 30 50 50))
    (table.insert objects p)))

(fn update [self dt]
  (if (<= self.projectile-timer 0)
      (do
        (set self.projectile-timer 40)
        (self:create-projectile))
      (set self.projectile-timer (- self.projectile-timer 1))))

(fn new [world objects ?x ?y ?tier]
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
      (tset :create-projectile (create-new-projectile objects))
      (tset :update update))
    new-enemy))

{: new}
