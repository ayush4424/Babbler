"""Create plate_with_hole.step: 200 x 100 x 5 mm plate with a 20 mm diameter central hole.

Stands in for a STEP file exported from CAD, and has a textbook answer (Peterson's
stress concentration factor) to check the STEP -> gmsh -> MOOSE workflow against.
"""
import gmsh

gmsh.initialize()
gmsh.option.setNumber("General.Terminal", 0)
gmsh.model.add("plate_with_hole")
plate = gmsh.model.occ.addBox(0, 0, 0, 200, 100, 5)
hole = gmsh.model.occ.addCylinder(100, 50, -1, 0, 0, 7, 10)
gmsh.model.occ.cut([(3, plate)], [(3, hole)])
gmsh.model.occ.synchronize()
gmsh.write("plate_with_hole.step")
gmsh.finalize()
