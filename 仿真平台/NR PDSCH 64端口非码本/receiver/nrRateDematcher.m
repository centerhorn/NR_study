%% Function Description
%  Rate Dematcher
%% Input
%  input :    column vector
%             a cw after Descrambling
%  cbsize :   C-dimension column vector
%             length of each codeblock
%  rmsize :   C-dimension column vector
%             length of each codeblock after rateMatching
%  rv     :   double
%             Redundancy version
%  cbsbuffer :Cell array with C K-dimension row vectors. 
%             Code blocks buffer for data merge
%  Modu      :double
%             Modulation order
%% Output
%  output    :Cell array with C K-dimension row vectors. 
%             Code blocks after RateDematcher
%  cbsbuffer :Cell array with C K-dimension row vectors. 
%             Code blocks buffer for data merge
%% Modify History
%  2018/05/23 modified by Song Erhao


function [output,cbsbuffer] = nrRateDematcher(input,cbssize,rmsize,rv,Z,BGSign,LDPCinflen,LDPCcodelen,cbsbuffer,Modu)

    % De-concatenate the received soft bits
    cbnum = length(cbssize); % Number of code blocks
    deconcatenated = cell(1,cbnum);
    for cbindex=1:cbnum
        deconcatenated{cbindex} = input(1:rmsize(cbindex));
        input(1:rmsize(cbindex)) = [];
    end

    output = cell(1,cbnum); % Circular buffer
    for cbindex=1:cbnum
        if isempty(cbsbuffer)
            output{cbindex} = cbRateRecover(deconcatenated{cbindex},cbssize(cbindex),rv,Z,BGSign,LDPCinflen,LDPCcodelen,cbsbuffer,Modu);
            output{cbindex} = output{cbindex}.';
            cbsbuffer{cbindex} = output{cbindex};
        else
            output{cbindex} = cbRateRecover(deconcatenated{cbindex},cbssize(cbindex),rv,Z,BGSign,LDPCinflen,LDPCcodelen,cbsbuffer{cbindex},Modu);
            output{cbindex} = output{cbindex}.';
            cbsbuffer{cbindex} = output{cbindex};
        end
    end
end

function cboutput = cbRateRecover(cbinput,cbsize,rv,Z,BGSign,LDPCinflen,LDPCcodelen,cbbuffer,Modu)

    LDPCchecklen = LDPCcodelen-LDPCinflen;
    cboutput = DeRateMatchLDPC(cbinput,LDPCchecklen+cbsize-2*Z,rv,Z,BGSign,Modu).';
    if ~isempty(cbbuffer)
        cboutput = cboutput + cbbuffer';
    end
    
    
end