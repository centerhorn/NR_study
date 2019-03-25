%% Function Description
%  precoding for DMRS and map to port
%% Input
% PrecodingMatrix: 2-Dimension array(portNums-layerNums)
%           codebook for precoding
% DMRS_MAP      : 3-Dimensional array (subcarrier-symbol-rank).
%                 DMRS sequence mapping for all layers.
%% Output
%  DmrsMapAfterPrecoding: 3-Dimension array(subcarrier-symbol-port)
%                         DMRS sequence mapping for all antenna ports.
%% Modify History
% 2018/1/14 created by Liu Chunhua 
% 2018/5/18 modified by Song Erhao

function DmrsMapAfterPrecoding = nrDLPrecodeDMRS(PrecodingMatrix,DMRS_MAP)
RANK = size(DMRS_MAP,3);
SubcarrierNum = size(DMRS_MAP,1);
SymbolNum = size(DMRS_MAP,2);
PortNum = size(PrecodingMatrix,1);
RENum = SubcarrierNum*SymbolNum;
% 计算各个DMRS预编码后
for RankInd = 1:RANK
    DmrsMapTemp = DMRS_MAP(:,:,RankInd);
    DmrsSeq = reshape(DmrsMapTemp,1,RENum);
    DmrsSeqCombine(:,:,RankInd) = PrecodingMatrix(:,RankInd)*DmrsSeq; %发射天线*RE个数*RANK
end

% 映射到各天线端口
DmrsPortAll = sum(DmrsSeqCombine,3);
for PortInd = 1:PortNum
    DmrsPortTemp = DmrsPortAll(PortInd,:);
    DmrsMapAfterPrecoding(:,:,PortInd) = reshape(DmrsPortTemp,SubcarrierNum,SymbolNum);
end

end