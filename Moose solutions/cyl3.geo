// Gmsh project created on Wed Sep 06 10:51:03 2023
//+
Point(1) = {0, 1, 0, 0.1};
//+
Point(2) = {0, 3, 0, 0.1};
//+
Point(3) = {1, 0, 0, 0.1};
//+
Point(4) = {3, 0, 0, 0.1};
//+
Point(5) = {0, 0, 0, 1.0};
//+
Circle(1) = {3, 5, 1};
//+
Circle(2) = {4, 5, 2};
//+
Line(3) = {2, 1};
//+
Line(4) = {4, 4};
//+
Line(5) = {4, 3};
//+
Curve Loop(1) = {1, -3, -2, 5};
//+
Plane Surface(1) = {1};
//+
Physical Curve("inner", 6) = {1};
//+
Physical Curve("bottom", 7) = {5};
//+
Physical Curve("outer", 8) = {2};
//+
Physical Curve("left", 9) = {3};
//+
Physical Point("pin", 10) = {5};
//+
Physical Surface("cylinder", 11) = {1};
//+
Transfinite Curve {1, 2} = 100 Using Progression 1;
//+
Transfinite Curve {3, 5} = 100 Using Progression 1;
//+
Physical Point("pin2", 12) = {3};
