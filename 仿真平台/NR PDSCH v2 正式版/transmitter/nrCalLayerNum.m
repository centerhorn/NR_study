%% Function Description
%  layer num for each cw(Reference to TS38.211 Section 7.3.1)
%% Input
%  RANK:        double
%               rank
%% Output
%  LayerNum£º   row vector.
%               layer num for each cw.
%% Modify History
% 2018/1/14 created by Liu Chunhua 
% 2018/5/29 modified by Song Erhao(editorial changes only)

function LayerNum = nrCalLayerNum(RANK)
if RANK<=4
   LayerNum = RANK;
elseif RANK==6 || RANK==8
   LayerNum = [RANK,RANK]/2;
elseif RANK==5
   LayerNum = [2,3];
elseif RANK==7
   LayerNum = [3,4]; 
end
end