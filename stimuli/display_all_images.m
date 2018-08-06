% display_all_images

n=325;
if (~exist('img_mat','var'))
load KLAB325.mat
end

current_subplot=0;
nx=10;ny=33;
wx=0.045;hy=wx;
spacing=0.008;
x=-wx+spacing;
y=spacing-hy;

indices=[1:60 301:305 61:120 306:310 121:180 311:315 181:240 316:320 241:300 321:325];
for current_image=1:n
%for current_image=1:30
    if (rem(current_image,65)==1)
        x=-wx+spacing;
        y=y+hy+spacing;
    end
    
    img_index=indices(current_image);
    img=img_mat{img_index};
    current_subplot=current_subplot+1;
    %hs=subplot(nx,ny,current_subplot);
    if ( (x+2*wx) > 1 )
        x=-wx+spacing;
        y=y+hy+spacing;
    end
    x=x+wx;
    hs=axes('Position',[x y wx hy]);
    imshow(img);
    axis square;
end

print -depsc display_all_images.eps
%print -djpeg display_all_images.jpg

