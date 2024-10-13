% Generate random data
nx = 4;
d = 3;
X = randn(nx, d);

% Compute spherical coordinates of points matrix
[az, el, rad] = cart2sph(X(:,1), X(:,2), X(:,3));
[x, y, z] = sph2cart(az, el, rad);
Xhat = [x y z];

disp(X);
disp(Xhat);

% Vertices and facets for plane
vert = [-1 -1 0; 1 -1 0; 1 1 0; -1 1 0];
fac = [1 2 3 4];
nvec = [0 0 2];  % Normal Vector
clf;

% Set axes
xlim([-2, 2]);
ylim([-2, 2]);
zlim([-2, 2]);
grid on;
view(120,30);
xlabel('x');
ylabel('y');
zlabel('z');

% Draw original plane
cline = [34 134 34]/256;
patch('Vertices', vert, 'Faces', fac, 'FaceColor', 'green', 'FaceAlpha', 0.5);
hold on;
plot3([0 nvec(1)], [0 nvec(2)], [0 nvec(3)], 'Linewidth', 3, 'Color', cline);

% Set rotation angles
yaw = 28;
pitch = -30;
roll = 0;

% Create rotation matrix
R = eul2rotm(deg2rad([yaw pitch roll]), 'ZYX');

vertRot = vert*R';  % Rotate vertices
nvecRot = nvec*R';  % Rotate normal vector

% Plot rotated plane
cline = [34 34 134]/256;
patch('Vertices', vertRot, 'Faces', fac, 'FaceColor', 'cyan', 'FaceAlpha', 0.5);
plot3([0 nvecRot(1)], [0 nvecRot(2)], [0 nvecRot(3)], 'Linewidth', 3, 'Color', cline);
view(3);
hold off;
