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

BASE_SX = 400; // Ooh, I might have to bust out my treadmill printer for this.  I guess you could split the base into the holder and the rotator.
BASE_SY = 200;
BASE_SZ = 30;
echo(BRICK_SY);

// Currently abt 162mm tall
//translate([0,0,BASE_SZ])
{

/*
Todo:
Cable tie-down holes
Base
Switch mount
Dimmer mount
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
color("RED") translate([BRICK_SX+HOLDER_T-DIMMER_SX,-DIMMER_SY-HOLDER_STEM_T,0]) cube([DIMMER_SX,DIMMER_SY,DIMMER_SZ]);

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