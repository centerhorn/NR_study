%% Function Description              
%  生成模拟端口向物理天线的映射矩阵，射频通道与天线的映射采用垂直1分3方式
%  即1个射频通道映射为同一列相同极化方向的3根天线

%% Input
%  gnbConfig：  Structure.
%               Configuration information for gNB.    
%  pdschConfig：Structure.
%               Configuration information for PDSCH.
%% Output
%  PrecodingMat:2-Dimension array(TxAntNum-PortNum)
%               Mapping Matrix of Port to Antenna
%% Modify History
%  2018/05/18 created by Song Erhao
function PrecodingMat = nrGetPortMappingMatrix(gnbConfig,pdschConfig)
    NBAntNum = gnbConfig.TxAntNum;
    Port = pdschConfig.PortCSIRS ; 
    PrecodingMat = zeros(Port,NBAntNum);
    RowInd = 1;
    ColInd = 1;
    while RowInd < Port
        PrecodingMat(RowInd,ColInd) = 1/sqrt(3);
        PrecodingMat(RowInd,ColInd+2) = 1/sqrt(3);
        PrecodingMat(RowInd,ColInd+4) = 1/sqrt(3);
        PrecodingMat(RowInd+1,ColInd+1) = 1/sqrt(3);
        PrecodingMat(RowInd+1,ColInd+3) = 1/sqrt(3);
        PrecodingMat(RowInd+1,ColInd+5) = 1/sqrt(3);
        RowInd = RowInd +2;
        ColInd = ColInd+6;
    end
    PrecodingMat = PrecodingMat.';
        
end