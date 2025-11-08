(var assets {})

(fn assets.load-assets []
  (set assets.font (love.graphics.newImageFont :assets/imagefont.png
                                               (.. " abcdefghijklmnopqrstuvwxyz"
                                                   :ABCDEFGHIJKLMNOPQRSTUVWXYZ0
                                                   "123456789.,!?-+/():;%&`'*#=[]\"")))
  (set assets.explosion-sound (love.audio.newSource :assets/explosion.wav :static))
  (set assets.hit-hurt-sound (love.audio.newSource :assets/hitHurt.wav :static))
  (set assets.laser-sound (love.audio.newSource :assets/laser.wav :static)))

assets
