
load digits.mat
%[n,d] = size(X);
nLabels = max(y);
yExpanded = linearInd2Binary(y,nLabels);
t = size(Xvalid,1);
t2 = size(Xtest,1);

%create more training examples
X_add = translation(X);
X = [X; X_add];
[n,d] = size(X);
yExpanded = [yExpanded; yExpanded];

% Standardize columns and add bias
[X,mu,sigma] = standardizeCols(X);
X = [ones(n,1) X];
d = d + 1;

% Make sure to apply the same transformation to the validation/test data
Xvalid = standardizeCols(Xvalid,mu,sigma);
Xvalid = [ones(t,1) Xvalid];
Xtest = standardizeCols(Xtest,mu,sigma);
Xtest = [ones(t2,1) Xtest];

% Choose network structure
nHidden = [40,40];

% Count number of parameters and initialize weights 'w'
nParams = d*nHidden(1);
for h = 2:length(nHidden)
    nParams = nParams+nHidden(h-1)*nHidden(h);
end
nParams = nParams+nHidden(end)*nLabels;
w = randn(nParams,1)/20;

% Train with stochastic gradient
maxIter = 100000;
stepSize = 1e-3;
funObj = @(w,i)MLPclassificationLoss(w,X(i,:),yExpanded(i,:),nHidden,nLabels);

%For momentum
lastweights = w;
momentum_strength = 0.9;
for iter = 1:maxIter
    if mod(iter-1,round(maxIter/20)) == 0
        yhat = MLPclassificationPredict(w,Xvalid,nHidden,nLabels);
        validation_error = sum(yhat~=yvalid)/t;
        fprintf('Training iteration = %d, validation error = %f\n',iter-1,validation_error);
        if validation_error < 0.3 && validation_error > 0.15
          stepSize = 0.7*1e-3;
        elseif validation_error < 0.15
          stepSize = 0.5*1e-3;
        end
    end
    
    i = ceil(rand*n);
    [f,g] = funObj(w,i);
    momentum_term = momentum_strength*(w-lastweights);
    lastweights = w;
    w = w - stepSize*g + momentum_term;
end

%lastlayerMatrix = finetuning(w,X,nHidden);
%output_w = (lastlayerMatrix'*lastlayerMatrix)\lastlayerMatrix'*yExpanded;
%output_w = reshape(output_w, nHidden(end)*nLabels,1);
%w(end-length(output_w)+1:end) = output_w;

% Evaluate test error
yhat = MLPclassificationPredict(w,Xtest,nHidden,nLabels);
fprintf('Test error with final model = %f\n',sum(yhat~=ytest)/t2);

