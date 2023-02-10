function [HtruncReal_perm, truncMean, truncStd] = preprocessChannelEstimate(Hest,opt)
% preprocessChannelEstimate sets the mean and variance of the
% channel estimates to the target mean and variance specified in OPT.
% It then maps the channel estimates to the angular-delay domain,
% truncates the delay domain, and maps them back to the
% spatial-frequency domain.

% Copyright 2022 The MathWorks, Inc.

maxDelay = opt.maxDelay;
targetStd = opt.targetStd;
targetMean = opt.targetMean;

[nSub,~,nRx,nTx] = size(Hest);

midPoint = floor(nSub/2);
lowerEdge = midPoint - (nSub-maxDelay)/2 + 1;
upperEdge = midPoint + (nSub-maxDelay)/2;

% Average over symbols (one slot)
H = reshape(mean(Hest,2), [nSub,nRx,nTx]);
H = permute(H,[1 3 2]);

% Decimate over subcarriers using 2-D FFT for each Rx antenna
HtruncReal = zeros(maxDelay,nTx,2,nRx,'like',real(H(1)));
for rx = 1:nRx
    Hdft2 = fft2(H(:,:,rx));
    Htemp = Hdft2([1:lowerEdge-1 upperEdge+1:end],:);
    Htrunc = ifft2(Htemp);

    HtruncReal(:,:,1,rx) = real(Htrunc);
    HtruncReal(:,:,2,rx) = imag(Htrunc);

    truncMean = mean(HtruncReal,'all');
    truncStd = std(HtruncReal,[],'all');

    HtruncReal(:,:,:,rx) = (HtruncReal(:,:,:,rx) - truncMean) ./ truncStd * targetStd + targetMean;
end

% Permute dimensions to nRx-by-nTx-by-maxDelay-by-2 to match the
% pre-trained Keras models input layer
HtruncReal_perm = permute(HtruncReal,[4,1,2,3]);
end