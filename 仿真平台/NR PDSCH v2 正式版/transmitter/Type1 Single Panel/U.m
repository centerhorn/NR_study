%% �������ܣ�
% ��������codebook�ĺ���
%% ���������
% m�����
% O2��CodeBook��ز���O2
% N2��CodeBook��ز���N2
%% �������
% Um������ֵ
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