function y = wah(x,Fw,damp,mix,Fs,minf,maxf)
%#codegen

% difference equation coefficients
Q1 = single(2*damp);     % this dictates size of the pass bands
delta = single(Fw/Fs);

yw = zeros(size(x),'single');
y = zeros(size(x),'single');

% apply difference equation to the sample
for n=1:length(x)
    % auto wah function
    Fc = triWaveUpdate(minf,maxf,delta);
    F1 = single(2*sin((pi*Fc)/Fs));
    yw(n) = wahFilter(x(n),F1,Q1); 
    % wet/dry mix
    y(n) = (1 - mix)*x(n) + mix*yw(n);
end

end

function yb = wahFilter(x,F1,Q1)
persistent zyl zyb
if isempty(zyl)
    zyl = single(0);
    zyb = single(0);
end

yh = x - zyl - Q1*zyb;
yb = F1*yh + zyb;
yl = F1*yb + zyl;
zyl = yl;
zyb = yb;

end

function FcOut = triWaveUpdate(minf,maxf,delta)
persistent iFc zFc FcUp;
if isempty(iFc)
    iFc = 1;
    zFc = single(minf);
    FcUp = true;
end
if (zFc >= minf) && (zFc < maxf) && FcUp
    Fc = zFc + delta;
elseif (zFc >= minf) && (zFc < maxf) && ~FcUp
    Fc = zFc - delta;
elseif zFc >= maxf
    FcUp = false;
    Fc = zFc - delta;
elseif zFc < minf
    FcUp = true;
    Fc = zFc + delta;
else
    Fc = single(minf);
end
FcOut = zFc;
zFc = Fc;
end