%% Function Description
%  TB CRC Check
%% Input
%  blkcrc; B-Dimension row vector
%          TB after add CRC
%  TrDataSize: double
%              size of transmit data
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
if TrDataSize > 3824
    det = crc.detector(crcPolynomial24A);
    [outdata,ERR] = detect(det,blkcrc');
else
    det = crc.detector(crcPolynomial16);
    [outdata,ERR] = detect(det,blkcrc');
end
blk = outdata';



end