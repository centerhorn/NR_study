%% Function Description
%  TB CRC Check
%% Input
%  CBcrc;  B-Dimension row vector
%          CB after add CRC
%% Output
%  blk: A-Dimension row vector
%       TB after CRC check
%  ERR: row vector
%       state of TB crc check (1 means false)
%% Modify history
% 2018/3/27 created by Liu Chunhua
% 2018/05/22 modified by Song Erhao(editorial changes only)

function [blk,ERR] = nrCRCDecode(blkcrc,TrDataSize)
% get Polynomial
crcPolynomial24A = [1 1 0 0 0 0 1 1 0 0 1 0 0 1 1 0 0 1 1 1 1 1 0 1 1];
crcPolynomial24B = [1 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 1 0 0 0 1 1];
crcPolynomial24C = [1 1 0 1 1 0 0 1 0 1 0 1 1 0 0 0 1 0 0 0 1 0 1 1 1];
crcPolynomial6 = [1 1 0 0 0 0 1];
crcPolynomial16 = [1 0 0 0 1 0 0 0 0 0 0 1 0 0 0 0 1];
crcPolynomial11 = [1 1 1 0 0 0 1 0 0 0 0 1];
% CRC check
det = crc.detector(crcPolynomial24B);
[outdata,ERR] = detect(det,blkcrc');

blk = outdata';



end