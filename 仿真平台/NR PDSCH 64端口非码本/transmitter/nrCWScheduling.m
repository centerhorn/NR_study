%% Function Description
%  generate Data,modulation order and coderate for current HARQ process
%% Input
%  MCSIndex:      double
%                 MCSIndex 
%  LayerNum       double
%                 layer number
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
%                size of a TB block
%% Modify History
%  2018/05/16 created by Song Erhao
%%

function [data,modu,R,TbLength] = nrCWScheduling(MCSIndex,LayerNum,pdschConfig)
    [TbLength,QmTemp,RTemp] = nrAMC(MCSIndex,LayerNum,pdschConfig);
    data = randi([0 1],TbLength,1);
    modu = QmTemp;
    R = RTemp;

end

