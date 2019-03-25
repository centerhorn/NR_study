%% Function Description
%  generate Data,modulation order and coderate for current HARQ process
%% Input
%  CqiIndex:      double
%                 CQIIndex 
%  LayerNum:      double
%                 layer num 
% pdschConfig:   structure
%                Configuration Information for pdsch
%% Output
%  data :        column vector
%                data for transmit
%  modu :        double
%                Modulation order for each cw
%  R    :        double
%                coderate for each cw
%  TbLength:     double
%                TBS size
%% Modify History
%  2018/05/16 created by Song Erhao
%%

function [data,modu,R,TbLength] = nrCWScheduling(CqiIndex,LayerNum,pdschConfig)
    [TbLength,QmTemp,RTemp] = nrAMC(CqiIndex,LayerNum,pdschConfig);
    [DataLength] = nrCalDataLengthLDPC(TbLength,RTemp);
    data = randi([0 1],DataLength,1);
    modu = QmTemp;
    R = RTemp;
end

