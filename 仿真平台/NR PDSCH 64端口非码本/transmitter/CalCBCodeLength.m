%% Function Description
%  Calulate CB length after rate matching
%% Input
%  RealTBCodeLen£ºdouble
%                 TB length after rate matching.            
%  C:             Double. 
%                 CB numbers.
%  rank
%  modu
%% Output
%  RealCodeLen£ºC-dimension column vectors.
%               length of each CB after rate matching
%% Modify History
%  2018/05/18 created by Song Erhao  
%  2018/06/15 modified by Song Erhao
function RealCodeLen = CalCBCodeLength(RealTBCodeLen,C,rank,modu)

G = RealTBCodeLen;
RealCodeLen = zeros(C,1);
gamma = mod(G/(rank*modu),C);
for cIndex = 1: C
    if cIndex <= C-gamma
     %    RealCodeLen(cIndex) = floor(G/C);
        RealCodeLen(cIndex) = rank*modu*floor(G/C/rank/modu);
    else
      %  RealCodeLen(cIndex) = ceil(G/C);
       RealCodeLen(cIndex) = rank*modu*ceil(G/C/rank/modu);
    end


end
end