%% Function Description
%  ideal channel estimination
%% Input
%  ueConfig      : Structure.
%                  Configuration information for UE.
%  HAll          :2-Dimension array(RxAntNum*PortNum-DataNum)
%  SnrLinear     :double
%                 snr
%  V1            :2-Dimension array(PortNum-PortNum)
%  initOLLAoffset:double
%                 OLLA value
%  CodeRate      :double
%                 coderate
%  Qm            :double
%                 Modulation order
%% Output
%  RI            :double
%                 Rank
%  MCSIndex      :double
%                 MCS
%% modified history
% 2018/1/15 created by Liu Chunhua
% 2018/7/1 modified by Liu Chunhua    (rank、MCS合并求解）
% muqin方法
%% coding
function [RI,MCSIndex]=nrRankMCSSelect(ueConfig,HAll,SnrLinear,V1,initOLLAoffset,CodeRate,Qm)
TxAntNum = size(V1,1);
UE_ANT_NUM = ueConfig.RxAntNum;
RankMax = min(TxAntNum,UE_ANT_NUM);
MCSIndexSet = cell(1,RankMax);
len = size(HAll,2);
CapacityCodebook = zeros(1,RankMax);
SINRAll2 = zeros(1,len);
for RIInd = 1:RankMax
    Codebook=V1(:,1:RIInd)/sqrt(RIInd);
    SINRAll = nrMMSEDetectorMIMOCsirs(HAll,SnrLinear,Codebook);
    for REInd = 1:len 
        SINR = SINRAll(:,REInd);
        Y = mean(SINR./(1+SINR));
        combSinr = Y/(1-Y);
        SINRAll2(1,REInd) = combSinr;
    end
    SINROutCsirs = nrEESMcsirs(SINRAll2,CodeRate,Qm);
    [MCSIndexSet{RIInd},SE]= nrMCSSelect(10*log10(SINROutCsirs)+initOLLAoffset(RIInd));
    CapacityCodebook(RIInd) = SE*0.9*RIInd;      
end
[~,RI] = max(CapacityCodebook);
MCSIndex = MCSIndexSet{RI};

end