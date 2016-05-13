
% Least squares software GPS receiver
%------------------------------------------------------------------------ 
% 
% This program provides GPS receiver functionality for post-processing
% data recorded in Receiver Independant Exchange (RINEX) files. The
% positioning algorithm is based on a least square solution for the
% receiver position.
%
% Input:
% Navigation RINEX file
% Observation RINEX file
%
% Output:
% GPS position estimates in an ECEF reference frame (X, Y, Z)
%
%------------------------------------------------------------------------
%
% * Tabib, S., A coordinate free distance geometry approach to the GPS and 
% kinematical computations for general localization, Ph.D. thesis,
% University of California, Davis (2007).
%
%------------------------------------------------------------------------
%
% Copyright 2016, Hadi Tabatabaee, All rights reserved.
%
%------------------------------------------------------------------------

% Loading RINEX navigation file
[Eph, iono, constellations] = load_RINEX_nav('brdm1660.13p', [], 0);

% Loading RINEX observation file
[pr1, ph1, pr2, ph2, dop1, dop2, snr1, snr2, time_ref, time, week, date, pos, interval, antoff, antmod, codeC1] = load_RINEX_obs('MODIFIED.13o', []);

nEpochs = length(time);      


nSatTot = constellations.nEnabledSat;
err_iono = zeros(nSatTot,nEpochs);
err_tropo = zeros(nSatTot,nEpochs);            
dtR = zeros(length(time),1);
dtR_dot = zeros(length(time),1);
XR = zeros(3, length(time));
% Locate satellites using Eph (this will need receiver clock bias as input)
% For now assume dtR = 0 for first epoch.

% Estimate drR for next epochs by using dtRdot.
for i = 1 : length(time)
sat0 = find(pr1(:,i) ~= 0);
%status_obs(sat0,i) = 0; % satellite observed
%Eph_t = rt_find_eph (Eph, time(i), nSatTot);
% if i > 2d
%     dtR_dot(i-1) = (dtR(i-1) - dtR(i-2))/(time(i-1) - time(i-2));
% end
% if i > 1
%     dtR(i) = dtR(i-1) + (time(i) - time(i-1))*dtR_dot(i-1);
% end
[XS, dtS, XS_tx, VS_tx, time_tx, no_eph, sys] = satellite_positions(time(i), pr1(:,i), sat0, Eph, [], [], err_tropo, err_iono, dtR(i));
[XR(:,i), dtR(i), A, b] = leastSquare(sat0, XS, pr1(:,i));
%[XR_geo(1,i), XR_geo(2,i), XR_geo(3,i)] = llh(XR(1,i), XR(2,i), XR(3,i));
end      
      
% Preprocessing finds clock bias and corrects errors
% [pr1, ph1, pr2, ph2, dtR, dtRdot, bad_sats, bad_epochs, ...
%     var_dtR, var_SPP, status_obs, status_cs] = ... 
%     pre_processing_DG(time_ref, time, XR0, pr1, ph1, pr2, ph2, ... 
%     dop1, dop2, snr1, Eph, SP3, iono, lambda, nSatTot, ... 
%     waitbar_handle, flag_XR, sbas);



% Calculate position using the distance geometry algorithm
% [XR, dtR, cov_XR, var_dtR, PDOP, HDOP, VDOP, cond_num, bad_obs, ...
%     bad_epoch, sigma02_hat, residuals_obs, is_bias] = ...
%     DG_SA_code(XR_approx, XS, pr_R, snr_R, elR, distR_approx, dtS, ...
%     err_tropo_RS, err_iono_RS, sys, SPP_threshold, A, Ainv);


