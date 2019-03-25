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
%  channel：    Structure.
%               Configuration information for channel.
%% Modify History
%  2018/05/21 modified by Song Erhao

function channel = nrChannelInit(pdschConfig, gnbConfig, ueConfig)

channel.SymbolsPerSlot=pdschConfig.SymbolsPerSlot;
channel.IfftSize = pdschConfig.IfftSize;
channel.T = pdschConfig.Ts;   % number of samples per slot
channel.SlotDuration = pdschConfig.SlotDuration;
channel.CenterFrequency = 3.5e9;
channel.UESpeed = 3/3.6;     %3km/h(must) 30km/h(must)  120km/h(not must)  
channel.fDmax = channel.UESpeed*channel.CenterFrequency/3e8;
channel.CoherenceTime = 0.179/channel.fDmax;            % 1 or 9/16/pi=0.179 or sqrt(9/16/pi)=0.423
channel.NBAntNum = gnbConfig.TxAntNum;
channel.UEAntNum = ueConfig.RxAntNum;
channel.DelaySpread = 100*1e-9;
channel.Type = 'CDL-C';                
%%%%%%

if strcmp(channel.Type,'CDL-C')
    %CDL-C-CAICT参数
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
elseif strcmp(channel.Type,'CDL-D')
    %CDL-D-CAICT参数
    channel.MulPath = 14;
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



