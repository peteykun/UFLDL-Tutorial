function dist=KLDiv(P,Q)
%  dist = KLDiv(P,Q) Kullback-Leibler divergence of two Bernoulli random
%  variables.
% P =  Probability of first RV = 1
% P =  Probability of second RV = 1
% dist = 1 x 1

if size(P,2)~=size(Q,2)
    error('the number of columns in P and Q should be the same');
end

if sum(~isfinite(P(:))) + sum(~isfinite(Q(:)))
   error('the inputs contain non-finite values!') 
end

dist = P * log(P/Q) + (1-P) * log((1-P)/(1-Q));
