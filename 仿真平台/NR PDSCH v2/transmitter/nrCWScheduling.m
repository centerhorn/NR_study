%% Function Description
%  generate Data,modulation order and coderate for current HARQ process
%% Input
%  CqiIndex:      double
%                 CQIIndex 
% pdschConfig:   structure
%                Configuration Information for pdsch
%% Output
%  data :        column vector
%                data for transmit
%  modu :        double
%                Modulation order for each cw
%  R    :        double
%                coderate for each cw
%% Modify History
%  2018/05/16 created by Song Erhao
%%

function [data,modu,R,TbLength] = nrCWScheduling(CqiIndex,LayerNum,pdschConfig)
load send.mat send;
    [TbLength,QmTemp,RTemp] = nrAMC(CqiIndex,pdschConfig.LayerNum,pdschConfig);
    [DataLength] = nrCalDataLengthLDPC(TbLength,RTemp);
    %harqProcess.data{cwInd} = randi([0 1], pdschConfig.TrBlkSizes(cwInd), 1);
    %data = randi([0 1],DataLength,1);
    data = send;
    %harqProcesses(harqProcIdx).data{i} = send;           %test code!!!
    modu = QmTemp;
    R = RTemp;

end

