function normal = getNormal(coords)

%This function calculates the normal of a line given 2 points on the line

dx = (coords(2,1)-coords(1,1));
dy = (coords(2,2)-coords(1,2));

normal = [-dy dx];
normal = normal/norm(normal);
end