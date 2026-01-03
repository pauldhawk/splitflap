
1. Create the OpenSCAD libraries folder

OpenSCAD automatically scans a specific directory for libraries.

Default location (all platforms)

Documents/
└── OpenSCAD/
    └── libraries/

If libraries doesn’t exist, create it.

⸻

2. Install the MCAD library (the workhorse)

Get it
	•	GitHub: https://github.com/openscad/MCAD
	•	Click Code → Download ZIP
	•	Unzip

Place it

Move the extracted folder so the path is:

Documents/OpenSCAD/libraries/MCAD/

Inside that folder you should see files like:

stepper.scad
bearing.scad
nuts_and_bolts.scad


⸻

3. (Optional but recommended) Install BOSL2

BOSL2 complements MCAD beautifully.

Get it
	•	GitHub: https://github.com/BelfrySCAD/BOSL2
	•	Download ZIP
	•	Unzip

Place it

Documents/OpenSCAD/libraries/BOSL2/


⸻

4. Verify OpenSCAD sees them

Restart OpenSCAD.

Go to:
	•	Help → Library Info

You should see:
	•	MCAD
	•	BOSL2

If not, the folder path is wrong.

⸻

5. Use the libraries correctly (use vs include)

This matters more than it looks.

MCAD (geometry generators)

Use use so it doesn’t pollute your namespace:

use <MCAD/stepper.scad>;
use <MCAD/bearing.scad>;

BOSL2 (functions + modules)

Use include:

include <BOSL2/std.scad>;


⸻

6. Quick sanity test (copy–paste)

include <BOSL2/std.scad>;
use <MCAD/stepper.scad>;

$fn = 64;

// NEMA 17 motor
translate([0,0,20])
    stepper_motor(17, shaft_length=24);

// Mounting screws
translate([0,0,0])
    screw("M3x10");

If you see:
	•	A stepper motor
	•	A visible M3 screw

🎉 You’re correctly installed.

⸻

7. Recommended project layout (future-you will thank you)

project/
├── lib/
│   └── hardware.scad
├── motor_mount.scad
├── drum.scad
├── frame.scad
└── assembly.scad

lib/hardware.scad

include <BOSL2/std.scad>;
use <MCAD/stepper.scad>;
use <MCAD/bearing.scad>;

Then everywhere else:

use <lib/hardware.scad>;


⸻

8. Common pitfalls (avoid these)

❌ Putting ZIP files directly in libraries
❌ Nesting folders like MCAD-master/MCAD/
❌ Importing STL when parametric exists
❌ Using include for MCAD

⸻

9. When to prefer which library

Part	Best library
Stepper motors	MCAD
Bearings	MCAD or BOSL2
Screws / nuts	BOSL2
Slots / patterns	BOSL2
Parametric frames	BOSL2


⸻

If you want, next I can:
	•	Build a drop-in NEMA-17 motor mount using MCAD + BOSL2
	•	Create a house-standard M3/M4 hardware config for your projects
	•	Help you wrap all this in a single reusable template repo

Say the word and I’ll wire it up 🔩