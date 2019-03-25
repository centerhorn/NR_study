%% Function Description
%  CRC calculation according to TS38.212 Section 5.1
%% Input
%  blk£ºA-dimension column vector. 
%       Transport block before CRC attachment.
%  poly: String. 
%        Cyclic generator polynominal. Valid values: {'24A', '24B', '24C',
%        '16', '11', '6'}.
%% Output
%  blkcrc£ºB-dimension row vectors, where B=A+L.
%          Transport block after CRC attachment.
%% Modify History
%  2018/03/27 created by Liu Chunhua 
%  2018/04/04 modified by Li Yong
%  2018/05/25 modified by Song Erhao
%%
function blkcrc = nrCRCEncode(blk)
 % Generator polynominal
    crcPolynomial24A = [1 1 0 0 0 0 1 1 0 0 1 0 0 1 1 0 0 1 1 1 1 1 0 1 1];
    crcPolynomial24B = [1 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 1 0 0 0 1 1];
    crcPolynomial24C = [1 1 0 1 1 0 0 1 0 1 0 1 1 0 0 0 1 0 0 0 1 0 1 1 1];
    crcPolynomial16 = [1 0 0 0 1 0 0 0 0 0 0 1 0 0 0 0 1];
    crcPolynomial11 = [1 1 1 0 0 0 1 0 0 0 0 1];
    crcPolynomial6 = [1 1 0 0 0 0 1];
 % Append CRC
 if length(blk) > 3824
     gen = crc.generator(crcPolynomial24A);
     blkcrc = generate(gen,blk);
 else
     gen = crc.generator(crcPolynomial16);
     blkcrc = generate(gen,blk);
 end
     blkcrc = blkcrc';
end
     
     
