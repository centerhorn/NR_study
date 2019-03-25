function [ceil_id2, Pss_location, CFO] = PSS_detect_MP_FP_LOW(data, ifft_length, N, Window , noise_power)
CFO = 0;
global PSS_LOW;
 
len = Window/N;
B = ifft_length/N;

M = 2; % 分段数
L = B/M;  %每段的长度
MaxValue = 0;
Pss_location = 0;
cor = 0;
%==============PSS synchronization==========
for d = 1:10000
        for n = 0:2
            current_pss = PSS_LOW(n+1, :);            
            cor = abs(data(d:d+ifft_length-1)*current_pss');
            cordata(d,n+1) = cor;
            if MaxValue < cor
                MaxValue = cor;
                ceil_id2 = n;
                Pss_location = d;
            end
        end
end