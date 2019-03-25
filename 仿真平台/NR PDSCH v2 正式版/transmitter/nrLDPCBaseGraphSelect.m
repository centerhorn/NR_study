%% Function Description
%  LDPC base graph selection according to TS38.212 Section 7.2.2
%% Input
%  trBlkSize£ºDouble. 
%             Transport block size.
%  codeRate: Double. 
%            LDPC coding rate.
%% Output
%  bgSign£ºDouble.
%          LDPC base graph.
%% Modify History
%  2018/01/19 created by Liu Chunhua 
%  2018/04/04 modified by Li Yong
%%
function bgSign = nrLDPCBaseGraphSelect(trBlkSize, codeRate)

if trBlkSize <=292 || (trBlkSize <= 3824 && codeRate <= 0.67) || codeRate <= 0.25
    bgSign = 2;
else
    bgSign = 1;
end

end