/**
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

HOLDER_STEM_T = 40;
HOLDER_STEM_L = 40;

// Ooh, I might have to bust out my treadmill printer for this.  I guess you could split the base into the holder and the rotator.
// You could also like, add holes that run lengthwise, and jam dowels down them to attach multiple segments.
BASE_SX = 400;
BASE_SY = 200;
BASE_SZ = 30;
echo(BRICK_SY);

// Currently abt 162mm tall
//translate([0,0,BASE_SZ])
difference() {
union() {

/*
Todo:
Cable tie-down holes
Switch mount
Rotation mechanism
  Slide up/down
  Slide forward/backward
  Flag for bearing OR just a hole
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
}

// Dimmer //DUMMY Remove
if ($preview) {
  color("RED") translate([BRICK_SX+HOLDER_T-DIMMER_SX,-DIMMER_SY-HOLDER_STEM_T,0]) cube([DIMMER_SX,DIMMER_SY,DIMMER_SZ]);
}

// Switch //DUMMY Remove
SWITCH_MARGIN = 25;
SWITCH_SETBACK = 10;
SWITCH_HOUSING_T = 5;
SWITCH_LATCH_LEEWAY = 5;
SWITCH_ELEVATION = SWITCH_S_TALL+10;
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
tz(HOLDER_STEM_L) rx(45)
difference() {
  union() {
    cmirror([0,-1,1]) translate([-HOLDER_T, -HOLDER_T, -HOLDER_T]) cube([BRICK_SX+2*HOLDER_T, BRICK_SY/2+HOLDER_T, HOLDER_T+BRICK_SZ/2]);
    rx(45) translate([-HOLDER_T, -HOLDER_STEM_L, -HOLDER_STEM_T/2]) cube([BRICK_SX+2*HOLDER_T, HOLDER_STEM_L, HOLDER_STEM_T]);
  }
  cube([BRICK_SX, $FOREVER, $FOREVER]);
}

}
//OXm([15,0,0]);
}