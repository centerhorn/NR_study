%% �������ܣ�
% ��������codebook�ĺ���
%% ���������
% L�����
% m�����
% O1,O2��CodeBook��ز���O1,O2
% N1,N2��CodeBook��ز���N1,N2
%% �������
% Vlm������ֵ
%% Modify history
% 2018/1/9 created by Liu Chunhua
%% code
function Vlm = V(L,m,O1,N1,O2,N2)
    Vlm=[];
    Um = U(m,O2,N2); 
    for N1Ind = 0:(N1-1)
        Vlm=[Vlm,exp(1i*2*pi*L*N1Ind/O1/N1)*Um];
    end
    Vlm = Vlm.';
end