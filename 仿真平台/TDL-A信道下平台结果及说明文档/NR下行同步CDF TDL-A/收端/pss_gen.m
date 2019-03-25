function td_pss = pss_gen(nid_2, ifft_length)
pss=PSS(nid_2);
Len = length(pss);
fd_pss =[pss(ceil(Len/2):end) zeros(1,ifft_length-Len) pss(1:floor(Len/2))];
% fd_pss = [0 pss(floor(Len/2):end) zeros(1,ifft_length-1-Len) pss(1:ceil(Len/2))];
td_pss =ifft(fd_pss,ifft_length)*sqrt(ifft_length)*sqrt((ifft_length)/Len);