%% �������ܣ�
% �Դ�������Ԥ�������
%% ���������
% in����ά���飬����Ϊÿ��ķ�����M_symb^layer������Ϊ����nu
% codebook��Ԥ������뱾,ap*nuά��apΪ���߶˿�����nuΪ����
%% ���������
% out����ά���飬����Ϊÿ�������ϵķ�����M_symb^ap(=M_symb^layer)������Ϊ���߶˿���
%% Modify history
% 2018/3/28 created by Liu Chunhua 
%% code
function out = nrDLPrecode(codebook,in)
% Ԥ����
%out = in*codebook.';
out = codebook*in;

end