%% Function Description
%  Initialize TDL channel configurations
%% Input
%  pdschConfig: Structure.
%               Configuration information for PDSCH
%  gnbConfig:   Structure.
%               Configuration information for gNB.
%  ueConfig:    Structure.
%               Configuration information for ue.
%% Output
%  channel£º    Structure.
%               Configuration information for channel.
%% Modify History
%  2018/05/21 modified by Song Erhao

function channel = nrChannelInit(pdschConfig, gnbConfig, ueConfig)

channel.SymbolsPerSlot=pdschConfig.SymbolsPerSlot;
channel.IfftSize = pdschConfig.IfftSize;
channel.T = pdschConfig.Ts;   % number of samples per slot
channel.SlotDuration = pdschConfig.SlotDuration;
channel.CenterFrequency = 3.5e9;
channel.UESpeed = 0;
channel.NBAntNum = gnbConfig.TxAntNum;
channel.UEAntNum = ueConfig.RxAntNum;
channel.DelaySpread = 100*1e-9;
channel.Type = 'TDL-A';                %include TDL-A,TDL-B,TDL-C,CDL-A,CDL-B,CDL-C,CDL-D,CDL-E
%%%%%%
if strcmp(channel.Type, 'empty')
    channel.MulPath = 0;
    channel.NormalizedDelay = 0;
    channel.RelativePower = [-1];
elseif strcmp(channel.Type, 'TDL-A')
    channel.MulPath = 23;
    channel.NormalizedDelay = [0.0000,0.3819,0.4025,0.5868,0.4610,0.5375,0.6708,0.5750,0.7618,1.5375,1.8978,2.2242,2.1718,2.4942,2.5119,3.0582,4.0810,4.4579,4.5695,4.7966,5.0066,5.3043,9.6586];
    channel.RelativePower = [-13.4,0,-2.2,-4,-6,-8.2,-9.9,-10.5,-7.5,-15.9,-6.6,-16.7,-12.4,-15.2,-10.8,-11.3,-12.7,-16.2,-18.3,-18.9,-16.6,-19.9,-29.7];
elseif strcmp(channel.Type, 'TDL-B')
    channel.MulPath = 23;
    channel.NormalizedDelay = [0.0000,0.1072,0.2155,0.2095,0.2870,0.2986,0.3752,0.5055,0.3681,0.3697,0.5700,0.5283,1.1021,1.2756,1.5474,1.7842,2.0169,2.8294,3.0219,3.6187,4.1067,4.2790,4.7834];
    channel.RelativePower = [0,-2.2,-4,-3.2,-9.8,-1.2,-3.4,-5.2,-7.6,-3,-8.9,-9,-4.8,-5.7,-7.5,-1.9,-7.6,-12.2,-9.8,-11.4,-14.9,-9.2,-11.3];
elseif strcmp(channel.Type, 'TDL-C')
    channel.MulPath = 24;
    channel.NormalizedDelay = [0.0000,0.2099,0.2219,0.2329,0.2176,0.6366,0.6448,0.6560,0.6584,0.7935,0.8213,0.9336,1.2285,1.3083,2.1704,2.7105,4.2589,4.6003,5.4902,5.6077,6.3065,6.6374,7.0427,8.6523];
    channel.RelativePower = [-4.4,-1.2,-3.5,-5.2,-2.5,0,-2.2,-3.9,-7.4,-7.1,-10.7,-11.1,-5.1,-6.8,-8.7,-13.2,-13.9,-13.9,-15.8,-17.1,-16,-15.7,-21.6,-22.8];
elseif strcmp(channel.Type, 'CDL-A')
    channel.MulPath=23;
    channel.SubPath=20;
    channel.NormalizedDelay = [0	0.3819	0.4025	0.5868	0.461	0.5375	0.6708	0.575	0.7618	1.5375	1.8978	2.2242	2.1718	2.4942	2.5119	3.0582	4.081	4.4579	4.5695	4.7966	5.0066	5.3043	9.6586];
    channel.RelativePower = [-13.4	0	-2.2	-4	-6	-8.2	-9.9	-10.5	-7.5	-15.9	-6.6	-16.7	-12.4	-15.2	-10.8	-11.3	-12.7	-16.2	-18.3	-18.9	-16.6	-19.9	-29.7];
    channel.AOD_CLUSTER = [-178.1	-4.2	-4.2	-4.2	90.2	90.2	90.2	121.5	-81.7	158.4	-83	134.8	-153	-172	-129.9	-136	165.4	148.4	132.7	-118.6	-154.1	126.5	-56.2];
    channel.AOA_CLUSTER = [51.3	-152.7	-152.7	-152.7	76.6	76.6	76.6	-1.8	-41.9	94.2	51.9	-115.9	26.6	76.6	-7	-23	-47.2	110.4	144.5	155.3	102	-151.8	55.2];
    channel.ZOD_CLUSTER = [50.2	93.2	93.2	93.2	122	122	122	150.2	55.2	26.4	126.4	171.6	151.4	157.2	47.2	40.4	43.3	161.8	10.8	16.7	171.7	22.7	144.9];
    channel.ZOA_CLUSTER = [125.4	91.3	91.3	91.3	94	94	94	47.1	56	30.1	58.8	26	49.2	143.1	117.4	122.7	123.2	32.6	27.2	15.2	146	150.7	156.1];
    channel.C_ASD = 5;
    channel.C_ASA = 11;
    channel.C_ZSD = 3;
    channel.C_ZSA =3;
    channel.XPR_dB =10;
    channel.InitialPhase_VV = 2*pi * rand(length(channel.AOA_CLUSTER), channel.SubPath)-pi;
    channel.InitialPhase_VH = 2*pi * rand(length(channel.AOA_CLUSTER), channel.SubPath)-pi;
    channel.InitialPhase_HV = 2*pi * rand(length(channel.AOA_CLUSTER), channel.SubPath)-pi;
    channel.InitialPhase_HH = 2*pi * rand(length(channel.AOA_CLUSTER), channel.SubPath)-pi;
elseif strcmp(channel.Type,'CDL-B')
    channel.MulPath=23;
    channel.SubPath=20;
    channel.NormalizedDelay = [0	0.1072	0.2155	0.2095	0.287	0.2986	0.3752	0.5055	0.3681	0.3697	0.57	0.5283	1.1021	1.2756	1.5474	1.7842	2.0169	2.8294	3.0219	3.6187	4.1067	4.279	4.7834];
    channel.RelativePower = [0	-2.2	-4	-3.2	-9.8	-1.2	-3.4	-5.2	-7.6	-3	-8.9	-9	-4.8	-5.7	-7.5	-1.9	-7.6	-12.2	-9.8	-11.4	-14.9	-9.2	-11.3];
    channel.AOD_CLUSTER = [9.3	9.3	9.3	-34.1	-65.4	-11.4	-11.4	-11.4	-67.2	52.5	-72	74.3	-52.2	-50.5	61.4	30.6	-72.5	-90.6	-77.6	-82.6	-103.6	75.6	-77.6];
    channel.AOA_CLUSTER = [-173.3	-173.3	-173.3	125.5	-88	155.1	155.1	155.1	-89.8	132.1	-83.6	95.3	103.7	-87.8	-92.5	-139.1	-90.6	58.6	-79	65.8	52.7	88.7	-60.4];
    channel.ZOD_CLUSTER = [105.8	105.8	105.8	115.3	119.3	103.2	103.2	103.2	118.2	102	100.4	98.3	103.4	102.5	101.4	103	100	115.2	100.5	119.6	118.7	117.8	115.7];
    channel.ZOA_CLUSTER = [78.9	78.9	78.9	63.3	59.9	67.5	67.5	67.5	82.6	66.3	61.6	58	78.2	82	62.4	78	60.9	82.9	60.8	57.3	59.9	60.1	62.3];
    channel.C_ASD = 10;
    channel.C_ASA = 22;
    channel.C_ZSD = 3;
    channel.C_ZSA =7;
    channel.XPR_dB =8;
    channel.InitialPhase_VV = 2*pi * rand(length(channel.AOA_CLUSTER), channel.SubPath)-pi;
    channel.InitialPhase_VH = 2*pi * rand(length(channel.AOA_CLUSTER), channel.SubPath)-pi;
    channel.InitialPhase_HV = 2*pi * rand(length(channel.AOA_CLUSTER), channel.SubPath)-pi;
    channel.InitialPhase_HH = 2*pi * rand(length(channel.AOA_CLUSTER), channel.SubPath)-pi;
elseif strcmp(channel.Type,'CDL-C')
    channel.MulPath=24;
    channel.SubPath=20;
    channel.NormalizedDelay = [0	0.2099	0.2219	0.2329	0.2176	0.6366	0.6448	0.656	0.6584	0.7935	0.8213	0.9336	1.2285	1.3083	2.1704	2.7105	4.2589	4.6003	5.4902	5.6077	6.3065	6.6374	7.0427	8.6523];
    channel.RelativePower = [-4.4	-1.2	-3.5	-5.2	-2.5	0	-2.2	-3.9	-7.4	-7.1	-10.7	-11.1	-5.1	-6.8	-8.7	-13.2	-13.9	-13.9	-15.8	-17.1	-16	-15.7	-21.6	-22.8];
    channel.AOD_CLUSTER = [-46.6	-22.8	-22.8	-22.8	-40.7	0.3	0.3	0.3	73.1	-64.5	80.2	-97.1	-55.3	-64.3	-78.5	102.7	99.2	88.8	-101.9	92.2	93.3	106.6	119.5	-123.8];
    channel.AOA_CLUSTER = [-101	120	120	120	-127.5	170.4	170.4	170.4	55.4	66.5	-48.1	46.9	68.1	-68.7	81.5	30.7	-16.4	3.8	-13.7	9.7	5.6	0.7	-21.9	33.6];
    channel.ZOD_CLUSTER = [97.2	98.6	98.6	98.6	100.6	99.2	99.2	99.2	105.2	95.3	106.1	93.5	103.7	104.2	93	104.2	94.9	93.1	92.2	106.7	93	92.9	105.2	107.8];
    channel.ZOA_CLUSTER = [87.6	72.1	72.1	72.1	70.1	75.3	75.3	75.3	67.4	63.8	71.4	60.5	90.6	60.1	61	100.7	62.3	66.7	52.9	61.8	51.9	61.7	58	57];
    channel.C_ASD = 2;
    channel.C_ASA = 15;
    channel.C_ZSD = 3;
    channel.C_ZSA =7;
    channel.XPR_dB =7;
    channel.InitialPhase_VV = 2*pi * rand(length(channel.AOA_CLUSTER), channel.SubPath)-pi;
    channel.InitialPhase_VH = 2*pi * rand(length(channel.AOA_CLUSTER), channel.SubPath)-pi;
    channel.InitialPhase_HV = 2*pi * rand(length(channel.AOA_CLUSTER), channel.SubPath)-pi;
    channel.InitialPhase_HH = 2*pi * rand(length(channel.AOA_CLUSTER), channel.SubPath)-pi;
elseif strcmp(channel.Type,'CDL-D')
    channel.MulPath = 13;
    channel.SubPath=20;
    channel.NormalizedDelay = [0   0   0.035   0.612   1.363   1.405   1.804   2.596   1.775   4.042   7.937   9.424   9.708   12.525];
    channel.RelativePower = [-0.2   -13.5   -18.8   -21   -22.8   -17.9   -20.1   -21.9   -22.9   -27.8   -23.6   -24.8   -30.0   -27.7];
    channel.AOD_CLUSTER = [0   0   89.2   89.2   89.2   13   13   13   34.6   -64.5   -32.9   52.6   -132.1   77.2];
    channel.AOA_CLUSTER = [-180   -180   89.2   89.2   89.2   163   163   163   -137   74.5   127.7   -119.6   -9.1   -83.8];
    channel.ZOD_CLUSTER = [98.5   98.5   85.5   85.5   85.5   97.5   97.5   97.5   98.5   88.4   91.3   103.8   80.3   86.5];
    channel.ZOA_CLUSTER = [81.5   81.5   86.9   86.9   86.9   79.4   79.4   79.4   78.2   73.6   78.3   87   70.6   72.9];
    channel.C_ASD = 5;
    channel.C_ASA = 8;
    channel.C_ZSD = 3;
    channel.C_ZSA = 3;
    channel.XPR_dB = 11;
    channel.InitialPhase_VV = 2*pi * rand(length(channel.AOA_CLUSTER), channel.SubPath)-pi;
    channel.InitialPhase_VH = 2*pi * rand(length(channel.AOA_CLUSTER), channel.SubPath)-pi;
    channel.InitialPhase_HV = 2*pi * rand(length(channel.AOA_CLUSTER), channel.SubPath)-pi;
    channel.InitialPhase_HH = 2*pi * rand(length(channel.AOA_CLUSTER), channel.SubPath)-pi;
elseif strcmp(channel.Type,'CDL-E')
    channel.MulPath = 14;
    channel.SubPath=20;
    channel.NormalizedDelay = [0.000   0.000   0.5133    0.5440   0.5630   0.5440   0.7112   1.9092   1.9293   1.9589   2.6426   3.7136   5.4524   12.0034   20.6419];
    channel.RelativePower = [-0.03   -22.03   -15.8   -18.1   -19.8   -22.9   -22.4   -18.6   -20.8   -22.6   -22.3   -25.6   -20.2   -29.8   -29.2];
    channel.AOD_CLUSTER = [0   0   57.5   57.5   57.5   -20.1   16.2   9.3   9.3   9.3   19   32.7   0.5   55.9   57.6];
    channel.AOA_CLUSTER = [-180   -180   18.2   18.2   18.2   101.8   112.9   -155.5   -155.5   -155.5   -143.3   -94.7   147   -36.2   -26];
    channel.ZOD_CLUSTER = [99.6   99.6   104.2   104.2   104.2   99.4   100.8   98.8   98.8   98.8   100.8   96.4   98.9   95.6   104.6];
    channel.ZOA_CLUSTER = [80.4   80.4   80.4   80.4   80.4   80.8   86.3   82.7   82.7   82.7   82.9   88   81   88.6   78.3];
    channel.C_ASD = 5;
    channel.C_ASA = 11;
    channel.C_ZSD = 3;
    channel.C_ZSA = 7;
    channel.XPR_dB = 8;
    channel.InitialPhase_VV = 2*pi * rand(length(channel.AOA_CLUSTER), channel.SubPath)-pi;
    channel.InitialPhase_VH = 2*pi * rand(length(channel.AOA_CLUSTER), channel.SubPath)-pi;
    channel.InitialPhase_HV = 2*pi * rand(length(channel.AOA_CLUSTER), channel.SubPath)-pi;
    channel.InitialPhase_HH = 2*pi * rand(length(channel.AOA_CLUSTER), channel.SubPath)-pi;
else
    error('No such channel type!');
end

Ts = channel.SlotDuration/channel.T;     % interval between samples
% actual delay for each path in second
DELAY_TIME = channel.DelaySpread * channel.NormalizedDelay;
% actual delay for each path in samples
channel.DelayOut = floor(DELAY_TIME/Ts);
channel.MaxDelay = max(channel.DelayOut);
% absolute amplitude for each path
Am = sqrt(10.^(0.1*channel.RelativePower));
channel.Am = Am./sqrt(sum(Am.^2));
end



