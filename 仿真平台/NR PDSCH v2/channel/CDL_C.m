%% CDL_C
CDL.delay = [0,0.2099,0.2219,0.2329,0.2176,0.6366,0.6448,0.6560,0.6584,0.7935,0.8213,0.9336,1.2285,1.3083,2.1704,2.7105,4.2589,4.6003,5.4902,5.6077,6.3065,6.6374,7.0427,8.6523] * 100;
CDL.power = [-4.4,-1.2,-3.5,-5.2,-2.5,0,-2.2,-3.9,-7.4,-7.1,-10.7,-11.1,-5.1,-6.8,-8.7,-13.2,-13.9,-13.9,-15.8,-17.1,-16,-15.7,-21.6,-22.8];
CDL.power = 10.^(CDL.power/10)/sum(10.^(CDL.power/10));
CDL.AOD = [-46.6,-22.8,-22.8,-22.8,-40.7,0.3,0.3,0.3,73.1,-64.5,80.2,-97.1,-55.3,-64.3,-78.5,102.7,99.2,88.8,-101.9,92.2,93.3,106.6,119.5,-123.8];
CDL.AOA = [-101,120,120,120,-127.5,170.4,170.4,170.4,55.4,66.5,-48.1,46.9,68.1,-68.7,81.5,30.7,-16.4,3.8,-13.7,9.7,5.6,0.7,-21.9,33.6];
CDL.ZOD = [97.2,98.6,98.6,98.6,100.6,99.2,99.2,99.2,105.2,95.3,106.1,93.5,103.7,104.2,93.0,104.2,94.9,93.1,92.2,106.7,93.0,92.9,105.2,107.8];
CDL.ZOA = [87.6,72.1,72.1,72.1,70.1,75.3,75.3,75.3,67.4,63.8,71.4,60.5,90.6,60.1,61.0,100.7,62.3,66.7,52.9,61.8,51.9,61.7,58,57];
CDL.ASD = 2;
CDL.ASA = 15;
CDL.ZSD = 3;
CDL.ZSA = 7;
CDL.XPR = 7;
%% Cluster Number
ClusterNum = length(CDL.AOD);
%% Offset Angle
DeltaAngle_Arrive = [0.0447    0.1413    0.2492    0.3715    0.5129    0.6797    0.8844    1.1481    1.5195    2.1551];
DeltaAngle_Arrive = [ DeltaAngle_Arrive ; -DeltaAngle_Arrive ];
DeltaAngle_Arrive = DeltaAngle_Arrive(:);
DeltaAngle_Departure = [ DeltaAngle_Arrive(11:20) ; DeltaAngle_Arrive(1:10)];
DeltaAngle_Arrive = repmat(DeltaAngle_Arrive,1,ClusterNum);
DeltaAngle_Departure = repmat(DeltaAngle_Departure,1,ClusterNum);
%% ray angle
CDL.AOD = repmat(CDL.AOD,20,1) + CDL.ASD*DeltaAngle_Departure;
CDL.AOD = CDL.AOD / 180 * pi;
CDL.ZOD = repmat(CDL.ZOD,20,1) + CDL.ZSD*DeltaAngle_Departure;
CDL.ZOD = CDL.ZOD / 180 * pi;
CDL.AOA = repmat(CDL.AOA,20,1) + CDL.ASA*DeltaAngle_Arrive;
CDL.AOA = CDL.AOA / 180 * pi;
CDL.ZOA = repmat(CDL.ZOA,20,1) + CDL.ZSA*DeltaAngle_Arrive;
CDL.ZOA = CDL.ZOA / 180 * pi;
%% rotate departure angle
MeanZOD = 0;
MeanAOD = 0;
for iCluster = 1 : ClusterNum
    for iRay = 1 : 20
        MeanZOD = MeanZOD + exp(1j*CDL.ZOD(iRay,iCluster))*CDL.power(iCluster)/20;
        MeanAOD = MeanAOD + exp(1j*CDL.AOD(iRay,iCluster))*CDL.power(iCluster)/20;
    end
end
MeanZOD = angle(MeanZOD);
MeanAOD = angle(MeanAOD);
CDL.AOD = CDL.AOD - MeanAOD + 0;
CDL.ZOD = CDL.ZOD - MeanZOD + pi/2;
%% rotate departure angle
MeanAOA = 0;
MeanZOA = 0;
for iCluster = 1 : ClusterNum
    for iRay = 1 : 20
        MeanZOA = MeanZOA + exp(1j*CDL.ZOA(iRay,iCluster))*CDL.power(iCluster)/20;
        MeanAOA = MeanAOA + exp(1j*CDL.AOA(iRay,iCluster))*CDL.power(iCluster)/20;
    end
end
MeanZOA = angle(MeanZOA);
MeanAOA = angle(MeanAOA);
CDL.AOA = CDL.AOA - MeanAOA + pi;
CDL.ZOA = CDL.ZOA - MeanZOA + pi/2; 
%% coherence time
% F_DopplerSpread = zeros(20,ClusterNum);
% for iCluster = 1 : ClusterNum
%     rx = [sin(CDL.ZOA(:,iCluster)).*cos(CDL.AOA(:,iCluster)),sin(CDL.ZOA(:,iCluster)).*sin(CDL.AOA(:,iCluster)),cos(CDL.ZOA(:,iCluster))];
%     F_DopplerSpread(:,iCluster) = rx * VDirection / wavelength;
% end
% TmpPower = repmat(CDL.power/20,20,1);
% F_RMS = std(reshape(F_DopplerSpread,ClusterNum*20,1),reshape(TmpPower,ClusterNum*20,1));
% period = 1 / F_RMS;
% period = floor(0.5 * period / (1/30000)) * 1/30000;