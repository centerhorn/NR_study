%% Function Description              
%  RB bundle deInterleave
%% Input
%  DataSymIn:              2-Dimension array(Rank-DataRENum)
%                          data after MMSE detection
%  RS_MAP_MATRIX:            3-dimensional array (subcarrier-symbol-rank).
%                          resource mapping matrix for DMRS,Data and PDCCH 
%  pdschConfig:            structure
%                          Configuration information for pdsch
%% Output
%  DataSymOut:             2-Dimension array(Rank-DataRENum)
%                          data after deInterleave
%% Modify History
%  2018/1/17 created by Liu Chunhua 
%  2018/05/28 modified by Song Erhao


%% code
function DataSymOut = nrDeInterleaveRBBundle(DataSymIn,RS_MAP_MATRIX,pdschConfig)

DataSymOut = zeros(size(DataSymIn));
RANK = size(DataSymIn,1);
[ReFreNum, ReTimeNum] = size(RS_MAP_MATRIX(:,:,1));                        % 资源映射矩阵
for RankInd = 1:RANK    
    SymOfdmIn = zeros(ReFreNum, ReTimeNum);                         % 系统时频资源块
    DataSymInd = 1;                                                 % 输入系统数据流索引    
    %% 资源映射，先频域再时域
    for TimeInd = 1 : ReTimeNum                                     
        for FreInd = 1 : ReFreNum
            if RS_MAP_MATRIX(FreInd, TimeInd,1) == 1                      %数据位置对应放置生成的数据
               SymOfdmIn(FreInd, TimeInd) = DataSymIn(RankInd,DataSymInd);
               DataSymInd = DataSymInd + 1;
            end
        end
    end
    
    DeInterLeaveOut = RB_bundle_De_Interleaver(SymOfdmIn,pdschConfig);

    %% 解资源映射
    DataSymInd = 1;
    for TimeInd=1:ReTimeNum
        for FreInd=1:ReFreNum
            if RS_MAP_MATRIX(FreInd, TimeInd) == 1                                  % 根据映射矩阵确定数据时频位置
                DataSymOut(RankInd,DataSymInd) = DeInterLeaveOut(FreInd, TimeInd);        % 输出的数据向量
                DataSymInd=DataSymInd+1;
            end     
        end
    end            
end