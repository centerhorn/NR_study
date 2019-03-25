%% Function Description    
%   AnalogPrecoding
%% Input
%  PrecodingMatrix:      2-Dimension array(TxAntNum-PortNum)
%                     Mapping Matrix of Port to Antenna
%  ResourceMapMat:    3-Dimension array(subcarrier-symbol-port)
%                     data and DMRS sequence mapping for all antenna ports.
%% Output
%  DataPortMap :     3-Dimension array(subcarrier-symbol-TxAntNum)
%                    pdsch Grid after AnalogPrecoding
%% Modify History
%  2018/05/18 created by Song Erhao

function DataPortMap = nrAnalogPrecoding(PrecodingMatrix,ResourceMapMat)
SubcarrierNum = size(ResourceMapMat,1);
SymbolNum = size(ResourceMapMat,2);
TxAntNum = size(PrecodingMatrix,1);
RENum = SubcarrierNum*SymbolNum;
PortNum = size(ResourceMapMat,3);

for PortInd = 1:PortNum
    DataPortMapTemp = ResourceMapMat(:,:,PortInd);
    DataPortSeq = reshape(DataPortMapTemp,1,RENum);
    DataPortCombine(:,:,PortInd) = PrecodingMatrix(:,PortInd)*DataPortSeq; %发射天线*RE个数*Port
    
end

% 映射到物理天线 
DataPortAll = sum(DataPortCombine,3);
for AntInd = 1:TxAntNum
    DataPortTemp = DataPortAll(AntInd,:);
    DataPortMap(:,:,AntInd) = reshape(DataPortTemp,SubcarrierNum,SymbolNum);
end
end