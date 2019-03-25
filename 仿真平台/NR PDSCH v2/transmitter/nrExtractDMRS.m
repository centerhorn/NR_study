%% Function Description
%  Extract DMRS sequence value
%% Input
%  DMRSGrid :   3-Dimensional array (subcarrier-symbol-rank).
%               DMRS sequence mapping for all layers.
%% Output
%  DRMSSeq :    2-Dimensional array(Rank-DMRSReNums)
%               DMRS sequence
%% Modify History
%  2018/06/01 modified by Song Erhao

function [DMRSSeq] = nrExtractDMRS(DMRSGrid)

rank = size(DMRSGrid,3);
ReFreNum  =size(DMRSGrid,1);
ReTimeNum = size(DMRSGrid,2);
PilotSize = sum(sum(DMRSGrid(:,:,1) ~=0));
DMRSSeq = zeros(rank,PilotSize);

for RankInd = 1:rank
    PilotSymInd = 1;
    for TimeInd=1:ReTimeNum
        for FreInd=1:ReFreNum
            if DMRSGrid(FreInd, TimeInd) ~=0                                  % 根据映射矩阵确定数据时频位置
                DMRSSeq(RankInd,PilotSymInd) = DMRSGrid(FreInd, TimeInd,RankInd);        % 输出的数据向量
                PilotSymInd=PilotSymInd+1;
            end
            
        end
    end
end
end