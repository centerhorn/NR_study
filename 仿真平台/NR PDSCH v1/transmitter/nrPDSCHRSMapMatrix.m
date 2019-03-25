%% Function Description
%  form resource mapping matrix for DMRS£¬Data,PDCCH     
%% Input
%  DMRSMap£º    3-dimensional array (subcarrier-symbol-rank)
%               DMRS sequence mapping for all layers.
%% Output
%  RSMapMatrix£º   3-dimensional array (subcarrier-symbol-rank).
%                  resource mapping matrix for DMRS,Data and PDCCH 

%% Modify History
% 2018/1/13 created by Liu Chunhua 
% 2018/05/16 modified by Song Erhao(editorial changes only)
%%
function RSMapMatrix = nrPDSCHRSMapMatrix(DMRSMap, PDCCH_LOCATION)

RankNum = size(DMRSMap, 3);

DMRSMapDuplicate = DMRSMap;
DMRSMapDuplicate(find(DMRSMap~=0)) = 2;


DMRSMapSum = sum(DMRSMapDuplicate, 3);
CommonMapMatrix = zeros(size(DMRSMap, 1), size(DMRSMap, 2));
CommonMapMatrix(find(DMRSMapSum==0)) = 1;
CommonMapMatrix(find(DMRSMapSum~=0)) = 0;
CommonMapMatrix(:,PDCCH_LOCATION+1) = -1;

for RankInd = 1:RankNum
    RSMapMatrix(:,:,RankInd) = DMRSMapDuplicate(:,:,RankInd) + CommonMapMatrix;   % -1:PDCCH; 0:empty; 1:PDSCH; 2:DMRS
end

end