function img = createPhaseScramble(imageSize, avgSpectra)
if length(imageSize) == 1
    imageSize=[imageSize, imageSize];
end
randomPhase = angle(fft2(rand(imageSize)));
img = real(ifft2(avgSpectra .* exp(sqrt(-1) * randomPhase)));
end
