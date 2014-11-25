function [B, Y_hat] = multiple_regression(X, Y)

B = (X'*X)\X'*Y;
Y_hat = X*B;