function alt = psi_to_altitude(psi)
% Function that converts pressure psi readings to altitude values in meters

% conversions
psi2kpa = 6.89476;
kpa_sea_level = 101.325;

% convert pressure readings
kpa = psi*psi2kpa;

% find the altitude
alt = -log(kpa./kpa_sea_level)./0.00011855;

end