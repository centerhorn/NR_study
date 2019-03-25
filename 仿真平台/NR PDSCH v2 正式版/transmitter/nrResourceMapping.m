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
[ReFreNum, ReTimeNum] = size(RS_MAP_MATRIX(:,:,1));                        % 资源映射矩阵
pdschGrid = zeros(ReFreNum, ReTimeNum,TxAntNum);
for TxAntInd = 1:TxAntNum    
    SymOfdmIn = zeros(ReFreNum, ReTimeNum);                         % 系统时频资源块
    DataSymInd = 1;                                                 % 输入系统数据流索引    
    %% 资源映射，先频域再时域
    for TimeInd = 1 : ReTimeNum                                     
        for FreInd = 1 : ReFreNum
            if RS_MAP_MATRIX(FreInd, TimeInd,1) == 1                      %数据位置对应放置生成的数据
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

