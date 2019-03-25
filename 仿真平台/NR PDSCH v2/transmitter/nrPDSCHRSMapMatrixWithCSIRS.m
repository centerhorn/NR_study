%% Function Description
%  form resource mapping matrix for DMRS��CSIRS,Data,PDCCH     
%% Input
%  DMRSMap :       3-Dimensional array (subcarrier-symbol-rank).
%                  DMRS sequence mapping for all layers.  
%  CSIRSMap:       3-Dimensional array (subcarrier-symbol-Port).
%                  CSIRS sequence mapping for all Ports.
%  PdcchSymbolsLocation: row vector
%                        PDCCH location
%% Output
%  RSMapMatrix:    3-dimensional array (subcarrier-symbol-rank).           
%                  resource mapping matrix for DMRS,CSIRS,Data and PDCCH        Data:1  PDCCH:-1 DMRS:2 CSIRS-3
%% Modify History
%  2018/05/29 created by Song Erhao
%%

function [ RSMapMatrix ] = nrPDSCHRSMapMatrixWithCSIRS( DMRSMap,CSIRSMap,PdcchSymbolsLocation)

PDCCH_LENGTH = length(PdcchSymbolsLocation); 
PortNum = size(DMRSMap,3);
DMRSMapMatrix = DMRSMap;
% ӳ��DMRS�ο��ź�
DMRSMapMatrix(find(DMRSMap~=0)) = 2;
% ӳ��CSIRS�ο��ź�
CSIRSMapTemp = CSIRSMap;
CSIRSMapTemp(find(CSIRSMap~=0)) = 3;
CSIRSMapTotal = sum(CSIRSMapTemp,3);
CSIRSMapTotal(find(CSIRSMapTotal~=0)) = 3;
% ӳ������
RSMapSumTemp = sum(DMRSMapMatrix,3)+CSIRSMapTotal;
DataMapMatrix = DMRSMap(:,:,1);
DataMapMatrix(find(RSMapSumTemp==0)) = 1;
DataMapMatrix(find(RSMapSumTemp~=0)) = 0;
DataMapMatrix(:,1:PDCCH_LENGTH) = -1;%�����ŵ���ӳ��
for PortInd = 1:PortNum
    RSMapMatrix(:,:,PortInd) = DMRSMapMatrix(:,:,PortInd) + DataMapMatrix + CSIRSMapTotal;
end
if ~isempty(find(RSMapMatrix>3))
    display('�ο��ź�λ�ó�ͻ������������');
end
end

