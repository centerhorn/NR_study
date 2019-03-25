%% Function Description
%  LDPC Encode   according to TS38.212 Section 5.3.2
%% Input
%  input£ºCell array with C K-dimension row vectors. 
%         Code blocks after code block segmentation and code block CRC attachment
%  bgSign: 1 or 2. 
%          LDPC base graph.
%% Output
% output£ºCell array with C K-dimension row vectors. 
%         Code blocks after LDPCEncode
%% Modify History
% 2018/04/16 created by Sharon Sha
% 2018/05/16 modified by Song Erhao(editorial changes only)
%%

function output = nrLDPCEncode(input,bgSign)

    cbnum = length(input);
    output = cell(1,cbnum);   
    for cbindex=1:cbnum
        output{cbindex} = singleCBLDPCEncode(input{cbindex}',bgSign);
        output{cbindex} = output{cbindex}';
    end
    
end

%Encode a single code block segement by LDPC
function cboutput = singleCBLDPCEncode(cbinput,bgSign)
    
    realinflen = length(cbinput);     
    [encL, decL, Z, LDPCinflen, LDPCcodelen] = MatrixSet(realinflen,bgSign);
    % adding padding bits
    padbit = LDPCinflen-realinflen;
    infbit = [cbinput;zeros(padbit,1)];
    % LDPC encode
    encoutput = step(encL,infbit);
    cboutput = [cbinput((2*Z+1):end); encoutput((LDPCinflen+1):end)];
    
end
