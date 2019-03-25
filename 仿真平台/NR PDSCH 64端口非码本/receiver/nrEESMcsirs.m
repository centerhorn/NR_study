%% Function Description
%   combine SINRs after MIMO detection
%% Input
%  SINR_in:      cell array (1 or 2 cell)    
%                SINR after layer demapping,each array is a column vector 
%  CodeRate:     number
%                ue CodeRate ;
%  Qm      :     number
%                Modulation Order
%% Output
%  SINR_out :    row vector(1 or 2 element)
%                SINR after merging for each cw
%% Modify history
% 2018/6/13 created by Liu Chunhua 

function [SINR_out] = nrEESMcsirs(SINR_inin,CodeRate,Qm)
    SINR_in = reshape(SINR_inin,1,[]);
    coderate = CodeRate;
    switch lower(Qm)
        case {1}
            beta=1;
        case {2} % QPSKΪ2
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
        case {4} %16QAMΪ4
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
        case {6} % 64QAMΪ6
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
            else
               beta = 127.05;           
            end            
    end 
    N = size(SINR_in,2);
    matrix=exp((-1)*SINR_in/beta);
    SINR_out=(-1)*beta*log((1/N)*sum(matrix));
end

