fc = 2.3e9;  % Carrier frequency
vp = physconst('lightspeed');  % Speed of light
lambda = vp/fc;  % Wavelength

% Construct the antenna object
ant = dipole( ...
    'Length', lambda/2,...
    'Width', 0.01*lambda);

% Display the antenna
ant.show();
ant.pattern(fc);

len = 0.49 * lambda;
groundPlaneLen = lambda;
ant2 = patchMicrostrip(...
    'Length', len, 'Width', 1.5*len, ...
    'GroundPlaneLength', groundPlaneLen, ...
    'GroundPlaneWidth', groundPlaneLen, ...
    'Height', 0.01*lambda, ...
    'FeedOffset', [0.25*len 0]);

% Tilt the element so that the maximum energy is in the x-axis
ant2.Tilt = 90;
ant2.TiltAxis = [0 1 0];

% Display antenna pattern after rotation
ant2.pattern(fc, 'Type', 'Directivity');
[dir,az,el] = ant2.pattern(fc, 'Type', 'directivity');

% Elevation angle to plot
elPlot = 0;

% Find the index closest to the desired angle
[~, iel] = min(abs(el - elPlot));

% Plot using polar plot. Note conversion to radians and using |rlim|
polarplot(deg2rad(az), dir(iel,:), 'Linewidth', 3);
rlim([-30, 15]);
title('Directivity (dBi)');

d = 500;  % Distance in meters

% Compute FSPL manually from Friis' Law
plOmni1 = -20*log10(lambda/4/pi/d);

% OR MATLAB's built in function
plOmni2 = fspl(d, lambda);

fprintf(1, 'Omni PL - manual: %7.2f\n', plOmni1);
fprintf(1, 'Omni PL - manual: %7.2f\n', plOmni2);

phasePattern = zeros(size(dir));
ant3 = phased.CustomAntennaElement( ...
    'AzimuthAngles', az, 'ElevationAngles', el, ...
    'MagnitudePattern', dir, ...
    'PhasePattern', phasePattern);

% Plot antenna pattern.
clf;
ant3.pattern(fc)

% Define linear path
npts = 100;
xstart = [500 -100 0]';
xend = [-500 200 50]';
t = linspace(0,1,npts)';

% Compute points on path
X = (1 - t)*xstart' + t*xend';

% Plot the path
clf;
plot3(X(:,1), X(:,2), X(:,3), 'bo', 'DisplayName', 'RX');
hold on
plot3(0, 0, 0, 'rs', 'MarkerSize', 10, 'DisplayName', 'RX');
hold off
grid on
view(30, 30)
xlabel('x');
ylabel('y');
zlabel('z');
legend()

% Get motion direction
v = xend-xstart;

% Compute angle of motion direction
[azDir, elDir, ~] = cart2sph(v(1), v(2), v(3));

% Rotation matrix aligned to motion direction
yaw = azDir;
pitch = -elDir;
roll = 0;
R = eul2rotm([yaw pitch roll], 'ZYX');

% Create vector from local antenna to remote signal source
Zpath = -X;

% Rotate to RX frame of reference
Zrot = Zpath * R;

% Compute angles in local frame of reference
[azpath, elpath, dist] = cart2sph(Zrot(:,1), Zrot(:,2), Zrot(:,3));

% Convert to degrees
azpath = rad2deg(azpath);
elpath = rad2deg(elpath);

% Plot angles over time
plot(t, [azpath elpath], 'Linewidth', 2);
grid on;
legend('AoA', 'ZoA');
xlabel('Time');

% Compute FSPL along path without antenna gain
plOmni = fspl(dist, lambda);

% Compute directivity using interpolition of pattern
% First, create interpolation object
F = griddedInterpolant({el,az},dir);

% Compute directivity using object
dirPath = F(elpath, azpath);

% Compute total path loss including directivity
plDir = plOmni - dirPath;

% Plot path loss over time
clf;
plot(t, [plOmni plDir], 'Linewidth', 3);
grid();
set(gca, 'Fontsize', 16);
legend('Omni', 'With directivity', 'Location', 'SouthEast');
xlabel('Time');
ylabel('Path loss (dB)');
