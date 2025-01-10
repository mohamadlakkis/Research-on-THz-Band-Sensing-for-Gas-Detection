function p  = generate_channel_param()

% Simulation Parameters
p.trials = 100;
% System Parameters
p.c = 3e8;                   % speed of light [m/s]
p.Fc = 100e9;                 % signal frequency [Hz]
p.lambda_c = p.c/p.Fc;          % Wavelength in meters 
p.BW = 2e9;                 % Bandwidth in Hz
p.N0_dBm = -173.8+10*log10(p.BW); % Noise power (dBm) % 10*log10(T*Kb) + 30 = -173.8
p.N0_sc = 10.^((p.N0_dBm-30)/10); % in Watts
p.SNR=1000;                 % 30dB

%% MIMO BS design (AoSA structure)

% Number of subarrays (SAs)

p.M_BS = 4; % Number of Receiver SAs (row)
p.N_BS = 4; % Number of Receiver SAs (column)

p.Q_BS = p.M_BS*p.N_BS; % Total number of receiver SAs

% Number of antenna elements (AEs) inside each SA

p.Mar = 1; % Number of receiver AEs (row) inside each SA
p.Nar = 1; % Number of receiver AEs (column) inside each SA

p.Qar = p.Mar*p.Nar; % Total number of receiver AEs inside each SA
p.Q = p.Q_BS*p.Qar;
% Define SA Spacing

p.DeltaMr = 0.05;    % Spacing between rows of SAs @Rx
p.DeltaNr = 0.05;    % Spacing between columns of SAs @Rx

% Define AE Spacing

p.deltaMr = p.lambda_c/2;    % Spacing between rows of AEs @Rx
p.deltaNr = p.lambda_c/2;    % Spacing between columns of AEs @Rx


% p.channelType = 'Multipath';   % Options: /'LoS' /'Multipath' /'Multipath+LoS'


%%
% Design geometry

p.BS_position = [0; 0; 0];      % Base Station position


% Initialize the antenna positions matrix with the desired dimensions
p.antenna_positions = zeros(3, p.M_BS * p.Mar, p.N_BS * p.Nar);
% Loop over each SA
for i = 0:p.M_BS-1  % Loop over SA rows
    for j = 0:p.N_BS-1  % Loop over SA columns
        % Calculate SA center position
        SA_position = p.BS_position + [0; j * p.DeltaNr+j*(p.Nar-1)*p.deltaNr; i * p.DeltaMr + i*(p.Mar-1)*p.deltaMr];
        
        % Loop over each AE inside the SA
        for m = 0:p.Mar-1  % Loop over AE rows within SA
            for n = 0:p.Nar-1  % Loop over AE columns within SA
                % Calculate AE position within SA
                AE_position = SA_position + [0; n * p.deltaNr; m * p.deltaMr];
                
                % Compute the global row and column indices for this AE in the matrix
                row_index = i * p.Mar + m + 1;
                col_index = j * p.Nar + n + 1;
                
                % Store the position in p.antenna_positions
                p.antenna_positions(:, row_index, col_index) = AE_position;
                
            end
        end 
        
    end

end

%%
Ray_dis=(2*((p.M_BS*((p.Mar-1)*p.deltaMr)+(p.M_BS-1)*p.DeltaMr)^2+(p.N_BS*((p.Nar-1)*p.deltaNr)+(p.N_BS-1)*p.DeltaNr)^2))/p.lambda_c;
Ray_dis=1*Ray_dis;
% Generate random angles for azimuth and elevation
theta =  pi * rand(1);  % Azimuth angle in [0, pi]
phi = pi * rand(1);        % Elevation angle in [0, pi]
% Combine into a position vector
p.User_position = [Ray_dis * rand(1) * cos(theta) * cos(phi); Ray_dis * rand(1) * cos(theta) * sin(phi); Ray_dis * rand(1) * sin(theta)];

%%
% Define the number of multipath components (scatterers)
p.num_Multipath = randi([0, 5]);

% Initialize matrix for scatterer positions
p.Scatterer_positions = zeros(3, p.num_Multipath);

% Define parameters for scatterer placement
scatter_distance = linspace(0.2, 0.8, p.num_Multipath); % Distances along the path 
offset_range = 0.5; % Range for offset perpendicular to LoS

% Vector along the LoS path
LoS_vector = p.User_position - p.BS_position;
LoS_unit_vector = LoS_vector / norm(LoS_vector); % Normalize the LoS vector

% Generate positions for scatterers
for i = 1:p.num_Multipath
    % Place scatterer along the LoS at a certain fraction of the distance
    scatter_point = p.BS_position + scatter_distance(i) * LoS_vector;
    
    perp_vector = null(LoS_unit_vector'); % Generates a basis for perpendicular vectors
    random_offset = perp_vector * (rand(2, 1) - 0.5) * 2 * offset_range; % Random offset in the perpendicular plane
    
    % Set scatterer position as the point along the LoS with the offset
    p.Scatterer_positions(:, i) = scatter_point + random_offset;
end


%%
p.Tp = 20;                 % Pilot duration
%%
% Compute Path Loss
%K_abs = get_Abs_Coef(p_ch);
p.K_abs = 0.0033;
p.PLE = 2; % path loss exponent



end
