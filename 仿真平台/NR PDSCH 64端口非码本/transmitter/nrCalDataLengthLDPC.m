%% Function Description
%  According to the length of the TB, calculate the data length after removing the CRC 
%% Input
% LP :            double
%                 TBS
% R  :            double
%                 rate
%% Output
%  data_len:      double
%                 data length after removing the CRC
%% Modify History
% 2017/10/28 created by Liu Chunhua 
% 2018/05/29 modified by Song Erhao 
%% 
function [ data_len] = nrCalDataLengthLDPC( Lp,R )
CRC_LENGTH_CB = 24;
CRC_LENGTH_TB16 = 16;
CRC_LENGTH_TB24 = 24;

% 基图选择
if (Lp - CRC_LENGTH_TB16)<=292 || ((Lp - CRC_LENGTH_TB16)<=3824 && R<=0.67) || R<=0.25
    BGSign = 2;
else
    BGSign = 1;
end
% 确定最大编码长度
if BGSign==1
   Kcb = 8448; 
elseif BGSign==2
   Kcb = 3840;  
end
% 确定分块个数
if Lp<=Kcb
    C = 1;
else
    C = ceil(Lp/Kcb);
end
% 确定数据长度
if C==1
    if Lp<=(3824+CRC_LENGTH_TB16)
        data_len=Lp-CRC_LENGTH_TB16;
    else
        data_len=Lp-CRC_LENGTH_TB24;
    end
elseif C>1
    data_len=Lp-CRC_LENGTH_TB24-CRC_LENGTH_CB*C;
end

end