clc
clear all

% Define the cost coefficients for the generators
data = [510 7.2 0.00142; % A1, Beta1, G1
310 7.85 0.00194; % A2, Beta2, G2
18 7.97 0.0082]; % A3, Beta3, G3

% Extracting cost coefficients
A = data(:, 1); % Fixed cost coefficients for generators
Beta = data(:, 2); % Linear cost coefficients for generators
G = data(:, 3); % Quadratic cost coefficients for generators

% Define power generation limits for each generator
Pmax = [600, 400, 200]; % Maximum power output for each generator
Pmin = [150, 100, 50]; % Minimum power output for each generator

% Define total power demand
PD = 800;

% Define loss coefficients for the system
B1 = ([0.0218, 0.0093, 0.0028; % Loss coefficients matrix
0.0093, 0.0228, 0.0017;
0.0028, 0.0031, 0.0015]) / 100;

B2 = ([0.0003, 0.0031, 0.0015]); % Loss coefficients vector
B3 = (0.00030523); % Additional loss coefficient

% Input for initial value of lambda
L = input('enter the value of lambda=');

% Define tolerance and initial power mismatch
E = 0.0001;
Pdel = 1; % Initial power mismatch

% Initialize iteration counter
iter = 0;

% Iteration until the power mismatch is within tolerance
while abs(Pdel) > E
iter = iter + 1; % Increment iteration count

%........ Power generation calculation..............%
for i = 1:3
% Calculate power output with loss
P(i) = (L - Beta(i)) / (2 * (G(i) + L * B1(i, i)));

% Check upper limit for power generation
P(i) = min(P(i), Pmax(i));
% Check lower limit for power generation
P(i) = max(P(i), Pmin(i));
end
end
% %........end of power generation calculation.........%

% Store power generation for each generator
P1gen(iter) = P(1);
P2gen(iter) = P(2);
P3gen(iter) = P(3);

%.....Loss calculation...............%
Loss1 = 0; % Initialize total transmission loss
for i = 1:3
for j = 1:3
Loss1 = Loss1 + P(i) * B1(i, j) * P(j); % Calculate transmission
losses
end
end

Loss2 = 0; % Initialize additional loss
for m = 1:3
Loss2 = Loss2 + P(m) * B2(m); % Calculate additional losses
end
Loss3 = B3; % Additional constant loss
Loss = Loss1 + Loss2 + Loss3; % Total losses
% %..........end of Loss calculation.......%

% Calculate power mismatch with losses
Pdel = PD + Loss - sum(P); % with loss
% Pdel = PD - sum(P); % without loss (commented out)

f = 0; % Initialize variable for correction in lambda
% %.......caculation for the correction in Lambda and its updation.......%
for l = 1:3
f = f + (G(l) + Beta(l) * B1(l, l)) / (2 * (G(l) + L * B1(l, l))^2); %
with loss
end

% del_l = abs(Pdel) / f; % Calculate change in lambda
del_l = abs(Pdel) / f; % Calculate change in lambda based on mismatch and
derivative

Psum = sum(P); % Calculate total power generated

%% .... update lambda
if Psum > (PD + Loss) % If generated power exceeds demand plus losses
L = L - del_l / 2; % Decrease lambda
elseif Psum < (PD + Loss) % If generated power is less than demand plus losses
L = L + del_l / 2; % Increase lambda
end
% %..........end of calculation.......%

% %.......caculation of total operating cost.......%
for m = 1:3
C(m) = A(m) + (Beta(m) * P(m)) + (G(m) * (P(m)^2)); % Calculate cost for
each generator
end

Cost(iter) = sum(C); % Total cost for current iteration
Lambda(iter) = L; % Store current value of lambda
Totalloss(iter) = Loss; % Store total losses
end
% %........Display of results and plot for convergence....%
L % Final value of lambda
d = sum(C) % Total operating cost
P % Power generation for each generator
L % Display lambda again (redundant)
Loss % Total losses

% Plotting the cost convergence
plot(Cost) % Plot total cost against iterations

xlabel('No. of iterations') % X-axis label
ylabel('cost($)') % Y-axis label
title('convergence plot') % Title for the plot

% Prepare results for display
result = [Lambda' P1gen' P2gen' P3gen' Totalloss' Cost']; % Combine results into
a matrix