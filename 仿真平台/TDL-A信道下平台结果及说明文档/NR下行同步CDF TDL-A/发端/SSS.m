function sss = SSS(nid1,nid2)
%����x~(n)
xn_gen0 = [1 0 0 1 0 0 0 1]; %���ɶ���ʽ����
xn_gen1 = [1 0 0 0 0 0 1 1];  %��ʼ���Ĵ�������
xn_reg0 = [0 0 0 0 0 0 1];
xn_reg1 = [0 0 0 0 0 0 1];
xn0 = mseq(xn_gen0, xn_reg0);
xn1 = mseq(xn_gen1, xn_reg1);

%��nid_1�ó�m0��m1��ֵ
m0 = 15*floor(nid1/112)+5*nid2;
m1 = mod(nid1,112);

%����Э���m���н��д���

for i=0:126
    y(i+1)=(1-2*xn0(mod((i+m0),127)+1))*(1-2*xn1(mod((i+m1),127)+1));
end
sss = y;
end