%% Function Description
%  Generate pseudo-random sequence for PDSCH DMRS (refer to 3GPP TS38.211 Sec.7.4.1.1.1)
%% Input
%  Mdmrs: double.
%         The length of PDSCH DMRS pseudo-random sequence.
%  ns: double.
%      The current slot index in the current subframe, starting from 0.
%  cell_id: double.
%           Cell ID.
%  l: double.
%     OFDM symbol index within the slot.
%% Output
%  DMRSSeq£ºrow vector of length Mdmrs.
%           PDSCH DMRS sequence.
%% Modify History
%  2018/01/04 created by Liu Chunhua 
%  2018/04/19 modified by Li Yong
%%
function DMRSSeq = nrPdschDmrs(Mdmrs,ns,cell_id, l)  %#OK
nSCID = 0;                           % assume default setting
NIDnSCID = cell_id;                  % assume default setting
cInit = mod(2^17*(14*ns+l+1)*(2*NIDnSCID+1)+2*NIDnSCID+nSCID, 2^31);    % ATTENTION: the former is lower-case letter l and the latter is digit 1
cInit = dec2base(cInit, 2, 31);      % invert number to string of length 31
cInit = str2num(cInit(:))';          % invert string to vector
cInit = fliplr(cInit);               % the least important bit should be placed first

MPN = 2*Mdmrs;
c = GeneratePseudoRandomSeq(MPN, cInit);
cTemp = reshape(c, 2, Mdmrs);
DMRSSeq = 1/sqrt(2)*(1-2*cTemp(1,:))+1i*1/sqrt(2)*(1-2*cTemp(2,:));
end