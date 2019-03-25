%% Function Description
%   combine SINRs after MIMO detection
%% Input
%  SINR_in:      cell array (1 or 2 cell)    
%                SINR after layer demapping,each array is a column vector 
%  CodeRate:     row vector
%                ue CodeRate for each CW ;
%  Qm      :     rwo vector
%                Modulation Order
%  modulated:    cell
%                each codeword after constellation mapping
%% Output
%  SINR_out :    row vector(1 or 2 element)
%                SINR after merging for each cw
%% Modify history
% 2017/10/28 created by Liu Chunhua 
% 2018/5/30 modified by Song Erhao

function [SINR_out] = nrEESM(SINR_in,CodeRate,Qm,modulated)
TBNum = size(SINR_in,1);
%首先根据调制阶数确定EESM中的beta值
for CWInd = 1:TBNum
    coderate = CodeRate(CWInd);
    switch lower(Qm(CWInd))
        case {1}
            beta=1;
        case {2} % QPSK为2
            if coderate<=1/3
                beta=1.49;
            elseif coderate<=2/5
                if abs(coderate-1/3)<=abs(coderate-2/5)
                    beta=1.49;
                else
                    beta=1.53;
                end
            elseif coderate<=1/2
                if abs(coderate-2/5)<=abs(coderate-1/2)
                    beta=1.53;
                else
                    beta=1.57;
                end
            elseif coderate<=3/5
                if abs(coderate-1/2)<=abs(coderate-3/5)
                    beta=1.57;
                else
                    beta=1.61;
                end
            elseif coderate<=2/3
                if abs(coderate-3/5)<=abs(coderate-2/3)
                    beta=1.61;
                else
                    beta=1.69;
                end
            elseif coderate<=3/4
                if abs(coderate-2/3)<=abs(coderate-3/4)
                    beta=1.69;
                else
                    beta=1.69;
                end                        
            elseif coderate<=4/5
                if abs(coderate-3/4)<=abs(coderate-4/5)
                    beta=1.69;
                else
                    beta=1.65;
                end 
            elseif coderate>4/5
                    beta=1.65;
            end
        case {4} %16QAM为4
            if coderate<=1/3
               beta=3.36;
            elseif coderate<=1/2
                if abs(coderate-1/3)<=abs(coderate-1/2)
                    beta=3.36;
                else
                    beta=4.56;
                end
            elseif coderate<=2/3
                if abs(coderate-1/2)<=abs(coderate-2/3)
                    beta=4.56;
                else
                    beta=6.42;
                end
            elseif coderate<=3/4
                if abs(coderate-2/3)<=abs(coderate-3/4)
                    beta=6.42;
                else
                    beta=7.33;
                end
            elseif coderate<=4/5
                if abs(coderate-3/4)<=abs(coderate-4/5)
                    beta=7.33;
                else
                    beta=7.68;
                end
            elseif coderate>4/5
                    beta=7.68;
            end
        case {6} % 64QAM为6
            if coderate<=1/3
               beta=9.21;
            elseif coderate<=2/5
                if abs(coderate-1/3)<=abs(coderate-2/5)
                    beta=9.21;
                else
                    beta=10.81;
                end
            elseif coderate<=1/2
                if abs(coderate-2/5)<=abs(coderate-1/2)
                    beta=10.81;
                else
                    beta=13.76;
                end
            elseif coderate<=3/5
                if abs(coderate-1/2)<=abs(coderate-3/5)
                    beta=13.76;
                else
                    beta=17.52;
                end
            elseif coderate<=2/3
                if abs(coderate-3/5)<=abs(coderate-2/3)
                    beta=17.52;
                else
                    beta=20.57;
                end
            elseif coderate<=17/24
                if abs(coderate-2/3)<=abs(coderate-17/24)
                    beta=20.57;
                else
                    beta=22.75;
                end 
            elseif coderate<=3/4
                if abs(coderate-17/24)<=abs(coderate-3/4)
                    beta=22.75;
                else
                    beta=25.16;
                end                        
            elseif coderate<=4/5
                if abs(coderate-3/4)<=abs(coderate-4/5)
                    beta=25.16;
                else
                    beta=28.38;
                end  
            elseif coderate>4/5
                    beta=28.38;
            end
        case {8} % 256QAM
            if coderate<=0.694
               beta=64.76;
            elseif coderate<=0.778
               beta = 190.22;
            elseif coderate<=1/2
               beta = 127.05;           
            end            
    end 
    N = length(modulated{CWInd});
   % matrix=exp((-1)*SINR_in(CWInd,1:N)/beta);
    matrix=exp((-1)*SINR_in{CWInd}(1:N)/beta);
    SINR_out(CWInd,:)=(-1)*beta*log((1/N)*sum(matrix));
end
end

