fid = fopen('/Users/gregfiore/Projects/NameGame/Additional Files/Names.txt','r');


n_names = 100;

maximum_text_size = 20;

background_color = [208, 208, 208]/256;
    
text_color = 'w';

fb_size = [851, 315];

% Create the background image

figure

fig_pos = get(gcf,'Position');

fig_pos(3) = fb_size(1);
fig_pos(4) = fb_size(2);

set(gcf,'Position',fig_pos);
set(gcf,'Units','normalized');
set(gcf,'Color','w');

sizes = rand(n_names,3);

for i = 1:n_names
    temp = fgetl(fid);
    text(sizes(i,1), sizes(i,2), temp, 'HorizontalAlignment','center',...
        'color',background_color, 'FontSize', sizes(i,3)*maximum_text_size);
    axis off
end
