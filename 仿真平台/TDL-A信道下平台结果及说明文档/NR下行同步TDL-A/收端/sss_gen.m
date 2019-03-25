function td_sss = sss_gen(nid1, nid_2, ifft_length)
sss=SSS(nid1, nid_2);
Len = length(sss);
fd_sss =[sss(ceil(Len/2):end) zeros(1,ifft_length-Len) sss(1:floor(Len/2))];
td_sss =ifft(fd_sss,ifft_length)*sqrt(ifft_length)*sqrt((ifft_length)/Len);