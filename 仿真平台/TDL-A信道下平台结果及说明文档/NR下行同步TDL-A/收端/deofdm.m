%�ó���������ɶ������źŽ���OFDM���
%���ߣ�������  
%������ڣ�2005��3��7

function [y]=deofdm(x,sub_carrier_num,ifft_length)

%��ÿ�����Ž���FFT����
fre_domain_x=fft(x)*sqrt(sub_carrier_num)/ifft_length;
%ȥ������ʱ��ӵ����
y=[fre_domain_x([ifft_length-sub_carrier_num/2+1:end]) fre_domain_x(1+[1:sub_carrier_num/2])];