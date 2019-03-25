function y = PSS( nid2 )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
oone=ones(1,127);
sn_gen = [1 0 0 1 0 0 0 1]; %生成多项式向量

sn_reg = [1 1 1 0 1 1 0];  %初始化寄存器向量
sn_m = mseq(sn_gen, sn_reg);
sn = oone -2* sn_m;
y = zeros(1,127);
    switch(nid2)
        case 0,
            y = sn;
        case 1,
            y = circshift(sn',43)';
        case 2, 
            y = circshift(sn',86)';
        otherwise
            disp('nid2必须是0-2整数');
    end

end

