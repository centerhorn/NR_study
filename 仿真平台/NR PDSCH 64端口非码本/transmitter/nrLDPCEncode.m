%% Function Description
%  LDPC Encode   according to TS38.212 Section 5.3.2
%% Input
%  input£º      Cell array with C K-dimension row vectors. 
%               Code blocks after code block segmentation and code block CRC attachment
%  realinflen:  real information length
%  Z:           LDPC lifting size
%  HbmatrixBit: check Matrix
%  LDPCinflen:  LDPC information length
%% Output
% output£ºCell array with C K-dimension row vectors. 
%         Code blocks after LDPCEncode
%% Modify History
% 2018/04/16 created by Sharon Sha
% 2018/05/16 modified by Song Erhao(editorial changes only)
%%

function output = nrLDPCEncode(input,realinflen,Z,HbmatrixBit,LDPCinflen)

    cbnum = length(input);
    output = cell(1,cbnum);   
    encL = comm.LDPCEncoder(HbmatrixBit);
    for cbindex=1:cbnum
       
        padbitlen = LDPCinflen-realinflen;
        output{cbindex} = singleCBLDPCEncode(input{cbindex}',encL,Z,LDPCinflen,padbitlen);
        
        output{cbindex} = output{cbindex}';
    end
    
end

%Encode a single code block segement by LDPC
function cboutput = singleCBLDPCEncode(cbinput,encL,Z,LDPCinflen,padbitlen)
    
    % adding padding bits
    infbit = [cbinput;zeros(padbitlen,1)];
    % LDPC encode
    encoutput = step(encL,infbit);
    cboutput = [cbinput((2*Z+1):end); encoutput((LDPCinflen+1):end)];
    
end
