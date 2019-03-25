function [ BGSign ] = LDPC_Base_Graph_Select( DataLen,R)
%% 函数功能：
% LDPC基图选择
%% 输入参数：
% DataLen：数据信号长度
% R：MCS中的码率
%% 输出参数：
% BGSign：选择的基图序号
%% Modify history
% 2018/1/19 created by Liu Chunhua 
%% code

if DataLen <=292 || (DataLen<=3824 && R<=0.67) || R<=0.25
    BGSign = 2;
else
    BGSign = 1;
end

end

