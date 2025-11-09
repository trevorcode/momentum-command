(local lg love.graphics)

(local projectile {})
(local speed 90)

(fn draw [self]
  (lg.setColor 1 0.3 0.3)
  (lg.circle :fill (self.body:getX) (self.body:getY) self.radius))

(fn update [self dt])

(fn new [world origin-x origin-y target-x target-y]
  (let [new-projectile {}
        radius 8
        body (love.physics.newBody world origin-x origin-y :dynamic)
        shape (love.physics.newCircleShape radius)
        fixture (love.physics.newFixture body shape)
        angle (math.atan2 (- target-y origin-y) (- target-x origin-x))
        vx (* speed (math.cos angle))
        vy (* speed (math.sin angle))]
    (fixture:setRestitution 1.0)
    (fixture:setSensor true)
    (fixture:setUserData new-projectile)
    (body:setMass 10)
    (body:setLinearVelocity vx vy)
    (doto new-projectile
      (tset :radius radius)
      (tset :body body)
      (tset :tag :projectile)
      (tset :shape shape)
      (tset :fixture fixture)
      (tset :draw draw)
      (tset :update update))
    new-projectile))

{: new}
