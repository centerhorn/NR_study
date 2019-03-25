%% Function Description
%   Demodulate
%% Input
%   data_in:   row vector
%              symbols after layer demapping
%   Qm     :   double
%              Modulation order
%   Snr_in :   row vector
%              SINR of data after layer demapping

%% Output
%   DeQamOut : row vector
%              bits after Demodulate
%% Modify history
% 2017/10/30 created by Liu Chunhua
% 2018/5/22 modified by Song Erhao(editorial changes only)


function  DeQamOut = nrSymbolDemodulate(data_in, Qm,Snr_in)   
    len_input=length(data_in);
    h = ones(1,len_input);
    switch (Qm)                            % 1：BPSK；2：QPSK；4：16QAM；6：64QAM
    %% PI/2-BPSK    
    case 0
        n_power=1./Snr_in;   
%         hTemp = reshape(h,2,len_input/2);
%         n_powerTemp = reshape(n_power,2,len_input/2);
        
        constel_diagram_odd = [-sqrt(2)/2+sqrt(2)/2*1i,sqrt(2)/2-sqrt(2)/2*1i];%奇数位的星座映射
        constel_diagram_even = [sqrt(2)/2+sqrt(2)/2*1i,-sqrt(2)/2-sqrt(2)/2*1i];%偶数位的星座映射
        DataTemp = reshape(data_in,2,len_input/2);
        
        d0_odd = abs(DataTemp(1,:) - constel_diagram_odd(1));
        d1_odd = abs(DataTemp(1,:) - constel_diagram_odd(2));
        DOdd = d1_odd.^2-d0_odd.^2;
 
        d0_even = abs(DataTemp(2,:) - constel_diagram_even(1));
        d1_even = abs(DataTemp(2,:) - constel_diagram_even(2));
        DEven = d1_even.^2-d0_even.^2;
        
        DTemp = [DOdd;DEven];
        DTemp2 = reshape(DTemp,1,len_input);
        
        DeQamOut = 1.*DTemp2./(n_power.*(1./((abs(h)).^2)));
        
    %% BPSK
    case 1
        n_power=1./Snr_in; 
        constel_diagram = [sqrt(2)/2+sqrt(2)/2*1i,-sqrt(2)/2-sqrt(2)/2*1i];
        d0 = abs(data_in - constel_diagram(1));
        d1 = abs(data_in - constel_diagram(2));
        DeQamOut = 1.*(d1.^2-d0.^2)./(n_power.*(1./((abs(h)).^2)));
        
   %% QPSK
    case 2                                       
        n_power=1./Snr_in;
        h_square=abs(h).^2; 
        D = 1/sqrt(2);
        
        r1 = real(data_in);
        r2 = imag(data_in);
        
        llr_0 = 1./n_power.*h_square*4*D.*r1;        
        llr_1 = 1./n_power.*h_square*4*D.*r2;       
        
        DeQamOutTemp = [llr_0;llr_1];
        DeQamOut = reshape(DeQamOutTemp,1,2*len_input);
   %% 16QAM 参照龙航软解调,这个输出的是1的概率除以0的概率，所以要取负
    case 4   
        n_power=1./Snr_in;
        h_square=abs(h).^2; 
        D = 1/sqrt(10);
        
        r1 = real(data_in);
        r2 = imag(data_in);
        
        llr_0 = 1./n_power.*h_square*4*D.*r1;        
        llr_1 = 1./n_power.*h_square*4*D.*r2;       
        llr_2 = 1./n_power.*h_square*4*D.*(2*D-abs(r1));
        llr_3 = 1./n_power.*h_square*4*D.*(2*D-abs(r2));
        
        DeQamOutTemp = [llr_0;llr_1;llr_2;llr_3];
        DeQamOut = reshape(DeQamOutTemp,1,4*len_input);
        
   %% 64QAM
    case 6                                
        n_power=1./Snr_in;
        h_square=abs(h).^2; 
        D = 1/sqrt(42);
        
        r1 = real(data_in);
        r2 = imag(data_in);
        
        llr_0 = 1./n_power.*h_square*4*D.*r1;        
        llr_1 = 1./n_power.*h_square*4*D.*r2;       
        llr_2 = 1./n_power.*h_square*4*D.*(4*D-abs(r1));
        llr_3 = 1./n_power.*h_square*4*D.*(4*D-abs(r2));
        llr_4 = 1./n_power.*h_square*4*D.*(2*D-abs(abs(r1)-4*D));
        llr_5 = 1./n_power.*h_square*4*D.*(2*D-abs(abs(r2)-4*D));
        
        DeQamOutTemp = [llr_0;llr_1;llr_2;llr_3;llr_4;llr_5];
        DeQamOut = reshape(DeQamOutTemp,1,6*len_input);
    case 8                                
        n_power=1./Snr_in;
        h_square=abs(h).^2; 
        D = 1/sqrt(170);
        
        r1 = real(data_in);
        r2 = imag(data_in);
        
        llr_0 = 1./n_power.*h_square*4*D.*r1;        
        llr_1 = 1./n_power.*h_square*4*D.*r2;       
        llr_2 = 1./n_power.*h_square*4*D.*(8*D-abs(r1));
        llr_3 = 1./n_power.*h_square*4*D.*(8*D-abs(r2));
        
        llr_4 = 1./n_power.*h_square*4*D.*(4*D-abs(abs(r1)-8*D));
        llr_5 = 1./n_power.*h_square*4*D.*(4*D-abs(abs(r2)-8*D));
        
        llr_6 = 1./n_power.*h_square*4*D.*(2*D-abs(abs(abs(r1)-8*D)-4*D));
        llr_7 = 1./n_power.*h_square*4*D.*(2*D-abs(abs(abs(r2)-8*D)-4*D));
        
        DeQamOutTemp = [llr_0;llr_1;llr_2;llr_3;llr_4;llr_5;llr_6;llr_7];
        DeQamOut = reshape(DeQamOutTemp,1,8*len_input);
    otherwise
        disp('Error! Please input again');        
    end
end