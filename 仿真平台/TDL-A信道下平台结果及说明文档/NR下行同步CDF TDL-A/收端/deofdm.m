%该程序用来完成对输入信号进行OFDM解调
%作者：赵亚利  
%编程日期：2005－3－7

function [y]=deofdm(x,sub_carrier_num,ifft_length)

%对每个符号进行FFT运算
fre_domain_x=fft(x)*sqrt(sub_carrier_num)/ifft_length;
%去除调制时添加的零点
y=[fre_domain_x([ifft_length-sub_carrier_num/2+1:end]) fre_domain_x(1+[1:sub_carrier_num/2])];