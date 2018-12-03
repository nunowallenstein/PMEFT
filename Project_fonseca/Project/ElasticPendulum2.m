
x0=-.2;
y0=.98;
Vx0=2.11026064740828;
Vy0=0;
m=80.0;
g=9.81;
k=12000;
l0=1;
yG=0;

Esys=1/2*m*(Vx0^2+Vy0^2)+1/2*k*(l0-(x0^2+y0^2)^(1/2))^2+m*g*(y0-yG);
Esys

sim('ElasticPendulum')