%% Function Description
%  LDPC Rate Match and code blocks concatenate(refer to 3GPP TS38.211 Sec.7.4.1.1)
%% Input
%  input：Cell array with C K-dimension row vectors. 
%         Code blocks after LDPC encode
%  cbsize:C-dimension column vector
%         length of each codeblock
%  rmsize:C-dimension column vector
%         length of each codeblock after rateMatching
%  rv:    double
%         Redundancy version
%  bgSign:double
%         bgSign type
%  Modu : double
%         Modulation order
%% Output
%  output: double array
%          data after rateMatching and code blocks concatenate
%          
%% Modify History
%  modified by Sharon Sha 
%  2018/05/25 modified by Song Erhao

function output = nrRateMatchLDPC(input,cbsize,rmsize,rv,bgSign,Modu)

    cbnum = length(input);
    output = [];    
    for cbindex = 1:cbnum         
        output = [output;cbRateMatch(input{cbindex},cbsize(cbindex),rmsize(cbindex),rv,bgSign,Modu)]; 
    end
    output = output';
    
end

%rate matching for a single code block segment for LDPC
function cboutput = cbRateMatch(cbinput,cbsize,cbrmsize,rv,bgSign,Modu)

%     Modu=2;%自适应AMC中需去掉  
    [encL, decL, Z, LDPCinflen, LDPCcodelen] = MatrixSet(cbsize,bgSign);
    cboutput = RateMatchLDPC(cbinput,cbrmsize,rv,Z,bgSign,Modu).';
    
end
