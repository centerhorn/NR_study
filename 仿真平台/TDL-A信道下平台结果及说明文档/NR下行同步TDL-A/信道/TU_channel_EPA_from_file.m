%% �������ܣ�
% ���ŵ��ļ��ж�ȡ�ŵ�
%% ���������
% block_index �����ݰ����
%% ���������
% H����ȡ���ŵ�
% delay_out�������ӳ�
% mul_path���ྶ��Ŀ
%% Modify history
% 2017/10/28 created by Liu Chunhua 
%% code
function[H,delay_out,mul_path]=TU_channel_EPA_from_file(block_index)
global T;
global UE_ANT_NUM;
global NB_ANT_NUM;
global BLOCK_NUM;
global SUBCARRIER_SPACE;
global IFFT_SIZE;

type_len=4;%float32
%�ྶ����Ŀ
mul_path=23;
%�����ŵ��ļ��Ĳ�������
Ts=1*10^(-3)/SUBCARRIER_SPACE/IFFT_SIZE;%(S)
%scaling parameters
delayspread=100*1e-9;
%%%%%%%%%%%���������ļ�%%%%%%%%%%%%%%
% channel_state=rand()*sum(100*clock);
normalized_delay=[0.0000,0.3819,0.4025,0.5868,0.4610,0.5375,0.6708,0.5750,0.7618,1.5375,1.8978,2.2242,2.1718,2.4942,2.5119,3.0582,4.0810,4.4579,4.5695,4.7966,5.0066,5.3043,9.6586];%%�������ӳ�ʱ��
delay=delayspread*normalized_delay;
delay_out=floor(delay/Ts);%%�������ӳٵ���
max_delay=max(delay_out);
relative_power=[-13.4,0,-2.2,-4,-6,-8.2,-9.9,-10.5,-7.5,-15.9,-6.6,-16.7,-12.4,-15.2,-10.8,-11.3,-12.7,-16.2,-18.3,-18.9,-16.6,-19.9,-29.7];%%�����Ĺ���
%normal:�����Ƿ��һ���ı�־��normal��1����relative_powerΪ��һ�����ʣ�����Ϊʵ��ͨ���˾����źŹ���
normal=1;
%�ź�ͨ���ŵ�ʱ����Է���ֵ
Am=sqrt(10.^(0.1*relative_power));
%�жϹ����Ƿ��һ��
if normal==1
    Am=Am./sqrt(sum(Am.^2));
end

for u=1:UE_ANT_NUM
    for s=1:NB_ANT_NUM
        for n=1:mul_path
            %���ŵ����������ļ�
            %Ѱ���ļ���ʼ��λ��
            temp_begin_position=0;%����ļ�ָ��
            temp_begin_position=T*mul_path*(mod(block_index-1,BLOCK_NUM))+(n-1)*T;
            fid_I=fopen(['TU_channel_An' num2str(s) num2str(u) '_I.bin'],'rb');
            fid_Q=fopen(['TU_channel_An' num2str(s) num2str(u) '_Q.bin'],'rb');
            flag=fseek(fid_I,temp_begin_position*type_len,-1);
            flag=fseek(fid_Q,temp_begin_position*type_len,-1);
            I=fread(fid_I,T,'float32');
            Q=fread(fid_Q,T,'float32');
            temp_begin_position_delay=0;
            temp_begin_position_delay=T*mul_path*mod((mod(block_index-1,BLOCK_NUM)+1),BLOCK_NUM)+(n-1)*T;
            flag=fseek(fid_I,temp_begin_position_delay*type_len,-1);
            flag=fseek(fid_Q,temp_begin_position_delay*type_len,-1);
            I_add=fread(fid_I,max_delay,'float32');
            Q_add=fread(fid_Q,max_delay,'float32');
            I=[I;I_add];
            Q=[Q;Q_add];
            temp_h=I+1i*Q;%%��������15436*1
            H(u,s,n,:)=temp_h*Am(n);%%����ص�
            fclose(fid_I);
            fclose(fid_Q);
        end
    end
end

    