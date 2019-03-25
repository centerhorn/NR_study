function [ID1, max_corr] = SSS_detect(sss, nid_2)

N = length(sss); % the length of received sss

% add your code: generate local sss  334*2 and correlation
max_corr = 0;

for nid_1 = 1:336
        local_sss = sss_gen(nid_1,nid_2,256);
        corr = abs(local_sss * sss');
        if max_corr < corr
            max_corr = corr;
            cell_id1 = nid_1;
        end
end

ID1 = cell_id1;

