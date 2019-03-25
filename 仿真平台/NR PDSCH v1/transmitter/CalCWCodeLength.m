%% Function Description
%  Calulate data length after rate matching
%% Input
%  ReNum£ºDouble. 
%             RE number used for PDSCH transmission.
%  modu: cell array. 
%            modulation for each cw.
%  rank: Double. 
%            rank for PDSCH.
%% Output
%  rmoutsizes£º2-dimension array(ncw-(data length after rate matching)).
%              data length after rate matching for each cw.
%% Modify History
%  2018/04/13 created by Liu Chunhua
%  2018/05/17 modified by Song Erhao(editorial changes only)
%%
function rmoutsizes = CalCWCodeLength(ReNum, modu, rank)
if rank <= 4
    ncw  = 1;
    LayerNum = rank;
else
    ncw = 2;
    LayerNum = [floor(rank/2), ceil(rank/2)];
end

if length(modu)~=ncw
    error('codeword number does not match the modulation configuration! ');
end

for cwInd = 1:ncw
    rmoutsizes(cwInd) = ReNum*modu(cwInd)*LayerNum(cwInd);
end

end