%% Function Description              
%  ResourceMapping for each  port 
%% Input
%  DataSymIn:              2-Dimension array(port-symbols_per_port)
%                          data after Precoding
%  DmrsMapAfterPrecoding:  3-Dimension array(subcarrier-symbol-port)
%                           DMRS sequence mapping for all antenna ports.
%  RS_MAP_MATRIX        :  3-dimensional array (subcarrier-symbol-rank).
%                          resource mapping matrix for DMRS,Data and PDCCH 
%  WithCSIRS        :      0 or 1
%                          if CSIRS exist
%% Output
%  pdschGrid:   3-Dimension array(subcarrier-symbol-port)
%               data and DMRS sequence mapping for all antenna ports.
%% Modify History
%  2018/05/18 created by Song Erhao

%% code
function pdschGrid = nrResourceMapping(DataSymIn,DmrsMapAfterPrecoding,RS_MAP_MATRIX,pdschConfig,WithCSIRS,CSIRS_MAP)
TxAntNum = size(DataSymIn,1);
[ReFreNum, ReTimeNum] = size(RS_MAP_MATRIX(:,:,1));                        % ��Դӳ�����
pdschGrid = zeros(ReFreNum, ReTimeNum,TxAntNum);
for TxAntInd = 1:TxAntNum    
    SymOfdmIn = zeros(ReFreNum, ReTimeNum);                         % ϵͳʱƵ��Դ��
    DataSymInd = 1;                                                 % ����ϵͳ����������    
    %% ��Դӳ�䣬��Ƶ����ʱ��
    for TimeInd = 1 : ReTimeNum                                     
        for FreInd = 1 : ReFreNum
            if RS_MAP_MATRIX(FreInd, TimeInd,1) == 1                      %����λ�ö�Ӧ�������ɵ�����
               SymOfdmIn(FreInd, TimeInd) = DataSymIn(TxAntInd,DataSymInd);
               DataSymInd = DataSymInd + 1;
            end
        end
    end
     if pdschConfig.EnableRbBundleInterleave==1
        SymOfdmIn = nrRBBundleInterleaver(SymOfdmIn,pdschConfig);
     end 
    pdschGrid(:,:,TxAntInd) = SymOfdmIn + DmrsMapAfterPrecoding(:,:,TxAntInd);
end
if WithCSIRS==1
   pdschGrid = pdschGrid +  CSIRS_MAP;
end
end

