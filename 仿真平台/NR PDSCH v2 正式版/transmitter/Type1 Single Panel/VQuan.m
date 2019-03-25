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
function VlmQuan = VQuan(L,m,O1,N1,O2,N2)
    VlmQuan=[];
    Um = U(m,O2,N2); 
    for N1Ind = 0:(N1/2-1)
        VlmQuan=[VlmQuan,exp(1i*4*pi*L*N1Ind/O1/N1)*Um];
    end
    VlmQuan = VlmQuan.';
end