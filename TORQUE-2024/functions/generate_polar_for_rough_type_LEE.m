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
% - This function script generates the lift and drag curves of a 
%   NACA64(3) 618 subjected to leading edge roughness accounted for with 
%   the equivalent sand grain model in the underlying CFD simulations. 
%   The chord-based Reynolds number is xx M, and the lift and drag curves 
%   are provided for angle of attack between -10 and 16 degrees. 
%   The function has two input variables, 
%   - damage_parameters vector of components: su,sl,K,Ks/K
%   with:
%   1) curvilinear extent of roughness on upper side per unit chord (su). 
%   2) curvilinear extent of roughness on lower side per unit chord  (sl), 
%   3) measure in micrometers of actual roughness height per unit chord (K),        
%   4) equivalent sand grain roughness in micrometers per unit chord (Ks).
%   
% - Following constraints should be observed: 
%   50<K<300 micron/m, 0.5<Ks/K<10, -2<sl<4, -2<su<4, su + sl > 0.3 %.
%
% Copyright (C) 2024 Alessio Castorrini, Andrea Ortolani, Edmondo Minisci, Michele Sergio Campobasso.
% These models are free software: you can redistribute it and/or modify it 
% under the terms of the GNU General Public License as published by the 
% Free Software Foundation, either version 3 of the License.
% These models are distributed in the hope that they will be useful, 
% but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY 
% or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License 
% for more details.
% You should have received a copy of the GNU General Public License along 
% with this program. If not, see <https://www.gnu.org/licenses/>.

function generate_polar_for_rough_type_LEE(damage_parameters, activate_plots)

minSu = -2;
maxSu = 4;
minSl = -2;
maxSl = 4;
minK = 50;
maxK = 300;
minKs_K = 0.5;
maxKs_K = 10;

%% Check damage provided if it is in the supported range
if (damage_parameters(1)<minSu || damage_parameters(1)>maxSu)
    error("The value provided for su/c variable is out of range of supported values, supported range is: "+minSu+" % < su/l < "+minSu+" %");
end
if (damage_parameters(2)<minSl || damage_parameters(2)>maxSl)
    error("The value provided for sl/c variable is out of range of supported values, supported range is: "+minSl+" % < su/l < "+minSl+" %");
end
if (damage_parameters(3)<minK || damage_parameters(3)>maxK)
    error("The value provided for K/c variable is out of range of supported values, supported range is: "+minK+" micron/m < K/c < "+maxK+" micron/m");
end
if (damage_parameters(4)<minKs_K || damage_parameters(4)>maxKs_K)
    error("The value provided for Ks/K variable is out of range of supported values, supported range is: "+minKs_K+" < su/l < "+minKs_K);
end
if (damage_parameters(1)+damage_parameters(2)<0.3)
    error("The value provided for su/c and sl/c variable is giving a too small (<0.3%) or negative length of LEE curvilinear extension. \n Please check that su/c + sl/c > 0.3 %");
end

%% Computation
% Add the folder
DirNewNets = 'ANNs_K_Ks';
addpath(DirNewNets)

% Define AoA range
AoA = -10:0.5:16;
aoa_length = length(AoA);

% Feature definition
xData=[0.01*damage_parameters(1)*ones(aoa_length,1) 0.01*damage_parameters(2)*ones(aoa_length,1) damage_parameters(3)*ones(aoa_length,1) damage_parameters(4)*ones(aoa_length,1) AoA'];

% Feature augmentation
x=[xData xData(:,1).*xData(:,2) xData(:,1).*xData(:,3) xData(:,1).*xData(:,4) xData(:,1).*xData(:,5) xData(:,2).*xData(:,3) xData(:,2).*xData(:,4) xData(:,2).*xData(:,5) xData(:,3).*xData(:,4) xData(:,3).*xData(:,5) xData(:,4).*xData(:,5) xData(:,1).^2 xData(:,2).^2 xData(:,3).^2 xData(:,4).^2 xData(:,5).^2];

% Call ANNs and compute the aerodynamic coefficients
Cl=ANN_CL(x');
Cd = ANN_CD(x');
polar = [AoA', Cl', Cd'];

% plot polars
if activate_plots == 1
    x0=0;
    y0=0;
    width=1200;
    height=400;
    figure
    subplot(1,2,1)
    plot(polar(:,1),polar(:,2),'k--x','LineWidth',1.5)
    xlabel("AoA [°]")
    ylabel("Cl")
    subplot(1,2,2)
    plot(polar(:,3),polar(:,2),'k--x','LineWidth',1.5)
    xlabel("Cd")
    ylabel("Cl")
    set(gcf,'position',[x0,y0,width,height])
end


fid = fopen("Polar.csv","w");
fprintf(fid, "AoA[°],\tCl,\tCd\n");
for i=1:aoa_length
    fprintf(fid, "%f,\t%f,\t%f\n",polar(i,1),polar(i,2),polar(i,3));
end
fclose(fid);

end

