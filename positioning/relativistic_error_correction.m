function [corr] = relativistic_error_correction(time, Eph, XS, VS)

% SYNTAX:
%   [corr] = relativistic_error_correction(time, Eph, XS, VS);
%
% INPUT:
%   time = GPS time
%   Eph = satellite ephemeris vector
%   XS = satellite position (X,Y,Z)
%   VS = satellite velocity (X,Y,Z)
%
% OUTPUT:
%   corr = relativistic correction term
%
% DESCRIPTION:
%   Computation of the relativistic correction term. From the
%   Interface Specification document revision E (IS-GPS-200E), page 86.

%----------------------------------------------------------------------------------------------
%                           goGPS v0.3.0 beta
%
% Copyright (C) 2009-2012 Mirko Reguzzoni, Eugenio Realini
%
%----------------------------------------------------------------------------------------------

global v_light

if (sum(Eph(:))~=0)
    roota = Eph(4);
    ecc   = Eph(6);
    
    Ek = ecc_anomaly(time, Eph);
    corr = -4.442807633e-10 * ecc * roota * sin(Ek);
else
    corr = -2*dot(XS,VS)/(v_light^2);
end