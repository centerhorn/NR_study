function [ceil_id2, Pss_location, CFO] = PSS_detect(data, ifft_length, N, Window , Cp_length ,method )
CFO = 0;
FFO = 0;
IFO = 0;
global PSS_NORMAL;
global Ts;
global SUBCARRIER_SPACE;
len = length(PSS_NORMAL(1,:));
MaxValue = 0;
Pss_location = 0;
cor = 0;
IFO_array = [-1 0 1];
%==============PSS synchronization==========
if method==1
    for d = 1:Window
        for n = 0:2
            current_pss = PSS_NORMAL(n+1,:);            
            cor = abs(data(d:d+ifft_length-1)*current_pss');
            cordata(d,n+1) = cor;
            if MaxValue < cor
                MaxValue = cor;
                ceil_id2 = n;
                Pss_location = d;
            end
        end
    end
    % 小数倍频偏估计----------基于cp
    if(Pss_location-Cp_length>0)
        repeat_pss = data(Pss_location-Cp_length:Pss_location-1);
        cp = data(Pss_location+len-Cp_length:Pss_location+len-1);
        cor_cp = repeat_pss*cp';
        CFO = -angle(cor_cp)/(2*pi*len)*1/Ts;
%         CFO = -angle(cor_cp)/(2*pi*len)*ifft_length;
    end
elseif method==2
    for I = 1:length(IFO_array)
        for d = 1:Window
            for n = 0:2
                current_pss = PSS_NORMAL(n+1,:);            
                cor = abs(data(d:d+ifft_length-1).*exp(-1*j*2*pi*IFO_array(I)*SUBCARRIER_SPACE*1000*(d:d+ifft_length-1)*Ts)*current_pss');
                cordata(d,n+1) = cor;
                if MaxValue < cor
                    MaxValue = cor;
                    ceil_id2 = n;
                    Pss_location = d;
                    IFO = IFO_array(I)*SUBCARRIER_SPACE*1000;
                end
            end
        end
    end
  % 小数倍频偏估计----------基于cp
    if(Pss_location-Cp_length>0)
        repeat_pss = data(Pss_location-Cp_length:Pss_location-1);
        cp = data(Pss_location+len-Cp_length:Pss_location+len-1);
        cor_cp = repeat_pss*cp';
        FFO = -angle(cor_cp)/(2*pi*len)*1/Ts;
    end
    CFO =FFO+IFO;
end


