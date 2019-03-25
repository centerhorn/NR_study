%% Function Description
%  Calulate CB length after rate matching
%% Input
%  RealTBCodeLen��double
%                 TB length after rate matching.            
%  C:             Double. 
%                 CB numbers.
%% Output
%  RealCodeLen��C-dimension column vectors.
%               length of each CB after rate matching
%% Modify History
%  2018/05/18 created by Song Erhao 
function RealCodeLen = CalCBCodeLength(RealTBCodeLen,C)

G = RealTBCodeLen;
RealCodeLen = zeros(C,1);
gamma = mod(G,C);
for cIndex = 1: C
    if cIndex <= C-gamma
        RealCodeLen(cIndex) = floor(G/C);
    else
        RealCodeLen(cIndex) = ceil(G/C);
    end


end
end