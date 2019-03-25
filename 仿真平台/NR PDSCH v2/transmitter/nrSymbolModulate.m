%% Function Description
%  symbol modulation according to TS38.211 Section 5.1
%% Input
%  input:      row vector
%              bit data after scrambling of each codeword   
%  Modulation: double
%              level of modulation
%              0:pi/2-BPSK 1£ºBPSK£»2£ºQPSK£»4£º16QAM£»6£º64QAM£»8£º245QAM
%% Output
%  modout:     row vector
%              symbols after modulation  
%% Modify History
%  2017/10/28 created by Liu Chunhua
%  2018/5/18  modified by Song Erhao(editorial changes only)
function modout = nrSymbolModulate(input,Modulation)

    % length of input data
    len=length(input);    
    switch (Modulation)                       
    %% pi/2-BPSK
    case 0
        b = input;
        modout=zeros(1,len);
        for I = 1:len
            modout(I) = exp(1i*pi/2*mod(I,2))/sqrt(2)*((1-2*b(I))+1i*(1-2*b(I)));
        end
   %% BPSK
    case 1
        b = input;
        modout=zeros(1,len);
        for I = 1:len
            modout(I) = 1/sqrt(2)*((1-2*b(I))+1i*(1-2*b(I)));
        end    
        
    %% QPSK
    case 2                                               
        modout=zeros(1,len/2);
        for I=1:len/2
            b = input((2*(I-1)+1):2*I);
            modout(I) = 1/sqrt(2)*((1-2*b(1))+1i*(1-2*b(2)));
        end
        
    %% 16QAM
    case 4                                               
        modout=zeros(1,len/4);
        for I=1:len/4
            b = input((4*(I-1)+1):4*I);
            modout(I) = 1/sqrt(10)*((1-2*b(1))*(2-(1-2*b(3)))+...
                1i*(1-2*b(2))*(2-(1-2*b(4))));
        end
        
    %% 64QAM
    case 6                                             
        modout=zeros(1,len/6);
        for I=1:len/6
            b = input((6*(I-1)+1):6*I);
            modout(I) = 1/sqrt(42)*((1-2*b(1))*(4-(1-2*b(3))*(2-(1-2*b(5))))+...
                1i*(1-2*b(2))*(4-(1-2*b(4))*(2-(1-2*b(6)))));
        end
      
    %% 256QAM
    case 8
        modout=zeros(1,len/8);
        for I=1:len/8
            b = input((8*(I-1)+1):8*I);
            modout(I) = 1/sqrt(170)*((1-2*b(1))*(8-(1-2*b(3))*(4-(1-2*b(5))*(2-(1-2*b(7)))))+...
                1i*(1-2*b(2))*(8-(1-2*b(4))*(4-(1-2*b(6))*(2-(1-2*b(8))))));
        end

    otherwise
        disp('Error! Please input again');
    end
   
end