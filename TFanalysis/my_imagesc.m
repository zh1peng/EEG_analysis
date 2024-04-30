function my_imagesc(data, x_range, freq_range,title2show,  colorrange, colorbar_mark)
% x_range [0, 1000]
% freq_range [1,30]
% colorange =[-10,10]
% colorbar_mark=1
imagesc(x_range, freq_range,data([freq_range(1):freq_range(end)],:));
set(gca,'YDir','normal')
if exist('colorrange')& ~isempty(colorrange)
caxis(colorrange)
end
if colorbar_mark
colorbar()
end
title(title2show)
end

