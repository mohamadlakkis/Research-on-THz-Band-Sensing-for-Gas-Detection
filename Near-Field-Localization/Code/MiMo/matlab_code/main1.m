%% reset variables
clc;
clear;
close all;

% Define parameters
n_samples=10000;
p = generate_channel_param();
User_position=zeros(3,n_samples);
Y=zeros(p.Q_BS,p.Tp,n_samples);

r_q_all = zeros(p.Mar*p.M_BS*p.Nar*p.N_BS,n_samples);

for i = 1:n_samples
    p = generate_channel_param(); 
    User_position(:,i)=p.User_position;
    [H,r_q] = channel_mat(p);
    H = reshape(H, [], 1);
    r_q_all(:,i) = reshape(r_q, [], 1);

    p_t=p.SNR*p.N0_sc/(2*mean(abs(H).^2, 'all'));
    x_t = ones(1,p.Tp);

    for indx_p = 1:p.Tp
        noise = sqrt(p.N0_sc/2)*(randn(p.Q,1)+1i*randn(p.Q,1));
        y_vec(:, indx_p) = sqrt(p_t)* H * x_t(indx_p) + noise*0;
    end
    Y(:,:,i) = y_vec; % 16 x 20 x n_samples
end
% y1_p1, y1_p2, ... y_1,pn -> r
% y2_p1, y2_p2, ... y_2,pn -> r
% ...
% yq_p1, yq_p2, ... y_q,pn -> r

save('r_q_all.mat','r_q_all');
save('Y.mat','Y');