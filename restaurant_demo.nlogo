


globals [
  customers-served
  customers-made
  customers-lost
  busy-time ;; normal time = 1, busy time = 2, slow time = 3
  total-wait-time
  happy-customers
  neutral-customers
  sad-customers
]

breed [chefs chef]
breed [customers customer]

customers-own [
  is-eating?
  time-eating
  time-waiting
  happy-level ;; 0-30 = sad, 31-70 = neutral, 71-100 = happy
]

;; set up the environment
to setup
  clear-all
  init-values
  ask patches [
    set pcolor brown - 2
    if is-door? [
      sprout 1 [
        set shape "tile brick"
        set color red - 3
        stamp
        die
      ]
    ]
  ]
  make-kitchen
  make-chefs
end

;; intialize global variables
to init-values
  reset-ticks
  set customers-served 0
  set customers-made 0
  set customers-lost 0
  set total-wait-time 0
  set busy-time 1
  set happy-customers 0
  set neutral-customers 0
  set sad-customers 0
end

;; start the model
to go
  new-customers
  move-customers
  move-chefs
  customers-eat
  update-happy-level
  if customers-served >= number-of-customers [
    ask customers [die]
    clear-output
    output-print "Day over!"
    stop
  ]
  tick
  display-label
end

;; updates the happy levels of the customers
to update-happy-level
  ask customers [
    if happy-level <= 30 [
      set shape "face sad"
      set color red
    ]
    if happy-level > 30 and happy-level <= 70 [
      set shape "face neutral"
      set color yellow
    ]
    if happy-level > 70 [
      set shape "face happy"
      set color lime
    ]
    if happy-level < 0 [
      set customers-served customers-served + 1
      set total-wait-time total-wait-time + time-waiting
      set customers-lost customers-lost + 1
      set sad-customers sad-customers + 1
      die
    ]
  ]
end

;; make the kitchen for the chefs
to make-kitchen
  ask patches with [is-kitchen? pycor] [set pcolor grey]
  make-block (gray - 1) -6 4 13 3
end

;; make a table
to make-table
  if (not is-kitchen? mouse-ycor) and mouse-down? [
    make-block green mouse-xcor mouse-ycor 1 1
  ]
end

;; erase any table
to eraser
  if (not is-kitchen? mouse-ycor) and mouse-down? [
    make-block (brown - 2) mouse-xcor mouse-ycor 1 1
  ]
end

;; make a block of any size and color
to make-block [block-color x-cor y-cor width height]
  let i 0
  while [i < height] [
    let j 0
    while [j < width] [
      ask patch (x-cor + j) (y-cor + i) [set pcolor block-color]
      set j j + 1
    ]
    set i i + 1
  ]
end

;; customers eat based on how many chefs are present
to customers-eat
  ask customers with [is-eating?] [
    set time-eating time-eating + 1
    if time-eating > (13 - number-of-chefs) [
      set customers-served customers-served + 1
      if shape = "face happy" [set happy-customers happy-customers + 1]
      if shape = "face neutral" [set neutral-customers neutral-customers + 1]
      if shape = "face sad" [set sad-customers sad-customers + 1]
      die
    ]
  ]
end

;; move the customers around the floor
to move-customers
  ask customers with [not is-eating?] [
    let open-table find-open-table
    ifelse not (open-table = nobody) [
      ifelse is-open-table? [ ;; already on an open table
        set total-wait-time total-wait-time + time-waiting
        set is-eating? true
        set happy-level happy-level + happiness-from-food
      ]
      [ ;; else move towards closest open table
        set heading towards open-table
        forward 1
      ]

    ]
    [ ;; else no open table found, wander
      right random 100 - 50
      if is-off-course? [set heading towards patch 0 -3]
      forward 1
    ]
    set time-waiting time-waiting + 1
    set happy-level happy-level - 1
  ]
end

;; move the chefs around the kitchen
to move-chefs
  ask chefs [
    let open-spot min-one-of patches with [is-kitchen? pycor and count turtles-here < 1] [distance myself]
    set heading towards open-spot
    forward 1
  ]
end

;; returns an open table within radius of 6
to-report find-open-table
  report min-one-of patches in-radius 6 with [pcolor = green and (count turtles-here = 0)] [distance myself]
end

;; returns if the table is open
to-report is-open-table?
  report (pcolor = green and count turtles-here = 1)
end

;; make new customers based on the time
to new-customers
  clear-output
  if busy-time = 1 [make-customers 3 output-print "normal time"]
  if busy-time = 2 [make-customers 1 output-print "busy time!"]
  if busy-time = 3 [make-customers 6 output-print "slow time"]
  if ticks mod 24 = 0 [
    set busy-time busy-time + 1
    if busy-time >= 4 [ set busy-time 1]
  ]
end

;; make new customers based on the delay
to make-customers [delay]
  if (number-of-customers >= customers-made) and (ticks mod delay = 0) [
    ask n-of 1 patches with [is-door?] [
      sprout-customers 1 [
        set shape "face neutral"
        set color yellow
        set is-eating? false
        set time-eating 0
        set time-waiting 0
        set happy-level 70
      ]
    ]
    set customers-made customers-made + 1
  ]
end

;; make chefs in the kitchen
to make-chefs
    ask n-of number-of-chefs patches with [is-kitchen? pycor] [
      sprout-chefs 1 [
        set shape "chef"
      ]
    ]
end

;; display happy level labels on the customers
to display-label
  ask customers [
    ifelse not show-happiness-level?
    [set label ""]
    [set label happy-level] ;; else show label
  ]
end

;; returns if the patch is part of the door
to-report is-door?
  report (pycor = -7) and (pxcor = 1 or pxcor = 0 or pxcor = -1)
end

;; returns if the customer is stuck in a corner
to-report is-off-course?
  report (abs ycor = max-pycor) or (abs xcor = max-pxcor) or (is-kitchen? ycor)
end

;; returns if the y-cor is in the kitchen
to-report is-kitchen? [y-cor]
  report y-cor > max-pycor - 5
end
@#$#@#$#@
GRAPHICS-WINDOW
210
15
663
469
-1
-1
29.7
1
10
1
1
1
0
0
0
1
-7
7
-7
7
0
0
1
ticks
30.0

BUTTON
55
45
140
78
NIL
setup\n
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
55
125
140
158
NIL
make-table
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
55
165
140
198
NIL
eraser
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
15
280
185
313
number-of-customers
number-of-customers
1
100
58.0
1
1
NIL
HORIZONTAL

SLIDER
15
320
185
353
number-of-chefs
number-of-chefs
1
10
8.0
1
1
NIL
HORIZONTAL

MONITOR
675
85
825
130
number of customers lost
customers-lost
17
1
11

BUTTON
55
205
140
238
NIL
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

OUTPUT
675
275
825
325
16

MONITOR
675
135
825
180
number of tables
count patches with [pcolor = green]
17
1
11

BUTTON
55
85
140
118
reset
init-values\nask customers [die]
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

MONITOR
675
185
825
230
time
ticks
17
1
11

MONITOR
890
180
995
225
average wait time
total-wait-time / customers-served
2
1
11

SLIDER
15
360
185
393
happiness-from-food
happiness-from-food
50
75
50.0
1
1
NIL
HORIZONTAL

MONITOR
890
30
995
75
NIL
happy-customers
17
1
11

MONITOR
890
80
995
125
NIL
neutral-customers
17
1
11

MONITOR
890
130
995
175
NIL
sad-customers
17
1
11

MONITOR
675
35
825
80
current number of customers
count customers
0
1
11

SWITCH
15
400
185
433
show-happiness-level?
show-happiness-level?
1
1
-1000

TEXTBOX
905
10
985
41
End of day:
14
0.0
1

TEXTBOX
710
255
795
273
Time of day:
14
0.0
1

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

chef
false
0
Polygon -7500403 true true 105 105 60 165 75 180 135 120
Polygon -7500403 true true 195 105 240 165 225 180 165 120
Circle -7500403 true true 120 45 60
Polygon -1 true false 105 105 120 210 120 255 105 300 135 300 150 225 165 300 195 300 180 255 180 210 195 105
Rectangle -7500403 true true 135 94 165 105
Rectangle -1 true false 120 0 180 60
Polygon -7500403 true true 120 210 120 210 120 255 105 300 135 300 150 225 165 300 195 300 180 255 180 210 180 210

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

person farmer
false
0
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Polygon -1 true false 60 195 90 210 114 154 120 195 180 195 187 157 210 210 240 195 195 90 165 90 150 105 150 150 135 90 105 90
Circle -7500403 true true 110 5 80
Rectangle -7500403 true true 127 79 172 94
Polygon -13345367 true false 120 90 120 180 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 180 90 172 89 165 135 135 135 127 90
Polygon -6459832 true false 116 4 113 21 71 33 71 40 109 48 117 34 144 27 180 26 188 36 224 23 222 14 178 16 167 0
Line -16777216 false 225 90 270 90
Line -16777216 false 225 15 225 90
Line -16777216 false 270 15 270 90
Line -16777216 false 247 15 247 90
Rectangle -6459832 true false 240 90 255 300

person service
false
0
Polygon -7500403 true true 180 195 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285
Polygon -1 true false 120 90 105 90 60 195 90 210 120 150 120 195 180 195 180 150 210 210 240 195 195 90 180 90 165 105 150 165 135 105 120 90
Polygon -1 true false 123 90 149 141 177 90
Rectangle -7500403 true true 123 76 176 92
Circle -7500403 true true 110 5 80
Line -13345367 false 121 90 194 90
Line -16777216 false 148 143 150 196
Rectangle -16777216 true false 116 186 182 198
Circle -1 true false 152 143 9
Circle -1 true false 152 166 9
Rectangle -16777216 true false 179 164 183 186
Polygon -2674135 true false 180 90 195 90 183 160 180 195 150 195 150 135 180 90
Polygon -2674135 true false 120 90 105 90 114 161 120 195 150 195 150 135 120 90
Polygon -2674135 true false 155 91 128 77 128 101
Rectangle -16777216 true false 118 129 141 140
Polygon -2674135 true false 145 91 172 77 172 101

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

tile brick
false
0
Rectangle -1 true false 0 0 300 300
Rectangle -7500403 true true 15 225 150 285
Rectangle -7500403 true true 165 225 300 285
Rectangle -7500403 true true 75 150 210 210
Rectangle -7500403 true true 0 150 60 210
Rectangle -7500403 true true 225 150 300 210
Rectangle -7500403 true true 165 75 300 135
Rectangle -7500403 true true 15 75 150 135
Rectangle -7500403 true true 0 0 60 60
Rectangle -7500403 true true 225 0 300 60
Rectangle -7500403 true true 75 0 210 60

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
1
@#$#@#$#@
