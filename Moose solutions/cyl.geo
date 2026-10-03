// Gmsh project created on Wed Sep 06 00:22:20 2023
//+
Point(1) = {0, 0, 0, 1.0};
//+
SetFactory("OpenCASCADE");
Circle(1) = {0, 0, 0, 1, 0, 2*Pi};
//+
Circle(2) = {0, 0, 0, 3, 0, 2*Pi};
//+
Physical Curve("Inner", 3) = {1};
//+
Physical Curve("Outer", 4) = {2};
//+
Physical Point("pin", 5) = {1};
Curve Loop(1) = {1};
//+
Curve Loop(2) = {2};
//+
Plane Surface(1) = {1, 2};
//+
Physical Surface("circplate", 6) = {1};
//+
Transfinite Curve {1} = 100 Using Progression 1;
//+
Transfinite Curve {2} = 100 Using Progression 1;
//+
Transfinite Curve {1, 2} = 100 Using Progression 1;
//+
