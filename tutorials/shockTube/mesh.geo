// Gmsh project created on Wed Feb 24 16:51:19 2021
//+

x_outlet = 1;
x_inlet  = 0;
y_inlet  = 0.05;


ny = 11;
nx = 101;
ninlet = ny;
ntop  =nx;
nbot = nx;
noutlet = ny;

Point(1) = {x_inlet, -y_inlet, 0, 1.0};
//+
Point(2) = {x_inlet, y_inlet, 0, 1.0};
//+
Point(3) = {x_outlet, y_inlet, 0, 1.0};
//+
Point(4) = {x_outlet, -y_inlet, 0, 1.0};
//+

Line(1) = {1,2};
//+
Line(2) = {2,3};
//+
Line(3) = {3, 4};
//+
Line(4) = {4, 1};
//+//+

Curve Loop(1) = {2, 3, 4, 1};
//+
Plane Surface(1) = {1};

//+
//Physical Curve("Inlet") = {1};
//+
//Physical Curve("top") = {2};
//+
//Physical Curve("outlet") = {3};
//+
//Physical Curve("bottom") = {4};
//+
//Physical Surface("domain") = {5};
//+


Transfinite Curve {1,-3} = ninlet Using Progression 1;
//+
Transfinite Curve {2,4} = ntop Using Progression 1;
//+


//+
//+
Transfinite Surface {1} = {2, 3, 4, 1};
Recombine Surface {1};