(local lg love.graphics)

(local projectile {})

(fn draw [self]
  (lg.circle :fill (self.body:getX) (self.body:getY) self.radius))

(fn update [dt])

(fn new [world origin-x origin-y target-x target-y]
  (let [radius 10
        body (love.physics.newBody world origin-x origin-y :static)
        shape (love.physics.newCircleShape radius)
        fixture (love.physics.newFixture body shape)]
    (fixture:setRestitution 1.0)
    (body:setMass 10)
    (body:setLinearVelocity 300 300)
    {:radius radius
     :body body
     :shape shape
     :fixture fixture
     :draw draw
     :update update}))

{: new}
