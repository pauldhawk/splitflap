# SF design

This design will all live in the 3d/redesign folder. examples of each part will be stored in ???? this unit will connect to other units from its left right top and bottom

## requiments

1. variable amount of flaps on the drum
1. varible size of drum
1. other units must be able to connect to the top, bottom, left and right

## open questions

1. hot to orgaize the folder / files
1. what open source libs to use
1. what to use to connect the parts (ie screw / nut, glue, screw with heat set inserts)
1. what constants to use
1. where can i find the stepper motor
1. how to connect other units to it
1. size of the gears.
1. where to storre the example parts to use as a template.
1. what file format should be used for the example parts

## later questions

1. where the pcbs will live
1. how todo wire managemnt (will firgure out after the pcs / wires are figured out)
1. size of the front opening on top and bottom needed to hold the flaps up that are being displaysed

## Parts

### Nema 17 Stepper Motor

this will be behind the drum need to find an online model. does BOSL2 or MCAD have one?

### Motor mounnt

holds the stepper motor. screws into the face

### Gears

- a gear that connects to the Stepper Motor
- a gear that connects to the drum

### belt

- a belt that connects to the stepper mottor and drum

### Case

- bottom of case:
  - connects the left and right together
  - connects Motor mounnt
- left of case:
  - connects to the drum
  - the side with the belt
  - has a spoke to connect the drum
- right of case:
  - connects to the drum with a spoke
  - the side with hall sensor
  - (possible) side with the pcb for power / data in adn out
- back of the case
  - keeps the unit solid
  - wire managment is important
- front top:
  - support for unit
  - holds flaps up

### drum

is round holds the flaps has 50 little holes for the flaps

- left drum
  - has the gear
  - connects to the left case
- right drum
  - has a magnit for the hall sensor
  - connects to the right case
- Spaces
  - 4 spacers that connect the left and right drum
  - using heat set inserts to connect
