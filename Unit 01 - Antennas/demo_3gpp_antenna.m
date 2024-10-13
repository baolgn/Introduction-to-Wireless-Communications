% Azimuth and elevation half-power beamwidth
azHpbw = 65;
elHpbw = 45;

% Side-lobe and min gain
SLAv = 30;
Am = 30;

% Azimuth and elevation angles to test
el = (-90:1:90)';
az = (-180:1:180)';

% Elevation and azimuth pattern
AEV = -min(12*(el/elHpbw).^2, SLAv);
AEH = -min(12*(az/azHpbw).^2, Am);

% Create directivity matrix
D0 = -min(-(AEV + AEH'), Am);

% Plot un-normalized directivity
imagesc(az,el,D0);
colorbar();
xlabel('Azimuth');
ylabel('Elevation');

azRad = deg2rad(az);
elRad = deg2rad(el);
scale = 1/mean(cos(elRad));

D0avg = mean(db2pow(D0).*cos(elRad), "all")*scale;
Dscale = -pow2db(D0avg);

D = Dscale + D0;

fprintf(1, 'Maximum directivity = %7.2f dBi\n', Dscale);

% Plot normalized directivity
imagesc(az,el,D);
colorbar();
xlabel('Azimuht');
ylabel('Elevation');

ant = phased.CustomAntennaElement( ...
    "AzimuthAngles", az, 'ElevationAngles', el, ...
    "MagnitudePattern", D);

fc = 28e9;
ant.pattern(fc);

% Antenna rotation angle
el0 = 45;
az0 = 80;

% Create rotation matrix
newax = rotz(az0)*roty(-el0);

% Rotate pattern
Drot = rotpat(D,az,el,newax);

% Create rotated element
antRot = phased.CustomAntennaElement( ...
    "AzimuthAngles", az, 'ElevationAngles', el, ...
    "MagnitudePattern", Drot);

% Plot pattern
antRot.pattern(fc);

% Plot rotated directivity in 2D
imagesc(az,el,Drot);
colorbar();
hold on;
plot(az0,el0, 'r+', 'MarkerSize',10);
hold off;
xlabel('Azimuth');
ylabel('Elevation');
