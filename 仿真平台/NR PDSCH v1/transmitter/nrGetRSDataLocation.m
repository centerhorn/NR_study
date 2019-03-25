%% Function Description
%  Get location of DMRS and Data,used for calculate Correlation matrix
%% Input
%  RS_MAP_MATRIX: 3-Dimensional array (subcarrier-symbol-rank).
%                  resource mapping matrix for DMRS,Data and PDCCH 
%% Output
%  DMRS_LOCATION: 3-Dimensional array (2(FreInd and TimeInd)-(number of DMRS RE)-rank)
%                 location of DMRS in the grid
%  DATA_LOCATION: 3-Dimensional array (2(FreInd and TimeInd)-(number of Data RE)-rank
%                 location of Data in the grid
%% Modify History
% 2018/05/21 modified by Song Erhao

function [DMRS_LOCATION,DATA_LOCATION] = nrGetRSDataLocation(RS_MAP_MATRIX)
[ReFreNum, ReTimeNum,RankNum] = size(RS_MAP_MATRIX);                        % ◊ ‘¥”≥…‰æÿ’Û
for RankInd = 1:RankNum
    DmrsLocaTemp = [];
    DataLocaTemp = [];
    for TimeInd = 1 : ReTimeNum                                     
        for FreInd = 1 : ReFreNum
            if RS_MAP_MATRIX(FreInd, TimeInd,RankInd) == 1                     
               DataLocaTemp = [DataLocaTemp,[FreInd;TimeInd]];
            elseif RS_MAP_MATRIX(FreInd, TimeInd,RankInd) == 2                 
               DmrsLocaTemp = [DmrsLocaTemp,[FreInd;TimeInd]];
            end
        end
    end  
    DMRS_LOCATION(:,:,RankInd) = DmrsLocaTemp;
    DATA_LOCATION(:,:,RankInd) = DataLocaTemp;
end
end