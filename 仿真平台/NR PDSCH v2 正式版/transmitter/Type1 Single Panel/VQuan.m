%% 函数功能：
% 用于生成codebook的函数
%% 输入参数：
% L：序号
% m：序号
% O1,O2：CodeBook相关参数O1,O2
% N1,N2：CodeBook相关参数N1,N2
%% 输出参数
% Vlm：函数值
%% Modify history
% 2018/1/9 created by Liu Chunhua
%% code
function VlmQuan = VQuan(L,m,O1,N1,O2,N2)
    VlmQuan=[];
    Um = U(m,O2,N2); 
    for N1Ind = 0:(N1/2-1)
        VlmQuan=[VlmQuan,exp(1i*4*pi*L*N1Ind/O1/N1)*Um];
    end
    VlmQuan = VlmQuan.';
end