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


function [output,cbsbuffer] = nrRateDematcher(input,cbssize,rmsize,rv,cbsbuffer,Modu)

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
            output{cbindex} = cbRateRecover(deconcatenated{cbindex},cbssize(cbindex),rv,cbsbuffer,Modu);
            output{cbindex} = output{cbindex}.';
            cbsbuffer{cbindex} = output{cbindex};
        else
            output{cbindex} = cbRateRecover(deconcatenated{cbindex},cbssize(cbindex),rv,cbsbuffer{cbindex},Modu);
            output{cbindex} = output{cbindex}.';
            cbsbuffer{cbindex} = output{cbindex};
        end
    end
end

function cboutput = cbRateRecover(cbinput,cbsize,rv,cbbuffer,Modu)

    rmoutlen = length(cbinput);
    % required coderate
    R = cbsize/rmoutlen;
    % obtain parameters for generating parity check matrix
    BGSign = LDPCBaseGraphSelect(cbsize,R);
    [encL, decL, Z, LDPCinflen, LDPCcodelen] = MatrixSet(cbsize, BGSign);
    LDPCchecklen = LDPCcodelen-LDPCinflen;
    %Modu = 2;%AMC自适应，需修改
    cboutput = DeRateMatchLDPC(cbinput,LDPCchecklen+cbsize-2*Z,rv,Z,BGSign,Modu).';
    if ~isempty(cbbuffer)
        cboutput = cboutput + cbbuffer';
    end
    
    
end