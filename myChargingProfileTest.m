%Author - Siddharth Pachpor
% 
%/*
% * Copyright (C) 2025  {Siddharth Pachpor}
% *
% * This software code is licensed under the MIT License.
% *
% * You may use, modify, and distribute this software code
% * for any purpose, including commercial use, provided
% * that the above copyright notice and this license
% * are included in all copies or substantial portions
% * of the software code.
% */


% load CC_CVMainparam.mat and models.mat parameter data total capacity, ..
% time constant, % diffusion resistance , % hysteresis max voltage .. 
% hysteresis rate gamma , % series resistance .. 
%Get model paramters 
maxtime = 3600; 
T = 25;
z= 0.5; % 50 percent SOC

% MainParamStruct = []
% MainParamStruct.q = getParamESC('QParam',T,model) % total capacity
% MainParamStruct.rc = exp(-1./abs(getParamESC('RCParam',T,model))) % time constant
% MainParamStruct.r = (getParamESC('RParam',T,model)) % diffusion resistance
% MainParamStruct.m = getParamESC('MParam',T,model) % hysteresis max voltage
% MainParamStruct.g = getParamESC('GParam',T,model) % hysteresis rate gamma
% MainParamStruct.r0 = getParamESC('R0Param',T,model) % series resistance
% % MainParamStruct.z_T = OCVfromSOCtemp(z,T,model)
% save('CC_CVMainparam.mat','MainParamStruct');

maxV = 4.15; % maximum cell voltage of 4.15 V

% initialise the simulation storage and state variabls
storeZ = zeros(maxtime,1) ;
storeV = zeros(maxtime,1) ;
storeI = zeros(maxtime,1) ;
storeP = zeros(maxtime,1) ;
z= 0.5; % 50 percent SOC
irc = 0 ;
h = -1;

% simulate the CC/CV Charging
CC= 10 ;% constant absolute current of 10 A
% loop through maxtime

for k = 1: maxtime
v = OCVfromSOCtemp(z,T,model)  + (MainParamStruct.m)*h - (MainParamStruct.r)*irc ;% fixed voltage
% OCV + hsterysis + diffusion  voltage --- not a function of instantaneous
% current
ik = (v - maxV)/(MainParamStruct.r0);
% put a limit to max current
ik = max(-CC,ik);

% update cell SOC
z= z - (1/3600)*ik/(MainParamStruct.q) ;

% update resitor currents
irc = (MainParamStruct.rc)*irc + (1-(MainParamStruct.rc))*ik;

% update hysteris voltage
fac = exp(-abs((MainParamStruct.g).*ik)./(3600*MainParamStruct.q));
h = fac.*h + (fac-1).*sign(ik);

storeZ(k) = z;
storeV(k) = v -ik*(MainParamStruct.r0);
storeI(k) = ik;
storeP(k) = ik-storeV(k);
end 
% plot
time = 0 :maxtime-1;
figure(1); clf; plot(time,100*storeZ); hold on
title('Figure 1 - SOC versus time');
xlabel('Time (s)')
ylabel('SOC (%)');
legend('CC/CV','Location','EastOutside')
grid on;
hold off;

figure(2); clf; plot(time,storeV); hold on
title('Figure 1 - Terminal voltage versus time');
xlabel('Time (s)')
ylabel('Voltage (V)');
grid on;
hold off;
legend('CC/CV','Location','EastOutside')

figure(3); clf; plot(time,storeI); hold on
title('Figure 1 - Cell Current versus time');
xlabel('Time (s)')
ylabel('Current (A)');
hold off;
grid on;
legend('CC/CV','Location','EastOutside')

figure(4); clf; plot(time,storeP); hold on
title('Figure 1 - Cell Power versus time');
xlabel('Time (s)')
ylabel('Power (W)');
hold off;
grid on;
legend('CC/CV','Location','EastOutside')



