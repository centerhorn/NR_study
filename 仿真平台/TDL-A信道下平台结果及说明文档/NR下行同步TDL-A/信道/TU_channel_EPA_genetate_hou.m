%% �����ܣ����������ŵ��ļ�

%�ƶ��ն˵��ٶ�
v=3/3.6;
%�ز�Ƶ��
fc=40*10^9;
%�����ŵ��ļ��Ĳ�������
period=1*10^(-3)/(SUBCARRIER_SPACE/15);      % һ����֡�ĳ���ʱ��(s)
Ts=1*10^(-3)/SUBCARRIER_SPACE/IFFT_SIZE;    % (s)
%�ྶ����Ŀ
N=23;
for u=1:UE_ANT_NUM
    for s=1:NB_ANT_NUM
        % ���ļ�
        fid1=fopen(['TU_channel_An' num2str(s) num2str(u) '_I.bin'],'wb');
        fid2=fopen(['TU_channel_An' num2str(s) num2str(u) '_Q.bin'],'wb');
        %%%%%%%%%%%%%���������ļ�%%%%%%%%%%%%%%
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