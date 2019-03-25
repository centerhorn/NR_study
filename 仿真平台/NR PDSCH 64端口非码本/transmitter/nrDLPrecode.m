%% 函数功能：
% 对传输层进行预编码操作
%% 输入参数：
% in：二维数组，行数为每层的符号数M_symb^layer，列数为层数nu
% codebook：预编码的码本,ap*nu维，ap为天线端口数，nu为层数
%% 输出参数：
% out：二维数组，行数为每个天线上的符号数M_symb^ap(=M_symb^layer)，列数为天线端口数
%% Modify history
% 2018/3/28 created by Liu Chunhua 
%% code
function out = nrDLPrecode(codebook,in)
% 预编码
%out = in*codebook.';
out = codebook*in;

end