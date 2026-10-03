//+
Point(1) = {0, 0, 0, 1.0};
//+
Point(2) = {1, 0, 0, 1.0};
//+
Point(3) = {1, 1, 0, 1.0};
//+
Point(4) = {0, 1, 0, 1.0};
//+
Point(5) = {0, 0.5, 0, 1.0};
//+
Point(6) = {0.5, 0.5, 0, 1.0};
//+
Point(7) = {1, 0.5, 0, 1.0};
//+
Point(8) = {0, 0.5, 0, 1.0};
//+
Point(9) = {0.5, 0.5, 0, 1.0};
//+
Point(10) = {1, 0.5, 0, 1.0};
//+
Line(1) = {1, 2};
//+
Line(2) = {2, 7};
//+
Line(3) = {7, 5};
//+
Line(4) = {5, 1};
//+
Line(5) = {5, 7};
//+
Line(6) = {7, 3};
//+
Line(7) = {3, 4};
//+
Line(8) = {4, 5};
//+
Physical Curve("bottom", 9) = {1};
//+
Physical Curve("right", 10) = {2, 6};
//+
Physical Curve("top", 11) = {7};
//+
Physical Curve("left", 10) += {8, 4};
//+
Curve Loop(1) = {1, 2, 3, 4};
//+
Plane Surface(1) = {1};
//+
Curve Loop(2) = {7, 8, -3, 6};
//+
Plane Surface(2) = {2};
//+
Physical Surface("1st block", 12) = {1};
//+
Physical Surface("2nd block", 13) = {2};
//+
//+
Transfinite Curve {1, 2, 3, 4, 6, 7, 8} = 10 Using Progression 1;
//+
Transfinite Surface {2};
//+
Transfinite Surface {1};
//+
Transfinite Curve {8, 6, 4, 2} = 10 Using Progression 1;
//+
Transfinite Curve {7, 3, 1} = 20 Using Progression 1;
