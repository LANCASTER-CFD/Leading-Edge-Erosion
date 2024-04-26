clear
clc
close all
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                           --- LEE2AERO ---                              %
% Opensource machine learning based tool for assessing blade performance  % 
%          impairment due to general leading edge degradation             %                      
%                           ----------------                              %
%                              Software by:                               %
%        Alessio Castorrini, Andrea Ortolani, Edmondo Minisci,            %
%                         M. Sergio Campobasso                            %
%                                                                         %
%                          Reference article:                             %
% Opensource machine learning metamodels for assessing blade performance  %
% impairment due to general leading edge degradation, Journal of Physics: % 
% Conference Series, Vol. xxxx, no.x, ref. xxxxxx, June 2024. DOI: xxxxxxxxx.
%                                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% This script allows the rapid generation of the lift and drag curves of 
% the NACA64(3) 618 featuring two classes of leading edge (LE) damage by 
% erosion. The rapid generation relies on artificial neural networks 
% trained with large sets of CFD simulations.
%
% One class of damage (ID = 1) corresponds to LE roughness accounted for 
% with the equivalent sand grain model in the underlying transitional flow 
% CFD simulations. The associated function:
%
% - generate_polar_for_rough_type_LEE.m
%
% has four input variables, all referred to unitary chord: 
% 1) curvilinear extent of roughness on upper side (su). 
% 2) curvilinear extent of roughness on lower side (sl), 
% 3) measure of actual roughness height (K),        
% 4) equivalent sand grain roughness (Ks).
%
% Following constraints should be observed: 
% 50 < K < 300 (micron/m), 0.5 < Ks/K < 10 (micron/m), -2% < sl < 4%, 
% -2% < su < 4%.
%
% The other class of damage (ID = 2) corresponds to severe damage 
% represented by chordwise grooves geometrically resolved in the underlying 
% fully turbulent CFD simulations. 
% The associated function:
% 
% - generate_polar_for_groove_type_LEE.m
%
% has three input variables, all referred to unitary chord: 
% 1) curvilinear extent of groove on upper side (su),
% 2) curvilinear extent of groove on lower side (sl),
% 3) groove depth (d).
%
% Following constraints should be observed: 
% 0.05% < d < 0.75%, -2% < sl < 4%, -2% < su < 4%.
%
% In all cases, the chord-based Reynolds number is 9 M, and the lift and 
% drag curves are provided for angle of attack between -10 and 16 degrees. 
%
% ------------------------------- USAGE----------------------------------
% Look for the only 3 code sections with tag #USER.
% 1) Select the LEE damage type:
% damage = 1 -> LE roughness;
% damage = 2 -> LE groove;
%
% 2) Set the values of the damage parameters
% -----------------------------------------------------------------------
%
% The authors of the aforementioned software declare that they deny any and 
% all liability for any damages arising out of using the considered 
% software, as well as deny any implied warranties.
%
%                                                   v.1.0.0 - 26 April 2024 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% #USER: Define the type of damage 
% 1 - groove-type damage. Parameters: [su, sl, d] - units [%c, %c, %c];
% 2 - roughness-type damage. Parameters: [su, sl, K, Ks] - units [%c, %c, micron/m, micron/m];
damage = 1; 

%% #USER: Damage values
su = 1.5;  % - Percentage of the chord length
sl = 0.1; % - Percentage of the chord length
d  = 0.5;  % - Percentage of the chord length       (not used if damage = 2)
K = 200;   % - micrometers/(meters of chord length) (not used if damage = 1)
Ks = 1000; % - micrometers/(meters of chord length) (not used if damage = 1)

%% #USER: Activate plots
% Select 1 for activating the plot of the aerodynamic force coefficients
activate_plots = 1;

%% Compute the aerodynamic coefficients and write the polar.csv file
DirFuncs = 'functions';
addpath(DirFuncs)
if damage == 1
    generate_polar_for_rough_type_LEE([su,sl,K,Ks/K], activate_plots);
elseif damage == 2
    generate_polar_for_groove_type_LEE([su,sl,d], activate_plots);
else
    error("The damage type selected is not supported. Possible damage type IDs are 1 and 2")
end