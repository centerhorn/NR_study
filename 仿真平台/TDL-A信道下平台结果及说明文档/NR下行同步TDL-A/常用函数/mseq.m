function seq = mseq(connections,registers)
%=========================================================================
%本函数产生一个周期长度的m序列
%输入参数：connections是m序列的生成多项式的向量，registers是寄存器的初始化向量
%输出参数：seq是生成的一个周期的m序列
%2009.10.4================================================================  
n = length (registers);
N = 2^n - 1;
seq = zeros(1,N);
for ii = 1:N
    seq(ii) = registers(n); %先弹出最高位寄存器的值
    newreg = mod(sum(connections(2:n+1).*registers),2); %算出新的应该弹入最低位寄存器的值
    for jj = n:-1:2
        registers(jj) = registers(jj-1); %寄存器移位
    end
    registers(1) = newreg; %把新的应该弹入最低为寄存器的值弹入
end