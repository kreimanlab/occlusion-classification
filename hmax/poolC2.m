function c2_bands_pool = ...
    poolC2(c2)
c2_bands_pool = zeros(fliplr(size(c2{1,1})));
n_training_imgs = size(c2{1,1},2);
for i = 1:n_training_imgs
    for f=1:length(c2{1,1})
        band_elements = zeros(1,length(c2));
        for b=1:length(c2)
            band_elements(b) = c2{1,b}(f,i);
        end
        c2_bands_pool(i,f) = max(band_elements);
    end
end
end