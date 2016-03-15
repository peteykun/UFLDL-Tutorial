function [cost,grad] = sparseAutoencoderCost(theta, visibleSize, hiddenSize, ...
                                             lambda, sparsityParam, beta, data)

% visibleSize: the number of input units (probably 64) 
% hiddenSize: the number of hidden units (probably 25) 
% lambda: weight decay parameter
% sparsityParam: The desired average activation for the hidden units (denoted in the lecture
%                           notes by the greek alphabet rho, which looks like a lower-case "p").
% beta: weight of sparsity penalty term
% data: Our 64x10000 matrix containing the training data.  So, data(:,i) is the i-th training example. 
  
% The input theta is a vector (because minFunc expects the parameters to be a vector). 
% We first convert theta to the (W1, W2, b1, b2) matrix/vector format, so that this 
% follows the notation convention of the lecture notes. 

W1 = reshape(theta(1:hiddenSize*visibleSize), hiddenSize, visibleSize);
W2 = reshape(theta(hiddenSize*visibleSize+1:2*hiddenSize*visibleSize), visibleSize, hiddenSize);
b1 = theta(2*hiddenSize*visibleSize+1:2*hiddenSize*visibleSize+hiddenSize);
b2 = theta(2*hiddenSize*visibleSize+hiddenSize+1:end);

%% ---------- YOUR CODE HERE --------------------------------------
%  Instructions: Compute the cost/optimization objective J_sparse(W,b) for the Sparse Autoencoder,
%                and the corresponding gradients W1grad, W2grad, b1grad, b2grad.
%
% W1grad, W2grad, b1grad and b2grad should be computed using backpropagation.
% Note that W1grad has the same dimensions as W1, b1grad has the same dimensions
% as b1, etc.  Your code should set W1grad to be the partial derivative of J_sparse(W,b) with
% respect to W1.  I.e., W1grad(i,j) should be the partial derivative of J_sparse(W,b) 
% with respect to the input parameter W1(i,j).  Thus, W1grad should be equal to the term 
% [(1/m) \Delta W^{(1)} + \lambda W^{(1)}] in the last block of pseudo-code in Section 2.2 
% of the lecture notes (and similarly for W2grad, b1grad, b2grad).
% 
% Stated differently, if we were using batch gradient descent to optimize the parameters,
% the gradient descent update to W1 would be W1 := W1 - alpha * W1grad, and similarly for W2, b1, b2. 
% 

m = size(data, 2);

% forward propagation
z_2 = W1 * data + repmat(b1, 1, m);
a_2 = sigmoid(z_2);
z_3 = W2 * a_2 + repmat(b2, 1, m);
a_3 = sigmoid(z_3);

cost = sum(sum((a_3 - data).^2)) / (2 * m);

% average activation
average_activation = sum(a_2, 2)/m;
cost = cost + beta * sum(KLDiv(sparsityParam * ones (size(average_activation)), average_activation));

% backward propagation
output_delta = -(data - a_3) .* a_3 .* (1 - a_3);
sparsityIndex = -sparsityParam ./ average_activation + (1-sparsityParam) ./ (1-average_activation);
hidden_delta = ((W2' * output_delta) + repmat(beta * sparsityIndex, 1, m))  .* a_2 .* (1 - a_2);

W1grad = hidden_delta * transpose(data);
W2grad = output_delta * transpose(a_2);
b1grad = sum(hidden_delta, 2);
b2grad = sum(output_delta, 2);

W2grad = (W2grad/size(data,2)) + (lambda*W2);
b2grad = b2grad/size(data,2);
W1grad = (W1grad/size(data,2)) + (lambda*W1);
b1grad = b1grad/size(data,2);

cost = cost + sum(sum(W1.^2)) * lambda / 2;
cost = cost + sum(sum(W2.^2)) * lambda / 2;

%-------------------------------------------------------------------
% After computing the cost and gradient, we will convert the gradients back
% to a vector format (suitable for minFunc).  Specifically, we will unroll
% your gradient matrices into a vector.
%opttheta = [W1(:) ; W2(:) ; b1(:) ; b2(:)];
grad = [W1grad(:) ; W2grad(:) ; b1grad(:) ; b2grad(:)];

end


%-------------------------------------------------------------------
% Here's an implementation of the sigmoid function, which you may find useful
% in your computation of the costs and the gradients.  This inputs a (row or
% column) vector (say (z1, z2, z3)) and returns (f(z1), f(z2), f(z3)). 

function sigm = sigmoid(x)
  
    sigm = 1 ./ (1 + exp(-x));
end
