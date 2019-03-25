%% Description: 
% Function ofdm_mod can be used to perform OFDM modulation operation,
% including IFFT and adding CP.
%% Input parameter:
% data: the input data to be OFDM modulated;
% ifft_length: the length of FFT/IFFT;
% num_OFDM_slot: the number of OFDM symbols per slot;
% Cp_length_long: the length of long CP; 
% Cp_length_short: the length of short CP;
%% Output parameter:
% data_ifft: the data after OFDM modulation;
%% Modify history:
% created by He Yuexia, 2017/3/9;
% modify by %%%;
%% Codes:
function [y]=ofdm_mod(data,ifft_length,num_OFDM_slot,Cp_length_long,Cp_length_short)

[num_used_subcarrier,num_OFDMperFrame] = size(data);

if ifft_length<num_used_subcarrier,
    disp('Input parameters error in insert0 function!');
    disp('ifft_length should larger than number of the row of data!')
    return;
end
if mod(num_used_subcarrier,2)~=0
    disp('Input parameters error in insert0 function!');
    disp('num_used_subcarrier should be even');
    return;
end

time_domain_frame_port0 = [];
for I_symbol = 1:num_OFDMperFrame
    %frequency mapping
    data_to_ifft([1:ifft_length])=[data([num_used_subcarrier/2+[1:num_used_subcarrier/2]],I_symbol).',zeros(1,ifft_length-num_used_subcarrier),data([1:num_used_subcarrier/2],I_symbol).']; %insert zero
    %data_to_ifft = sqrt(ifft_length/num_used_subcarrier)*data_to_ifft;
    data_to_ifft = sqrt(ifft_length/sum(data_to_ifft~=0))*data_to_ifft;
    %CP length
    if any(I_symbol==[1:num_OFDM_slot:num_OFDMperFrame]),
        temp_Cp_length = Cp_length_long;
    else 
        temp_Cp_length = Cp_length_short;
    end
    %iFFT transform
    post_ifft = sqrt(ifft_length)*ifft(data_to_ifft,ifft_length);
    %CP attach
    post_ifft_cp = [post_ifft((ifft_length-temp_Cp_length+1):end) post_ifft];
    %construct the subframe by symbols
    time_domain_frame_port0 = [time_domain_frame_port0 post_ifft_cp];
end
y = time_domain_frame_port0;
