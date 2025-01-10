function H_hat = LS_est(G, y,pow)
H_hat = y*pinv(G)/sqrt(pow);
end