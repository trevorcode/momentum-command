(local push (require :lib.push))

(fn vector-length [[vx vy]]
  (math.sqrt (+ (^ vx 2) (^ vy 2))))

(fn vector-normalize [[vx vy]]
  (let [len (vector-length [vx vy])
        new-vx (/ vx len)
        new-vy (/ vy len)]
    [new-vx new-vy]))

(fn vector-scale [[x y] mag]
  [(* x mag) (* y mag)])

(fn vector-rotate [[vx vy] rad]
  [(- (* vx (math.cos rad)) (* vy (math.sin rad)))
   (+ (* vx (math.sin rad)) (* vy (math.cos rad)))])

(fn point-within? [point boundingBox]
  (if (and point boundingBox)
      (let [{: x : y} point
            {:x x2 :y y2 : width : height} boundingBox]
        (and width height x2 y2 x y (<= x2 x (+ width x2))
             (<= y2 y (+ height y2))))
      false))

(fn cursor-position []
  (push:toGame (love.mouse.getPosition)))

(fn cursor-within? [boundingBox]
  (let [(x y) (cursor-position)
        point {: x : y}]
    (point-within? point boundingBox)))

{: point-within? : cursor-within? : cursor-position : vector-length : vector-scale : vector-normalize : vector-rotate }
