%% 函数功能：
% 用于生成codebook的函数
%% 输入参数：
% m：序号
% O2：CodeBook相关参数O2
% N2：CodeBook相关参数N2
%% 输出参数
% Um：函数值
%% Modify history
% 2018/1/9 created by Liu Chunhua
%% code
function Um = U(m,O2,N2)
    if N2==1
       Um=1;
    elseif N2>1
       Um=[];
       for N2Ind = 0:(N2-1)
           Um=[Um,exp(1i*2*pi*m*N2Ind/O2/N2)];
       end
    end
end