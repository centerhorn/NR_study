%% Function Description
%  scrambling according to TS38.211 Section 7.3.1
%% Input
%  nID:  double
%        NCell ID for gnb     
%  RNTI: double
%        RNTI for pdsch
%  cwindex: double
%           the index of codeword, which is selected from{0,1}
%  cwsize:  double
%          the length of each codeword, which determines the length of pseudo random sequence output
            
%% Output
%  cRandom£ºrow vector
%           whose length equals to the length of each codeword input.
%% Modify History
%  2018/04/16 created by Sharon Sha
%  2018/05/18 modified by Song Erhao(editorial changes only)
%% Code
function cRandom = nrScrambling(nID,RNTI,cwindex,cwsize)  %#OK

Cinit = dec2bin(RNTI*2^15 +cwindex*2^14+nID);
Cinit = dec2base(Cinit, 2, 31);      % invert number to string of length 31
Cinit = str2num(Cinit(:))';          % invert string to vector
Cinit = fliplr(Cinit);               % the least important bit should be placed first

cRandom = GeneratePseudoRandomSeq(cwsize, Cinit);

end