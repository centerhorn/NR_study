function seq = mseq(connections,registers)
%=========================================================================
%����������һ�����ڳ��ȵ�m����
%���������connections��m���е����ɶ���ʽ��������registers�ǼĴ����ĳ�ʼ������
%���������seq�����ɵ�һ�����ڵ�m����
%2009.10.4================================================================  
n = length (registers);
N = 2^n - 1;
seq = zeros(1,N);
for ii = 1:N
    seq(ii) = registers(n); %�ȵ������λ�Ĵ�����ֵ
    newreg = mod(sum(connections(2:n+1).*registers),2); %����µ�Ӧ�õ������λ�Ĵ�����ֵ
    for jj = n:-1:2
        registers(jj) = registers(jj-1); %�Ĵ�����λ
    end
    registers(1) = newreg; %���µ�Ӧ�õ������Ϊ�Ĵ�����ֵ����
end