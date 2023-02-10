function CSIT = postprocessChannelEstimate(Hhat,opt)
% postprocessChannelEstimate sets the mean and variance of the
% predicated channel estimates to those of the original data set after
% truncation. It also maps the channel estimates to the angular-delay domain,
% interpolates the delay domain, and maps them back to the
% spatial-frequency domain.

% Copyright 2022 The MathWorks, Inc.

Hhat = single(Hhat);

% Permute Hhat to Nsub-by-nTx-by-dataChannels-by-nRx
Hhat = permute(Hhat, [2,3,4,1]);

nTx = opt.NumTxAntennas;
nRx = opt.NumRxAntennas;

midPoint = floor(opt.NumSubcarriers/2);
lowerEdge = midPoint - (opt.NumSubcarriers-opt.maxDelay)/2 + 1;

Htemp = ((Hhat(:,:,:,:) - opt.targetMean) / opt.targetStd) * opt.chanStats.std + opt.chanStats.mean;
Htrunc = squeeze(complex(Htemp(:,:,1,:),Htemp(:,:,2,:)));
HdaTrunc = fft2(Htrunc);
Hda = [HdaTrunc(1:lowerEdge-1,:,:); zeros((opt.NumSubcarriers-opt.maxDelay),nTx,nRx); HdaTrunc(lowerEdge:end,:,:)];
CSIT = ifft2(Hda);

% Permute CSIT nRx-by-nTx-by-Nsub
CSIT = permute(CSIT, [3,2,1]);
end