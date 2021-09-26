D = 0.2;

inlet_h = 49;
inlet_v = 81;
outlet_h = 193;
outlet_v = 65;
step_v = 17;

Point(1) = {3*D, 0, 0};
Point(2) = {0, 0, 0};
Point(3) = {0, 5*D, 0};
Point(4) = {3*D, 5*D,0};
Point(5) =  {15*D,5*D,0};
Point(6) =  {15*D,D,0};
Point(7) = {3*D ,D, 0};

Line(1) = {2, 3};
Line(2) = {3, 4};
Line(4) = {1, 2};
Line(5) = {4, 5};
Line(6) = {5, 6};
Line(7) = {6, 7};
Line(9) = {7, 1};
Line Loop(11) = {1,2,5,6,7,9,4};
Plane Surface(12) = {11};

//+
Transfinite Curve {1} = inlet_v Using Progression 1;
//+
Transfinite Curve {2, 4} = inlet_h Using Progression 1;
//+
Transfinite Curve {5, 7} = outlet_h Using Progression 1;
//+
Transfinite Curve {6} = outlet_v Using Progression 1;
//+
Transfinite Curve {9} = step_v Using Progression 1;
//+



//Transfinite Surface "*";
Recombine Surface "*";

//Transfinite Volume "*";
Recombine Volume "*";
