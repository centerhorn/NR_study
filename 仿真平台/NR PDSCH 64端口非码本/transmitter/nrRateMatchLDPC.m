%% Function Description
%  LDPC Rate Match and code blocks concatenate(refer to 3GPP TS38.211 Sec.7.4.1.1)
%% Input
%  input£ºCell array with C K-dimension row vectors. 
%         Code blocks after LDPC encode
%  rmsize:C-dimension column vector
%         length of each codeblock after rateMatching
%  rv:    double
%         Redundancy version
%  Z: LDPC lifting size
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

function output = nrRateMatchLDPC(input,rmsize,rv,Z,bgSign,Modu)

    cbnum = length(input);  
    output = [];    
    for cbindex = 1:cbnum         
        output = [output;cbRateMatch(input{cbindex},rmsize(cbindex),rv,Z,bgSign,Modu)]; 
    end
    output = output';
    
end

%rate matching for a single code block segment for LDPC
function cboutput = cbRateMatch(cbinput,cbrmsize,rv,Z,bgSign,Modu)

    cboutput = RateMatchLDPC(cbinput,cbrmsize,rv,Z,bgSign,Modu).';
    
end
