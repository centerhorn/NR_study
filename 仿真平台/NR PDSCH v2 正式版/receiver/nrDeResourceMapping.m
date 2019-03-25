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

%% 解资源映射
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

%%每个接收天线解资源映射
function  [rxDataOutTemp,PilotSymOutTemp] = DeResourceMap(DataSymMatrix,RS_MAP_MATRIX,DMRS_MAP)
DmrsSymMatrix = DataSymMatrix.*conj(DMRS_MAP);
DataSymInd = 1;
DataSize = sum(sum(RS_MAP_MATRIX == 1));
rxDataOutTemp = zeros(1,DataSize);                                             % 输出数据向量初始化
PilotSymInd = 1;
PilotSize = sum(sum(RS_MAP_MATRIX == 2));
PilotSymOutTemp = zeros(1,PilotSize);    
[ReFreNum,ReTimeNum] = size(DataSymMatrix);
% 输出DMRS向量初始化
for TimeInd=1:ReTimeNum
    for FreInd=1:ReFreNum
        if RS_MAP_MATRIX(FreInd, TimeInd) == 1                                  % 根据映射矩阵确定数据时频位置
            rxDataOutTemp(DataSymInd) = DataSymMatrix(FreInd, TimeInd);        % 输出的数据向量
            DataSymInd=DataSymInd+1;
        end
        if RS_MAP_MATRIX(FreInd, TimeInd) == 2                                  %根据映射矩阵确定DMRS时频位置
            PilotSymOutTemp(PilotSymInd) = DmrsSymMatrix(FreInd, TimeInd);      %输出的DMRS向量
            PilotSymInd=PilotSymInd+1;
        end
    end
end
end