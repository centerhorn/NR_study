%% Function Description
%  Generate pseudo-random sequence (refer to 3GPP TS38.211 Sec.5.2.1)
%% Input
%  MPN: double.
%       The length of pseudo-random sequence output.
%  cInit: row vector of length 31.
%         The initialization state of the second m-sequence.
%% Output
%  PseudoRandomSeq£ºrow vector of length MPN.
%                   Pseudo-random sequence.
%% Modify History
%  2018/01/04 created by Liu Chunhua 
%  2018/04/19 modified by Li Yong
%%
function PseudoRandomSeq = GeneratePseudoRandomSeq(MPN,cInit)  %#OK
Nc = 1600;
TotalLenC = Nc+MPN;
x1 = [1,zeros(1,30)];
x2 = cInit;
for n = 1:TotalLenC-31
    x1(n+31) = mod((x1(n+3)+x1(n)),2);
    x2(n+31) = mod((x2(n+3)+x2(n+2)+x2(n+1)+x2(n)),2);
end

PseudoRandomSeq = mod((x1(Nc+1:end)+x2(Nc+1:end)),2);
end