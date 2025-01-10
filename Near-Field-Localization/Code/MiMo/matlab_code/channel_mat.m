function [H,r_q]  = channel_mat(p) % generate the channel matrix


   % Reflection coefficients and phase shifts for scatterers
   rho_n = rand(1, p.num_Multipath); % Reflection coefficients (example)
   psi_n = 2 * pi*rand(1, p.num_Multipath); % Phase shifts from the scatterer n in the range [0,2π].
   
   % Compute the channel matrix h_q
   hq = zeros( p.Mar*p.M_BS,p.Nar*p.N_BS );
   r_q = zeros( p.Mar*p.M_BS,p.Nar*p.N_BS );
   for q_row = 1:p.Mar*p.M_BS 
       for q_col = 1: p.Nar*p.N_BS
       % Calculate distance r_q from UE to each BS antenna q
       r_q(q_row,q_col) = norm(p.User_position - p.antenna_positions(:, q_row,  q_col ));
       % Line-of-sight component
       hq(q_row,q_col) = (p.lambda_c / (4 * pi * r_q(q_row,q_col))) * exp(-p.K_abs * r_q(q_row,q_col) / 2) * exp(-1j * 2 * pi * r_q(q_row,q_col) / p.lambda_c);
        %hq(q_row,q_col) = (p.lambda_c / (4 * pi * r_q(q_row,q_col))) * exp(-1i * 2 * pi * r_q(q_row,q_col) / p.lambda_c);
   
           % % NLOS component from scatterers
           % for n = 1:p.num_Multipath
           %     % Calculate distance t_n from UE to scatterer n
           %     t_n = norm(p.User_position - p.Scatterer_positions(:, n));
           % 
           %     % Calculate distance d_qn from scatterer n to BS antenna q
           %     d_qn = norm(p.Scatterer_positions(:, n) - p.antenna_positions(:, q_row,  q_col ));
           % 
           %     % NLOS contribution for scatterer n
           %     hq(q_row,q_col) = hq(q_row,q_col) + (p.lambda_c * rho_n(n) / (4 * pi * (t_n + d_qn))) ...
           %         * exp(-p.K_abs * (t_n + d_qn) / 2) ...
           %         * exp(-1j * 2 * pi * (t_n + d_qn) / p.lambda_c + 1j * psi_n(n));
           % end
      end
   end
   H=hq;
   
   end
   
   