function [q1,q2] = cornerdescriptorpoints(rows12,cols12,valid_points1,valid_points2)

uu = [rows12 cols12];
zzz = valid_points1(uu(:, 1), :);
yyy = valid_points2(uu(:, 2), :);
q1 = zzz.Location;
q2 = yyy.Location;

end