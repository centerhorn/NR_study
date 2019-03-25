%% Function Description
%  code block desegment and CB CRC decoding
%% Input
%  cbs; Cell array with C K-dimension row vectors. 
%       Code blocks after LDPC Decode
%% Output
%  blk: B-Dimension row vector
%       TB after add CRC
%  ERR: row vector
%       state of CB crc check,if only 1 CB, retur []
%% Modify history
% 2018/3/27 created by Liu Chunhua 
% 2018/05/22 modified by Song Erhao(editorial changes only)

function [blk,ERR] = nrCodeBlockDesegmentLDPC(cbs)
% 确定码块个数
C = length(cbs);
if C==1
    blk = cbs{1};
    ERR = [];
end

if C>1
    ERR = zeros(1,C);
    blk = [];
    for CBInd = 1:C
        CBTemp = cbs{CBInd};
        [CBInfor,ERR(CBInd)] = nrCBCRCDecode(CBTemp);
        blk = [blk,CBInfor];
    end
end

end