function [zz, mask]=AddBubble(img,P)
%c=round(numel(img)*rand(1,P.nbubbles)); 
c = P.c;
myeps=10^-8;
zz=double(img);
mask=zeros(size(img));
[y,x]=ndgrid(1:size(img,1),1:size(img,2));
[yc, xc]=ind2sub(size(img),c);
for i=1:length(xc)
    maskt=exp(-((x-xc(i)).^2+(y-yc(i)).^2)/2/P.sig(i)^2);
    maskt=maskt/max(maskt(:));
    mask=max(mask,maskt);
end
mask(mask<myeps)=0;

m = max(255,max(zz(:)));
zz=zz/m-0.5;
zz=zz.*mask+0.5;
zz=uint8(zz*255);

return
