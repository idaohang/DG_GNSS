function goGPS_LS_SA_code(time_rx, pr1, pr2, snr, Eph, SP3_time, SP3_coor, SP3_clck, iono, phase)

% SYNTAX:
%   goGPS_LS_SA_code(time_rx, pr1, pr2, snr, Eph, SP3_time, SP3_coor, SP3_clck, iono, phase);
%
% INPUT:
%   time_rx  = GPS reception time
%   pr1      = code observations (L1 carrier)
%   pr2      = code observations (L2 carrier)
%   snr      = signal-to-noise ratio
%   Eph      = satellite ephemeris
%   SP3_time = precise ephemeris time
%   SP3_coor = precise ephemeris coordinates
%   SP3_clck = precise ephemeris clocks
%   iono     = ionosphere parameters
%   phase    = L1 carrier (phase=1), L2 carrier (phase=2)
%
% DESCRIPTION:
%   Computation of the receiver position (X,Y,Z).
%   Standalone code positioning by least squares adjustment.

%----------------------------------------------------------------------------------------------
%                           goGPS v0.3.1 beta
%
% Copyright (C) 2009-2012 Mirko Reguzzoni, Eugenio Realini
%----------------------------------------------------------------------------------------------
%
%    This program is free software: you can redistribute it and/or modify
%    it under the terms of the GNU General Public License as published by
%    the Free Software Foundation, either version 3 of the License, or
%    (at your option) any later version.
%
%    This program is distributed in the hope that it will be useful,
%    but WITHOUT ANY WARRANTY; without even the implied warranty of
%    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%    GNU General Public License for more details.
%
%    You should have received a copy of the GNU General Public License
%    along with this program.  If not, see <http://www.gnu.org/licenses/>.
%----------------------------------------------------------------------------------------------

global sigmaq0
global cutoff snr_threshold cond_num_threshold o1 o2 o3

global Xhat_t_t Cee conf_sat conf_cs pivot pivot_old
global azR elR distR
global PDOP HDOP VDOP

%covariance matrix initialization
cov_XR = [];

%topocentric coordinate initialization
azR   = zeros(32,1);
elR   = zeros(32,1);
distR = zeros(32,1);

%visible satellites (ROVER)
if (phase == 1)
    sat = find(pr1 ~= 0);
else
    sat = find(pr2 ~= 0);
end

if (size(sat,1) >= 4)
    
    if (phase == 1)
        [XR, dtR, XS, dtS, XS_tx, VS_tx, time_tx, err_tropo, err_iono, sat, elR(sat), azR(sat), distR(sat), cov_XR, var_dtR, PDOP, HDOP, VDOP, cond_num] = init_positioning(time_rx, pr1(sat), snr(sat), Eph, SP3_time, SP3_coor, SP3_clck, iono, [], [], [], sat, cutoff, snr_threshold, 0, 0); %#ok<ASGLU>
    else
        [XR, dtR, XS, dtS, XS_tx, VS_tx, time_tx, err_tropo, err_iono, sat, elR(sat), azR(sat), distR(sat), cov_XR, var_dtR, PDOP, HDOP, VDOP, cond_num] = init_positioning(time_rx, pr2(sat), snr(sat), Eph, SP3_time, SP3_coor, SP3_clck, iono, [], [], [], sat, cutoff, snr_threshold, 0, 0); %#ok<ASGLU>
    end

    %--------------------------------------------------------------------------------------------
    % SATELLITE CONFIGURATION SAVING
    %--------------------------------------------------------------------------------------------
    
    %satellite configuration
    conf_sat = zeros(32,1);
    conf_sat(sat,1) = +1;
    
    %no cycle-slips when working with code only
    conf_cs = zeros(32,1);
    
    %previous pivot
    pivot_old = 0;
    
    %actual pivot
    [null_max_elR, i] = max(elR(sat)); %#ok<ASGLU>
    pivot = sat(i);

    %if less than 4 satellites are available after the cutoffs, or if the 
    % condition number in the least squares exceeds the threshold
    if (size(sat,1) < 4 | cond_num > cond_num_threshold)
        
        if (~isempty(Xhat_t_t))
            XR = Xhat_t_t([1,o1+1,o2+1]);
            pivot = 0;
        else
            return
        end
    end
else
    if (~isempty(Xhat_t_t))
        XR = Xhat_t_t([1,o1+1,o2+1]);
        pivot = 0;
    else
        return
    end
end

if isempty(cov_XR) %if it was not possible to compute the covariance matrix
    cov_XR = sigmaq0 * eye(3);
end
sigma2_XR = diag(cov_XR);

%-------------------------------------------------------------------------------

Xhat_t_t = zeros(o3,1);
Xhat_t_t(1)    = XR(1);
Xhat_t_t(o1+1) = XR(2);
Xhat_t_t(o2+1) = XR(3);
Cee(:,:) = zeros(o3);
Cee(1,1) = sigma2_XR(1);
Cee(o1+1,o1+1) = sigma2_XR(2);
Cee(o2+1,o2+1) = sigma2_XR(3);