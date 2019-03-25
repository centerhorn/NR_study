%% Function Description
%  Get CSI-RS channel gain
%% Input
%  DataIn:     2-dimensional array(UE_ANT_NUM-(number of samples per slot))
%              data after channel
%  ROW_INDEX:  double
%              configuration row for CSI-RS, Note that there is no row 6 in the protocol, but this platform contains 6, not 19
%  CSIRS_MAP:  3-Dimensional array (subcarrier-symbol-Port).
%              CSIRS sequence mapping for all Ports.
%  pdschConfig:      structure
%              Configuration information for pdsch
%% Output
%  CsirsH :    cell 
%              CSI-RS channel gain
%% Modify History
%  2018/1/17 created by Liu Chunhua
%  2018/05/30 modified by Song Erhao
%%

%% Coding
function CsirsH = nrDeChannelCSIRS(DataIn,ROW_INDEX,CSIRS_MAP,pdschConfig)
PORT_CSIRS = pdschConfig.PortCSIRS;
RxAntNum = size(DataIn,1);
CsirsH = cell(1,RxAntNum);
for RxAntInd = 1:RxAntNum
    CsirsH{RxAntInd} = De_Channel_CSIRS(DataIn(RxAntInd,:),ROW_INDEX,CSIRS_MAP,PORT_CSIRS,pdschConfig);
end

end