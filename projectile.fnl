(local lg love.graphics)

(local projectile {})

(fn draw [self]
  (lg.circle :fill (self.body:getX) (self.body:getY) self.radius))

(fn update [self dt]
  (print "I'm a projectile!"))

(fn new [world origin-x origin-y target-x target-y]
  (let [radius 20
        body (love.physics.newBody world origin-x origin-y :dynamic)
        shape (love.physics.newCircleShape radius)
        fixture (love.physics.newFixture body shape)]
    (fixture:setRestitution 1.0)
    (body:setMass 10)
    (body:setLinearVelocity 30 30)
    {:radius radius
     :body body
     :tag :projectile
     :shape shape
     :fixture fixture
     :draw draw
     :update update}))

{: new}
