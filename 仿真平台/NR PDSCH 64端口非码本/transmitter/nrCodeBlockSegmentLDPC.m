%% Function Description
%  Code block segmentation and code block CRC attachement for LDPC
%  according to TS38.212 Section 5.2.2
%% Input
%  blk£ºB-dimension row vector. 
%       Transport block after CRC attachment.
%  bgSign: 1 or 2. 
%          LDPC base graph.
%% Output
% cbs£ºCell array with C K-dimension row vectors. 
%      Code blocks after code block segmentation and CRC attachement.
%% Modify History
% 2018/03/27 created by Liu Chunhua 
% 2018/04/04 modified by Li Yong
%%
function cbs = nrCodeBlockSegmentLDPC(blk, bgSign)

% maximum code block size
switch bgSign
    case 1
        Kcb = 8448;
    case 2
        Kcb = 3840;
    otherwise
        error('LDPC base graph should be either 1 or 2!');
end

% total number of code blocks
B = length(blk);
if B <= Kcb
    cbs{1} = blk;
else
    L = 24;
    C = ceil(B/(Kcb - L));
   % if mod(B,C) == 0
        cbLen = B/C;
        for cInd = 1:C
            % each code block before CRC attachment
            cbTemp = blk(((cInd-1)*cbLen+1):cInd*cbLen);
            % each code block after CRC attachment
            cbs{cInd} = nrCBCRCEncode(cbTemp);  %#ok<AGROW>
        end
   % else
       % error('The input transport block cannot be equally divided!');
    %end  
end

end