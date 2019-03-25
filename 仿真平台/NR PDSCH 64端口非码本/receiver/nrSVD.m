%% Function Description
%  ideal channel estimination
%% Input
%  HIdeal   :2-Dimension array(RxAntNum*PortNum-DataNum)
%  channelConfig: structure. 
%                 channel configuration.
%  pdschConfig :  structure. 
%                 pdsch configuration.
%% Output
%  V1      : 2-Dimension array(PortNum-PortNum)

%% Modify History
%  2018/04/18 created by Liu Chunhua 
%%
function V1 = nrSVD(HIdeal,channelConfig,pdschConfig)
HAverage = mean(HIdeal,2);
HAverage = (reshape(HAverage,pdschConfig.PortCSIRS,channelConfig.UEAntNum)).';
[UU,SS,V1] = svd(HAverage);