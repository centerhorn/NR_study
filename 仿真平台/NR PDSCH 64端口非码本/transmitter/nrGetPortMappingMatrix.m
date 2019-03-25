%% Function Description              
%  ����ģ��˿����������ߵ�ӳ�������Ƶͨ�������ߵ�ӳ����ô�ֱ1��3��ʽ
%  ��1����Ƶͨ��ӳ��Ϊͬһ����ͬ���������3������

%% Input
%  gnbConfig��  Structure.
%               Configuration information for gNB.    
%  pdschConfig��Structure.
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