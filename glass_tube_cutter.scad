/**
Glass bottle/tube thermal shock cutter, derived from https://www.youtube.com/watch?v=Gdn8ix2_LdE

Note that some of this assumes you're taking a brick BRICK_SY in length,
and cutting it into two pieces differing in length by BRICK_SZ, so you can
make a corner out of them and have it be symmetrical.

Run get_deps.sh to clone dependencies into a linked folder in your home directory.
*/

use <deps.link/BOSL/nema_steppers.scad>
use <deps.link/BOSL/joiners.scad>
use <deps.link/BOSL/shapes.scad>
use <deps.link/erhannisScad/misc.scad>
use <deps.link/erhannisScad/auto_lid.scad>
use <deps.link/scadFluidics/common.scad>
use <deps.link/quickfitPlate/blank_plate.scad>
use <deps.link/getriebe/Getriebe.scad>
use <deps.link/gearbox/gearbox.scad>

$FOREVER = 1000;
$EPS=1e-2;
DUMMY = false;
$fn = DUMMY ? 10 : 60;

INCH = 25.4;

BRICK_SX = 4.5*INCH;
BRICK_SY = 9*INCH;
BRICK_SZ = 1.25*INCH;

SWITCH_S_WIDTH = 10.3;
SWITCH_S_TALL = 28.5;
SWITCH_S_DEEP = 3.5;

DIMMER_SX = 85.2;
DIMMER_SY = 58.2;
DIMMER_SZ = 38;
DIMMER_HOLE_DX = 77;
DIMMER_HOLE_DY = 47.6;
DIMMER_HOLE_INSET_X = 3.5;
DIMMER_HOLE_INSET_Y = 4.5;
DIMMER_HOLE_D_OUTER = 3.2;
DIMMER_HOLE_D = 2.5;

HOLDER_T = 15;
HOLDER_BRICK_OVERHANG = BRICK_SZ*0.75; // Arbitrary, proportional
HOLDER_STEM_T = 40;
HOLDER_STEM_L = 40;
HOLDER_STEM_PASSTHROUGH_D = 20;


// Ooh, I might have to bust out my treadmill printer for this.  I guess you could split the base into the holder and the rotator.
// You could also like, add holes that run lengthwise, and jam dowels down them to attach multiple segments.
BASE_SX = 400;
BASE_SY = 200;
BASE_SZ = 15;

SWITCH_MARGIN = 25;
SWITCH_SETBACK = 10;
SWITCH_HOUSING_T = 5;
SWITCH_LATCH_LEEWAY = 5;
SWITCH_ELEVATION = SWITCH_S_TALL+10;

X_SLIDE_SY = 100;

X_SLIDE_GUIDE_T = 10;
X_SLIDE_GUIDE_SZ = 10;
X_SLIDE_GUIDE_L = BASE_SX - (2*HOLDER_STEM_T+BRICK_SX);

X_SLIDE_TRACK_T = 6;
X_SLIDE_TRACK_MARGIN = 10+X_SLIDE_TRACK_T/2;

module cableTie(t=4,d=10,h=$FOREVER) {
  translate([-t/2,-(d+t)/2,0]) {
    ctranslate([0,d,0]) cube([t,t,h]);
    cube([t,d+t,t]);
  }
}

// Currently abt 147mm tall
//translate([0,0,BASE_SZ])
difference() {
union() {

/*
Todo:
Rotation mechanism
  Slide up/down
  Slide forward/backward
  Flag for bearing OR just a hole
  Motor vs crank - I'll probably just use a crank until that gets too obnoxious or doesn't work
*/

// Base
difference() {
  union() {
    translate([BRICK_SX+HOLDER_T-BASE_SX/2,0,-BASE_SZ/2]) cube([BASE_SX, BASE_SY, BASE_SZ], center=true);
  }
  
  // Dimmer holes
  translate([BRICK_SX+HOLDER_T-DIMMER_SX,-DIMMER_SY-HOLDER_STEM_T,0]) // Dimmer corner
  translate([DIMMER_HOLE_INSET_X, DIMMER_HOLE_INSET_Y, 0]) // Holes inset
  for (p = [[0,0,0],[DIMMER_HOLE_DX,DIMMER_HOLE_DY,0]]) {
    mz() translate(p) cylinder(d=DIMMER_HOLE_D,h=$FOREVER);
  }
  
  // X-slide track
  minkowski() {
    tx(BRICK_SX+HOLDER_T-BASE_SX) {
      tz(-BASE_SZ/2) cylinder(d=X_SLIDE_TRACK_T, h=BASE_SZ/2+$EPS);
      tz(-BASE_SZ-0.5) cylinder(d=2*X_SLIDE_TRACK_T, h=BASE_SZ/2+1);
    }
    tx(X_SLIDE_TRACK_MARGIN) cube([X_SLIDE_GUIDE_L-2*X_SLIDE_TRACK_MARGIN,$EPS,$EPS]);
  }
  
  // Misc cable tie holes
  translate([BRICK_SX+HOLDER_T,-HOLDER_STEM_T/2,-BASE_SZ])
    ctranslate([
      [-7,-10,0],
      [-17,-10,0],
      [-DIMMER_SX-4,-10,0],
      [-DIMMER_SX-14,-10,0],
      ])
    mx() my() cableTie();
  translate([BRICK_SX+HOLDER_T,HOLDER_STEM_T/2,-BASE_SZ])
    ctranslate([
      [-7,10,0],
      [-17,10,0],
      [-(BRICK_SX+2*HOLDER_T)/2+5,10,0],
      [-(BRICK_SX+2*HOLDER_T)/2-5,10,0],
      ])
    mx() cableTie();
}

// X-slide guides
cmirror([0,1,0]) ty(X_SLIDE_SY/2) tx(BRICK_SX+HOLDER_T-BASE_SX) cube([X_SLIDE_GUIDE_L, X_SLIDE_GUIDE_T, X_SLIDE_GUIDE_SZ]);

// Dimmer (do not print)
if ($preview) {
  color("RED") translate([BRICK_SX+HOLDER_T-DIMMER_SX,-DIMMER_SY-HOLDER_STEM_T,0]) cube([DIMMER_SX,DIMMER_SY,DIMMER_SZ]);
}

// Switch (do not print)
if ($preview) {
  color("RED")
  translate([0,SWITCH_SETBACK,SWITCH_ELEVATION])
  translate([BRICK_SX+HOLDER_T-DIMMER_SX-SWITCH_S_WIDTH-SWITCH_MARGIN,-DIMMER_SY-HOLDER_STEM_T,0])
  rx(45)
  cube([SWITCH_S_WIDTH,SWITCH_S_TALL,SWITCH_S_DEEP]);
}

HOUSING_SZ = SWITCH_S_TALL+2*SWITCH_LATCH_LEEWAY+2*SWITCH_HOUSING_T;

// Switch holder
// I'm probably going to regret making this symmetrical at the cost of easy access
translate([0,SWITCH_SETBACK,SWITCH_ELEVATION])
  translate([BRICK_SX+HOLDER_T-DIMMER_SX-SWITCH_S_WIDTH-SWITCH_MARGIN,-DIMMER_SY-HOLDER_STEM_T,0])
  rx(45)
  difference() {
  union() {
    translate([-SWITCH_HOUSING_T,-SWITCH_HOUSING_T-SWITCH_LATCH_LEEWAY,-HOUSING_SZ+SWITCH_S_DEEP])
      cube([SWITCH_S_WIDTH+2*SWITCH_HOUSING_T, HOUSING_SZ, HOUSING_SZ]);
    SWITCH_CENTER_Z = frotate([45,0,0],[0,-(HOUSING_SZ-SWITCH_S_TALL)/2,SWITCH_S_DEEP])[2]+SWITCH_ELEVATION;
    translate([0,-(HOUSING_SZ-SWITCH_S_TALL)/2,SWITCH_S_DEEP])
      rx(-45)
      tz(-SWITCH_CENTER_Z)
      tx(-SWITCH_HOUSING_T) cube([SWITCH_S_WIDTH+2*SWITCH_HOUSING_T, HOUSING_SZ*sqrt(2),SWITCH_CENTER_Z]);
  }
  ty(-SWITCH_LATCH_LEEWAY) tz(-$FOREVER) cube([SWITCH_S_WIDTH, SWITCH_S_TALL+2*SWITCH_LATCH_LEEWAY, $FOREVER]);
  tz(-$FOREVER/2) cube([SWITCH_S_WIDTH, SWITCH_S_TALL, $FOREVER]);
}

// Brick holder
difference() {
  HOLDER_L = (BRICK_SY-BRICK_SZ)/2+BRICK_SZ+HOLDER_T-HOLDER_BRICK_OVERHANG;
  tz(HOLDER_STEM_L) rx(45)
  difference() {
    union() {    
      // Y
      cmirror([0,-1,1]) translate([-HOLDER_T, -HOLDER_T, -HOLDER_T]) cube([BRICK_SX+2*HOLDER_T, HOLDER_L, HOLDER_T+BRICK_SZ/2]);
      
      // Stem
      rx(45) translate([-HOLDER_T, -HOLDER_STEM_L, -HOLDER_STEM_T/2]) cube([BRICK_SX+2*HOLDER_T, HOLDER_STEM_L, HOLDER_STEM_T]);
    }
    cube([BRICK_SX, $FOREVER, $FOREVER]);
    
    // Cable ties
    cmirror([0,-1,1]) mz()
      ctranslate([
        [BRICK_SX/2,HOLDER_L*0.5,0],
        [BRICK_SX/2,HOLDER_L-HOLDER_T-10,0],
        ])
      rz(90) cableTie();
  }
  
  // Filament tiedown wire holes
  // Vertical position is a bit hand-wavey
  FILAMENT_TIEDOWN_D = 4;
  cmirror([1,0,0],[BRICK_SX/2,0,0]) translate([-FILAMENT_TIEDOWN_D,0,HOLDER_STEM_L-HOLDER_T*0.34755]) tx(BRICK_SX+HOLDER_T) {
    // Crossways
    mx() ty(-$FOREVER/2) cube([FILAMENT_TIEDOWN_D,$FOREVER,FILAMENT_TIEDOWN_D]);
    
    // Center tap
    rz(-90) tx(-FILAMENT_TIEDOWN_D/2) cube([FILAMENT_TIEDOWN_D,$FOREVER,FILAMENT_TIEDOWN_D]);
  }
  
  // Passthrough
  tx(-HOLDER_STEM_PASSTHROUGH_D/2+BRICK_SX/2) ty(-$FOREVER/2) cube([HOLDER_STEM_PASSTHROUGH_D,$FOREVER,HOLDER_STEM_PASSTHROUGH_D]);
}

// Bricks (do not print)
if ($preview) {
  tz(HOLDER_STEM_L) my() rx(45) {
    color("RED") cube([BRICK_SX,(BRICK_SY-BRICK_SZ)/2+BRICK_SZ,BRICK_SZ]);
    color("GREEN") rx(90) mz() ty(BRICK_SZ) cube([BRICK_SX,(BRICK_SY-BRICK_SZ)/2,BRICK_SZ]);
  }
}

  
}
//OXm([15,0,0]);
}

//cube([BRICK_SX,BRICK_SY,BRICK_SZ]);