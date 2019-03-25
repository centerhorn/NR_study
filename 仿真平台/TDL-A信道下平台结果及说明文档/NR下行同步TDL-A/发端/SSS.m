function sss = SSS(nid1,nid2)
%生成x~(n)
xn_gen0 = [1 0 0 1 0 0 0 1]; %生成多项式向量
xn_gen1 = [1 0 0 0 0 0 1 1];  %初始化寄存器向量
xn_reg0 = [0 0 0 0 0 0 1];
xn_reg1 = [0 0 0 0 0 0 1];
xn0 = mseq(xn_gen0, xn_reg0);
xn1 = mseq(xn_gen1, xn_reg1);

%由nid_1得出m0和m1的值
m0 = 15*floor(nid1/112)+5*nid2;
m1 = mod(nid1,112);

%按照协议对m序列进行处理

for i=0:126
    y(i+1)=(1-2*xn0(mod((i+m0),127)+1))*(1-2*xn1(mod((i+m1),127)+1));
end
sss = y;
end