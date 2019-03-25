%% Function Description
%   Resource Element Demapping
%% Input
%  rxGrid :     3-Dimension array(subcarrier-symbol-port)
%               resource grid after OFDM Demodulate
%  DMRSMatrix : 3-Dimension array (subcarrier-symbol-rank).
%               DMRS sequence mapping for all layers.
%  RSMapMatrix:  3-Dimension array (subcarrier-symbol-rank).
%                resource mapping matrix for DMRS,Data and PDCCH
%  CDMGroupMap:  1-Dimension array.
%                CDM group for all active ports.
%% Output
%  rxDataOut :   2-Dimensional array (RxAntNum-DataRENum)
%                Data after demapping
%  rxDMRSOut :   cell of RxAntNum (each cell with a 2-Dimension array(RANK-DMRSReNum))
%                DMRS after demapping

%% Modify history
% 2018/05/21 created by Song Erhao
% 2018/05/23 modified by Song Erhao

%% ����Դӳ��
function [rxDataOut,rxDMRSOut] = nrDeResourceMapping(rxGrid,DMRSMatrix,RSMapMatrix,CDM_GROUP);

UE_ANT_NUM = size(rxGrid,3);
rxDMRSOut=cell(1,UE_ANT_NUM);
for RxAntInd = 1:UE_ANT_NUM
    CDMGroup0Num = length(find(CDM_GROUP==0));
    CDMGroup1Num = length(find(CDM_GROUP==1));
    if CDMGroup1Num==0
        [rxDataOut(RxAntInd,:), PilotSymOut] = DeResourceMap(rxGrid(:,:,RxAntInd),RSMapMatrix(:,:,1),DMRSMatrix(:,:,1));
        rxDMRSOut{RxAntInd} = DecodeDMRS(PilotSymOut,CDMGroup0Num,DMRSMatrix);
    else
        [rxDataOut(RxAntInd,:), PilotSymOut0] = DeResourceMap(rxGrid(:,:,RxAntInd),RSMapMatrix(:,:,1),DMRSMatrix(:,:,1));
        PilotH0 = DecodeDMRS(PilotSymOut0,CDMGroup0Num,DMRSMatrix);
        [rxDataOut(RxAntInd,:), PilotSymOut1] = DeResourceMap(rxGrid(:,:,RxAntInd),RSMapMatrix(:,:,3),DMRSMatrix(:,:,3));
        PilotH1 = DecodeDMRS(PilotSymOut1,CDMGroup1Num,DMRSMatrix);
        rxDMRSOut{RxAntInd}(find(CDM_GROUP==0),:) = PilotH0;
        rxDMRSOut{RxAntInd}(find(CDM_GROUP==1),:) = PilotH1;
    end
end
end

%%ÿ���������߽���Դӳ��
function  [rxDataOutTemp,PilotSymOutTemp] = DeResourceMap(DataSymMatrix,RS_MAP_MATRIX,DMRS_MAP)
DmrsSymMatrix = DataSymMatrix.*conj(DMRS_MAP);
DataSymInd = 1;
DataSize = sum(sum(RS_MAP_MATRIX == 1));
rxDataOutTemp = zeros(1,DataSize);                                             % �������������ʼ��
PilotSymInd = 1;
PilotSize = sum(sum(RS_MAP_MATRIX == 2));
PilotSymOutTemp = zeros(1,PilotSize);    
[ReFreNum,ReTimeNum] = size(DataSymMatrix);
% ���DMRS������ʼ��
for TimeInd=1:ReTimeNum
    for FreInd=1:ReFreNum
        if RS_MAP_MATRIX(FreInd, TimeInd) == 1                                  % ����ӳ�����ȷ������ʱƵλ��
            rxDataOutTemp(DataSymInd) = DataSymMatrix(FreInd, TimeInd);        % �������������
            DataSymInd=DataSymInd+1;
        end
        if RS_MAP_MATRIX(FreInd, TimeInd) == 2                                  %����ӳ�����ȷ��DMRSʱƵλ��
            PilotSymOutTemp(PilotSymInd) = DmrsSymMatrix(FreInd, TimeInd);      %�����DMRS����
            PilotSymInd=PilotSymInd+1;
        end
    end
end
end