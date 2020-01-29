;; model of creation
;; Mar21Creation2.nlogo
;; new commands: wait, diffuse, max-one-of, min-one-of, scale-color

patches-own [ altitude ]
breed [cows cow]
breed [fishes fish]
breed [tortoises tortoise]

globals [
  season
  spring
  summer
  fall
  winter
]

;;beginning handler
to create-the-beginning
  clear-all
  clear-output  ;;clears output area
  reset-ticks
  ask patches [set altitude -1]
  cover-with-darkness
  output-print "The earth was a formless wasteland"
  make-mighty-wind
  cover-with-darkness
end

;make a mighty wind
to make-mighty-wind
  let time 0
  wait .5
  output-print "A mighty wind swept over the waters"
  ask patches [ set pcolor blue ]
  set time 0
  while [ time < 1000 ]
  [
    ifelse time mod 2 = 0
    [
      ask n-of 50 patches [ set pcolor white ]  ;50
    ]
    [
      ask patches [ set pcolor blue ]
    ]
    set time time + 1
  ]
end

;;first day
to create-the-first-day
  ifelse ticks mod 24 < 12 [
    cover-with-darkness
  ][
    make-there-light
  ]
  if ticks mod 24 = 0 [
    output-print "Thus evening came, and morning followed"
    output-print "The first day"
  ]
end

;;colr screen black
to cover-with-darkness
  ask patches [ set pcolor black ]
  tick
end

;;color screen light (yellow)
to make-there-light
  ask patches [ set pcolor yellow ]
  tick
end

;second day
to create-the-second-day
  output-print "Let there be a dome in the"
  output-print " middle of the waters, to separate"
  output-print " one body of water from the other."
  output-print "God called the dome the sky."
  create-turtles 1
  ask turtles [
    setxy 0 min-pycor
    set color blue
    set size 33
    set shape "circle"
  ]
end

;;third day
to create-the-third-day
  output-print "Let the water under the sky be"
  output-print " gathered into a single basin,"
  output-print " so that the dry land may appear."
  make-water-and-land
  ask patches with [is-beach?] [set pcolor brown + 2]
end

;;fourth day
to create-the-fourth-day
  output-print "Let the water teem with gold fish"
  make-water-creatures
end

;;fifth day
to create-the-fifth-day
  output-print "Let the beaches prosper with"
  output-print " turtles and let the cows"
  output-print " roam the open land"
  make-land-creatures
  make-amp-creatures
end

;;sixth day
to create-the-sixth-day
  output-print "Let there be different sizes of turtles"
  ask n-of (num-of-turtles / 2) tortoises [set size 2.5]
  ask tortoises with [size = 1.5] [set size 0.8]
end

;;seventh day
to create-the-seventh-day
  output-print "God rested from all his hard work"
  make-zs 3
  init-seasons
  reset-ticks
end

;;make num amount of Zs that move to off the screen
to make-zs [num]
  let i 0
  while [i < num] [
    ask patch 0 0 [
      sprout 1 [
        set shape "z"
        set color blue
        set heading 45
        while[xcor < max-pxcor and ycor < max-pycor] [
          forward 1
          set size size + .2
          wait .05
        ]
        die
      ]
    ]
    set i i + 1
  ]
end

;;eigth day
to create-the-eigth-day
  clear-output
  if season = spring [spring-move]
  if season = summer [summer-move]
  if season = fall [fall-move]
  if season = winter [winter-move]
  tick
  if (ticks mod 5 = 0) [set season season + 1]
  if season = 5 [set season spring]
end

;spring movement for the turtles
to spring-move
  output-print "Spring has sprung letting"
  output-print " the turtles swim anywhere"
  ask tortoises [turtles-swim-anywhere]

end

;summer movement for the turtles
to summer-move
  output-print "Summer is here letting"
  output-print " the turtles still swim anywhere"
  ask tortoises [turtles-swim-anywhere]
  make-natural-disaster
end

; chance of wildfire killing the land animals
; for everyday in summer;
to make-natural-disaster
  if natural-disaster-mode? [
    let rand random 10
    if (rand > 6) [
      output-print "A wildfire has started! It kills all the cows"
      create-turtles 300 [
        set shape "fire"
        set color orange
      ]
      create-turtles 300 [
        set shape "fire"
        set color yellow
      ]
      create-turtles 300 [
        set shape "fire"
        set color red
      ]
      ask turtles with [ shape = "fire" ] [
        set size random-float 1 + 1
        set heading random 360
      ]
      let spd 8; vary the speed of the flames as the move along
      while [spd > .1] [
        ask turtles with [ shape = "fire" ] [
          right 4
          forward spd * (random-float 2.2 - .5) ; Sometimes the flames travel backwards, which spreads out the flames decently
        ]
        set spd (spd / 1.2 ) ; The flames slow down every frame
        wait .05
      ]
      ask turtles with [shape = "fire" or shape = "cow"] [die]
    ]
  ]
end

;fall movement for the turtles
to fall-move
  output-print "Fall is here making the"
  output-print " small turtles head"
  output-print " back to shallow waters"
  big-turtles-swim-deep
  small-turtles-move
end

;winter movement for the turtles
to winter-move
  output-print "Winter is here and the"
  output-print " large turtles may swim"
  output-print " in the deep water"
  big-turtles-swim-deep
  small-turtles-move
end

; movement for small turtles in cold weather
to small-turtles-move
  ask tortoises with [size = 0.8 and is-beach?] [
    let target-patch min-one-of patches in-radius 25 with [is-beach? and (distance myself > 1)] [distance myself]
    move-to target-patch
  ]
  ask tortoises with [size = 0.8 and not is-beach?] [
    let target-patch min-one-of patches in-radius 25 with [is-shallow-water? and (distance myself > 1)] [distance myself]
    move-to target-patch
  ]
end

; movement for big turtles in cold weather
to big-turtles-swim-deep
  ask tortoises with [size = 2.5] [
    let target-patch min-one-of patches in-radius 25 with [is-deep-water? and (distance myself > 1)] [distance myself]
    move-to target-patch
  ]
end

; movement for turtles in warm weather
to turtles-swim-anywhere
  let target-patch min-one-of patches in-radius 25 with [is-water? and (distance myself > 1)] [distance myself]
  move-to target-patch
end

;;make cows
to make-land-creatures
  ask n-of num-of-cows patches with [is-land?] [sprout-cows 1 [
    set shape "cow"
    set color brown
    set size 1.5
  ]]
end

;;make fish
to make-water-creatures
  ask n-of num-of-fish patches with [is-water?] [sprout-fishes 1 [
    set shape "fish"
    set color yellow
    set size 1.5
  ]]
end

;;make turtles
to make-amp-creatures
  ask n-of num-of-turtles patches with [is-beach?] [sprout-tortoises 1 [
    set shape "turtle"
    set color green
    set size 1.5
  ]]
end

;;create 3 patches of land
to make-water-and-land
  ask turtles [ die ]
  repeat 3 [
    ask patch random-xcor random-ycor [
      set altitude 100.0 + random-float 50.0
      ;show altitude
    ]
  ]
  repeat 100 [ diffuse altitude 0.25 ]  ;100
  spread-out-water-and-land
  color-the-world
  ;ask patches [ show altitude ]
end

;inialize the seasons and set the current to spring
to init-seasons
  set spring 1
  set summer 2
  set fall 3
  set winter 4
  set season spring
end

;returns true if the patch is land
; else false
to-report is-land?
  report altitude > 20
end

;returns true if the patch is beach
; else false
to-report is-beach?
  report altitude > -10 and altitude < 20
end

;returns true if the patch is water
; else false
to-report is-water?
  report altitude < -10
end

;returns true if the patch is shallow water
; else false
to-report is-shallow-water?
  report altitude > -30
end

;returns true if the patch is deep water
; else false
to-report is-deep-water?
  report altitude < -200
end



;;spread altitudes from input of 100 to 150 and map to a range from -500 to +500
;;From: http://stackoverflow.com/questions/5731863/mapping-a-numeric-range-onto-another
;First, if we want to map input numbers in the range [0, x] to output range [0, y], we just need to scale by an appropriate amount. 0 goes to 0, x goes to y, and a number t will go to (y/x)*t.
;So, let's reduce your problem to the above simpler problem.
;An input range of [input_start, input_end] has input_end - input_start + 1 numbers. So it's equivalent to a range of [0, r], where r = input_end - input_start.
;Similarly, the output range is equivalent to [0, R], where R = output_end - output_start.
;An input of input is equivalent to x = input - input_start. This, from the first paragraph will translate to y = (R/r)*x. Then, we can translate the y value back to the original output range by adding output_start: output = output_start + y.
;This gives us:
;output = output_start + ((output_end - output_start) / (input_end - input_start)) * (input - input_start)
;Or, another way:
;
;Note, "slope" below is a constant for given numbers, so if you are calculating
;   a lot of output values, it makes sense to calculate it once.  It also makes
;   understanding the code easier
;slope = (output_end - output_start) / (input_end - input_start)
;output = output_start + slope * (input - input_start)

to spread-out-water-and-land
  let highest [ altitude ] of max-one-of patches [ altitude ]
  let lowest  [ altitude ] of min-one-of patches [ altitude ]
  let slope 1000 / (highest - lowest)
  ask patches [
    set altitude 500 + slope * (altitude - highest)
  ;show slope
  ;show altitude
  ]
end

;;set water to blue and land to varying colors of green
to color-the-world
  let highest [ altitude ] of max-one-of patches [ altitude ]
  let lowest  [ altitude ] of min-one-of patches [ altitude ]
  ask patches [
    ifelse altitude < 0
    [
      set pcolor scale-color blue altitude lowest (-(lowest / 2))
    ]
    [
    set pcolor scale-color green altitude 0 (highest * 1.5)
    ]
  ]
end
@#$#@#$#@
GRAPHICS-WINDOW
210
10
985
630
-1
-1
13.0
1
10
1
1
1
0
0
0
1
-29
29
-23
23
0
0
1
ticks
1.0

BUTTON
41
19
161
53
in the beginning
create-the-beginning
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

OUTPUT
998
10
1832
627
32

BUTTON
42
61
160
95
the first day
create-the-first-day
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
43
103
161
137
the second day
create-the-second-day
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
44
146
160
179
the third day
create-the-third-day
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
45
189
159
222
the fourth day
create-the-fourth-day
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
67
597
141
630
clear all
clear-all
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
46
231
158
264
the fifth day
create-the-fifth-day
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
47
273
160
306
the sixth day
create-the-sixth-day
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
17
399
189
432
num-of-turtles
num-of-turtles
1
count patches with [is-beach?]
4.0
1
1
turtles
HORIZONTAL

SLIDER
17
442
189
475
num-of-cows
num-of-cows
1
count patches with [is-land?]
8.0
1
1
cows
HORIZONTAL

SLIDER
18
486
190
519
num-of-fish
num-of-fish
1
20
4.0
1
1
fish
HORIZONTAL

BUTTON
45
315
160
348
the seventh day
create-the-seventh-day
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
46
355
161
388
the eigth day
create-the-eigth-day
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SWITCH
19
527
203
560
natural-disaster-mode?
natural-disaster-mode?
0
1
-1000

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fire
false
0
Polygon -7500403 true true 151 286 134 282 103 282 59 248 40 210 32 157 37 108 68 146 71 109 83 72 111 27 127 55 148 11 167 41 180 112 195 57 217 91 226 126 227 203 256 156 256 201 238 263 213 278 183 281
Polygon -955883 true false 126 284 91 251 85 212 91 168 103 132 118 153 125 181 135 141 151 96 185 161 195 203 193 253 164 286
Polygon -2674135 true false 155 284 172 268 172 243 162 224 148 201 130 233 131 260 135 282

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270

z
false
0
Polygon -7500403 true true 60 60 60 90 180 90 60 210 60 240 240 240 240 210 120 210 240 90 240 60 60 60 45 15
@#$#@#$#@
NetLogo 6.0.4
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
