function [ BGSign ] = LDPC_Base_Graph_Select( DataLen,R)
%% �������ܣ�
% LDPC��ͼѡ��
%% ���������
% DataLen�������źų���
% R��MCS�е�����
%% ���������
% BGSign��ѡ��Ļ�ͼ���
%% Modify history
% 2018/1/19 created by Liu Chunhua 
%% code

if DataLen <=292 || (DataLen<=3824 && R<=0.67) || R<=0.25
    BGSign = 2;
else
    BGSign = 1;
end

end

