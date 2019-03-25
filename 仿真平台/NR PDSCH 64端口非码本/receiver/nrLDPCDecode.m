%% Function Description
%  LDPC Decode
%% Input
%  input  :Cell array with C K-dimension row vectors. 
%          Code blocks after RateDematcher
%  cbssize:C-dimension column vector
%          length of each codeblock
%   rmsize :  C-dimension column vector
%             length of each codeblock after rateMatching
%% Output
%   output :Cell array with C K-dimension row vectors. 
%           Code blocks after LDPC Decode
%% Modify History
%  2018/05/22 modified by Song Erhao


function output = nrLDPCDecode(input,cbssize,Z,HbmatrixBit,LDPCinflen)

    ncbs = length(input);
    output = cell(1,ncbs);
    decL = comm.LDPCDecoder(HbmatrixBit);
    for index = 1:ncbs
        output{index} = singleCBSDecode(input{index}.',cbssize(index),Z,HbmatrixBit,LDPCinflen,decL);
        output{index} = output{index}.';
    end
    
end

% Decode a single code block segement
function output = singleCBSDecode(input,cbsize,Z,HbmatrixBit,LDPCinflen,decL)

    
    padbit = LDPCinflen-cbsize;
    DeModuLLR = [zeros(2*Z,1); input(1:cbsize-2*Z);10000*ones(padbit,1);input(cbsize-2*Z+1:end)];
    DeModuLLR(find(DeModuLLR>20))=20;
    DeModuLLR(find(DeModuLLR<-20))=-20; 
    % LDPCÒëÂë
    cbrx= step(decL,DeModuLLR);
    % ½âÌî³ä±ÈÌØ
    output = cbrx(1:cbsize);
        
end