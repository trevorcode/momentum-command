(var assets {})

(var horizontal-glow-shader-code
     "
extern vec2 stepSize; 

vec4 effect(vec4 color, Image texture, vec2 uv, vec2 screenCoords) {
    vec4 pixel = Texel(texture, uv);

    for (int i = -40; i <= 40; i++) {
        pixel += Texel(texture, uv + vec2(stepSize.x * float(i), 0.0));
    }

    return pixel / 41.0;
}
")

(var vertical-glow-shader-code
     "
extern vec2 stepSize; 

vec4 effect(vec4 color, Image texture, vec2 uv, vec2 screenCoords) {
    vec4 pixel = Texel(texture, uv);

    for (int i = -40; i <= 40; i++) {
        pixel += Texel(texture, uv + vec2(0.0, stepSize.y * float(i)));
    }

    return pixel / 41.0;
}
")

(fn assets.load-assets []
  (set assets.glow-shader-x (love.graphics.newShader horizontal-glow-shader-code))
  (set assets.glow-shader-y (love.graphics.newShader vertical-glow-shader-code))
  (set assets.font (love.graphics.newImageFont :assets/imagefont.png
                                               (.. " abcdefghijklmnopqrstuvwxyz"
                                                   :ABCDEFGHIJKLMNOPQRSTUVWXYZ0
                                                   "123456789.,!?-+/():;%&`'*#=[]\"")))
  (set assets.bg-music (love.audio.newSource "assets/ERH BlueBeat 01 [loop].ogg" :static))
  (set assets.explosion-sound (love.audio.newSource :assets/explosion.wav :static))
  (set assets.hit-hurt-sound (love.audio.newSource :assets/hitHurt.wav :static))
  (set assets.laser-sound (love.audio.newSource :assets/laser.wav :static))
  (set assets.paddlehurt-sound (love.audio.newSource :assets/paddlehurt.wav :static))
  (set assets.heart (love.graphics.newImage :assets/heart.png))
  (assets.heart:setFilter "nearest" "nearest"))

assets
