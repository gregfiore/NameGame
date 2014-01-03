% fid = fopen('/Users/gregfiore/Desktop/Names.txt','r');
% fid2 = fopen('/Users/gregfiore/Desktop/Names2.txt','w');
% 
% while feof(fid) == 0
%     temp = fgetl(fid);
%     temp = ['<string>',temp,'</string>'];
%     fprintf(fid2,'%s\n',temp);
% end
% 
% fclose(fid)
% fclose(fid2)


% fid = fopen('/Users/gregfiore/Desktop/Names.txt','r');
fid2 = fopen('/Users/gregfiore/Desktop/Names2.txt','w');

for i = 1:length(Data)
    if isempty(Data{i,2})
        Data{i,2} = '';
    end
end

unique_categories = unique(Data(:,2));

fprintf(fid2,'<key>General</key>\n');
fprintf(fid2,'<array>\n');

for i = 1:length(Data)
    if isempty(Data{i,2})
        fprintf(fid2,'<string>%s</string>\n',Data{i,1});
    end
end

fprintf(fid2,'</array>\n');

for i = 2:length(unique_categories)
    fprintf(fid2,'<key>%s</key>\n',unique_categories{i});
    fprintf(fid2,'<array>\n');
    for j = 1:length(Data)
        if strcmp(Data{j,2},unique_categories{i})
            fprintf(fid2,'<string>%s</string>\n',Data{j,1});
        end
    end
    fprintf(fid2,'</array>\n');
end

fclose(fid2)