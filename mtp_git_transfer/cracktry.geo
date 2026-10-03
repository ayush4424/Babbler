Point(1) = {0, 0, 0, 1.0};
//+
Point(2) = {0.5, 0, 0, 1.0};
//+
Point(3) = {1, 0, 0, 1.0};
//+
Point(4) = {1, 0.5, 0, 1.0};
//+
Point(5) = {1, 1, 0, 1.0};
//+
Point(6) = {0.5, 1, 0, 1.0};
//+
Point(7) = {0, 1, 0, 1.0};
//+
Point(8) = {0, 0.5, 0, 1.0};
//+
Point(9) = {0.5, 0.5, 0, 1.0};
//+
Point(10) = {-0, 0.5, 0, 1.0};
//+
Line(1)={1,2};
//+
Line(2) = {2, 3};
//+
Line(3) = {3, 4};
//+
Line(4) = {4, 5};
//+
Line(5) = {5, 6};
//+
Line(6) = {6, 7};
//+
Line(7) = {7, 8};
//+
Line(8) = {8, 9};
//+
Line(9) = {9, 10};
//+
Line(10) = {10, 1};
//+
Physical Curve("top") = {6, 5};
//+
Physical Curve("left") = {7, 10};
//+
Physical Curve("right") = {4, 3};
//+
Physical Curve("bottom") = {1, 2};
//+
Line(11) = {9, 6};
//+
Line(12) = {9, 4};
//+
Line(13) = {9, 2};
//+
Curve Loop(1) = {7, 8, 11, 6};
//+
Plane Surface(1) = {1};
//+
Curve Loop(2) = {5, -11, 12, 4};
//+
Plane Surface(2) = {2};
//+
Curve Loop(3) = {13, 2, 3, -12};
//+
Plane Surface(3) = {3};
//+
Curve Loop(4) = {9, 10, 1, -13};
//+
Plane Surface(4) = {4};
//+
Transfinite Curve {7, 11, 6, 8} = 128 Using Progression 1;
//+
Transfinite Curve {5, 11, 4, 12} = 128 Using Progression 1;
//+
Transfinite Curve {3, 13, 12, 2} = 128 Using Progression 1;
//+
Transfinite Curve {9, 10, 13, 1} = 128 Using Progression 1;
//+
Transfinite Surface {1};
//+
Transfinite Surface {2};
//+
Transfinite Surface {3};
//+
Transfinite Surface {4};
//+
