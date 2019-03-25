%% 程序功能：生成离线信道文件

%移动终端的速度
v=3/3.6;
%载波频率
fc=40*10^9;
%产生信道文件的采样周期
period=1*10^(-3)/(SUBCARRIER_SPACE/15);      % 一个子帧的持续时间(s)
Ts=1*10^(-3)/SUBCARRIER_SPACE/IFFT_SIZE;    % (s)
%多径的数目
N=23;
for u=1:UE_ANT_NUM
    for s=1:NB_ANT_NUM
        % 打开文件
        fid1=fopen(['TU_channel_An' num2str(s) num2str(u) '_I.bin'],'wb');
        fid2=fopen(['TU_channel_An' num2str(s) num2str(u) '_Q.bin'],'wb');
        %%%%%%%%%%%%%产生数据文件%%%%%%%%%%%%%%
        channel_state=rand(1,N)*sum(100*clock);
        for I=1:BLOCK_NUM

            t=[(I-1)*period:Ts:I*period-Ts];

            for n=1:N
                channel=Jakes_gen(v,fc,t,channel_state(n));
                h_I(n,:)=real(channel);
                h_Q(n,:)=imag(channel);
            end
            fwrite(fid1,h_I.','float32');
            fwrite(fid2,h_Q.','float32');
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        fclose(fid1);
        fclose(fid2);
    end
end