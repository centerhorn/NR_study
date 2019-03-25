function config_global_parameters()
%% 函数功能：
% 配置全局变量
%% Modify history
% 2017/10/28 created by Liu Chunhua 
%% code

global_parameters;

BLOCK_NUM = 10;

SYS_BW = 100;%以PRB为单位
SUBCARRIER_PER_RB = 12;
SUBCARRIER_SPACE = 15;%单位kHz
SYMBOL_PER_SUBFRAME = 14;
PDCCH_LENTH=2;

NB_ANT_NUM = 1;
UE_ANT_NUM = 1;
MODULATION = 6;
CRC_LENGTH_CB = 24;
CRC_LENGTH_TB = 24;
IFFT_SIZE = 256;
T = IFFT_SIZE*15;

CP_LONG = 160* (IFFT_SIZE/2048);
CP_SHORT = 144* (IFFT_SIZE/2048);
LONG_CP_PERIOD=7;
MAX_CODE_LENTH = 6144;

DMRS_FREQUENCY = [2,4,6,8,10,12];
DMRS_TIME = [3];
NL=1;

PSS_ALLOCATED_LENGTH = 144;     %PSS sequence length allocated; 
SSS_ALLOCATED_LENGTH = 144;     %SSS sequence length allocated; 
NUM_SUBFRAME = 10;              %number of subframe per frame(for 10ms case);
SLOT_PERSUBFRAME = 2;           %the number of slots per subframe;
NUM_OFDM_SLOT = 7;              %the number of OFDM symbols per slot;
NUM_RB = 12;                    %the number of RBs of an OFDM symbol, 50RBs for 20M BandWidth;
NUM_SUBCARRIER_PER_RB = 12;       %the number of subcarriers of a RB; 
MODU_MODE = 2;                   %modulation mode, 2 for QPSK;
CP_LENGTH_SHORT = 18;           %CP_short length;
CP_LENGTH_LONG = 20;            %CP_long length;

%%%%%%%%%%%%%%%%%%%%%%%%%%%compute parameters
Ts = 1/(IFFT_SIZE*SUBCARRIER_SPACE*1e3);                                                         %采样周期(s)
NUM_USED_SUBCARRIER = NUM_RB*NUM_SUBCARRIER_PER_RB;                                     %the number of subcarriers used;
NUM_OFDM_PER_SUBFRAME = SLOT_PERSUBFRAME*NUM_OFDM_SLOT;                                 %the number of OFDM symbols per subframe;
NUM_OFDM_PER_FRAME =NUM_OFDM_PER_SUBFRAME*NUM_SUBFRAME;                                   %the number of OFDM symbols per frame
NUM_BITS_PER_SUBFRAME = NUM_USED_SUBCARRIER*NUM_OFDM_PER_SUBFRAME*MODU_MODE;               %the number of bits per subframe;
NUM_BITS_PER_FRAME = NUM_BITS_PER_SUBFRAME*NUM_SUBFRAME;                                  %the number of bits per frame;
SUBFRAME_LEN = CP_LENGTH_LONG * SLOT_PERSUBFRAME + CP_LENGTH_SHORT * SLOT_PERSUBFRAME* (NUM_OFDM_SLOT - 1)+ IFFT_SIZE * NUM_OFDM_PER_SUBFRAME; %the length of per subframe(include CP);
FRAME_LEN = SUBFRAME_LEN * NUM_SUBFRAME;                                                %the length of per frame(include CP);

%% 1/8量化pss
for id = 0:2
td_pss = pss_gen(id, IFFT_SIZE);
td_pss = td_pss/max(abs(td_pss));
pss_real = real(td_pss);
pss_imag = imag(td_pss);
for i=1:length(td_pss)
    if(pss_real(i)>-0.0625&&pss_real(i)<0.0625)
        a(i)=0;
    elseif(pss_real(i)>=0.0625&&pss_real(i)<0.1875)
        a(i)=0.125;
    elseif(pss_real(i)>=0.1875&&pss_real(i)<0.3125)
        a(i)=0.25;
    elseif(pss_real(i)>=0.3125&&pss_real(i)<0.4375)
        a(i)=0.375;
    elseif(pss_real(i)>=0.4375&&pss_real(i)<0.5625)
        a(i)=0.5;
    elseif(pss_real(i)>=0.5625&&pss_real(i)<0.6875)
        a(i)=0.625;
    elseif(pss_real(i)>=0.6875&&pss_real(i)<0.8125)
        a(i)=0.75;
    elseif(pss_real(i)>=0.8125&&pss_real(i)<0.9375)
        a(i)=0.875;
    elseif(pss_real(i)>=0.9375&&pss_real(i)<=1)
        a(i)=1;
        
    elseif(pss_real(i)<=0.0625&&pss_real(i)>-0.1875)
        a(i)=-0.125;
    elseif(pss_real(i)<=-0.1875&&pss_real(i)>-0.3125)
        a(i)=-0.25;
    elseif(pss_real(i)<=-0.3125&&pss_real(i)>-0.4375)
        a(i)=-0.375;
    elseif(pss_real(i)<=-0.4375&&pss_real(i)>-0.5625)
        a(i)=-0.5;
    elseif(pss_real(i)<=-0.5625&&pss_real(i)>-0.6875)
        a(i)=-0.625;
    elseif(pss_real(i)<=-0.6875&&pss_real(i)>-0.8125)
        a(i)=-0.75;
    elseif(pss_real(i)<=-0.8125&&pss_real(i)>-0.9375)
        a(i)=-0.875;
    elseif(pss_real(i)<=-0.9375&&pss_real(i)>=-1)
        a(i)=-1;
    end
end
% 虚部
for i=1:length(td_pss)
    if(pss_imag(i)>-0.0625&&pss_imag(i)<0.0625)
        d(i)=0;
    elseif(pss_imag(i)>=0.0625&&pss_imag(i)<0.1875)
        d(i)=0.125;
    elseif(pss_imag(i)>=0.1875&&pss_imag(i)<0.3125)
        d(i)=0.25;
    elseif(pss_imag(i)>=0.3125&&pss_imag(i)<0.4375)
        d(i)=0.375;
    elseif(pss_imag(i)>=0.4375&&pss_imag(i)<0.5625)
        d(i)=0.5;
    elseif(pss_imag(i)>=0.5625&&pss_imag(i)<0.6875)
        d(i)=0.625;
    elseif(pss_imag(i)>=0.6875&&pss_imag(i)<0.8125)
        d(i)=0.75;
    elseif(pss_imag(i)>=0.8125&&pss_imag(i)<0.9375)
        d(i)=0.875;
    elseif(pss_imag(i)>=0.9375&&pss_imag(i)<=1)
        d(i)=1;
        
    elseif(pss_imag(i)<=0.0625&&pss_imag(i)>-0.1875)
        d(i)=-0.125;
    elseif(pss_imag(i)<=-0.1875&&pss_imag(i)>-0.3125)
        d(i)=-0.25;
    elseif(pss_imag(i)<=-0.3125&&pss_imag(i)>-0.4375)
        d(i)=-0.375;
    elseif(pss_imag(i)<=-0.4375&&pss_imag(i)>-0.5625)
        d(i)=-0.5;
    elseif(pss_imag(i)<=-0.5625&&pss_imag(i)>-0.6875)
        d(i)=-0.625;
    elseif(pss_imag(i)<=-0.6875&&pss_imag(i)>-0.8125)
        d(i)=-0.75;
    elseif(pss_imag(i)<=-0.8125&&pss_imag(i)>-0.9375)
        d(i)=-0.875;
    elseif(pss_imag(i)<=-0.9375&&pss_imag(i)>=-1)
        d(i)=-1;
    end
end
quantification_pss(id+1,:) = a + d*1i;   
end
 PSS_QUALIFY = quantification_pss;
 %% 正常pss
 for n = 0:2
  PSS_NORMAL(n+1,:) = pss_gen(n, IFFT_SIZE);
 end
 %% 低量化精度1/4
for id = 0:2
td_pss = pss_gen(id, IFFT_SIZE);
td_pss = td_pss/max(abs(td_pss));
pss_real = real(td_pss);
pss_imag = imag(td_pss);
for i=1:length(td_pss)
    if(pss_real(i)>-0.125&&pss_real(i)<0.125)
        b(i)=0;
    elseif(pss_real(i)>=0.125&&pss_real(i)<0.375)
        b(i)=0.25;
    elseif(pss_real(i)>=0.375&&pss_real(i)<=0.625)
        b(i)=0.5;
        elseif(pss_real(i)>=0.625&&pss_real(i)<=0.875)
        b(i)=0.75;
        elseif(pss_real(i)>=0.875&&pss_real(i)<=1)
        b(i)=1;
        
    elseif(pss_real(i)<=-0.125&&pss_real(i)>-0.375)
        b(i)=-0.25;
    elseif(pss_real(i)<=-0.375&&pss_real(i)>=-0.625)
        b(i)=-0.5;
        elseif(pss_real(i)<=-0.625&&pss_real(i)>=-0.875)
        b(i)=-0.75;
        elseif(pss_real(i)<=-0.875&&pss_real(i)>=-1)
        b(i)=-1;
    end
end
% 虚部
for i=1:length(td_pss)
    if(pss_imag(i)>-0.125&&pss_imag(i)<0.125)
        e(i)=0;
    elseif(pss_imag(i)>=0.125&&pss_imag(i)<0.375)
        e(i)=0.25;
    elseif(pss_imag(i)>=0.375&&pss_imag(i)<=0.625)
        e(i)=0.5;
        elseif(pss_imag(i)>=0.625&&pss_imag(i)<=0.875)
        e(i)=0.75;
        elseif(pss_imag(i)>=0.875&&pss_imag(i)<=1)
        e(i)=1;
        
    elseif(pss_imag(i)<=-0.125&&pss_imag(i)>-0.375)
        e(i)=-0.25;
    elseif(pss_imag(i)<=-0.375&&pss_imag(i)>=-0.625)
        e(i)=-0.5;
        elseif(pss_imag(i)<=-0.625&&pss_imag(i)>=-0.875)
        e(i)=-0.75;
        elseif(pss_imag(i)<=-0.875&&pss_imag(i)>=-1)
        e(i)=-1;
    end
end
quantification_pss_low(id+1,:) = b + e*1i;   
end
PSS_LOW = quantification_pss_low;
end

